local const = require("scripts.lib.const")

local audio = {}


function audio.play(fx, delay, gain)
	delay = delay and delay or nil
	gain = gain and gain or nil
	sound.play(fx, { delay = delay, gain = gain })
end

function audio.stop(fx)
	sound.stop(fx)
end

return audio
