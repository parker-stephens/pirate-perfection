-- Non consumable equipments
-- Author: baldwin

plugins:new_plugin('non_consumable_equipments')

VERSION = '1.0'

function MAIN()
	local void = void
	local backuper = backuper
	local hijack = backuper.hijack
	local backup = backuper.backup
	hijack(backuper, 'GrenadeCrateBase.take_grenade',function(o,self,unit,...) -- Infinite take grenade crate
		local r = o(self,unit,...)
		self._grenade_amount = self._grenade_amount + r
		return r
	end)
	backup(backuper, 'GrenadeCrateBase.sync_grenade_taken')
	GrenadeCrateBase.sync_grenade_taken = void


	hijack(backuper, 'BodyBagsBagBase.take_bodybag',function(o,self,unit,...) -- Infinite take body bags
		local r = o(self,unit,...)
		self._bodybag_amount = self._bodybag_amount + r
		return r
	end)
	backup(backuper, 'BodyBagsBagBase.sync_bodybag_taken')
	BodyBagsBagBase.sync_bodybag_taken = void


	hijack(backuper, 'AmmoBagBase._take_ammo', function(o,self, unit, ... ) -- Infinite take ammo bags
		local r = o(self, unit, ...)
		self._ammo_amount = self._ammo_amount + r
		return r
	end)
	backup(backuper, 'AmmoBagBase.sync_ammo_taken')
	AmmoBagBase.sync_ammo_taken = void

	hijack(backuper, 'DoctorBagBase._take',function(o, self, unit, ... ) -- Infinite take doctor bags
		local r = o(self, unit, ... )
		self._amount = self._amount + r
		return r
	end)
	backup(backuper, 'DoctorBagBase.sync_taken')
	DoctorBagBase.sync_taken = void
end

function UNLOAD()
	local backuper = backuper
	local restore = backuper.restore
	restore(backuper, 'GrenadeCrateBase.take_grenade')
	restore(backuper, 'GrenadeCrateBase.sync_grenade_taken')
	restore(backuper, 'BodyBagsBagBase.take_bodybag')
	restore(backuper, 'BodyBagsBagBase.sync_bodybag_taken')
	restore(backuper, 'AmmoBagBase._take_ammo')
	restore(backuper, 'AmmoBagBase.no_consume')
	restore(backuper, 'DoctorBagBase._take')
	restore(backuper, 'DectorBagBase.sync_taken')
end

FINALIZE()