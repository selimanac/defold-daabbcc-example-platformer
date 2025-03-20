local audio        = require("scripts.lib.audio")
local collision    = require("scripts.lib.collision")
local data         = require("scripts.lib.data")
local const        = require("scripts.lib.const")
local player_state = require("scripts.lib.player_state")
local particles    = require("scripts.lib.particles")
local camera_fx    = require("scripts.lib.camera_fx")

local box          = {}

function box.enter(prop, query_result)
	if (query_result.normal_y == -1 or query_result.normal_y == 1) and prop.status == false then
		prop.status = true

		collision.remove(prop.aabb_id)

		if query_result.normal_y == 1 then
			data.player.state.on_ground = false
			data.player.velocity.y = const.PLAYER.WALL_JUMP_FORCE
			player_state.jump(0)
		elseif query_result.normal_y == -1 then
			data.player.velocity.y = 0
			data.player.gravity_down = const.PLAYER.GRAVITY_DOWN
			player_state.fall()
		end

		camera_fx.shake(2, 4)

		audio.play(const.AUDIO.BOX_CRACK)

		go.animate(prop.id, "position.y", go.PLAYBACK_ONCE_FORWARD, prop.position.y - (20 * query_result.normal_y), go.EASING_LINEAR, 0.2)

		sprite.play_flipbook(prop.sprite, prop.anims.on, function()
			go.delete(prop.id)
			local part_ids = collectionfactory.create(prop.data.break_factory, prop.position)
			particles.spawn(part_ids, prop.data.part_count)
		end)

		data.props[prop.aabb_id] = nil
	end
end

return box
