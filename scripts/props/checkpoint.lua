local audio      = require("scripts.lib.audio")
local data       = require("scripts.lib.data")
local const      = require("scripts.lib.const")

local checkpoint = {}

function checkpoint.enter(prop, query_result)
	if prop.status == false then
		prop.status = true

		local checkpoint_item = data.checkpoints[prop.data.checkpoint_id]
		audio.play(const.AUDIO.CHECKPOINT)

		sprite.play_flipbook(prop.sprite, prop.anims.on, function()
			sprite.play_flipbook(prop.sprite, prop.anims.on_idle)
		end)

		if checkpoint_item.active == false then
			checkpoint_item.active = true
			data.last_checkpoint = prop.data.checkpoint_id
		end
	end
end

function checkpoint.add(prop, object_data)
	local checkpoint = {
		position = prop.position,
		x = prop.position.x,
		y = prop.position.y,
		active = false,
		aabb_id = prop.aabb_id,
		id = prop.id
	}

	if data.last_checkpoint == 0 then
		data.checkpoints[object_data.id] = checkpoint
	end

	prop.data = {
		checkpoint_id = object_data.id
	}
end

function checkpoint.reset()
	data.checkpoints     = {}
	data.last_checkpoint = 0
end

function checkpoint.check()
	data.player.position = data.player.initial_position
	if data.last_checkpoint > 0 then
		local checkpoint = data.checkpoints[data.last_checkpoint]

		data.player.position = vmath.vector3(checkpoint.x, checkpoint.y, data.player.position.z)
		data.player.position.x = data.player.position.x + 10
		data.player.position.y = data.player.position.y - const.PLAYER.HALF_SIZE.h

		for _, checkpoint in pairs(data.checkpoints) do
			if checkpoint.active then
				local checkpoint_prop = data.props[checkpoint.aabb_id]
				checkpoint_prop.fn(checkpoint_prop)
			end
		end
	end
end

return checkpoint
