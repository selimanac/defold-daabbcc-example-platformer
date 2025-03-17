local const = require("scripts.lib.const")
local data = require("scripts.lib.data")

local audio = {}

function audio.play(fx, delay, gain)
	delay = delay and delay or nil
	gain = gain and gain or nil
	sound.play(fx, { delay = delay, gain = gain })
end

function audio.stop(fx)
	sound.stop(fx)
end

function audio.play_music()
	if data.game.is_music == false then
		data.game.is_music = true
		sound.play(const.AUDIO.MUSIC)
	end
end

function audio.stop_music()
	if data.game.is_music then
		data.game.is_music = false
		sound.stop(const.AUDIO.MUSIC)
	end
end

return audio
