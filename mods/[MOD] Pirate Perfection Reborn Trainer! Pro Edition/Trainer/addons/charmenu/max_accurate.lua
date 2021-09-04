-- No spread
-- Author: baldwin

plugins:new_plugin('max_accurate')

VERSION = '1.0'

CATEGORY = 'character'

function MAIN()
	backuper:backup('NewRaycastWeaponBase._get_spread_from_number')
	function NewRaycastWeaponBase._get_spread_from_number() return 0 end
end

function UNLOAD()
	backuper:restore('NewRaycastWeaponBase._get_spread_from_number')
end

FINALIZE()