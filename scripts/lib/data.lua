local data           = {}

data.map_width       = 0
data.map_height      = 0
data.map             = {}
data.map_objects     = {}
data.props           = {}
data.enemies         = {}
data.backgrounds     = {}
data.checkpoints     = {}
data.last_checkpoint = 0
data.directions      = {}

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
		on_slope     = false,
		jump_pressed = false,
		is_jumping   = false,
		is_walking   = false,
		is_sliding   = false,
		is_falling   = false,

	}
}

data.camera          = {
	zoom = 0,
	position = vmath.vector3(),
	deadzone = vmath.vector3()
}

function data.final()
	for _, prop in pairs(data.props) do
		if prop.data and prop.data.timer_handle then
			timer.cancel(prop.data.timer_handle)
		end
		go.delete(prop.id, true)
	end

	for _, enemy in pairs(data.enemies) do
		go.delete(enemy.id)
	end

	data.enemies     = {}
	data.directions  = {}
	data.props       = {}
	data.map_objects = {}
	data.map         = {}
	data.enemies     = {}
end

return data
