-- Increase walk speed
-- Author: Simplity

plugins:new_plugin('increase_standard_speed')

local T_speed = tweak_data.player.movement_state.standard.movement.speed

VERSION = '1.0'

CATEGORY = 'character'

function MAIN()
	backuper:backup('tweak_data.player.movement_state.standard.movement.speed.STANDARD_MAX')
	T_speed.STANDARD_MAX = 1150
end

function UNLOAD()
	backuper:restore('tweak_data.player.movement_state.standard.movement.speed.STANDARD_MAX')
end

FINALIZE()