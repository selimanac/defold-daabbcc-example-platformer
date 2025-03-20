local data                  = require("scripts.lib.data")
local const                 = require("scripts.lib.const")
local player_state          = require("scripts.lib.player_state")

local water                 = {}

local water_splash_position = vmath.vector3(0)
local water_splash_id       = nil
local water_splash_particle = msg.url()
local splash_left           = hash("splash_left")

function water.enter(prop, query_result)
	print("water prop.status", prop.status)
	if prop.status == false then
		prop.status = true

		water_splash_position.x = query_result.contact_point_x
		water_splash_position.y = query_result.contact_point_y

		water_splash_id = factory.create(const.FACTORIES.WATER_SPLASH, water_splash_position)

		water_splash_particle = msg.url(water_splash_id)
		water_splash_particle.fragment = "water_splash"

		particlefx.play(water_splash_particle, function(self, id, emitter, state)
			if emitter == splash_left and state == particlefx.EMITTER_STATE_SLEEPING then
				particlefx.stop(water_splash_particle)
				go.delete(water_splash_id)
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
