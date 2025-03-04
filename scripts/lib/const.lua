local const            = {}

const.DISPLAY_WIDTH    = sys.get_config_number("display.width")
const.DISPLAY_HEIGHT   = sys.get_config_number("display.height")

const.BACKGROUND_COLOR = vmath.vector4(221 / 255, 198 / 255, 161 / 255, 1)

const.COLLISION_BITS   = {
	PLAYER = 1,
	ENEMY  = 2,
	TILE   = 4,
	ITEM   = 8,
	PROP   = 16,

	ALL    = bit.bnot(0) -- -1 for all results
}

const.FACTORIES        = {
	PLAYER = "/factories#player",
	FALLING_PLATFORM = "/props#falling_platform",
	TRAMPOLINE = "/props#trampoline"
}

const.PLAYER           = {
	SIZE               = { w = 20, h = 25 },

	MOVE_ACCELERATION  = 800,
	MAX_MOVE_SPEED     = 150,
	DECELERATION_LERP  = 0.2,
	JUMP_FORCE         = 350,
	WALL_JUMP_FORCE    = 250,
	GRAVITY_UP         = -1500,
	GRAVITY_DOWN       = -1500,
	GRAVITY_SLIDE      = -200,
	GRAVITY_WALL_JUMP  = -800,
	MAX_JUMP_HOLD_TIME = 1,

	ANIM               = {
		IDLE = hash("virtual_guy_player_idle"),
		RUN = hash("virtual_guy_player_run"),
		JUMP = hash("virtual_guy_player_jump"),
		FALL = hash("virtual_guy_player_fall"),
		HIT = hash("virtual_guy_player_hit"),
		DOUBLE_JUMP = hash("virtual_guy_player_double_jump"),
		WALL_JUMP = hash("virtual_guy_player_wall_jump")
	}
}

const.CAMERA           = {
	DEADZONE    = vmath.vector3(60, 60, 0),  -- Deadzone x and heighty
	CAMERA_LERP = 5,                         -- Smoothing factor -> higher = faster catch-up
	BOUNDS_MIN  = vmath.vector3(190, -1768, 0), -- Minimum camera bound position (left/bottom)
	BOUNDS_MAX  = vmath.vector3(2024, 1768, 0), -- Maximum camera bound position (right/top)
}

const.TRIGGERS         = {
	MOVE_LEFT = hash("MOVE_LEFT"),
	MOVE_RIGHT = hash("MOVE_RIGHT"),
	JUMP = hash("JUMP")
}

const.URLS             = {
	CAMERA_CONTAINER = "/camera",
	CAMERA_ID        = "/camera#camera",
	MAP              = "/level/map#level"
}

return const
