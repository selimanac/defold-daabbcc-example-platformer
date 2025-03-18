local data         = require("scripts.lib.data")
local const        = require("scripts.lib.const")
local player_state = require("scripts.lib.player_state")

local water        = {}

function water.enter(prop, query_result)
	print("water prop.status", prop.status)
	if prop.status == false then
		prop.status = true

		local water_splash_position = vmath.vector3(query_result.contact_point_x, query_result.contact_point_y, 0)
		local water_splash = factory.create(const.FACTORIES.WATER_SPLASH, water_splash_position)

		local water_splash_particle = msg.url(water_splash)
		water_splash_particle.fragment = "water_splash"
		particlefx.play(water_splash_particle, function(self, id, emitter, state)
			if emitter == hash("emitter1") and state == particlefx.EMITTER_STATE_SLEEPING then
				particlefx.stop(water_splash_particle)
				go.delete(water_splash)
			end
		end)

		data.player.gravity_down = math.abs(data.player.gravity_down)

		timer.delay(0.3, false, function()
			player_state.die()
			prop.status = false
		end)
	end
end

return water
