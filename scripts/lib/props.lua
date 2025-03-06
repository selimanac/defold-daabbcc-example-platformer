local const        = require("scripts.lib.const")
local utils        = require("scripts.lib.utils")
local data         = require("scripts.lib.data")
local collision    = require("scripts.lib.collision")
local player_state = require("scripts.lib.player_state")

local props        = {}

local function init_falling_platform(prop, query_result, callback_fnc)
	if query_result.normal_y == 1 and prop.status == false then
		prop.status = true
		sprite.play_flipbook(prop.sprite, prop.anims.on)

		timer.delay(0.5, false, function()
			collision.remove(prop.aabb_id)
			go.animate(prop.sprite, "tint.w", go.PLAYBACK_ONCE_FORWARD, 0, go.EASING_LINEAR, 0.2, 0)

			go.animate(prop.id, "position.y", go.PLAYBACK_ONCE_FORWARD, prop.position.y - 30, go.EASING_LINEAR, 0.2, 0, function()
				go.delete(prop.id)
				data.props[prop.aabb_id] = nil
			end)
		end)
	end
end

local function init_trampoline(prop, query_result)
	if query_result.normal_y == 1 and prop.status == false then
		prop.status = true
		sprite.play_flipbook(prop.sprite, prop.anims.on)
		player_state.jump(0)
		data.player.velocity.y = data.player.velocity.y - (const.PLAYER.GRAVITY_UP * 0.5)
		prop.status = false
	end
end

local function init_collectable(prop, query_result)
	if prop.status == false then
		prop.status = true
		collision.remove(prop.aabb_id)
		sprite.play_flipbook(prop.sprite, prop.anims.on, function()
			go.delete(prop.id)
		end)

		data.props[prop.aabb_id] = nil
	end
end



local function init_box(prop, query_result)
	if (query_result.normal_y == -1 or query_result.normal_y == 1) and prop.status == false then
		prop.status = true
		collision.remove(prop.aabb_id)
		if query_result.normal_y == 1 then
			player_state.jump(0)
			data.player.velocity.y = data.player.velocity.y - (const.PLAYER.GRAVITY_SLIDE * 0.5)
		end
		sprite.play_flipbook(prop.sprite, prop.anims.on, function()
			go.delete(prop.id)
		end)

		data.props[prop.aabb_id] = nil
	end
end

local function init_spikes(prop, query_result)
	prop.status = true
	data.game.state.input_pause = true
	data.game.state.skip_colliders = true

	player_state.die()
end

local function init_checkpoint(prop, _)
	if prop.status == false then
		prop.status = true

		local checkpoint = data.checkpoints[prop.data.checkpoint_id]

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
		id = nil,
		sprite = nil,
		collision_bit = const.COLLISION_BITS.TILE,
		anims = {
			idle = hash("box1_idle"),
			on = hash("box1_on"),
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
		id = nil,
		sprite = nil,
		collision_bit = const.COLLISION_BITS.TILE,
		anims = {
			idle = hash("spikes")
		}
	},

	SPIKE_HEAD = {
		size = { width = 43, height = 43 },
		collider_size = { width = 43, height = 43 },
		offset = vmath.vector3(),
		center = { x = 0, y = 0 },
		fn = init_spikes,
		factory = const.FACTORIES.SPIKE_HEAD,
		position = vmath.vector3(),
		status = false,
		collectable = false,
		aabb_id = 0,
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
		id = nil,
		sprite = nil,
		collision_bit = const.COLLISION_BITS.PROP,
		anims = {
			idle    = hash("checkpoint_no_flag"),
			on      = hash("checkpoint_flag_out"),
			on_idle = hash("checkpoint_flag_idle"),
		}
	},
}

local function object_rotate(object_data)
	-- object rotation is very problematic at Tiled. this is a very ugly solution
	local size = vmath.vector3(object_data.width, object_data.height, 0)
	local rotated_size = vmath.rotate(vmath.quat_rotation_z(math.rad(object_data.rotation * -1)), size)

	rotated_size.x = math.abs(rotated_size.x)
	rotated_size.y = math.abs(rotated_size.y)

	local centerX = object_data.width / 2
	local centerY = object_data.height / 2
	local cosRotation = math.cos(math.rad(object_data.rotation))
	local sinRotation = math.sin(math.rad(object_data.rotation))
	local rotatedCenterX = centerX * cosRotation - centerY * sinRotation
	local rotatedCenterY = centerX * sinRotation + centerY * cosRotation

	if object_data.rotation == -90 or object_data.rotation == 90 then
		object_data.x = math.floor(object_data.x - rotatedCenterX - (object_data.width / 2))
		object_data.y = math.floor((object_data.y + rotatedCenterY) + (object_data.height / 2))
	elseif object_data.rotation == 180 or object_data.rotation == -180 then
		object_data.x = math.floor(object_data.x - rotatedCenterX - (object_data.width + (object_data.width / 2)))
		object_data.y = math.floor((object_data.y + rotatedCenterY) + (object_data.height + object_data.height / 2))
	end

	object_data.width  = rotated_size.x
	object_data.height = rotated_size.y
end

function props.add(object_data, hflip, vflip)
	hflip = hflip and hflip or false
	vflip = vflip and vflip or false

	if object_data.rotation ~= 0 then
		object_rotate(object_data)
	end

	local rotation = object_data.rotation and vmath.quat_rotation_z(math.rad(object_data.rotation * -1)) or nil
	local prop = utils.table_copy(props.TYPE[object_data.type])

	prop.center.x = object_data.x + (prop.size.width / 2)
	prop.center.y = (data.map_height - object_data.y) + (prop.size.height / 2)
	prop.position = vmath.vector3(prop.center.x, prop.center.y, 0.1)
	prop.id = factory.create(prop.factory, prop.position, rotation)
	prop.sprite = msg.url(prop.id)
	prop.sprite.fragment = "sprite"

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
	prop.aabb_id = collision.insert_aabb(prop.center.x, prop.center.y, prop.collider_size.width, prop.collider_size.height, prop.collision_bit)

	-- add checkpoints
	if object_data.type == "CHECKPOINT" then
		print("CHECKPOINT aabb id:", prop.aabb_id)
		local checkpoint = {
			position = prop.position,
			x = prop.position.x,
			y = prop.position.y,
			active = false,
			aabb_id = prop.aabb_id
		}


		if data.last_checkpoint == 0 then
			--	print("object_data.id:", object_data.id)
			data.checkpoints[object_data.id] = checkpoint
		else
			data.checkpoints[object_data.id].aabb_id = prop.aabb_id
		end

		prop.data = {
			checkpoint_id = object_data.id
		}
	end

	data.props[prop.aabb_id] = prop
end

return props
