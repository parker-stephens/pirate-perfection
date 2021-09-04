-- Increase melee damage
-- Author: baldwin, original: ???

plugins:new_plugin('increase_melee_dmg')

VERSION = '1.0'

CATEGORY = 'character'

function MAIN()
	local backuper = backuper
	local backup = backuper.backup
	
	local damage_melee_original = backup(backuper, 'CopDamage.damage_melee')
	function CopDamage:damage_melee( attack_data, ... )
		attack_data.damage = attack_data.damage * 5000
		return damage_melee_original( self, attack_data, ... )
	end

	backup(backuper, 'TankCopDamage.damage_melee') --Bulldozers can be meleed by anything now
	local super_damage_melee = TankCopDamage.super.damage_melee
	function TankCopDamage.damage_melee( ... )
		return super_damage_melee( ... )
	end

	backup(backuper, 'HuskTankCopDamage.damage_melee')
	local super_damage_melee = HuskTankCopDamage.super.damage_melee
	function HuskTankCopDamage.damage_melee( ... )
		return super_damage_melee( ... )
	end
end

function UNLOAD()
	local backuper = backuper
	local restore = backuper.restore
	restore(backuper, 'CopDamage.damage_melee')
	restore(backuper, 'TankCopDamage.damage_melee')
	restore(backuper, 'HuskTankCopDamage.damage_melee')
end

FINALIZE()