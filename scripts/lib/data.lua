local const          = require("scripts.lib.const")

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

-- Shaders
data.shader_time     = vmath.vector4(0)
data.dt              = vmath.vector4(0)

-- Audio


data.debug  = {
	profiler  = false,
	colliders = true,
	imgui     = true,
	init      = sys.get_config_int("platformer.debug", 1) == 1 and true or false
}

data.game   = {
	state = {
		pause          = false,
		input_pause    = false,
		skip_colliders = false
	},
	level = 1,
	is_music = false
}

data.player = {
	position          = vmath.vector3(),
	initial_position  = vmath.vector3(),
	aabb_id           = -1,
	velocity          = vmath.vector3(0, 0, 0),
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
		over_platform      = false,
		on_moving_platform = false

	}
}

data.camera = {
	zoom          = 0,
	position      = vmath.vector3(),
	base_position = vmath.vector3(),
	deadzone      = vmath.vector3(),
	view          = vmath.matrix4()
}

function data.reset_checkpoints()
	data.checkpoints     = {}
	data.last_checkpoint = 0
end

function data.check_checkpoint()
	local player_z = 0.9
	if data.last_checkpoint > 0 then
		data.player.position = vmath.vector3()
		local checkpoint = data.checkpoints[data.last_checkpoint]
		data.player.position = vmath.vector3(checkpoint.x, checkpoint.y, player_z)
		data.player.position.z = player_z
		data.player.position.y = data.player.position.y - const.PLAYER.HALF_SIZE.h
		data.player.position.x = data.player.position.x + 10

		for _, checkpoint in pairs(data.checkpoints) do
			if checkpoint.active then
				local checkpoint_prop = data.props[checkpoint.aabb_id]
				checkpoint_prop.fn(checkpoint_prop)
			end
		end
	end
end

function data.toggle_game_pause(state)
	print(state)
	data.game.state.pause = state

	if state then
		daabbcc.run(false)
	else
		daabbcc.run(true)
	end
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
	data.shader_time = vmath.vector4(0)
	data.enemies     = {}
	data.directions  = {}
	data.props       = {}
	data.map_objects = {}
	data.map         = {}
	data.enemies     = {}
end

return data
