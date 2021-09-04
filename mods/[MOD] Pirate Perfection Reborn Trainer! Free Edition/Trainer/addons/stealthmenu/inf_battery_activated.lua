-- Infinite battery in ecm
-- Author: Simplity

local backuper = backuper
local backup = backuper.backup
local restore = backuper.restore

local ECMJammerBase = ECMJammerBase

plugins:new_plugin('inf_battery_activated')

VERSION = '1.0'

function MAIN()
	backup(backuper, 'ECMJammerBase.update')
	
	function ECMJammerBase:update()
		self._battery_life = self._max_battery_life
	end
end

function UNLOAD()
	restore(backuper, 'ECMJammerBase.update')
end

FINALIZE()