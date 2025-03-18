local const = require("scripts.lib.const")
local data = require("scripts.lib.data")

local audio = {}

function audio.play(fx, delay, gain)
	if not data.game.is_sound_fx then
		return
	end
	delay = delay and delay or nil
	gain = gain and gain or nil
	sound.play(fx, { delay = delay, gain = gain })
end

function audio.stop(fx)
	sound.stop(fx)
end

function audio.play_music()
	if not data.game.is_music then
		return
	end
	if data.game.is_music_playing == false then
		data.game.is_music_playing = true
		sound.play(const.AUDIO.MUSIC)
	end
end

function audio.stop_music()
	if data.game.is_music_playing then
		data.game.is_music_playing = false
		sound.stop(const.AUDIO.MUSIC)
	end
end

return audio
