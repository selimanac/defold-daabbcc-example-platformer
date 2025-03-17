local audio            = require("scripts.lib.audio")
local collision        = require("scripts.lib.collision")
local data             = require("scripts.lib.data")
local const            = require("scripts.lib.const")

local falling_platform = {}

function falling_platform.enter(prop, query_result)
	if query_result.normal_y == 1 and prop.status == false then
		prop.status = true
		sprite.play_flipbook(prop.sprite, prop.anims.on)
		audio.play(const.AUDIO.FALLING_PLATFORM)
		timer.delay(0.5, false, function()
			collision.remove(prop.aabb_id)
			go.animate(prop.sprite, "tint.w", go.PLAYBACK_ONCE_FORWARD, 0, go.EASING_LINEAR, 0.2, 0)
			audio.stop(const.AUDIO.FALLING_PLATFORM)
			go.animate(prop.id, "position.y", go.PLAYBACK_ONCE_FORWARD, prop.position.y - 30, go.EASING_LINEAR, 0.2, 0, function()
				go.delete(prop.id)
				data.props[prop.aabb_id] = nil
			end)
		end)
	end
end

return falling_platform
