-- No limit how many modifications can be installed on weapon
-- Author: Simplity

plugins:new_plugin('no_weap_mod_limit')

VERSION = '1.0'

CATEGORY = 'main'

function MAIN()
	local backuper = backuper
	
	backuper:backup('BlackMarketManager.get_modify_weapon_consequence')
	function BlackMarketManager.get_modify_weapon_consequence()
		return {}, {}
	end

	backuper:backup('WeaponFactoryManager.change_part_blueprint_only')
	function WeaponFactoryManager:change_part_blueprint_only( factory_id, part_id, blueprint, remove_part )
		local factory = tweak_data.weapon.factory
		local part = factory.parts[ part_id ]
		if not part then
			return false
		end
		table.insert( blueprint, part_id )
		return true
	end
end

function UNLOAD()
	local backuper = backuper
	backuper:restore('BlackMarketManager.get_modify_weapon_consequence')
	backuper:restore('WeaponFactoryManager.change_part_blueprint_only')
end

FINALIZE()