local audio        = require("scripts.lib.audio")
local collision    = require("scripts.lib.collision")
local const        = require("scripts.lib.const")
local camera_fx    = require("scripts.lib.camera_fx")
local player_state = require("scripts.lib.player_state")

local finish       = {}

function finish.enter(prop, query_result)
	if prop.status == false then
		prop.status = true

		audio.play(const.AUDIO.END)

		collision.remove(prop.aabb_id)

		camera_fx.shake(2, 4)

		player_state.die(true)
	end
end

return finish
