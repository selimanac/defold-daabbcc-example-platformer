local audio       = require("scripts.lib.audio")
local collision   = require("scripts.lib.collision")
local data        = require("scripts.lib.data")
local const       = require("scripts.lib.const")

local collectable = {}

function collectable.enter(prop, query_result)
	if prop.status == false then
		prop.status = true

		audio.play(const.AUDIO.COLLECT)

		collision.remove(prop.aabb_id)

		data.player.collected_apples = data.player.collected_apples + 1

		msg.post(const.URLS.GUI, const.MSG.COLLECT)

		sprite.play_flipbook(prop.sprite, prop.anims.on, function()
			go.delete(prop.id)
		end)

		data.props[prop.aabb_id] = nil
	end
end

return collectable
