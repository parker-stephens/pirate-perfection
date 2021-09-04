_G.XAudio = {}

-- Constants
XAudio.PLAYER = "xa_player_1"

-- Variables
XAudio._sources = {}
XAudio._next_source_id = 1
XAudio._base_gains = {
	sfx = 1,
	music = 1
}

BLT:Require("req/xaudio/XAudioBuffer")
BLT:Require("req/xaudio/XAudioSource")
BLT:Require("req/xaudio/XAudioUnitSource")

BLT:Require("req/xaudio/VoicelineManager")

-- This is our wu-to-meters conversion
-- You can get it using blt.xaudio.getworldscale() if you need to use it
-- This means we can use positions from the game without worrying about
--  unit conversion or anything.
blt.xaudio.setworldscale(100)

-- Delete any existing sources from the last heist/menu
blt.xaudio.reset()

local function update(t, dt, paused)
	XAudio._base_gains.music = managers.user:get_setting("music_volume") / 100
	XAudio._base_gains.sfx = managers.user:get_setting("sfx_volume") / 100

	for id, src in pairs(XAudio._sources) do
		src:update(t, dt, paused)
	end
end

Hooks:Add("MenuUpdate", "Base_XAudio_MenuSetupUpdate", function( t, dt )
	update(t, dt, false)
end)

Hooks:Add("GameSetupUpdate", "Base_XAudio_GameSetupUpdate", function( t, dt )
	update(t, dt, false)
end)

Hooks:Add("GameSetupPausedUpdate", "Base_XAudio_GameSetupPausedUpdate", function( t, dt )
	update(t, dt, true)
end)
