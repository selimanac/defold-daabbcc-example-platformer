local const       = require("scripts.lib.const")
local collectable = require("scripts.props.collectable")
local entities    = {}

entities.PROP     = {
	FALLING_PLATFORM = {
		size = { width = 32, height = 10 },
		collider_size = { width = 32, height = 10 },
		offset = vmath.vector3(),
		center = { x = 0, y = 0 },
		fn = init_falling_platform,
		factory = const.FACTORIES.FALLING_PLATFORM,
		position = vmath.vector3(),
		status = false,
		collectable = false,
		aabb_id = 0,
		is_fixed = true,
		id = nil,
		sprite = nil,
		collision_bit = const.COLLISION_BITS.TILE,
		anims = {
			idle = hash("falling_platform_idle"),
			on = hash("falling_platform_on"),
		}
	},
	TRAMPOLINE = {
		size = { width = 27, height = 27 },
		collider_size = { width = 23, height = 11 },
		offset = vmath.vector3(0, 8, 0),
		center = { x = 0, y = 0 },
		fn = init_trampoline,
		factory = const.FACTORIES.TRAMPOLINE,
		position = vmath.vector3(),
		status = false,
		collectable = false,
		aabb_id = 0,
		is_fixed = true,
		id = nil,
		sprite = nil,
		collision_bit = const.COLLISION_BITS.TILE,
		anims = {
			idle = hash("trampoline_idle"),
			on = hash("trampoline_on"),
		}
	},
	APPLE = {
		size = { width = 32, height = 32 },
		collider_size = { width = 14, height = 14 },
		offset = vmath.vector3(0, 0, 0),
		center = { x = 0, y = 0 },
		fn = init_collectable,
		factory = const.FACTORIES.APPLE,
		position = vmath.vector3(),
		status = false,
		collectable = true,
		aabb_id = 0,
		is_fixed = true,
		id = nil,
		sprite = nil,
		collision_bit = const.COLLISION_BITS.PROP,
		anims = {
			idle = hash("prop_apple_idle"),
			on = hash("prop_collected"),
		}
	},
	BOX_1 = {
		size = { width = 20, height = 20 },
		collider_size = { width = 20, height = 20 },
		offset = vmath.vector3(0, 0, 0),
		center = { x = 0, y = 0 },
		fn = init_box,
		factory = const.FACTORIES.BOX1,
		position = vmath.vector3(),
		status = false,
		collectable = false,
		aabb_id = 0,
		is_fixed = true,
		id = nil,
		sprite = nil,
		collision_bit = const.COLLISION_BITS.TILE,
		anims = {
			idle = hash("box1_idle"),
			on = hash("box1_on"),
		},
		data = {
			break_factory = const.FACTORIES.BOX1_BREAK,
			part_count = 4
		}
	},
	SPIKES = {
		size = { width = 16, height = 8 },
		collider_size = { width = 16, height = 8 },
		offset = vmath.vector3(),
		center = { x = 0, y = 0 },
		fn = init_spikes,
		factory = const.FACTORIES.SPIKE,
		position = vmath.vector3(),
		status = false,
		collectable = false,
		aabb_id = 0,
		is_fixed = true,
		id = nil,
		sprite = nil,
		collision_bit = const.COLLISION_BITS.TILE,
		anims = {
			idle = hash("spikes")
		}
	},

	SPIKE_HEAD = {
		size = { width = 43, height = 43 },
		collider_size = { width = 30, height = 30 },
		offset = vmath.vector3(),
		center = { x = 0, y = 0 },
		fn = init_spikes,
		factory = const.FACTORIES.SPIKE_HEAD,
		position = vmath.vector3(),
		status = false,
		collectable = false,
		aabb_id = 0,
		is_fixed = true,
		id = nil,
		sprite = nil,
		collision_bit = const.COLLISION_BITS.TILE,
		anims = {
			idle = hash("spike_head_idle")
		}
	},
	CHECKPOINT = {
		size = { width = 64, height = 64 },
		collider_size = { width = 12, height = 128 },
		offset = vmath.vector3(8, -32, 0),
		center = { x = 0, y = 0 },
		fn = init_checkpoint,
		factory = const.FACTORIES.CHECKPOINT,
		position = vmath.vector3(),
		status = false,
		collectable = true,
		aabb_id = 0,
		is_fixed = true,
		id = nil,
		sprite = nil,
		collision_bit = const.COLLISION_BITS.PROP,
		anims = {
			idle    = hash("checkpoint_no_flag"),
			on      = hash("checkpoint_flag_out"),
			on_idle = hash("checkpoint_flag_idle"),
		}
	},
	FIRE = {
		size = { width = 16, height = 32 },
		collider_size = { width = 16, height = 4 },
		offset = vmath.vector3(0, 2, 0),
		center = { x = 0, y = 0 },
		fn = init_fire,
		factory = const.FACTORIES.FIRE,
		position = vmath.vector3(),
		status = false,
		collectable = false,
		aabb_id = 0,
		is_fixed = true,
		id = nil,
		sprite = nil,
		collision_bit = const.COLLISION_BITS.TILE,
		anims = {
			idle = hash("fire_idle"),
			on = hash("fire_on"),
			hit = hash("fire_hit"),
		},
		data = {
			active = false,
			burning = false,
			timer_handle = nil
		}
	},
	MOVING_PLATFORM = {
		size = { width = 32, height = 8 },
		collider_size = { width = 32, height = 4 },
		offset = vmath.vector3(0, 0, 0),
		center = { x = 0, y = 0 },
		fn = nil,
		factory = const.FACTORIES.MOVING_PLATFORM,
		position = vmath.vector3(),
		status = false,
		collectable = false,
		aabb_id = 0,
		is_fixed = false,
		id = nil,
		sprite = nil,
		collision_bit = const.COLLISION_BITS.PLATFORM,
		data = {
			active = false,
			prev_position = vmath.vector3(),
			velocity = vmath.vector3()
		}
	},
	END = {
		size = { width = 64, height = 64 },
		collider_size = { width = 32, height = 64 },
		offset = vmath.vector3(0, 0, 0),
		center = { x = 0, y = 0 },
		fn = init_end,
		factory = const.FACTORIES.END,
		position = vmath.vector3(),
		status = false,
		collectable = true,
		aabb_id = 0,
		is_fixed = true,
		id = nil,
		sprite = nil,
		collision_bit = const.COLLISION_BITS.PROP,
		anims = {
			idle = hash("prop_end_idle"),
		}
	},
	WATER = {
		size = { width = 1, height = 1 },
		collider_size = { width = 1, height = 1 },
		offset = vmath.vector3(),
		center = { x = 0, y = 0 },
		fn = init_water,
		factory = const.FACTORIES.WATER,
		position = vmath.vector3(),
		status = false,
		collectable = true, -- <- Fake it
		aabb_id = 0,
		is_fixed = true,
		id = nil,
		sprite = nil,
		model = nil,
		collision_bit = const.COLLISION_BITS.PROP,
	},
	WATERFALL = {
		size = { width = 1, height = 1 },
		collider_size = { width = 1, height = 1 },
		offset = vmath.vector3(),
		center = { x = 0, y = 0 },
		fn = nil,
		factory = const.FACTORIES.WATERFALL,
		position = vmath.vector3(),
		status = false,
		collectable = false,
		aabb_id = 0,
		is_fixed = true,
		id = nil,
		sprite = nil,
		model = nil,
		collision_bit = const.COLLISION_BITS.WATERFALL,
	}
}

return entities
