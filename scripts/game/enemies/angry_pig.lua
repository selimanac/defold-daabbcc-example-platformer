local audio        = require("scripts.lib.audio")
local collision    = require("scripts.lib.collision")
local data         = require("scripts.lib.data")
local const        = require("scripts.lib.const")
local player_state = require("scripts.game.player.player_state")

local angry_pig    = {}

function angry_pig.enter(enemy, query_result)
	if query_result.normal_y == 1 and enemy.status == false then
		enemy.status = true
		enemy.state.is_moving = false

		data.player.state.on_ground = false
		data.player.velocity.y = const.PLAYER.WALL_JUMP_FORCE

		player_state.jump(0)

		audio.play(const.AUDIO.SQUEEZE)

		collision.remove(enemy.aabb_id)

		sprite.play_flipbook(enemy.sprite, enemy.anims.hit, function()
			go.delete(enemy.id)
		end)

		data.enemies[enemy.aabb_id] = nil
	elseif enemy.status == false and enemy.is_killer then
		player_state.die()
	end
end

return angry_pig
