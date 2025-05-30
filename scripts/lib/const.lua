local const            = {}

const.DISPLAY_WIDTH    = sys.get_config_number("display.width")
const.DISPLAY_HEIGHT   = sys.get_config_number("display.height")

const.BACKGROUND_COLOR = vmath.vector4(33 / 255, 31 / 255, 48 / 255, 1)

const.LIVEUPDATE       = {
	URL = sys.get_config_string("platformer.http_url", nil),
	FILE = "platformer.zip"
}

----------------------
-- Collision
----------------------
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
	WATERFALL  = 512
}

----------------------
-- Factories
----------------------
const.FACTORIES        = {
	LEVEL_MAP        = "/factories#level",
	PLAYER           = "/factories#player",
	MOBILE_GUI       = "/factories#mobile_gui",

	-- Props
	FALLING_PLATFORM = "/props#falling_platform",
	TRAMPOLINE       = "/props#trampoline",
	APPLE            = "/props#apple",
	FINISH           = "/props#finish",
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

----------------------
-- Player
----------------------
local PLAYER_WIDTH     = 20
local PLAYER_HEIGHT    = 26

const.PLAYER           = {
	SIZE                  = { w = PLAYER_WIDTH, h = PLAYER_HEIGHT },
	HALF_SIZE             = { w = PLAYER_WIDTH / 2, h = PLAYER_HEIGHT / 2 },
	RAY_Y                 = (PLAYER_HEIGHT / 2) + 16, --<- Tile size
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
	MAX_VELOCITY_Y        = -600, -- <- Too much velocity may cause collision to skip. There is no CCD at daabbcc
	MAX_JUMP_HOLD_TIME    = 1,
	PLATFORM_JUMP_OFFSET  = 10,
	HEALTH                = 3,

	ANIM                  = {
		IDLE         = hash("virtual_guy_player_idle"),
		RUN          = hash("virtual_guy_player_run"),
		JUMP         = hash("virtual_guy_player_jump"),
		FALL         = hash("virtual_guy_player_fall"),
		HIT          = hash("virtual_guy_player_hit"),
		DOUBLE_JUMP  = hash("virtual_guy_player_double_jump"),
		WALL_JUMP    = hash("virtual_guy_player_wall_jump"),
		APPEARING    = hash("player_appearing"),
		DISAPPEARING = hash("player_disappearing"),
	}
}

----------------------
-- Camera
----------------------
const.CAMERA           = {
	DEADZONE          = vmath.vector3(60, 60, 0), -- <- Might be different on mobile devices.
	CAMERA_LERP       = 5,
	BOUNDS_MIN        = vmath.vector3(270, 150, 0), -- Minimum camera bound position (left/bottom) <-It might be better to calculate according to the tile map’s width and height.
	BOUNDS_MAX        = vmath.vector3(4250, 200, 0), -- Maximum camera bound position (right/top) <-It might be better to calculate according to the tile map’s width and height.

	MOBILE_BOUNDS_MIN = vmath.vector3(270, 0, 0),
	MOBILE_BOUNDS_MAX = vmath.vector3(4250, 220, 0)
}

----------------------
-- Triggers
----------------------
const.TRIGGERS         = {
	MOVE_LEFT            = hash("MOVE_LEFT"),
	MOVE_RIGHT           = hash("MOVE_RIGHT"),
	JUMP                 = hash("JUMP"),
	MOUSE_BUTTON_LEFT    = hash("MOUSE_BUTTON_LEFT"),
	GAMEPAD_CONNECTED    = hash("GAMEPAD_CONNECTED"),
	GAMEPAD_DISCONNECTED = hash("GAMEPAD_DISCONNECTED"),
	GAMEPAD_START        = hash("GAMEPAD_START"),
	GAMEPAD_LSTICK_DOWN  = hash("GAMEPAD_LSTICK_DOWN"),
	GAMEPAD_LSTICK_UP    = hash("GAMEPAD_LSTICK_UP"),
	GAMEPAD_RPAD_RIGHT   = hash("GAMEPAD_RPAD_RIGHT"),
	KEY_ESC              = hash("KEY_ESC"),
	TOUCH_MULTI          = hash("TOUCH_MULTI")
}

----------------------
-- Loading proxy
----------------------
const.PROXY            = {
	GAME                = msg.url("loading:/proxy#game_proxy"),
	SCRIPT              = msg.url("loading:/script#loading"),
	ORIENTATION_FACTORY = msg.url("loading:/factories#orientation"),
	GUI_CONTAINER       = msg.url("loading:/gui"),
	GUI                 = msg.url("loading:/gui#loading")
}

----------------------
-- URLs
----------------------
const.URLS             = {
	CAMERA_CONTAINER = "/camera",
	CAMERA_ID        = "/camera#camera",
	MAP              = "",
	MAP_CONTANINER   = "",
	GAME             = "/script#game",
	BACKGROUND       = "/background",
	BACKGROUND_MODEL = "/background#model",
	GUI              = "/gui#game",
	MOBILE_GUI       = ""
}

----------------------
-- Messages
----------------------
const.MSG              = {
	RESTART              = hash("restart"),
	PLAYER_DIE           = hash("player_die"),
	GAME_PAUSE           = hash("game_pause"),
	LANDSCAPE_PAUSE      = hash("landscape_pause"),
	COLLECT              = hash("collect"),
	PLAYER_HEALTH_UPDATE = hash("player_health_update"),
	TOGGLE_AUDIO         = hash("toggle_audio"),

	-- PROXY
	PROXY_LOADED         = hash("proxy_loaded"),
	GUY_REMOVED          = hash("guy_removed"),
	ENABLE_GAME          = hash("enable_game"),
	LOAD_GAME            = hash("load_game"),
	DOWNLOAD_ARCHIVE     = hash("download_archive")
}

----------------------
-- Audio
----------------------
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
