-- Player receive 50% less damage
-- Author: Simplity

plugins:new_plugin('less_damage')

VERSION = '1.0'

local backuper = backuper
local restore = backuper.restore
local backup = backuper.backup

function MAIN()
	local _set_health = backup(backuper, "PlayerDamage.set_health")
	function PlayerDamage:set_health(health)
		local real_health = self:get_real_health()
		if health < real_health then
			local damage = real_health - health
			damage = damage - (damage * 0.5)
			
			health = real_health - damage
		end
		
		return _set_health(self, health)
	end
end

function UNLOAD()
	restore(backuper, "PlayerDamage.set_health")
end

FINALIZE()