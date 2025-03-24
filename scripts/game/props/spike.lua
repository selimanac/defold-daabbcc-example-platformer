local player_state = require("scripts.game.player.player_state")

local spike        = {}

function spike.enter(prop, query_result)
	player_state.die()
end

return spike
