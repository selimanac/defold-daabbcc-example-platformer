local player_state = require("scripts.game.player.player_state")

local rock_head = {}

function rock_head.enter(enemy, query_result)
	if (query_result.normal_y == 1 or query_result.normal_y == -1) and enemy.status == false then
		player_state.die()
	end
end

return rock_head
