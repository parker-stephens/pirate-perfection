-- God mode for sentry gun
-- Author: baldwin

plugins:new_plugin('invulnerable_sentry')

VERSION = '1.0'

function MAIN()
	local damage_bullet = backuper:backup('SentryGunDamage.damage_bullet')
	function SentryGunDamage:damage_bullet(attack_data)
		local turret_units = managers.groupai:state():turrets()
		if turret_units and table.contains(turret_units, self._unit) then
			return damage_bullet(self, attack_data)
		end
	end
end

function UNLOAD()
	backuper:restore('SentryGunDamage.damage_bullet')
end

FINALIZE()