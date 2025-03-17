local audio       = require("scripts.lib.audio")
local collision   = require("scripts.lib.collision")
local data        = require("scripts.lib.data")
local const       = require("scripts.lib.const")

local collectable = {}

function collectable.enter(prop, query_result)
	if prop.status == false then
		audio.play(const.AUDIO.COLLECT)
		prop.status = true
		collision.remove(prop.aabb_id)
		sprite.play_flipbook(prop.sprite, prop.anims.on, function()
			go.delete(prop.id)
		end)

		data.props[prop.aabb_id] = nil
	end
end

return collectable
