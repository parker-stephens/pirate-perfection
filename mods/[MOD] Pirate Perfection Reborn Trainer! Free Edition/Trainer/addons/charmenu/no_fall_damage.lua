-- No fall damage
-- Author:

plugins:new_plugin('no_fall_damage')

VERSION = '1.0'

CATEGORY = 'character'

function MAIN()
	backuper:backup("PlayerDamage.damage_fall")
	function PlayerDamage.damage_fall() end
end

function UNLOAD()
	backuper:restore("PlayerDamage.damage_fall")
end

FINALIZE()