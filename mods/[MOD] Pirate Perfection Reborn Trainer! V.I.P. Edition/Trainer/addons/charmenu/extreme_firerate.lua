--Purpose: Toggle crazy firerate.
--Author: baldwin

plugins:new_plugin('extreme_firerate')

local NewRaycastWeaponBase = NewRaycastWeaponBase

VERSION = '1.0'

CATEGORY = 'character'

local backuper = backuper
local backup = backuper.backup
local restore = backuper.restore

function MAIN()
	backup(backuper, 'NewRaycastWeaponBase.trigger_held')
	function NewRaycastWeaponBase:trigger_held( ... )
		return self:fire( ... )
	end

	backup(backuper, 'NewRaycastWeaponBase.fire_mode')
	function NewRaycastWeaponBase.fire_mode() --Crazy as hell shooting.
		return 'auto'
	end
end

function UNLOAD()
	restore(backuper, 'NewRaycastWeaponBase.trigger_held')
	restore(backuper, 'NewRaycastWeaponBase.fire_mode')
end

FINALIZE()