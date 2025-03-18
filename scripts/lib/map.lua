local data                      = require("scripts.lib.data")
local const                     = require("scripts.lib.const")
local collision                 = require("scripts.lib.collision")
local props                     = require("scripts.lib.props")
local utils                     = require("scripts.lib.utils")
local enemies                   = require("scripts.lib.enemies")
local directions                = require("scripts.lib.directions")

local map                       = {}

-- Tiled flip
local FLIPPED_HORIZONTALLY_FLAG = 0x80000000
local FLIPPED_VERTICALLY_FLAG   = 0x40000000
local FLIPPED_DIAGONALLY_FLAG   = 0x20000000

-- generic gid flip and rotate for tiles only
local function tile_flip(global_tile_id)
	-- Extract flip flags using the bit library.
	local hflip = bit.band(global_tile_id, FLIPPED_HORIZONTALLY_FLAG) ~= 0
	local vflip = bit.band(global_tile_id, FLIPPED_VERTICALLY_FLAG) ~= 0
	local dflip = bit.band(global_tile_id, FLIPPED_DIAGONALLY_FLAG) ~= 0
	local rotation = 0

	-- local ID
	local local_tile_id = bit.band(
		global_tile_id,
		bit.bnot(bit.bor(FLIPPED_HORIZONTALLY_FLAG, FLIPPED_VERTICALLY_FLAG, FLIPPED_DIAGONALLY_FLAG))
	)

	if dflip then
		rotation = 90
		-- For a diagonal flip
		hflip = not hflip
		vflip = not vflip
	end

	return local_tile_id, hflip, vflip, rotation
end

function map.init()
	local level_map_ids       = collectionfactory.create(const.FACTORIES.LEVEL_MAP)

	const.URLS.MAP_CONTANINER = msg.url(level_map_ids[hash("/container")])
	const.URLS.MAP            = msg.url(level_map_ids[hash("/container")])
	const.URLS.MAP.fragment   = "level"
end

function map.load(level)
	local json_data, error = sys.load_resource("/data/level_" .. level .. ".json")
	if error then
		print(error)
		return
	end

	if not json_data then
		print("No data")
		return
	end

	local map_data = json.decode(json_data)

	data.map_width = map_data.width * map_data.tilewidth
	data.map_height = map_data.height * map_data.tileheight

	for _, layer in ipairs(map_data.layers) do
		----------------------
		-- Tiles
		----------------------
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

		----------------------
		-- Tile collision objects
		----------------------
		if layer.name == "map_collision" then
			for i = 1, #layer.objects do
				local object_data = layer.objects[i]

				local properties = utils.set_object_properties(object_data.properties)

				local center_x = object_data.x + (object_data.width / 2)
				local center_y = (data.map_height - object_data.y) - (object_data.height / 2)

				local collision_bit = const.COLLISION_BITS.TILE
				if properties.collision_bit then
					collision_bit = const.COLLISION_BITS[properties.collision_bit]
				end

				local aabb_id = collision.insert_aabb(center_x, center_y, object_data.width, object_data.height, collision_bit)

				data.map_objects[aabb_id] = {
					raw_x = object_data.x,
					raw_y = object_data.y,
					x = object_data.x,
					y = (data.map_height - object_data.y) - object_data.height,
					center = { x = center_x, y = center_y },
					size = { width = object_data.width, height = object_data.height },
					name = object_data.name,
					aabb_id = aabb_id
				}

				if properties then
					data.map_objects[aabb_id].properties = {}
					data.map_objects[aabb_id].properties = properties
				end

				if object_data.name == "SLOPE" then
					if properties.direction == 1 or properties.direction == -1 then
						local angle = math.rad(properties.angle or 45)
						local slope_height = math.tan(angle) * object_data.width

						local x1 = object_data.x + (properties.direction == -1 and object_data.width or 0)
						local x2 = object_data.x + (properties.direction == 1 and object_data.width or 0)

						local y1 = (data.map_height - object_data.y) - object_data.height
						local y2 = y1 + slope_height

						local m, b = utils.slope_intercept(x1, y1, x2, y2)
						data.map_objects[aabb_id].properties.slope = { x1 = x1, y1 = y1, x2 = x2, y2 = y2, m = m, b = b }
					end
				end
			end
		end

		----------------------
		-- Prop objects
		----------------------
		if layer.name == "prop_collision" then
			for i = 1, #layer.objects do
				local object_data = layer.objects[i]

				local local_tile_id, hflip, vflip, rotation = tile_flip(object_data.gid) -- generic gid flip and rotate for tiles only

				local properties = utils.set_object_properties(object_data.properties)
				props.add(object_data, hflip, vflip, properties)
			end
		end

		--------------------------------------
		-- Entities (Player, enemies...)
		--------------------------------------
		if layer.name == "entities" then
			for i = 1, #layer.objects do
				local object_data = layer.objects[i]

				local local_tile_id, hflip, vflip, rotation = tile_flip(object_data.gid)

				if object_data.type == "ENEMY" then
					local properties = utils.set_object_properties(object_data.properties)
					enemies.add(object_data, hflip, vflip, properties)
				end

				-- Player init position
				if object_data.name == "PLAYER" then
					data.player.position = vmath.vector3(object_data.x + (object_data.width / 2), (data.map_height - object_data.y) - (object_data.height / 2), data.player.position.z)

					data.player.initial_position = data.player.position

					-- Checkpoints
					--data.check_checkpoint()
				end
			end
		end

		----------------------
		-- Move directions for idiot npcs
		----------------------
		if layer.name == "move_directions" then
			for i = 1, #layer.objects do
				local object_data = layer.objects[i]
				directions.add(object_data)
			end
		end

		-- loop end
	end
end

function map.final()
	go.delete(const.URLS.MAP_CONTANINER, true)
end

return map
