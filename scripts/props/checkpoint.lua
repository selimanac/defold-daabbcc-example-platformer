local audio      = require("scripts.lib.audio")
local collision  = require("scripts.lib.collision")
local data       = require("scripts.lib.data")
local const      = require("scripts.lib.const")

local checkpoint = {}

function checkpoint.enter(prop, query_result)
	if prop.status == false then
		prop.status = true

		local checkpoint_item = data.checkpoints[prop.data.checkpoint_id]
		audio.play(const.AUDIO.CHECKPOINT)
		collision.remove(prop.aabb_id)
		sprite.play_flipbook(prop.sprite, prop.anims.on, function()
			sprite.play_flipbook(prop.sprite, prop.anims.on_idle)
		end)

		if checkpoint_item.active == false then
			checkpoint_item.active = true
			data.last_checkpoint = prop.data.checkpoint_id
		end
	end
end

return checkpoint
