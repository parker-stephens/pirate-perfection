-- Kill enemies faster
-- Author: Simplity

plugins:new_plugin('kill_in_one_hit')

local HUGE = math.huge

VERSION = '1.0'

CATEGORY = 'character'

local backuper = backuper
local restore = backuper.restore
local backup = backuper.backup

function MAIN()
	backup(backuper, "RaycastWeaponBase._get_current_damage")
	function RaycastWeaponBase._get_current_damage()
		return HUGE
	end
end

function UNLOAD()
	restore(backuper, "RaycastWeaponBase._get_current_damage")
end

FINALIZE()