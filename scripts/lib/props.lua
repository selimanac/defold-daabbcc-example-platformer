local const             = require("scripts.lib.const")
local data              = require("scripts.lib.data")
local collision         = require("scripts.lib.collision")
local player_state      = require("scripts.lib.player_state")
local particles         = require("scripts.lib.particles")
local utils             = require("scripts.lib.utils")
local camera_fx         = require("scripts.lib.camera_fx")
local audio             = require("scripts.lib.audio")

local props             = {}

local prop_query_result = {}
local prop_direction    = 0

local function init_falling_platform(prop, query_result, callback_fnc)
	if query_result.normal_y == 1 and prop.status == false then
		prop.status = true
		sprite.play_flipbook(prop.sprite, prop.anims.on)
		audio.play(const.AUDIO.FALLING_PLATFORM)
		timer.delay(0.5, false, function()
			collision.remove(prop.aabb_id)
			go.animate(prop.sprite, "tint.w", go.PLAYBACK_ONCE_FORWARD, 0, go.EASING_LINEAR, 0.2, 0)

			go.animate(prop.id, "position.y", go.PLAYBACK_ONCE_FORWARD, prop.position.y - 30, go.EASING_LINEAR, 0.2, 0, function()
				go.delete(prop.id)
				data.props[prop.aabb_id] = nil
				audio.stop(const.AUDIO.FALLING_PLATFORM)
			end)
		end)
	end
end

local function init_trampoline(prop, query_result)
	if query_result.normal_y == 1 and prop.status == false then
		audio.play(const.AUDIO.TRAMPOLINE)
		prop.status = true
		sprite.play_flipbook(prop.sprite, prop.anims.on, function()
			prop.status = false
		end)
		camera_fx.shake(2, 4)
		data.player.state.on_ground = false
		data.player.state.jump_pressed = false
		data.player.velocity.y = const.PLAYER.TRAMPOLINE_JUMP_FORCE
		player_state.jump(0)
	end
end

local function init_collectable(prop, query_result)
	if prop.status == false then
		audio.play(const.AUDIO.COLLECT)
		prop.status = true
		collision.remove(prop.aabb_id)
		sprite.play_flipbook(prop.sprite, prop.anims.on, function()
			go.delete(prop.id)
		end)

		data.props[prop.aabb_id] = nil
	end
end

local function init_end(prop, query_result)
	if prop.status == false then
		prop.status = true
		audio.play(const.AUDIO.END)
		data.reset_checkpoints()
		collision.remove(prop.aabb_id)
		--	data.props[prop.aabb_id] = nil
		camera_fx.shake(2, 4)
		player_state.die()
	end
end



local function init_box(prop, query_result)
	if (query_result.normal_y == -1 or query_result.normal_y == 1) and prop.status == false then
		prop.status = true

		collision.remove(prop.aabb_id)

		if query_result.normal_y == 1 then
			data.player.state.on_ground = false
			data.player.velocity.y = const.PLAYER.WALL_JUMP_FORCE
			player_state.jump(0)
		elseif query_result.normal_y == -1 then
			data.player.velocity.y = 0
			data.player.gravity_down = const.PLAYER.GRAVITY_DOWN
			player_state.fall()
		end
		camera_fx.shake(2, 4)
		audio.play(const.AUDIO.BOX_CRACK)
		go.animate(prop.id, "position.y", go.PLAYBACK_ONCE_FORWARD, prop.position.y - (20 * query_result.normal_y), go.EASING_LINEAR, 0.2)
		sprite.play_flipbook(prop.sprite, prop.anims.on, function()
			go.delete(prop.id)
			local part_ids = collectionfactory.create(prop.data.break_factory, prop.position)
			particles.spawn(part_ids, prop.data.part_count)
		end)


		data.props[prop.aabb_id] = nil
	end
end

local function init_fire(prop, query_result)
	if prop.status == false and prop.data.active == false then
		prop.status = true
		prop.data.active = true
		sprite.play_flipbook(prop.sprite, prop.anims.hit, function()
			prop.data.burning = true
			prop.status = false
			audio.play(const.AUDIO.FIRE)
			sprite.play_flipbook(prop.sprite, prop.anims.on)
			prop.data.timer_handle = timer.delay(1.0, false, function()
				sprite.play_flipbook(prop.sprite, prop.anims.idle)
				prop.data.active = false
				prop.data.burning = false
			end)
		end)
	end

	if prop.data.burning == true then
		player_state.die()
	end
end

local function init_spikes(prop, query_result)
	prop.status = true

	player_state.die()
end

local function init_checkpoint(prop, _)
	if prop.status == false then
		prop.status = true

		local checkpoint = data.checkpoints[prop.data.checkpoint_id]
		audio.play(const.AUDIO.CHECKPOINT)
		collision.remove(prop.aabb_id)
		sprite.play_flipbook(prop.sprite, prop.anims.on, function()
			sprite.play_flipbook(prop.sprite, prop.anims.on_idle)
		end)

		if checkpoint.active == false then
			checkpoint.active = true
			data.last_checkpoint = prop.data.checkpoint_id
		end
	end
end

