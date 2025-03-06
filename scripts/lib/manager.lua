local map         = require("scripts.lib.map")
local collision   = require("scripts.lib.collision")
local player      = require("scripts.lib.player")
local data        = require("scripts.lib.data")
local debug       = require("scripts.lib.debug")
local const       = require("scripts.lib.const")
local game_camera = require("scripts.lib.game_camera")


local manager = {}

local function collect_garbage()
	print("garbage before: ", collectgarbage("count"))
	collectgarbage("collect")
	print("garbage after: ", collectgarbage("count"))

	collectgarbage("setstepmul", 1000);
	collectgarbage('setpause', 1000);
end

local function setup_urls()
	for key, url in pairs(const.URLS) do
		const.URLS[key] = msg.url(url)
	end

	for key, url in pairs(const.FACTORIES) do
		const.FACTORIES[key] = msg.url(url)
	end
end


function manager.init()
	msg.post(".", "acquire_input_focus")
	msg.post("@render:", "clear_color", { color = const.BACKGROUND_COLOR })

	setup_urls()

	if defos then
		const.DISPLAY_WIDTH  = sys.get_config_number("defos.view_width")
		const.DISPLAY_HEIGHT = sys.get_config_number("defos.view_height")
	end

	collision.init()
	map.init()
	map.load(data.game.level)
	player.init()
	game_camera.init()

	if data.debug.init then
		debug.init()
	end

	collect_garbage()
end

function manager.update(dt)
	if data.debug.init then
		debug.update()
	end

	if data.game.state.pause then
		return
	end

	player.update(dt)
	game_camera.update(dt)
end

function manager.input(action_id, action)
	if data.game.state.input_pause or data.game.state.pause then
		return
	end

	player.input(action_id, action)
end

function manager.message(message_id, message, sender)
	if message_id == const.MSG.RESTART then
		manager.final()
		manager.init()
	end
end

function manager.final()
	collision.final()
	map.final()
	player.final()
	data.final()
end

return manager
