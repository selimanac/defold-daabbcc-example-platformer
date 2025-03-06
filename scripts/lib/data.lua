local data           = {}

data.map_width       = 0
data.map_height      = 0

data.map             = {}
data.map_objects     = {}
data.props           = {}

data.debug           = {
	profiler = false,
	colliders = true,
	imgui = true,
	init = true
}

data.game            = {
	state = {
		pause = false,
		input_pause = false,
		skip_colliders = false
	},
	level = 1
}

data.player          = {
	position     = vmath.vector3(),
	aabb_id      = -1,

	velocity     = vmath.vector3(0, 0, 0),
	direction    = 0,
	gravity_down = 0,

	ids          =
	{
		CONTAINER      = nil,
		PLAYER_SPRITE  = nil,
		WALK_PFX       = nil,
		GROUND_HIT_PFX = nil,
		JUMP_PFX       = nil,
		SLIDING_PFX    = nil
	},

	state        = {
		on_ground    = true,
		jump_pressed = false,
		is_jumping   = false,
		is_walking   = false,
		is_sliding   = false,
		is_falling   = false,
		--is_wall_jump = false,
	}
}

data.checkpoints     = {}
data.last_checkpoint = 0

data.camera          = {
	zoom = 0,
	position = vmath.vector3(),
	deadzone = vmath.vector3()
}

function data.final()
	for _, prop in pairs(data.props) do
		go.delete(prop.id, true)
	end

	data.props = {}
	data.map_objects = {}
	data.map = {}
end

return data