props.TYPE = {
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
		fn = init_spikes,
		factory = const.FACTORIES.WATER,
		position = vmath.vector3(),
		status = false,
		collectable = false,
		aabb_id = 0,
		is_fixed = true,
		id = nil,
		sprite = nil,
		model = nil,
		collision_bit = const.COLLISION_BITS.WATERFALL,

	},
	WATERFALL = {
		size = { width = 1, height = 1 },
		collider_size = { width = 1, height = 1 },
		offset = vmath.vector3(),
		center = { x = 0, y = 0 },
		fn = init_spikes,
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


function props.add(object_data, hflip, vflip, properties)
	hflip = hflip and hflip or false
	vflip = vflip and vflip or false

	if object_data.rotation ~= 0 then
		utils.object_rotate(object_data)
	end

	local rotation = object_data.rotation and vmath.quat_rotation_z(math.rad(object_data.rotation * -1)) or nil
	local prop = utils.table_copy(props.TYPE[object_data.type])

	local object_scale = vmath.vector3(1)


	-- scale water quad
	if object_data.type == "WATER" or object_data.type == "WATERFALL" then
		prop.size.width = object_data.width
		prop.size.height = object_data.height
		prop.collider_size.width = object_data.width
		prop.collider_size.height = object_data.height
		object_scale = vmath.vector3(prop.size.width / 2, prop.size.height / 2, 1)
	end


	prop.x = object_data.x
	prop.y = (data.map_height - object_data.y) - object_data.height
	prop.center.x = object_data.x + (prop.size.width / 2)
	prop.center.y = (data.map_height - object_data.y) + (prop.size.height / 2)
	prop.position = vmath.vector3(prop.center.x, prop.center.y, 0.1)

	prop.id = factory.create(prop.factory, prop.position, rotation, nil, object_scale)
	prop.sprite = msg.url(prop.id)
	prop.sprite.fragment = "sprite"


	if object_data.type == "WATER" or object_data.type == "WATERFALL" then
		prop.model = msg.url(prop.id)
		prop.model.fragment = "model"
		pprint(prop.model)
		go.set(prop.model, "uResolution", vmath.vector4(object_scale.x, object_scale.y, 1, 1))
	end

	if next(properties) ~= nil then
		prop.direction_x = properties.direction_x
		prop.direction_y = properties.direction_y
		prop.speed = properties.speed
	end

	-- h-v flip
	if hflip then
		sprite.set_hflip(prop.sprite, hflip)
	elseif vflip then
		sprite.set_vflip(prop.sprite, vflip)
	end

	-- rotate collider
	if rotation then
		local rotated_size = vmath.rotate(rotation, vmath.vector3(prop.collider_size.width, prop.collider_size.height, 0))
		prop.offset = vmath.rotate(rotation, prop.offset)
		prop.collider_size.width = math.abs(rotated_size.x)
		prop.collider_size.height = math.abs(rotated_size.y)
	end

	-- apply offset
	prop.center.x = prop.center.x - prop.offset.x
	prop.center.y = prop.center.y - prop.offset.y

	-- insert aabb
	if not prop.is_fixed then
		prop.aabb_id = collision.insert_gameobject(prop.id, prop.collider_size.width, prop.collider_size.height, prop.collision_bit)
	else
		prop.aabb_id = collision.insert_aabb(prop.center.x, prop.center.y, prop.collider_size.width, prop.collider_size.height, prop.collision_bit)
	end

	-- add checkpoints
	if object_data.type == "CHECKPOINT" then
		local checkpoint = {
			position = prop.position,
			x = prop.position.x,
			y = prop.position.y,
			active = false,
			aabb_id = prop.aabb_id,
			id = prop.id
		}

		if data.last_checkpoint == 0 then
			data.checkpoints[object_data.id] = checkpoint
		else
			-- just update the aabb id
			data.checkpoints[object_data.id].aabb_id = prop.aabb_id
		end

		prop.data = {
			checkpoint_id = object_data.id
		}
	end



	data.props[prop.aabb_id] = prop
end

function props.update(dt)
	data.shader_time.x = data.shader_time.x + dt
	for _, prop in pairs(data.props) do
		if not prop.is_fixed and prop.status == false then
			-- there is a Vsyc problem going on here.....
			-- If it is set to ON there is a interpolation or timing mismatches.
			go.set_position(prop.position, prop.id) -- Temporary fix: Set the position before(next frame) to prevent interpolation or timing mismatches.

			prop.data.prev_position.x = prop.position.x
			prop.data.prev_position.y = prop.position.y

			prop.position.x = prop.position.x + (prop.speed * prop.direction_x) * dt
			prop.position.y = prop.position.y + (prop.speed * prop.direction_y) * dt
			prop.data.velocity = (prop.position - prop.data.prev_position) / dt

			prop.y = prop.position.y - (prop.size.height / 2) -- used for top of the prop for platforms

			prop.center = prop.position

			prop_query_result, _ = collision.query_id(prop.aabb_id, const.COLLISION_BITS.DIRECTIONS)
			if prop_query_result then
				prop_direction = data.directions[prop_query_result[1]]
				prop.direction_x = prop_direction.direction_x
				prop.direction_y = prop_direction.direction_y
			end
		end
	end
end

return props
