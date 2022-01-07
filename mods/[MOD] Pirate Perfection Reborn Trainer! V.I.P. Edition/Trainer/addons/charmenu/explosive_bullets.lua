--Toggle explosive/normal bullets by baldwin
--Purpose: Toggles ammunition type from normal to explosive and backwards.
--Also improved it a bit.

plugins:new_plugin('explosive_bullets')

local InstantExplosiveBulletBase = InstantExplosiveBulletBase

VERSION = '1.0'

CATEGORY = 'character'

local backuper = backuper
local restore = backuper.restore
local hijack = backuper.hijack

function MAIN()
	hijack(backuper, "NewRaycastWeaponBase._fire_raycast",function( o, self, ... )
		local old_class = self._bullet_class
		self._bullet_class = InstantExplosiveBulletBase
		local r = o( self, ...)
		self._bullet_class = old_class
		return r
	end)

	hijack(backuper, "NewShotgunBase._fire_raycast",function( o, self, ... )
		local old_class = self._bullet_class
		self._bullet_class = InstantExplosiveBulletBase
		local r = o( self, ...)
		self._bullet_class = old_class
		return r
	end)

	hijack(backuper, "ShotgunBase._fire_raycast",function( o, self, ... )
		local old_class = self._bullet_class
		self._bullet_class = InstantExplosiveBulletBase
		local r = o( self, ...)
		self._bullet_class = old_class
		return r
	end)
end

function UNLOAD()
	restore(backuper, "NewRaycastWeaponBase._fire_raycast")
	restore(backuper, "NewShotgunBase._fire_raycast")
	restore(backuper, "ShotgunBase._fire_raycast")
end

FINALIZE()