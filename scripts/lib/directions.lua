local const      = require("scripts.lib.const")
local data       = require("scripts.lib.data")
local utils      = require("scripts.lib.utils")
local collision  = require("scripts.lib.collision")

local directions = {}

directions.TYPE  = {
	DIRECTION_RIGHT = {
		size = { width = 16, height = 16 },
		collider_size = { width = 1, height = 1 },
		center = { x = 0, y = 0 },
		position = vmath.vector3(),
		direction_x = 1,
		direction_y = 0
	},
	DIRECTION_LEFT = {
		size = { width = 16, height = 16 },
		collider_size = { width = 1, height = 1 },
		center = { x = 0, y = 0 },
		position = vmath.vector3(),
		direction_x = -1,
		direction_y = 0
	},
	DIRECTION_UP = {
		size = { width = 16, height = 16 },
		collider_size = { width = 1, height = 1 },
		center = { x = 0, y = 0 },
		position = vmath.vector3(),
		direction_x = 0,
		direction_y = 1
	},
	DIRECTION_DOWN = {
		size = { width = 16, height = 16 },
		collider_size = { width = 1, height = 1 },
		center = { x = 0, y = 0 },
		position = vmath.vector3(),
		direction_x = 0,
		direction_y = -1
	},
}

function directions.add(object_data)
	local direction = utils.table_copy(directions.TYPE[object_data.type])

	direction.center.x = object_data.x + (direction.direction_x == -1 and direction.size.width or 0)
	direction.center.y = (data.map_height - object_data.y) + (direction.direction_y == 1 and 0 or (direction.size.height / 2)) + (direction.direction_y == -1 and direction.size.height / 2 or 0)

	direction.position = vmath.vector3(direction.center.x, direction.center.y, 0)

	direction.aabb_id = collision.insert_aabb(direction.center.x, direction.center.y, direction.collider_size.width, direction.collider_size.height, const.COLLISION_BITS.DIRECTIONS)

	data.directions[direction.aabb_id] = direction
end

return directions
