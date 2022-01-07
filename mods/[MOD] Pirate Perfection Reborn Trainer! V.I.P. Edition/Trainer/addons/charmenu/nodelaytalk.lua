-- Purpose: Allows you to speak without delay in both stealth and loud modes. Become the most annoying player on the server!
-- Author: Baldwin

plugins:new_plugin('nodelaytalk')

VERSION = '1.0'

local managers = managers
local M_groupAI = managers.groupai --Should be static
local backuper=backuper
local backup=backuper.backup
local restore=backuper.restore
local tweak_data=tweak_data
local tw_pl_movement_state = tweak_data.player.movement_state
local tw_upgrades = tweak_data.upgrades
local is_playing = is_playing
local query_execution_testfunc = query_execution_testfunc
local PlayerMovement = PlayerMovement
local AI_State --Here will be groupai:state()

local function catch_ai_state()
	if ( not AI_State ) then
		AI_State = M_groupAI:state()
	end
	return AI_State
end

local function main()
	backup(backuper, 'tweak_data.player.movement_state.interaction_delay')
	tw_pl_movement_state.interaction_delay = 0 --This is what removes delay between said lines

	backup(backuper, 'tweak_data.upgrades.morale_boost_base_cooldown')
	tw_upgrades.morale_boost_base_cooldown = 0 --GO GO GO GO GO GO GO GO GO GO GO GO GO GO GO GO!
	
	--[[local AI_State = M_groupAI:state()
	if AI_State then
		AI_State._whisper_mode = false --Shout during stealth
	end]]

	backup(backuper, 'PlayerMovement.rally_skill_data')
	function PlayerMovement.rally_skill_data() 
		return { range_sq = 1400*1400, --Increases "GO GO GO" buff max. range
			morale_boost_delay_t = 0,
			long_dis_revive = true, --Allows you to revive by shouting without having skill
			revive_chance = 1, --100% revive chance
			morale_boost_cooldown_t = 0, --This affects talk delay too
		}
	end
end

local function unload()
	restore(backuper, 'tweak_data.player.movement_state.interaction_delay')
	restore(backuper, 'tweak_data.upgrades.morale_boost_base_cooldown')
	restore(backuper, 'PlayerMovement.rally_skill_data')
end

function UNLOAD()
	unload()
end

function MAIN()
	if ( is_playing() ) then
		main()
	else
		query_execution_testfunc(is_playing, { f = main })
	end
end

FINALIZE()