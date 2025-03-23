local const              = require("scripts.lib.const")
local data               = require("scripts.lib.data")
local collision          = require("scripts.lib.collision")
local player_collisions  = require("scripts.lib.player_collisions")
local player_input       = require("scripts.lib.player_input")
local audio              = require("scripts.lib.audio")
local checkpoint         = require("scripts.props.checkpoint")

local player             = {}

local tile_query_results = nil
local tile_query_count   = 0

-- Queries
local player_offset_x    = 0
local player_offset_y    = 0
local query_result       = {}
local query_aabb_id      = 0

local query_prop         = {}
local query_enemy        = {}

-- Prop & enemy items
local is_prop            = false
local is_enemy           = false
local is_collectable     = false

function player.init()
	checkpoint.check()

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

	audio.play(const.AUDIO.PLAYER_APPEAR)

	sprite.play_flipbook(data.player.ids.PLAYER_SPRITE, const.PLAYER.ANIM.APPEARING, function()
		data.game.state.input_pause    = false
		data.game.state.skip_colliders = false
	end)
end

function player.update(dt)
	if data.game.state.skip_colliders then
		return
	end

	player_input.vertical_movement(dt)
	player_input.horizontal_movement(dt)

	-- Update position using current data.player.velocity.
	data.player.position = data.player.position + data.player.velocity * dt

	-- Update aabb position with new position before query so we are checking for next frame
	collision.update_aabb(data.player.aabb_id, data.player.position.x, data.player.position.y, const.PLAYER.SIZE.w, const.PLAYER.SIZE.h)

	---------------------
	-- SLOPE
	---------------------
	player_collisions.slope()

	---------------------
	-- PLATFORM
	---------------------
	player_collisions.platform(dt)

	---------------------
	-- TILE(MAP) QUERY
	---------------------
	-- Player to tiles collision
	tile_query_results, tile_query_count = collision.tiles(data.player.aabb_id)

	if tile_query_results then
		for i = 1, tile_query_count do
			query_result = tile_query_results[i]
			query_aabb_id = query_result.id

			-- collision offset
			player_offset_x = query_result.normal_x * query_result.depth
			player_offset_y = query_result.normal_y * query_result.depth

			query_prop = data.props[query_aabb_id]
			query_enemy = data.enemies[query_aabb_id]

			is_enemy = query_enemy and true or false
			is_prop = query_prop and true or false

			is_collectable = (is_prop and query_prop.collectable) and query_prop.collectable or false

			---------------------------------------
			-- Bottom Collision: normal_y == 1
			---------------------------------------
			if query_result.normal_y == 1
				and data.player.state.on_ground == false
				and data.player.state.is_falling
				and is_collectable == false
				and not data.player.state.on_slope
			then
				player_collisions.bottom(player_offset_y)
			end

			---------------------------------------
			-- Top Collision: normal_y == -1
			---------------------------------------
			if query_result.normal_y == -1
				and data.player.state.is_jumping
				and is_collectable == false
				and not data.player.state.on_slope
			then
				player_collisions.top(player_offset_y, dt)
			end

			---------------------------------------
			-- Side (Left / Right) Collision: normal_x == 1 or normal_x == -1
			---------------------------------------
			if (query_result.normal_x == 1 or query_result.normal_x == -1)
				and is_collectable == false
				and not data.player.state.on_slope
			then
				player_collisions.side(player_offset_x)
			end

			---------------------------------------
			-- Prop & Enemy items
			---------------------------------------
			if is_prop and query_prop.status == false then
				query_prop.fn(query_prop, query_result)
			end

			if is_enemy then
				query_enemy.fn(query_enemy, query_result)
			end

			-- end for
		end
	elseif not data.player.state.on_slope and not data.player.state.over_platform then -- no result
		-- No more collision, let it fall
		player_collisions.fall()
	end -- end query


	-- set final position
	go.set_position(data.player.position, data.player.ids.CONTAINER)
end

function player.final(reset_health)
	if reset_health then
		data.player.health = const.PLAYER.HEALTH
		msg.post(const.URLS.GUI, const.MSG.PLAYER_HEALTH_UPDATE)

		data.player.collected_apples = 0
		msg.post(const.URLS.GUI, const.MSG.COLLECT)
	end

	collision.remove(data.player.aabb_id)

	go.delete(data.player.ids.CONTAINER, true)

	data.player.ids.CONTAINER      = nil

	is_collectable                 = false
	is_prop                        = false
	is_enemy                       = false

	data.player.velocity           = vmath.vector3()
	data.player.direction          = 0
	data.player.current_direction  = 0
	data.player.is_hit             = false

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
