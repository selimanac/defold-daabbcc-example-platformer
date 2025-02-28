local data = require("scripts.lib.data")
local const = require("scripts.lib.const")
local collision = require("scripts.lib.collision")

local map = {}


local objects = {}

function map.load(level)
	local px_w = 0
	local px_h = 0
	local json_data, error = sys.load_resource("/data/level_" .. level .. ".json")

	if json_data then
		local data_table = json.decode(json_data)

		px_w = data_table.width * data_table.tilewidth
		px_h = data_table.height * data_table.tileheight

		-- Tiles
		for i, tiled_data in ipairs(data_table.layers) do
			if tiled_data.name == "map" then
				for y = 1, data_table.height do
					data.map[y] = {}

					local reverse_y = data_table.height - y + 1
					for x = 1, data_table.width do
						local tile = tiled_data.data[(y - 1) * data_table.width + x]

						tilemap.set_tile("/level_1/map#level_1", "map", x, reverse_y, tile)
						data.map[y][x] = tile
					end
				end
			end

			-- Tile collision objects
			if tiled_data.name == "collision" then
				for i = 1, #tiled_data.objects do
					local object_data = tiled_data.objects[i]

					local center_x = object_data.x + (object_data.width / 2)
					local center_y = (px_h - object_data.y) - (object_data.height / 2)

					local aabb_id = collision.insert_aabb(center_x, center_y, object_data.width, object_data.height, const.COLLISION_BITS.TILE)

					data.map_objects[aabb_id] = {
						x = object_data.x,
						y = (px_h - object_data.y) - object_data.height,
						center_x = center_x,
						center_y = center_y,
						width = object_data.width,
						height = object_data.height,
						name = object_data.name,
						aabb_id = aabb_id
					}
				end
			end

			-- Entities
			if tiled_data.name == "entities" then
				for i = 1, #tiled_data.objects do
					local object_data = tiled_data.objects[i]

					-- Player init position
					if object_data.name == "player" then
						data.player.position = vmath.vector3(object_data.x + (object_data.width / 2), (px_h - object_data.y) - (object_data.height / 2), 0.1)
					end
				end
			end
		end
	else
		print(error)
	end
end

return map
