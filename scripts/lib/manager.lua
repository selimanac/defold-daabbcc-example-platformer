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


function manager.init(level)
	msg.post(".", "acquire_input_focus")
	msg.post("@render:", "clear_color", { color = const.BACKGROUND_COLOR })

	setup_urls()

	if defos then
		const.DISPLAY_WIDTH  = sys.get_config_number("defos.view_width")
		const.DISPLAY_HEIGHT = sys.get_config_number("defos.view_height")
	end

	collision.init()
	map.load(level)
	player.init()
	game_camera.init()

	if data.debug then
		debug.init()
	end

	collect_garbage()
end

function manager.update(dt)
	player.update(dt)
	game_camera.update(dt)

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
