-- Buddha mode
-- Author: Simplity

plugins:new_plugin('buddha_mode')

VERSION = '1.0'

local backuper = backuper
local restore = backuper.restore
local backup = backuper.backup

function MAIN()
	local _set_health = backup(backuper, "PlayerDamage.set_health")
	function PlayerDamage:set_health(health)
		if health <= 1 then
			health = 1
		end
		return _set_health(self, health)
	end
end

function UNLOAD()
	restore(backuper, "PlayerDamage.set_health")
end

FINALIZE()