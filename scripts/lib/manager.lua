local map       = require("scripts.lib.map")
local collision = require("scripts.lib.collision")
local player    = require("scripts.lib.player")
local data      = require("scripts.lib.data")
local debug     = require("scripts.lib.debug")
local manager   = {}

function manager.init(level)
	msg.post(".", "acquire_input_focus")
	collision.init()
	map.load(level)
	player.init()
end

function manager.update(dt)
	player.update(dt)

	if data.debug then
		debug.update()
	end
end

function manager.input(action_id, action)
	player.input(action_id, action)
end

function manager.final()

end

return manager
