-- Increase run speed
-- Author: Simplity

plugins:new_plugin('increase_speed')

local ppr_config = ppr_config
local T_speed = tweak_data.player.movement_state.standard.movement.speed

VERSION = '1.0'

CATEGORY = 'character'

function MAIN()
	backuper:backup('tweak_data.player.movement_state.standard.movement.speed.RUNNING_MAX')
	T_speed.RUNNING_MAX = (ppr_config.RunSpeed or 115) * 10
end

function UNLOAD()
	backuper:restore('tweak_data.player.movement_state.standard.movement.speed.RUNNING_MAX')
end

FINALIZE()