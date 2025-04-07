local map          = require("scripts.lib.map")
local collision    = require("scripts.lib.collision")
local audio        = require("scripts.lib.audio")
local data         = require("scripts.lib.data")
local const        = require("scripts.lib.const")
local game_camera  = require("scripts.lib.game_camera")
local particles    = require("scripts.lib.particles")
local background   = require("scripts.lib.background")
local camera_fx    = require("scripts.lib.camera_fx")

local player_input = require("scripts.game.player.player_input")
local enemies      = require("scripts.game.enemies")
local props        = require("scripts.game.props")
local checkpoint   = require("scripts.game.props.checkpoint")
local player       = require("scripts.game.player")

local debug        = nil

local manager      = {}

local function collect_garbage()
	print("collect_garbage before: ", collectgarbage("count"))
	collectgarbage("collect")
	print("collect_garbage after: ", collectgarbage("count"))
	collectgarbage("setstepmul", 110)
end

local function setup_urls()
	for key, url in pairs(const.URLS) do
		const.URLS[key] = msg.url(url)
	end

	for key, url in pairs(const.FACTORIES) do
		const.FACTORIES[key] = msg.url(url)
	end

	for key, url in pairs(const.AUDIO) do
		const.AUDIO[key] = msg.url(url)
	end
end

local function check_mobile()
	if data.game.is_mobile and not data.game.is_mobile_init then
		data.game.is_mobile_init = true
		data.window_scale = (data.window_scale * 0.7) -- <- More zoom for mobile
		local mobile_gui = factory.create(const.FACTORIES.MOBILE_GUI, vmath.vector3(0))
		const.URLS.MOBILE_GUI = msg.url(mobile_gui)
	end
end

function manager.add_backgrounds(self)
	data.backgrounds[1] = self.background_1
	data.backgrounds[2] = self.background_2
	data.backgrounds[3] = self.background_3
	data.backgrounds[4] = self.background_4
	data.backgrounds[5] = self.background_5
	data.backgrounds[6] = self.background_6
	data.backgrounds[7] = self.background_7
end

function manager.init()
	msg.post(".", "acquire_input_focus")

	setup_urls()
	check_mobile()

	collision.init()
	map.init()
	map.load(data.game.level)
	background.init()
	player.init()
	game_camera.init()

	if data.debug.init then
		debug = require("scripts.lib.debug")
		debug.init()
	end

	collect_garbage()

	game_camera.check_orientation()

	audio.play_music()
end

function manager.update(dt)
	if data.debug.init then
		debug.update()
	end

	-- for shaders
	data.shader_time.x = data.shader_time.x + dt
	data.dt.x = dt

	if data.game.state.pause then
		return
	end

	player.update(dt)
	game_camera.update(dt)
	enemies.update(dt)
	props.update(dt)
	particles.update(dt)
	camera_fx.update(dt)
end

function manager.input(action_id, action)
	if data.game.state.input_pause or data.game.state.pause then
		return
	end

	player_input.input(action_id, action)
end

function manager.message(message_id, message, sender)
	if message_id == const.MSG.RESTART then
		checkpoint.reset()
		manager.final()
		manager.init()
	elseif message_id == const.MSG.PLAYER_DIE then
		player.final(false)
		props.set_collected()
		collect_garbage()
		player.init()
	elseif const.MSG.TOGGLE_AUDIO then
		if not data.game.is_music then
			audio.stop_music()
		else
			audio.play_music()
		end
	end
end

function manager.final()
	particles.final()
	map.final()
	player.final(true)
	data.final()
	collision.final()
end

return manager
