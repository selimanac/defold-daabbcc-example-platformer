local data       = {}

data.map_width   = 0
data.map_height  = 0

data.map         = {}
data.map_objects = {}
data.props       = {}
data.debug       = true

data.player      = {
	position     = vmath.vector3(),
	aabb_id      = -1,
	ids          = {},
	velocity     = vmath.vector3(0, 0, 0),
	direction    = 0,
	gravity_down = 0,
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

data.camera      = {
	zoom = 0,
	position = vmath.vector3(),
	deadzone = vmath.vector3()
}

return data
