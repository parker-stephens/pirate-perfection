--Fixes problems, related to weapon preloading.
--Author: ThisJazzman
backuper:backup('NewRaycastWeaponBase.set_timer')
local alive = alive
local pairs = pairs
local NewRaycastWeaponBase = NewRaycastWeaponBase
local super_set_timer = NewRaycastWeaponBase.super.set_timer
NewRaycastWeaponBase.set_timer = function( self, ... )
	if ( alive(self._unit) ) then --Check if we have unit
		super_set_timer( self, ... )
		for _,data in pairs( self._parts ) do
			local unit = data.unit
			if ( alive(unit) ) then --Check if part's data have unit
				unit:set_timer( ... )
				unit:set_animation_timer( ... )
			end
		end
	end
end