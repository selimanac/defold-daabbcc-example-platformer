local const      = require("scripts.lib.const")
local data       = require("scripts.lib.data")
local collision  = require("scripts.lib.collision")

local player     = {}

local on_ground  = true
local jump_held  = false
local jump_timer = 0
local is_walking = false

function player.init()
	local player_ids       = collectionfactory.create(const.FACTORIES.PLAYER, data.player.position)
	local player_sprite    = msg.url(player_ids[hash("/player")])
	player_sprite.fragment = "sprite"

	data.player.ids        =
	{
		CONTAINER = msg.url(player_ids[hash("/container")]),
		PLAYER_SPRITE = player_sprite,
	}

	data.player.aabb_id    = collision.insert_gameobject(data.player.ids.CONTAINER, const.PLAYER.SIZE.w, const.PLAYER.SIZE.h, const.COLLISION_BITS.PLAYER, false)
end

function player.update(dt)
	data.player.position = go.get_position(data.player.ids.CONTAINER)

	-- Horizontal movement
	if data.player.direction ~= 0 then
		if not is_walking and on_ground then
			sprite.play_flipbook(data.player.ids.PLAYER_SPRITE, const.PLAYER.ANIM.RUN)
			is_walking = true
		elseif not on_ground then
			is_walking = false
		end

		sprite.set_hflip(data.player.ids.PLAYER_SPRITE, data.player.direction == -1)

		data.player.velocity.x = data.player.velocity.x + data.player.direction * const.PLAYER.MOVE_ACCELERATION * dt

		if math.abs(data.player.velocity.x) > const.PLAYER.MAX_MOVE_SPEED then
			data.player.velocity.x = data.player.direction * const.PLAYER.MAX_MOVE_SPEED
		end
	else
		if is_walking then
			sprite.play_flipbook(data.player.ids.PLAYER_SPRITE, const.PLAYER.ANIM.IDLE)
			is_walking = false
		end

		data.player.velocity.x = vmath.lerp(const.PLAYER.DECELERATION_LERP, data.player.velocity.x, 0)
	end


	-- Vertical movement:
	if not on_ground then
		if jump_held and jump_timer < const.PLAYER.MAX_JUMP_HOLD_TIME and data.player.velocity.y > 0 then
			sprite.play_flipbook(data.player.ids.PLAYER_SPRITE, const.PLAYER.ANIM.JUMP)

			data.player.velocity.y = data.player.velocity.y + (const.PLAYER.GRAVITY_UP * 0.5) * dt
			jump_timer = jump_timer + dt
		else
			-- released or time expires, apply .
			if data.player.velocity.y > 0 then
				data.player.velocity.y = data.player.velocity.y + const.PLAYER.GRAVITY_UP * dt
			else
				sprite.play_flipbook(data.player.ids.PLAYER_SPRITE, const.PLAYER.ANIM.FALL)
				data.player.velocity.y = data.player.velocity.y + const.PLAYER.GRAVITY_DOWN * dt
			end
		end
	end

	-- Update position using current data.player.velocity.
	data.player.position = data.player.position + data.player.velocity * dt

	-- Update daabbcc with new position
	collision.update_aabb(data.player.aabb_id, data.player.position.x, data.player.position.y, const.PLAYER.SIZE.w, const.PLAYER.SIZE.h)

	local result, count = collision.tile(data.player.aabb_id)

	if result then
		for i = 1, count do
			local offset_x = result[i].normal_x * result[i].depth
			local offset_y = result[i].normal_y * result[i].depth

			-- Bottom Collision: normal_y == 1
			if result[i].normal_y == 1 and on_ground == false then
				data.player.position.y = data.player.position.y + offset_y

				if on_ground == false and not is_walking then
					sprite.play_flipbook(data.player.ids.PLAYER_SPRITE, const.PLAYER.ANIM.IDLE)
				end

				data.player.velocity.y = 0
				on_ground = true
			end

			-- Top Collision: normal_y == -1
			if result[i].normal_y == -1 then
				data.player.position.y = data.player.position.y + offset_y
				data.player.velocity.y = 0
				data.player.velocity.y = data.player.velocity.y + const.PLAYER.GRAVITY_DOWN * dt
			end

			-- Left / Right Collision: normal_x == 1 or normal_x == -1
			if result[i].normal_x == 1 or result[i].normal_x == -1 then
				data.player.velocity.x = 0
				data.player.position.x = data.player.position.x + offset_x
			end
		end
	else
		on_ground = false
	end

	go.set_position(data.player.position, data.player.ids.CONTAINER)
end

function player.input(action_id, action)
	if action_id == const.KEY.MOVE_LEFT then
		if action.pressed then
			data.player.direction = -1
		elseif action.released then
			if data.player.direction < 0 then data.player.direction = 0 end
		end
	elseif action_id == const.KEY.MOVE_RIGHT then
		if action.pressed then
			data.player.direction = 1
		elseif action.released then
			if data.player.direction > 0 then data.player.direction = 0 end
		end
	elseif action_id == const.KEY.JUMP then
		if action.pressed and on_ground then
			data.player.velocity.y = const.PLAYER.JUMP_FORCE
			on_ground = false
			jump_held = true
			jump_timer = 0
		elseif action.released then
			jump_held = false
		end
	end
end

return player
