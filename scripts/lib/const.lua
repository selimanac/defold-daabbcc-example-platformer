local const = {}

const.COLLISION_BITS = {
	PLAYER  = 1, -- (2^0)
	ENEMY   = 2, -- (2^1)
	TILE    = 4, -- (2^2)
	ITEM    = 8, -- (2^3)
	WALL    = 16, -- (2^4)
	POINTER = 32,
	BUTTON  = 64,
	ALL     = bit.bnot(0) -- -1 for all results
}

const.FACTORIES = {
	PLAYER = msg.url("game:/factories#player")
}

const.PLAYER = {
	SIZE               = { w = 20, h = 25 },

	MOVE_ACCELERATION  = 800, -- pixels/sec^2 when accelerating
	MAX_MOVE_SPEED     = 150, -- maximum horizontal speed
	DECELERATION_LERP  = 0.2, -- smoothing factor (for vmath.lerp) when no input
	JUMP_FORCE         = 350, -- initial jump impulse
	GRAVITY_UP         = -1500, -- gravity while rising
	GRAVITY_DOWN       = -1500, -- gravity while falling (stronger for a snappier descent)
	MAX_JUMP_HOLD_TIME = 1,  -- hold time (in seconds) to slightly reduce gravity

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


const.KEY = {
	MOVE_LEFT = hash("MOVE_LEFT"),
	MOVE_RIGHT = hash("MOVE_RIGHT"),
	JUMP = hash("JUMP")
}




return const
