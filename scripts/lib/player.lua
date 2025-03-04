local const              = require("scripts.lib.const")
local data               = require("scripts.lib.data")
local collision          = require("scripts.lib.collision")
local player_state       = require("scripts.lib.player_state")

local player             = {}

local jump_timer         = 0
local current_dir        = 0
local tile_query_results = nil
local tile_query_count   = 0

function player.init()
	local player_ids         = collectionfactory.create(const.FACTORIES.PLAYER, data.player.position)
	local player_sprite      = msg.url(player_ids[hash("/player")])
	player_sprite.fragment   = "sprite"

	local run_pfx            = msg.url(player_ids[hash("/particles")])
	run_pfx.fragment         = "run"

	local ground_hit_pfx     = msg.url(player_ids[hash("/particles")])
	ground_hit_pfx.fragment  = "ground_hit"

	local jump_pfx           = msg.url(player_ids[hash("/particles")])
	jump_pfx.fragment        = "jump"

	local sliding_pfx        = msg.url(player_ids[hash("/particles")])
	sliding_pfx.fragment     = "slide"

	data.player.ids          =
	{
		CONTAINER      = msg.url(player_ids[hash("/container")]),
		PLAYER_SPRITE  = player_sprite,
		WALK_PFX       = run_pfx,
		GROUND_HIT_PFX = ground_hit_pfx,
		JUMP_PFX       = jump_pfx,
		SLIDING_PFX    = sliding_pfx
	}

	data.player.gravity_down = const.PLAYER.GRAVITY_DOWN

	data.player.aabb_id      = collision.insert_gameobject(data.player.ids.CONTAINER, const.PLAYER.SIZE.w, const.PLAYER.SIZE.h, const.COLLISION_BITS.PLAYER, false)
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
local function verticle_movement(dt)
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

function player.update(dt)
	verticle_movement(dt)
	horizontal_movement(dt)

	-- Update position using current data.player.velocity.
	data.player.position = data.player.position + data.player.velocity * dt

	-- Update aabb position with new position before query so we are checking for next frame
	collision.update_aabb(data.player.aabb_id, data.player.position.x, data.player.position.y, const.PLAYER.SIZE.w, const.PLAYER.SIZE.h)

	-- Player to tiles collision
	tile_query_results, tile_query_count = collision.tiles(data.player.aabb_id)

	if tile_query_results then
		for i = 1, tile_query_count do
			local query_result = tile_query_results[i]
			local aabb_id = query_result.id

			-- collision offset
			local offset_x = query_result.normal_x * query_result.depth
			local offset_y = query_result.normal_y * query_result.depth

			local tile = data.map_objects[aabb_id]
			local prop = data.props[aabb_id]

			local is_single_side_platform = false
			local is_single_side_platform_top = false


			local r, c = collision.query_aabb(data.player.position.x, data.player.position.y - (const.PLAYER.SIZE.h / 2), 5, 5, const.COLLISION_BITS.TILE, true)


			if c > 0 then
				--tile = data.map_objects[r[1].id]
				--	pprint(tile)
			end
			if tile and tile.name == "SINGLE_SIDE_PLATFORM" and c > 0 and r[1].normal_y == 1 then
				is_single_side_platform_top = true
			else
				is_single_side_platform_top = false
			end

			if tile and tile.name == "SINGLE_SIDE_PLATFORM" then
				is_single_side_platform = true
			end

			-- Bottom Collision: normal_y == 1
			if query_result.normal_y == 1 and
				data.player.state.on_ground == false and
				data.player.state.is_falling
			then
				-- ground offset
				data.player.position.y = data.player.position.y + offset_y

				-- Falling to ground, set it to idle
				if data.player.state.on_ground == false and not data.player.state.is_walking then
					player_state.idle(true, current_dir)
					data.player.gravity_down = const.PLAYER.GRAVITY_DOWN -- reset slide gravity
					data.player.state.is_falling = false  -- on ground
				end

				data.player.velocity.y = 0
				data.player.state.on_ground = true
			end

			-- Top Collision: normal_y == -1
			if query_result.normal_y == -1 and data.player.state.is_jumping and is_single_side_platform == false then
				data.player.position.y = data.player.position.y + offset_y
				data.player.velocity.y = 0
				data.player.velocity.y = data.player.velocity.y + data.player.gravity_down * dt
			end

			-- Left / Right Collision: normal_x == 1 or normal_x == -1
			if query_result.normal_x == 1 or query_result.normal_x == -1 and is_single_side_platform == false then
				data.player.velocity.x = 0
				data.player.position.x = data.player.position.x + offset_x

				-- Slide on the wall if falling
				if data.player.state.is_falling and not data.player.state.is_sliding then
					player_state.slide()
				end
			end

			if prop and prop.status == false then
				prop.fn(prop, query_result)
			end

			-- end for
		end
	else -- no result
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
				jump_timer = 0
			end
		elseif action.released then
			data.player.state.jump_pressed = false
		end
	end
end

return player
