local player_state = require("scripts.lib.player_state")

local spike        = {}

function spike.enter(prop, query_result)
	prop.status = true
	player_state.die()
end

return spike
