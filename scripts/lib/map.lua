local data                      = require("scripts.lib.data")
local const                     = require("scripts.lib.const")
local collision                 = require("scripts.lib.collision")
local props                     = require("scripts.lib.props")

local map                       = {}

-- Tiled flip
local FLIPPED_HORIZONTALLY_FLAG = 0x80000000
local FLIPPED_VERTICALLY_FLAG   = 0x40000000
local FLIPPED_DIAGONALLY_FLAG   = 0x20000000

-- generic gid flip and rotate fot tiles only
function tile_flip(global_tile_id)
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
				local local_tile_id, hflip, vflip, rotation = tile_flip(object_data.gid) -- generic gid flip and rotate for tiles only
				props.add(object_data, hflip, vflip)
			end
		end

		-- Entities
		if layer.name == "entities" then
			for i = 1, #layer.objects do
				local object_data = layer.objects[i]

				-- Player init position
				if object_data.name == "PLAYER" then
					local player_z = 0.9

					data.player.position = vmath.vector3(object_data.x + (object_data.width / 2), (data.map_height - object_data.y) - (object_data.height / 2), player_z)

					if data.last_checkpoint > 0 then
						data.player.position = vmath.vector3()
						local checkpoint = data.checkpoints[data.last_checkpoint]
						data.player.position = vmath.vector3(checkpoint.x, checkpoint.y, player_z)
						data.player.position.z = player_z
						data.player.position.y = data.player.position.y - (object_data.height / 2)
						data.player.position.x = data.player.position.x + 10

						for _, checkpoint in pairs(data.checkpoints) do
							if checkpoint.active then
								local checkpoint_prop = data.props[checkpoint.aabb_id]
								checkpoint_prop.fn(checkpoint_prop)
							end
						end
					end
				end
			end
		end

		-- loop end
	end
end

function map.final()
	go.delete(const.URLS.MAP_CONTANINER, true)
end

return map
