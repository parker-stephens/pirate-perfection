-- Purpose:  Stops Medics from healing anyone you kill
-- Author:  The Joker

plugins:new_plugin('pointless_medics')

VERSION = '1.0'

local backuper = backuper

function MAIN()
	backuper:backup('MedicDamage.heal_unit')
	function MedicDamage:heal_unit() return false end
end

function UNLOAD()
	backuper:restore('MedicDamage.heal_unit')
end

FINALIZE()