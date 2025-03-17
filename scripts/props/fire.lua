local audio        = require("scripts.lib.audio")
local const        = require("scripts.lib.const")
local player_state = require("scripts.lib.player_state")

local fire         = {}

function fire.enter(prop, query_result)
	if prop.status == false and prop.data.active == false then
		prop.status = true
		prop.data.active = true
		sprite.play_flipbook(prop.sprite, prop.anims.hit, function()
			prop.data.burning = true
			prop.status = false
			audio.play(const.AUDIO.FIRE)
			sprite.play_flipbook(prop.sprite, prop.anims.on)
			prop.data.timer_handle = timer.delay(1.0, false, function()
				sprite.play_flipbook(prop.sprite, prop.anims.idle)
				prop.data.active = false
				prop.data.burning = false
			end)
		end)
	end

	if prop.data.burning == true then
		player_state.die()
	end
end

return fire
