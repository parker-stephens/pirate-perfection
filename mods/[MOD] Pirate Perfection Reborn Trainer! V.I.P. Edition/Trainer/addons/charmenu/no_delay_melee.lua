local backuper = backuper
local hijack = backuper.hijack
local restore = backuper.restore

plugins:new_plugin('no_delay_melee')

VERSION = '0.1'

FULL_NAME = 'No melee attack delay'

DESCRIPTION = 'Removes delay between melee attacks'

local hooked_check_action_melee = function( o, self, ... )
	local state_data = self._state_data
	--Removing delays, if we have them
	state_data.melee_expire_t = nil
	state_data.melee_repeat_expire_t = nil
	return o(self, ...)
end

function MAIN()
	hijack(backuper, 'PlayerStandard._check_action_melee',hooked_check_action_melee)
end

function UNLOAD()
	restore(backuper, 'PlayerStandard._check_action_melee')
end

FINALIZE()