-- No hit distraction
-- Author: Simplity

plugins:new_plugin('no_hit')

local managers = managers
local M_env_controller = managers.environment_controller

VERSION = '1.0'

CATEGORY = 'character'

function MAIN()
	backuper:backup('managers.environment_controller._hit_amount')
	M_env_controller._hit_amount = 0
end

function UNLOAD()
	backuper:restore('managers.environment_controller._hit_amount')
end

FINALIZE()