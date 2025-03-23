local audio        = require("scripts.lib.audio")
local collision    = require("scripts.lib.collision")
local const        = require("scripts.lib.const")
local camera_fx    = require("scripts.lib.camera_fx")
local player_state = require("scripts.lib.player_state")
local data         = require("scripts.lib.data")

local finish       = {}

local finish_left  = hash("finish_left")

function finish.enter(prop, query_result)
	if prop.status == false then
		prop.status = true

		audio.play(const.AUDIO.END)

		collision.remove(prop.aabb_id)

		camera_fx.shake(2, 4)

		local finish_particle_fx = msg.url(prop.id)
		finish_particle_fx.fragment = "finish"

		data.player.direction = 0
		data.game.state.input_pause = true

		particlefx.play(finish_particle_fx, function(_, _, emitter, state)
			if emitter == finish_left and state == particlefx.EMITTER_STATE_SLEEPING then
				particlefx.stop(finish_particle_fx)
				player_state.die(true)
			end
		end)
	end
end

return finish
