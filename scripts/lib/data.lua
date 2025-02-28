local data       = {}

data.map         = {}
data.map_objects = {}
data.debug       = true

data.player      = {
	position  = vmath.vector3(),
	aabb_id   = -1,
	ids       = {},
	velocity  = vmath.vector3(0, 0, 0),
	direction = 0

}

return data
