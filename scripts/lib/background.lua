local data       = require("scripts.lib.data")
local const      = require("scripts.lib.const")

local background = {}

function background.init()
	-- Scale quad to map size
	go.set_scale(vmath.vector3(data.map_width, data.map_height, 1), const.URLS.BACKGROUND)

	-- Tiles are 64x64
	local u_repeat = vmath.vector4(data.map_width / 64, data.map_height / 64, 0, 0)

	-- Set random background tile
	go.set(const.URLS.BACKGROUND_MODEL, "texture0", data.backgrounds[rnd.range(1, 7)])
	go.set(const.URLS.BACKGROUND_MODEL, "u_repeat", u_repeat)

	-- Center the tilemap
	go.set_position(vmath.vector3(data.map_width / 2, data.map_height / 2, 0), const.URLS.BACKGROUND)
end

return background
