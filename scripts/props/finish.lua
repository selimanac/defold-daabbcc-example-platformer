local audio        = require("scripts.lib.audio")
local collision    = require("scripts.lib.collision")
local data         = require("scripts.lib.data")
local const        = require("scripts.lib.const")
local camera_fx    = require("scripts.lib.camera_fx")
local player_state = require("scripts.lib.player_state")

local finish       = {}

function finish.enter(prop, query_result)
	if prop.status == false then
		prop.status = true
		audio.play(const.AUDIO.END)
		--data.reset_checkpoints()
		collision.remove(prop.aabb_id)
		--	data.props[prop.aabb_id] = nil
		camera_fx.shake(2, 4)
		player_state.die(true)
	end
end

return finish
