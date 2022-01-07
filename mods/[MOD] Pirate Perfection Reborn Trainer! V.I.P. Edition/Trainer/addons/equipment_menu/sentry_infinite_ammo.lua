-- Infinite ammo for sentry
-- Author: baldwin

plugins:new_plugin('sentry_infinite_ammo')

VERSION = '1.0'

function MAIN()
	backuper:hijack('SentryGunWeapon.fire',function( o, self, blanks, expend_ammo, ... )
		return o(self, blanks, false, ...)
	end)
end

function UNLOAD()
	backuper:restore('SentryGunWeapon.fire')
end

FINALIZE()