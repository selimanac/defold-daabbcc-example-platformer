local data      = require("scripts.lib.data")
local const     = require("scripts.lib.const")
local collision = require("scripts.lib.collision")
local props     = require("scripts.lib.props")


local map = {}


function map.load(level)
	local json_data, error = sys.load_resource("/data/level_" .. level .. ".json")
	if error then
		print(error)
		return
	end

	if not json_data then
		pprint(json_data)
		return
	end

	local map_data = json.decode(json_data)

	data.map_width = map_data.width * map_data.tilewidth
	data.map_height = map_data.height * map_data.tileheight


	for i, layer in ipairs(map_data.layers) do
		-- Tiles
		if layer.name == "map" then
			for y = 1, map_data.height do
				data.map[y] = {}

				local reverse_y = map_data.height - y + 1
				for x = 1, map_data.width do
					local tile = layer.data[(y - 1) * map_data.width + x]

					tilemap.set_tile(const.URLS.MAP, "map", x, reverse_y, tile)
					data.map[y][x] = tile
				end
			end
		end

		-- Tile collision objects
		if layer.name == "map_collision" then
			for i = 1, #layer.objects do
				local object_data = layer.objects[i]

				local center_x = object_data.x + (object_data.width / 2)
				local center_y = (data.map_height - object_data.y) - (object_data.height / 2)

				local aabb_id = collision.insert_aabb(center_x, center_y, object_data.width, object_data.height, const.COLLISION_BITS.TILE)

				data.map_objects[aabb_id] = {
					x = object_data.x,
					y = (data.map_height - object_data.y) - object_data.height,
					center = { x = center_x, y = center_y },
					size = { width = object_data.width, height = object_data.height },
					name = object_data.name,
					aabb_id = aabb_id
				}
			end
		end

		-- Prop collision objects
		if layer.name == "prop_collision" then
			for i = 1, #layer.objects do
				local object_data = layer.objects[i]
				props.add(object_data.x, object_data.y, object_data.width, object_data.height, object_data.type)
			end
		end

		-- Entities
		if layer.name == "entities" then
			for i = 1, #layer.objects do
				local object_data = layer.objects[i]

				-- Player init position
				if object_data.name == "PLAYER" then
					data.player.position = vmath.vector3(object_data.x + (object_data.width / 2), (data.map_height - object_data.y) - (object_data.height / 2), 0.1)
				end
			end
		end

		-- loop end
	end
end

return map
