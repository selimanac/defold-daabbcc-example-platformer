local const                     = require("scripts.lib.const")
local data                      = require("scripts.lib.data")
local collision                 = require("scripts.lib.collision")
local player_state              = require("scripts.lib.player_state")
local utils                     = require("scripts.lib.utils")

local player                    = {}

local jump_timer                = 0
local current_dir               = 0

local tile_query_results        = nil
local tile_query_count          = 0

-- Slope
local slope_ray_result          = nil
local slope_ray_count           = 0
local slope_tile                = {}
local player_side_x             = 0
local slope_y                   = 0

--Platforms
local platform_back_ray_result  = {}
local platform_front_ray_result = {}
local platform_query            = {}
local platform_count            = 0

-- Queries
local player_offset_x           = 0
local player_offset_y           = 0
local query_result              = {}
local query_aabb_id             = 0

-- Prop & enemy items
local is_prop                   = false
local is_enemy                  = false
local is_collectable            = false

function player.init()
	local player_ids               = collectionfactory.create(const.FACTORIES.PLAYER, data.player.position)
	local player_sprite            = msg.url(player_ids[hash("/player")])
	player_sprite.fragment         = "sprite"

	local run_pfx                  = msg.url(player_ids[hash("/particles")])
	run_pfx.fragment               = "run"

	local ground_hit_pfx           = msg.url(player_ids[hash("/particles")])
	ground_hit_pfx.fragment        = "ground_hit"

	local jump_pfx                 = msg.url(player_ids[hash("/particles")])
	jump_pfx.fragment              = "jump"

	local sliding_pfx              = msg.url(player_ids[hash("/particles")])
	sliding_pfx.fragment           = "slide"

	data.player.ids                =
	{
		CONTAINER      = msg.url(player_ids[hash("/container")]),
		PLAYER_SPRITE  = player_sprite,
		WALK_PFX       = run_pfx,
		GROUND_HIT_PFX = ground_hit_pfx,
		JUMP_PFX       = jump_pfx,
		SLIDING_PFX    = sliding_pfx
	}

	data.player.gravity_down       = const.PLAYER.GRAVITY_DOWN

	data.player.aabb_id            = collision.insert_gameobject(data.player.ids.CONTAINER, const.PLAYER.SIZE.w, const.PLAYER.SIZE.h, const.COLLISION_BITS.PLAYER, false)

	data.game.state.input_pause    = true
	data.game.state.skip_colliders = true

	sprite.play_flipbook(data.player.ids.PLAYER_SPRITE, const.PLAYER.ANIM.APPEARING, function()
		data.game.state.input_pause    = false
		data.game.state.skip_colliders = false
	end)
end

---------------------------
-- Horizontal movement
---------------------------
local function horizontal_movement(dt)
	if data.player.direction ~= 0 then
		player_state.run()
		current_dir = player_state.flip(current_dir)

		data.player.velocity.x = data.player.velocity.x + data.player.direction * const.PLAYER.MOVE_ACCELERATION * dt

		-- clamp to max speed
		if math.abs(data.player.velocity.x) > const.PLAYER.MAX_MOVE_SPEED then
			data.player.velocity.x = data.player.direction * const.PLAYER.MAX_MOVE_SPEED
		end
	else
		if data.player.state.is_walking then
			player_state.idle(false, current_dir)
		end

		data.player.velocity.x = vmath.lerp(const.PLAYER.DECELERATION_LERP, data.player.velocity.x, 0)
	end
end

---------------------------
-- Vertical movement
---------------------------
local function vertical_movement(dt)
	if not data.player.state.on_ground then
		-- wall jump
		if data.player.state.is_sliding and data.player.state.jump_pressed and data.player.direction ~= 0 and data.player.direction ~= current_dir then
			data.player.state.on_ground = false
			jump_timer = 0
			data.player.state.is_sliding = false
			data.player.velocity.y = const.PLAYER.WALL_JUMP_FORCE
			data.player.gravity_down = const.PLAYER.GRAVITY_WALL_JUMP -- reset jump gravity
		end

		-- jump
		if data.player.state.jump_pressed and jump_timer < const.PLAYER.MAX_JUMP_HOLD_TIME and data.player.velocity.y > 0 and not data.player.state.is_sliding then
			player_state.jump(jump_timer)

			data.player.velocity.y = data.player.velocity.y + (const.PLAYER.GRAVITY_UP * 0.5) * dt
			jump_timer = jump_timer + dt
		else
			-- released or time expires
			if data.player.velocity.y > 0 then
				data.player.velocity.y = data.player.velocity.y + const.PLAYER.GRAVITY_UP * dt
			else
				-- falling
				if not data.player.state.is_falling and not data.player.state.is_sliding then
					player_state.fall()
				end
				data.player.velocity.y = data.player.velocity.y + data.player.gravity_down * dt
			end
		end
	end
