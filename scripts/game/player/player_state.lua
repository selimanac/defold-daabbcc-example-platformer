local const        = require("scripts.lib.const")
local data         = require("scripts.lib.data")
local camera_fx    = require("scripts.lib.camera_fx")
local audio        = require("scripts.lib.audio")

local player_state = {}

function player_state.flip()
	if data.player.current_direction ~= data.player.direction then
		local rot = data.player.direction == -1 and vmath.quat_rotation_y(math.pi) or vmath.quat_rotation_y(0)
		go.set_rotation(rot, data.player.ids.CONTAINER)
	end

	return data.player.direction
end

function player_state.idle(grounded)
	audio.stop(const.AUDIO.RUN)

	particlefx.stop(data.player.ids.WALK_PFX)
	particlefx.stop(data.player.ids.SLIDING_PFX)

	data.player.state.is_jumping = false
	data.player.state.is_sliding = false
	data.player.state.is_walking = false
	data.player.current_direction = data.player.direction

	sprite.play_flipbook(data.player.ids.PLAYER_SPRITE, const.PLAYER.ANIM.IDLE)

	if grounded then
		audio.play(const.AUDIO.ON_GROUND)
		particlefx.play(data.player.ids.GROUND_HIT_PFX)
	end
end

function player_state.die(restart)
	restart = restart and true or false

	if data.player.is_hit == true then
		return
	end

	data.player.is_hit = true

	data.game.state.input_pause = true
	data.game.state.skip_colliders = true

	audio.stop(const.AUDIO.RUN)
	audio.play(const.AUDIO.PLAYER_DEATH)

	camera_fx.shake(10, 4)

	particlefx.stop(data.player.ids.WALK_PFX)

	sprite.play_flipbook(data.player.ids.PLAYER_SPRITE, const.PLAYER.ANIM.HIT)

	data.player.health = data.player.health - 1
	msg.post(const.URLS.GUI, const.MSG.PLAYER_HEALTH_UPDATE)

	go.animate(data.player.ids.CONTAINER, "position.y", go.PLAYBACK_ONCE_FORWARD, data.player.position.y + 50, go.EASING_OUTSINE, 0.3, 0, function()
		audio.play(const.AUDIO.PLAYER_DISAPPEAR)

		sprite.play_flipbook(data.player.ids.PLAYER_SPRITE, const.PLAYER.ANIM.DISAPPEARING, function()
			timer.delay(0.3, false, function()
				if restart then
					msg.post(const.URLS.GAME, const.MSG.RESTART)
				else
					if data.player.health == 0 then
						msg.post(const.URLS.GAME, const.MSG.RESTART)
					else
						msg.post(const.URLS.GAME, const.MSG.PLAYER_DIE)
					end
				end
			end)
		end)
	end)
end

function player_state.jump(jump_timer)
	if jump_timer == 0 then
		audio.stop(const.AUDIO.RUN)
		audio.play(const.AUDIO.JUMP)

		data.player.state.is_jumping = true
		data.player.state.is_sliding = false
		data.player.state.on_moving_platform = false

		particlefx.stop(data.player.ids.WALK_PFX)
		sprite.play_flipbook(data.player.ids.PLAYER_SPRITE, const.PLAYER.ANIM.JUMP)
		particlefx.play(data.player.ids.JUMP_PFX)
	end
end

function player_state.slide()
	data.player.state.is_jumping = false
	data.player.velocity.y = 0
	data.player.gravity_down = const.PLAYER.GRAVITY_SLIDE -- set slide gravity
	data.player.state.is_sliding = true

	sprite.play_flipbook(data.player.ids.PLAYER_SPRITE, const.PLAYER.ANIM.WALL_JUMP)

	particlefx.play(data.player.ids.SLIDING_PFX)
end

function player_state.fall()
	data.player.state.is_jumping = false
	data.player.state.is_falling = true
	data.player.state.on_moving_platform = false

	sprite.play_flipbook(data.player.ids.PLAYER_SPRITE, const.PLAYER.ANIM.FALL)
end

function player_state.run()
	if not data.player.state.is_walking and data.player.state.on_ground then
		audio.play(const.AUDIO.RUN)

		particlefx.play(data.player.ids.WALK_PFX)

		sprite.play_flipbook(data.player.ids.PLAYER_SPRITE, const.PLAYER.ANIM.RUN)

		data.player.state.is_walking = true
	elseif not data.player.state.on_ground then
		data.player.state.is_walking = false
	end
end

return player_state
