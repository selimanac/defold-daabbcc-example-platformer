local const             = require("scripts.lib.const")
local data              = require("scripts.lib.data")
local collision         = require("scripts.lib.collision")
local utils             = require("scripts.lib.utils")
local entities          = require("scripts.lib.entities")
local checkpoint        = require("scripts.props.checkpoint")

local props             = {}

local prop_query_result = {}
local prop_direction    = 0

function props.set_collected()
	for _, prop in ipairs(data.collected_props) do
		prop.status = false
		prop.id = factory.create(prop.factory, prop.position, prop.rotation, nil, prop.scale)
		prop.sprite = msg.url(prop.id)
		prop.sprite.fragment = "sprite"

		if not prop.is_fixed then
			prop.aabb_id = collision.insert_gameobject(prop.id, prop.collider_size.width, prop.collider_size.height, prop.collision_bit)
		else
			prop.aabb_id = collision.insert_aabb(prop.center.x, prop.center.y, prop.collider_size.width, prop.collider_size.height, prop.collision_bit)
		end

		data.props[prop.aabb_id] = prop
	end

	data.collected_props = {}
end

function props.add(object_data, hflip, vflip, properties)
	hflip = hflip and hflip or false
	vflip = vflip and vflip or false

	-- Copy from table
	local prop = utils.table_copy(entities.PROP[object_data.type])

	prop.rotation = utils.object_rotate(object_data)

	-- Scale water and waterfall quads
	prop.scale = vmath.vector3(1)
	if object_data.type == "WATER" or object_data.type == "WATERFALL" then
		prop.size.width = object_data.width
		prop.size.height = object_data.height
		prop.collider_size.width = object_data.width
		prop.collider_size.height = object_data.height
		prop.scale = vmath.vector3(prop.size.width / 2, prop.size.height / 2, 1)
	end

	prop.name = object_data.name
	prop.properties = properties
	prop.x = object_data.x
	prop.y = (data.map_height - object_data.y) - object_data.height
	prop.center.x = object_data.x + (prop.size.width / 2)
	prop.center.y = (data.map_height - object_data.y) + (prop.size.height / 2)
	prop.position = vmath.vector3(prop.center.x, prop.center.y, 0.1)

	-- factory
	prop.id = factory.create(prop.factory, prop.position, prop.rotation, nil, prop.scale)
	prop.sprite = msg.url(prop.id)
	prop.sprite.fragment = "sprite"

	-- Other water and waterfall stuff
	if object_data.type == "WATER" or object_data.type == "WATERFALL" then
		prop.model = msg.url(prop.id)
		prop.model.fragment = "model"

		if object_data.type == "WATERFALL" then
			prop.pfx = msg.url(prop.id)
			prop.pfx.fragment = "waterfall_splash"
			particlefx.play(prop.pfx)
		end

		go.set(prop.model, "uResolution", vmath.vector4(prop.scale.x, prop.scale.y, 1, 1))
	else -- Only set if it is sprite
		-- h-v flip
		utils.flip_object_sprite(prop.sprite, hflip, vflip)
	end

	-- rotate collider
	utils.rotate_object_collider(prop.rotation, prop)

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
		checkpoint.add(prop, object_data)
	end

	--add to props table
	data.props[prop.aabb_id] = prop

	-- in this case just for moving platforms:
	if not prop.is_fixed then
		table.insert(data.moving_props, prop)
	end
end

function props.update(dt)
	for _, prop in ipairs(data.moving_props) do
		if not prop.is_fixed and prop.status == false then
			-- there is a Vsyc problem going on here.....
			-- If Vsyc is set to ON there is a interpolation or timing mismatches.
			go.set_position(prop.position, prop.id) -- Temporary fix: Set the position before(next frame) to prevent interpolation or timing mismatches.

			-- Velocity
			prop.data.prev_position.x = prop.position.x
			prop.data.prev_position.y = prop.position.y

			prop.position.x = prop.position.x + (prop.properties.speed * prop.properties.direction_x) * dt
			prop.position.y = prop.position.y + (prop.properties.speed * prop.properties.direction_y) * dt
			prop.center = prop.position

			-- These are used for player
			prop.y = prop.position.y - (prop.size.height / 2)          -- used for top of the prop for platforms
			prop.data.velocity = (prop.position - prop.data.prev_position) / dt -- velocity for player

			-- Query directions
			prop_query_result, _ = collision.query_id(prop.aabb_id, const.COLLISION_BITS.DIRECTIONS)
			if prop_query_result then
				prop_direction = data.directions[prop_query_result[1]]
				prop.properties.direction_x = prop_direction.direction_x
				prop.properties.direction_y = prop_direction.direction_y
			end
		end
	end
end

return props
