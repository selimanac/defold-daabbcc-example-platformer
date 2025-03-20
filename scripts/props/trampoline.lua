local audio        = require("scripts.lib.audio")
local data         = require("scripts.lib.data")
local const        = require("scripts.lib.const")
local camera_fx    = require("scripts.lib.camera_fx")
local player_state = require("scripts.lib.player_state")

local trampoline   = {}

function trampoline.enter(prop, query_result)
	if query_result.normal_y == 1 and prop.status == false then
		prop.status = true
		data.player.state.on_ground = false
		data.player.state.jump_pressed = false
		data.player.velocity.y = const.PLAYER.TRAMPOLINE_JUMP_FORCE

		audio.play(const.AUDIO.TRAMPOLINE)

		sprite.play_flipbook(prop.sprite, prop.anims.on, function()
			prop.status = false
		end)

		camera_fx.shake(2, 4)

		player_state.jump(0)
	end
end

return trampoline