end

local over_platform = false
function player.update(dt)
	if data.game.state.skip_colliders then
		return
	end

	vertical_movement(dt)
	horizontal_movement(dt)


	-- Update position using current data.player.velocity.
	data.player.position = data.player.position + data.player.velocity * dt

	-- Update aabb position with new position before query so we are checking for next frame
	collision.update_aabb(data.player.aabb_id, data.player.position.x, data.player.position.y, const.PLAYER.SIZE.w, const.PLAYER.SIZE.h)

	-- Player to tiles collision
	tile_query_results, tile_query_count = collision.tiles(data.player.aabb_id)

	---------------------
	-- SLOPE
	---------------------
	-- center ray for slope
	slope_ray_result, slope_ray_count = collision.raycast(
		data.player.position.x,
		data.player.position.y,
		data.player.position.x,
		data.player.position.y - (const.PLAYER.HALF_SIZE.h + 16),
		const.COLLISION_BITS.SLOPE)

	data.player.state.on_slope = slope_ray_count > 0 and true or false

	slope_tile = {}

	if data.player.state.on_slope then
		slope_tile = data.map_objects[slope_ray_result[1]]

		if not data.player.state.is_jumping then
			player_side_x = 0

			if slope_tile.properties.slope.m < 0 then
				player_side_x = data.player.position.x + const.PLAYER.HALF_SIZE.w
			else
				player_side_x = data.player.position.x - const.PLAYER.HALF_SIZE.w
			end

			slope_y = slope_tile.properties.slope.m * player_side_x + slope_tile.properties.slope.b

			if data.player.position.y + const.PLAYER.SIZE.h >= slope_y and data.player.position.y <= slope_y + const.PLAYER.SIZE.h then
				data.player.state.on_ground = true

				if data.player.state.is_falling then
					data.player.state.is_falling = false
					data.player.velocity.y = 0
					player_state.idle(true, current_dir)
				end
			end
			if not data.player.state.is_falling then
				data.player.position.y = slope_y + const.PLAYER.SIZE.h
			end
		end
	end

	---------------------
	-- PLATFORM
	---------------------
	local on_platform = false

	platform_back_ray_result, _ = collision.raycast(
		data.player.position.x,
		data.player.position.y,
		data.player.position.x - const.PLAYER.HALF_SIZE.w,
		data.player.position.y - (const.PLAYER.HALF_SIZE.h + 14),
		const.COLLISION_BITS.PLATFORM)

	platform_front_ray_result, _ = collision.raycast(
		data.player.position.x,
		data.player.position.y,
		data.player.position.x + const.PLAYER.HALF_SIZE.w,
		data.player.position.y - (const.PLAYER.HALF_SIZE.h + 14),
		const.COLLISION_BITS.PLATFORM)


	if platform_back_ray_result or platform_front_ray_result then
		local result = utils.merge_tables(platform_back_ray_result, platform_front_ray_result)

		local aabb_id = result[1]
		local tile = data.map_objects[aabb_id]
		local player_bottom_y = data.player.position.y - const.PLAYER.HALF_SIZE.h

		if player_bottom_y >= tile.y + 10 then
			over_platform = true
		end
	else
		over_platform = false
	end


	if over_platform then
		platform_query, platform_count = collision.query_id(data.player.aabb_id, const.COLLISION_BITS.PLATFORM, true)
		if platform_query then
			for i = 1, platform_count do
				query_result = platform_query[i]

				player_offset_y = query_result.normal_y * query_result.depth

				if query_result.normal_y == 1 and data.player.state.is_falling then
					-- ground offset
					data.player.position.y = data.player.position.y + player_offset_y

					-- Falling to ground, set it to idle
					if data.player.state.on_ground == false and not data.player.state.is_walking then
						player_state.idle(true, current_dir)
						data.player.gravity_down = const.PLAYER.GRAVITY_DOWN -- reset slide gravity
						data.player.state.is_falling = false -- on ground
					end

					data.player.velocity.y = 0
					data.player.state.on_ground = true
				end
			end
		end
	end

	if tile_query_results then
		for i = 1, tile_query_count do
			query_result = tile_query_results[i]
			query_aabb_id = query_result.id

			-- collision offset
			player_offset_x = query_result.normal_x * query_result.depth
			player_offset_y = query_result.normal_y * query_result.depth

			--	local tile = data.map_objects[aabb_id]
			local prop = data.props[query_aabb_id]
			local enemy = data.enemies[query_aabb_id]

			is_enemy = enemy and true or false
			is_prop = prop and true or false

			is_collectable = (prop and prop.collectable) and prop.collectable or false


			--is_collectable = false
			--	print(is_collectable)
			--	local is_one_way_platform = (tile and tile.name == "ONE_WAY_PLATFORM") and true or false
			--	local is_top_one_way_platform = false

			---------------------------------------
			-- Bottom Collision: normal_y == 1
			---------------------------------------


			-- if (query_result.normal_y == 1
			-- 		and not data.player.state.on_ground
			-- 		and data.player.state.is_falling
			-- 		and not is_collectable
			-- 		and not data.player.state.on_slope
			-- 		and not is_one_way_platform)
			-- 	or (is_one_way_platform and over_platform)
			-- then


			if query_result.normal_y == 1
				and data.player.state.on_ground == false
				and data.player.state.is_falling
				and is_collectable == false
				and not data.player.state.on_slope
			then
				-- ground offset
				data.player.position.y = data.player.position.y + player_offset_y

				-- Falling to ground, set it to idle
				if data.player.state.on_ground == false and not data.player.state.is_walking then
					player_state.idle(true, current_dir)
					data.player.gravity_down = const.PLAYER.GRAVITY_DOWN -- reset slide gravity
					data.player.state.is_falling = false  -- on ground
				end

				data.player.velocity.y = 0
				data.player.state.on_ground = true
			end

			---------------------------------------
			-- Top Collision: normal_y == -1
			---------------------------------------
			if query_result.normal_y == -1
				and data.player.state.is_jumping
				and is_collectable == false
				and not data.player.state.on_slope
			--	is_one_way_platform == false and
			then
				data.player.position.y = data.player.position.y + player_offset_y
				data.player.velocity.y = 0
				data.player.velocity.y = data.player.velocity.y + data.player.gravity_down * dt
			end

			---------------------------------------
			-- Left / Right Collision: normal_x == 1 or normal_x == -1
			---------------------------------------
			if (query_result.normal_x == 1 or query_result.normal_x == -1)
				and is_collectable == false
				and not data.player.state.on_slope
			--	is_one_way_platform == false and
			then
				data.player.velocity.x = 0
				data.player.position.x = data.player.position.x + player_offset_x

				-- Slide on the wall if falling
				if data.player.state.is_falling and not data.player.state.is_sliding then
					player_state.slide()
				end
			end

			---------------------------------------
			-- Prop & Enemy items
			---------------------------------------
			if is_prop and prop.status == false then
				prop.fn(prop, query_result)
			end

			if is_enemy then
				enemy.fn(enemy, query_result)
			end

			-- end for
		end
	elseif not data.player.state.on_slope and not over_platform then -- no result
		-- No more collision, let it fall
		data.player.state.on_ground = false

		-- fall from sliding
		if not data.player.state.on_ground and data.player.state.is_sliding then
			data.player.state.is_sliding = false
			player_state.fall()
			data.player.gravity_down = const.PLAYER.GRAVITY_DOWN
		end
	end -- end query


	-- set final position
	go.set_position(data.player.position, data.player.ids.CONTAINER)
