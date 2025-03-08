local const        = require("scripts.lib.const")
local data         = require("scripts.lib.data")

local player_state = {}

function player_state.flip(current_dir)
	if current_dir ~= data.player.direction then
		local rot = data.player.direction == -1 and vmath.quat_rotation_y(math.pi) or vmath.quat_rotation_y(0)
		go.set_rotation(rot, data.player.ids.CONTAINER)
	end

	return data.player.direction
end

function player_state.idle(grounded, current_dir)
	data.player.state.is_jumping = false
	data.player.state.is_sliding = false
	data.player.state.is_walking = false
	sprite.play_flipbook(data.player.ids.PLAYER_SPRITE, const.PLAYER.ANIM.IDLE)
	particlefx.stop(data.player.ids.WALK_PFX)
	current_dir = data.player.direction
	particlefx.stop(data.player.ids.SLIDING_PFX)
	if grounded then
		particlefx.play(data.player.ids.GROUND_HIT_PFX)
	end
end

function player_state.die()
	data.game.state.input_pause = true
	data.game.state.skip_colliders = true

	particlefx.stop(data.player.ids.WALK_PFX)
	sprite.play_flipbook(data.player.ids.PLAYER_SPRITE, const.PLAYER.ANIM.HIT)
	go.animate(data.player.ids.CONTAINER, "position.y", go.PLAYBACK_ONCE_FORWARD, data.player.position.y + 50, go.EASING_OUTSINE, 0.3, 0, function()
		sprite.play_flipbook(data.player.ids.PLAYER_SPRITE, const.PLAYER.ANIM.DISAPPEARING, function()
			timer.delay(0.3, false, function()
				msg.post(const.URLS.GAME, const.MSG.RESTART)
			end)
		end)
	end)
end

function player_state.jump(jump_timer)
	if jump_timer == 0 then
		data.player.state.is_jumping = true
		data.player.state.is_sliding = false
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
	sprite.play_flipbook(data.player.ids.PLAYER_SPRITE, const.PLAYER.ANIM.FALL)
end

function player_state.run()
	if not data.player.state.is_walking and data.player.state.on_ground then
		particlefx.play(data.player.ids.WALK_PFX)
		sprite.play_flipbook(data.player.ids.PLAYER_SPRITE, const.PLAYER.ANIM.RUN)
		data.player.state.is_walking = true
	elseif not data.player.state.on_ground then
		data.player.state.is_walking = false
	end
end

return player_state
