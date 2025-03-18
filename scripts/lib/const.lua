local const            = {}

const.DISPLAY_WIDTH    = sys.get_config_number("display.width")
const.DISPLAY_HEIGHT   = sys.get_config_number("display.height")

const.BACKGROUND_COLOR = vmath.vector4(33 / 255, 31 / 255, 48 / 255, 1)

const.COLLISION_BITS   = {
	PLAYER     = 1,
	ENEMY      = 2,
	TILE       = 4,
	ITEM       = 8,
	PROP       = 16,
	PARTICLES  = 32,
	SLOPE      = 64,
	PLATFORM   = 128,
	DIRECTIONS = 256,
	WATERFALL  = 512,

	ALL        = bit.bnot(0) -- -1 for all results
}

const.FACTORIES        = {
	LEVEL_MAP        = "/factories#level",
	PLAYER           = "/factories#player",

	-- Props
	FALLING_PLATFORM = "/props#falling_platform",
	TRAMPOLINE       = "/props#trampoline",
	APPLE            = "/props#apple",
	END              = "/props#end",
	BOX1             = "/props#box1",
	BOX1_BREAK       = "/props#box1_break",
	PROP_COLLECTED   = "/props#prop_collected",
	SPIKE            = "/props#spikes",
	WATER            = "/props#water",
	WATERFALL        = "/props#waterfall",
	SPIKE_HEAD       = "/props#spike_head",
	CHECKPOINT       = "/props#checkpoint",
	FIRE             = "/props#fire",
	MOVING_PLATFORM  = "/props#moving_platform",
	WATER_SPLASH     = "/props#water_splash",

	-- Enemnies
	ANGRY_PIG        = "/enemies#enemy_angry_pig",
	ROCK_HEAD        = "/enemies#enemy_rock_head"
}

const.PLAYER           = {
	SIZE                  = { w = 20, h = 25 },
	HALF_SIZE             = { w = 20 / 2, h = 25 / 2 },
	MOVE_ACCELERATION     = 800,
	MAX_MOVE_SPEED        = 150,
	DECELERATION_LERP     = 0.2,
	JUMP_FORCE            = 350,
	WALL_JUMP_FORCE       = 250,
	TRAMPOLINE_JUMP_FORCE = 750,
	GRAVITY_UP            = -1500,
	GRAVITY_DOWN          = -1500,
	GRAVITY_SLIDE         = -200,
	GRAVITY_WALL_JUMP     = -800,
	MAX_VELOCITY_Y        = -600, -- <- Too much speed may cause collision to skip.
	MAX_JUMP_HOLD_TIME    = 1,
	PLATFORM_JUMP_OFFSET  = 10,
	HEALTH                = 3,

	ANIM                  = {
		IDLE = hash("virtual_guy_player_idle"),
		RUN = hash("virtual_guy_player_run"),
		JUMP = hash("virtual_guy_player_jump"),
		FALL = hash("virtual_guy_player_fall"),
		HIT = hash("virtual_guy_player_hit"),
		DOUBLE_JUMP = hash("virtual_guy_player_double_jump"),
		WALL_JUMP = hash("virtual_guy_player_wall_jump"),
		APPEARING = hash("player_appearing"),
		DISAPPEARING = hash("player_disappearing"),
	}
}

const.CAMERA           = {
	DEADZONE    = vmath.vector3(60, 60, 0),
	CAMERA_LERP = 5,
	BOUNDS_MIN  = vmath.vector3(270, -800, 0),
	BOUNDS_MAX  = vmath.vector3(4250, 200, 0)
}

const.TRIGGERS         = {
	MOVE_LEFT = hash("MOVE_LEFT"),
	MOVE_RIGHT = hash("MOVE_RIGHT"),
	JUMP = hash("JUMP"),
	MOUSE_BUTTON_LEFT = hash("MOUSE_BUTTON_LEFT"),
	GAMEPAD_CONNECTED = hash("gamepad_connected"),
	GAMEPAD_DISCONNECTED = hash("gamepad_disconnected")
}

const.URLS             = {
	CAMERA_CONTAINER = "/camera",
	CAMERA_ID        = "/camera#camera",
	MAP              = "",
	MAP_CONTANINER   = "",
	GAME             = "/script#game",
	BACKGROUND       = "/background",
	BACKGROUND_MODEL = "/background#model",
	GUI              = "/gui#game"
}

const.MSG              = {
	RESTART = hash("restart"),
	PLAYER_DIE = hash("player_die"),
	GAME_PAUSE = hash("game_pause"),
	COLLECT = hash("collect"),
	PLAYER_HEALTH_UPDATE = hash("player_health_update")
}

const.AUDIO            = {
	ON_GROUND        = "/fx#on_ground",
	JUMP             = "/fx#jump",
	RUN              = "/fx#run",
	TRAMPOLINE       = "/fx#trampoline",
	MUSIC            = "/audio#music",
	COLLECT          = "/fx#collect",
	WALL_JUMP        = "/fx#wall_jump",
	BOX_CRACK        = "/fx#box_crack",
	PIECE_DROP       = "/fx#piece_drop",
	FALLING_PLATFORM = "/fx#falling_platform",
	PLAYER_DEATH     = "/fx#death",
	PLAYER_DISAPPEAR = "/fx#disappear",
	PLAYER_APPEAR    = "/fx#appear",
	SQUEEZE          = "/fx#squeeze",
	FIRE             = "/fx#fire",
	CHECKPOINT       = "/fx#checkpoint",
	END              = "/fx#end",
}

return const
