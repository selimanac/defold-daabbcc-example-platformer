local const                     = require("scripts.lib.const")
local data                      = require("scripts.lib.data")
local player_state              = require("scripts.game.player.player_state")
local collision                 = require("scripts.lib.collision")
local utils                     = require("scripts.lib.utils")

local player_collisions         = {}

-- Slope
local slope_ray_result          = nil
local slope_ray_count           = 0
local slope_tile                = {}
local player_side_x             = 0
local slope_y                   = 0

--Platforms
local platform_back_ray_result  = {}
local platform_front_ray_result = {}
local platform_ray_result       = {} -- merge results from back and front ray
local platform_ray_count        = 0
local platform_query            = {}
local platform_count            = 0
local platform_query_aabb_id    = 0
local platform_query_tile       = {}
local platform_player_offset_y  = 0
local platform_query_result     = {}

---------------------------------------
-- Bottom Collision: normal_y == 1
---------------------------------------
function player_collisions.bottom(player_offset_y)
	-- ground offset
	data.player.position.y = data.player.position.y + player_offset_y

	-- Falling to ground, set it to idle
	if data.player.state.on_ground == false and not data.player.state.is_walking then
		player_state.idle(true)
		data.player.gravity_down = const.PLAYER.GRAVITY_DOWN -- reset slide gravity
		data.player.state.is_falling = false           -- on ground
	end

	data.player.velocity.y = 0
	data.player.state.on_ground = true
end

---------------------------------------
-- Top Collision: normal_y == -1
---------------------------------------
function player_collisions.top(player_offset_y, dt)
	data.player.position.y = data.player.position.y + player_offset_y
	data.player.velocity.y = 0
	data.player.velocity.y = data.player.velocity.y + data.player.gravity_down * dt
end

---------------------------------------
-- Side (Left / Right) Collision: normal_x == 1 or normal_x == -1
---------------------------------------
function player_collisions.side(player_offset_x)
	data.player.velocity.x = 0
	data.player.position.x = data.player.position.x + player_offset_x

	-- Slide on the wall if falling
	if data.player.state.is_falling and not data.player.state.is_sliding then
		player_state.slide()
	end
end

---------------------------------------
-- No collision, let it fall
---------------------------------------
function player_collisions.fall()
	data.player.state.on_ground = false

	-- fall from sliding
	if not data.player.state.on_ground and data.player.state.is_sliding then
		data.player.state.is_sliding = false
		player_state.fall()
		data.player.gravity_down = const.PLAYER.GRAVITY_DOWN
	end
end

---------------------
-- SLOPE
---------------------
function player_collisions.slope()
	-- center ray for slope
	slope_ray_result, slope_ray_count = collision.raycast(
		data.player.position.x,
		data.player.position.y,
		data.player.position.x,
		data.player.position.y - const.PLAYER.RAY_Y,
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
					player_state.idle(true)
				end
			end
			if not data.player.state.is_falling then
				data.player.position.y = slope_y + const.PLAYER.SIZE.h
			end
		end
	end
end

---------------------
-- PLATFORM
---------------------
function player_collisions.platform(dt)
	local is_moving_patform = false
	-- Raycast from front and back
	platform_back_ray_result, _ = collision.raycast(
		data.player.position.x,
		data.player.position.y,
		data.player.position.x - const.PLAYER.HALF_SIZE.w,
		data.player.position.y - const.PLAYER.RAY_Y,
		const.COLLISION_BITS.PLATFORM)

	platform_front_ray_result, _ = collision.raycast(
		data.player.position.x,
		data.player.position.y,
		data.player.position.x + const.PLAYER.HALF_SIZE.w,
		data.player.position.y - const.PLAYER.RAY_Y,
		const.COLLISION_BITS.PLATFORM)

	if platform_back_ray_result or platform_front_ray_result then
		-- Maybe I should add a batch raycast function to daabbcc....
		-- merge ray results
		platform_ray_result = utils.merge_tables(platform_back_ray_result, platform_front_ray_result)

		for i = 1, #platform_ray_result do
			platform_query_aabb_id = platform_ray_result[i]

			platform_query_tile = data.map_objects[platform_query_aabb_id] and data.map_objects[platform_query_aabb_id] or data.props[platform_query_aabb_id]

			is_moving_patform = data.props[platform_query_aabb_id] and true or false

			local player_bottom_y = data.player.position.y - const.PLAYER.HALF_SIZE.h

			if player_bottom_y >= platform_query_tile.y + const.PLAYER.PLATFORM_JUMP_OFFSET
				or (data.player.state.on_ground and player_bottom_y >= platform_query_tile.y)
			then -- jump offset
				data.player.state.over_platform = true
			end
		end
	else
		data.player.state.over_platform = false
	end

	if data.player.state.over_platform then
		platform_query, platform_count = collision.query_id(data.player.aabb_id, const.COLLISION_BITS.PLATFORM, true)
		if platform_query then
			for i = 1, platform_count do
				platform_query_result = platform_query[i]

				platform_player_offset_y = platform_query_result.normal_y * platform_query_result.depth

				if platform_query_result.normal_y == 1 and data.player.state.is_falling then
					player_collisions.bottom(platform_player_offset_y)
					if is_moving_patform then
						data.player.state.on_moving_platform = true
					end
				end
			end
		elseif not data.player.state.over_platform then
			data.player.state.on_ground = false
			data.player.gravity_down = const.PLAYER.GRAVITY_DOWN
			player_state.fall()
		end
	end

	if data.player.state.on_moving_platform then
		data.player.position.x = data.player.position.x + (platform_query_tile.data.velocity.x * dt)
		data.player.position.y = data.player.position.y + (platform_query_tile.data.velocity.y * dt)
	end
end

return player_collisions
