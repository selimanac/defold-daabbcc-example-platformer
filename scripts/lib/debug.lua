local data  = require("scripts.lib.data")
local const = require("scripts.lib.const")

local debug = {}

function debug.draw_aabb(x, y, width, height, color)
	msg.post("@render:", "draw_line", { start_point = vmath.vector3(x, y, 0), end_point = vmath.vector3(x + width, y, 0), color = color })
	msg.post("@render:", "draw_line", { start_point = vmath.vector3(x, y, 0), end_point = vmath.vector3(x, y + height, 0), color = color })
	msg.post("@render:", "draw_line", { start_point = vmath.vector3(x + width, y, 0), end_point = vmath.vector3(x + width, y + height, 0), color = color })
	msg.post("@render:", "draw_line", { start_point = vmath.vector3(x, y + height, 0), end_point = vmath.vector3(x + width, y + height, 0), color = color })
end

function debug.debug_draw_aabb(aabb_data, color)
	for _, data in ipairs(aabb_data) do
		debug.draw_aabb(data.x, data.y, data.width, data.height, color)
	end
end

function debug.debug_draw_center_aabb(aabb_data, color)
	for _, data in pairs(aabb_data) do
		debug.draw_aabb(data.center_x - (data.width / 2), data.center_y - (data.height / 2), data.width, data.height, color)
	end
end

function debug.update()
	debug.debug_draw_center_aabb(data.map_objects, vmath.vector4(1, 0, 0, 1))

	debug.draw_aabb(data.player.position.x - (const.PLAYER.SIZE.w / 2), data.player.position.y - (const.PLAYER.SIZE.h / 2), const.PLAYER.SIZE.w, const.PLAYER.SIZE.h, vmath.vector4(1, 0, 0, 1))

	--[[	local p = go.get_world_position(data.player.ids.COLLISION)
	debug.draw_aabb(p.x, p.y, const.PLAYER.size.w, const.PLAYER.size.h, vmath.vector4(0, 1, 0, 1))]]
end

return debug
