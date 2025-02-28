local data               = require("scripts.lib.data")
local const              = require("scripts.lib.const")

local collision          = {}

local aabb_group_id      = 0
local selected_mask_bits = bit.bor(const.COLLISION_BITS.ENEMY, const.COLLISION_BITS.ITEM)
local tile_mask_bits     = bit.bor(const.COLLISION_BITS.TILE)

function collision.init()
	aabb_group_id = daabbcc.new_group(daabbcc.UPDATE_PARTIALREBUILD)
end

function collision.insert_aabb(x, y, width, height, collision_bit)
	collision_bit = collision_bit and collision_bit or nil
	return daabbcc.insert_aabb(aabb_group_id, x, y, width, height, collision_bit)
end

function collision.insert_gameobject(go_url, width, height, collision_bit, get_world_position)
	get_world_position = get_world_position and true or false

	collision_bit = collision_bit and collision_bit or nil

	return daabbcc.insert_gameobject(aabb_group_id, go_url, width, height, collision_bit, get_world_position)
end

function collision.query_id(aabb_id, is_mask, get_manifold)
	local mask_bits = is_mask and selected_mask_bits or nil
	get_manifold    = get_manifold and get_manifold or nil
	return daabbcc.query_id(aabb_group_id, aabb_id, mask_bits, get_manifold)
end

function collision.tile(aabb_id)
	return daabbcc.query_id(aabb_group_id, aabb_id, nil, true)
end

function collision.update_aabb(aabb_id, x, y, width, height)
	daabbcc.update_aabb(aabb_group_id, aabb_id, x, y, width, height)
end

return collision
