if (not GameSetup) then
	return
end

local in_slowmo = false

local config = ppr_config
local managers = managers
local M_time_speed = managers.time_speed
local play_effect = M_time_speed.play_effect
local stop_effect = M_time_speed.stop_effect

local speed = config.SmSpeed / 100
local slow_player = config.SmSlowPlayer
local HUGE = math.huge

local desc_pausable_world = {
	speed = speed,
	fade_in = 0.05,
	sustain = HUGE,
	fade_out = 0.1,
	timer = "pausable",
	--sync = sync,
}

local desc_pausable_player = {
	speed = speed,
	fade_in = 0.05,
	sustain = HUGE,
	fade_out = 0.1,
	timer = "pausable",
	affect_timer = "player",
	--sync = sync,
}

local function ToggleSlowmo()
	if ( not in_slowmo ) then
		play_effect(M_time_speed, 'drunken_world', desc_pausable_world)
		
		if slow_player then
			play_effect(M_time_speed, 'drunken_player', desc_pausable_player)
		end
		in_slowmo = true
		show_mid_text("---- ON ----", "BULLET-TIME", 0.5 )
	else
		stop_effect(M_time_speed, 'drunken_world', 0.00000001)
		
		if slow_player then
			stop_effect(M_time_speed, 'drunken_player', 0.00000001)
		end
		in_slowmo = false
		show_mid_text("---- OFF ---", "BULLET-TIME", 0.5 )
	end
end

return ToggleSlowmo