end

function player.input(action_id, action)
	if action_id == const.TRIGGERS.MOVE_LEFT then
		if action.pressed then
			data.player.direction = -1
		elseif action.released then
			if data.player.direction < 0 then data.player.direction = 0 end
		end
	elseif action_id == const.TRIGGERS.MOVE_RIGHT then
		if action.pressed then
			data.player.direction = 1
		elseif action.released then
			if data.player.direction > 0 then data.player.direction = 0 end
		end
	elseif action_id == const.TRIGGERS.JUMP then
		if action.pressed then
			data.player.state.jump_pressed = true
			if data.player.state.on_ground then
				data.player.velocity.y = const.PLAYER.JUMP_FORCE
				data.player.state.on_ground = false
				data.player.state.on_slope = false
				jump_timer = 0
			end
		elseif action.released then
			data.player.state.jump_pressed = false
		end
	end
end

function player.final()
	go.delete(data.player.ids.CONTAINER, true)
	data.player.velocity           = vmath.vector3()
	data.player.direction          = 0
	current_dir                    = 0

	is_collectable                 = false
	data.player.velocity           = vmath.vector3()
	data.player.state.on_slope     = false
	data.player.state.jump_pressed = false
	data.player.state.is_jumping   = false
	data.player.state.is_walking   = false
	data.player.state.is_sliding   = false
	data.player.state.is_falling   = false
	tile_query_results             = nil
	tile_query_count               = 0
end

return player
