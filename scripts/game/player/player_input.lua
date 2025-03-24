local const        = require("scripts.lib.const")
local data         = require("scripts.lib.data")
local player_state = require("scripts.game.player.player_state")
local audio        = require("scripts.lib.audio")

local player_input = {}

---------------------------
-- Vertical movement
---------------------------
function player_input.vertical_movement(dt)
	if not data.player.state.on_ground then
		-- wall jump
		if data.player.state.is_sliding and data.player.state.jump_pressed and data.player.direction ~= 0 and data.player.direction ~= data.player.current_direction then
			audio.play(const.AUDIO.WALL_JUMP)
			data.player.state.on_ground = false
			data.player.jump_timer = 0
			data.player.state.is_sliding = false
			data.player.velocity.y = const.PLAYER.WALL_JUMP_FORCE
			data.player.gravity_down = const.PLAYER.GRAVITY_WALL_JUMP -- reset jump gravity
		end

		-- jump
		if data.player.state.jump_pressed and data.player.jump_timer < const.PLAYER.MAX_JUMP_HOLD_TIME and data.player.velocity.y > 0 and not data.player.state.is_sliding then
			player_state.jump(data.player.jump_timer)

			data.player.velocity.y = data.player.velocity.y + (const.PLAYER.GRAVITY_UP * 0.5) * dt
			data.player.jump_timer = data.player.jump_timer + dt
		else
			-- released or time expires
			if data.player.velocity.y > 0 then
				data.player.velocity.y = data.player.velocity.y + const.PLAYER.GRAVITY_UP * dt
			else
				-- falling
				if not data.player.state.is_falling and not data.player.state.is_sliding then
					player_state.fall()
				end

				data.player.velocity.y = math.max(data.player.velocity.y + data.player.gravity_down * dt, const.PLAYER.MAX_VELOCITY_Y)
			end
		end
	end
end

---------------------------
-- Horizontal movement
---------------------------
function player_input.horizontal_movement(dt)
	if data.player.direction ~= 0 then
		player_state.run()
		data.player.current_direction = player_state.flip()

		data.player.velocity.x = data.player.velocity.x + data.player.direction * const.PLAYER.MOVE_ACCELERATION * dt

		-- clamp to max speed
		if math.abs(data.player.velocity.x) > const.PLAYER.MAX_MOVE_SPEED then
			data.player.velocity.x = data.player.direction * const.PLAYER.MAX_MOVE_SPEED
		end
	else
		if data.player.state.is_walking then
			player_state.idle(false)
		end

		data.player.velocity.x = vmath.lerp(const.PLAYER.DECELERATION_LERP, data.player.velocity.x, 0)
	end
end

---------------------------
-- Input
---------------------------
function player_input.input(action_id, action)
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
				data.player.jump_timer = 0
			end
		elseif action.released then
			data.player.state.jump_pressed = false
		end
	end
end

return player_input
