local const          = require("scripts.lib.const")
--local device         = require("scripts.lib.device")

local data           = {}

data.window_size     = { width = 0, height = 0 }
data.is_mobile       = false
data.window_scale    = 1

-- Loading proxy
data.proxy           = {
	loaded = false,
	gui_container = msg.url("loading:/gui"),
	gui = msg.url("loading:/gui#loading"),
	script = msg.url("loading:/script#loading"),
	msg = {
		proxy_loaded = hash("proxy_loaded"),
		guy_removed = hash("guy_removed"),
		enable_game = hash("enable_game")
	}
}

-- Tile map
data.map_width       = 0
data.map_height      = 0
data.map             = {} -- <- Map tile data. Not using this.
data.map_objects     = {}

-- Props
data.props           = {}
data.moving_props    = {}
data.collected_props = {} -- keep track of falling platforms.

-- Enemies
data.enemies         = {}

-- Background images
data.backgrounds     = {}

-- Checkpoints
data.checkpoints     = {}
data.last_checkpoint = 0

-- Map directions
data.directions      = {}

-- Shaders
data.shader_time     = vmath.vector4(0)
data.dt              = vmath.vector4(0)

-- Debug
data.debug           = {
	profiler  = false,
	colliders = false,
	imgui     = false,
	init      = sys.get_config_int("platformer.debug", 1) == 1 and true or false
}

data.game            = {
	state = {
		pause          = false,
		input_pause    = false,
		skip_colliders = false
	},
	level = 1,
	is_music_playing = false,
	is_music = true,
	is_sound_fx = true,
	is_gamepad_connected = false,
}

data.player          = {
	position          = vmath.vector3(0.9), -- <- Z position
	initial_position  = vmath.vector3(0.9),
	aabb_id           = -1,
	velocity          = vmath.vector3(0, 0, 0),
	collected_apples  = 0,
	health            = const.PLAYER.HEALTH,
	direction         = 0,
	current_direction = 0,
	gravity_down      = 0,
	jump_timer        = 0,
	ids               =
	{
		CONTAINER      = nil,
		PLAYER_SPRITE  = nil,
		WALK_PFX       = nil,
		GROUND_HIT_PFX = nil,
		JUMP_PFX       = nil,
		SLIDING_PFX    = nil
	},
	state             = {
		on_ground          = true,
		on_slope           = false,
		jump_pressed       = false,
		is_jumping         = false,
		is_walking         = false,
		is_sliding         = false,
		is_falling         = false,
		is_hit             = false,
		over_platform      = false,
		on_moving_platform = false

	}
}

data.camera          = {
	zoom          = 0,
	position      = vmath.vector3(),
	base_position = vmath.vector3(),
	deadzone      = vmath.vector3(),
	view          = vmath.matrix4()
}

function data.set_game_pause(state)
	data.game.state.pause = state
	daabbcc.run(not state)
	msg.post(const.URLS.GUI, const.MSG.GAME_PAUSE)

	if data.proxy.loaded then
		if data.game.state.pause then
			msg.post(const.PROXY, "set_time_step", { factor = 0, mode = 0 })
		else
			msg.post(const.PROXY, "set_time_step", { factor = 1, mode = 1 })
		end
	end
end

function data.set_audio(state)
	data.game.is_sound_fx = state
	data.game.is_music = state
end

function data.final()
	for _, prop in pairs(data.props) do
		if prop.data and prop.data.timer_handle then
			timer.cancel(prop.data.timer_handle)
		end
		go.delete(prop.id)
	end

	for _, enemy in pairs(data.enemies) do
		go.delete(enemy.id)
	end

	data.shader_time             = vmath.vector4(0)
	data.enemies                 = {}
	data.directions              = {}
	data.props                   = {}
	data.moving_props            = {}
	data.collected_props         = {}
	data.player.collected_apples = 0

	data.map_objects             = {}
	data.map                     = {}
	data.enemies                 = {}
end

return data
