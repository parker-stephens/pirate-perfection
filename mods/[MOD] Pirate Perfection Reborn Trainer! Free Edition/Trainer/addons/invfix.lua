--Purpose: Prevents ctd, when someone changes weapon, that isn't loaded.

local managers = managers
local M_dyn_resource = managers.dyn_resource
local dyn_resource_load = M_dyn_resource.load
local Idstring = Idstring
local ids_unit = Idstring('unit')

local backuper = backuper
local hijack = backuper.hijack
local tweak_data = tweak_data
local T_W_factory = tweak_data.weapon.factory

hijack(backuper, 'PlayerInventory.add_unit_by_factory_name',function(o,self,name, ...)
	local factory_data = T_W_factory[name]
	local unit_name = factory_data and factory_data.unit
	if unit_name then
		dyn_resource_load(M_dyn_resource, ids_unit, unit_name:id(), "packages/dyn_resources", false)
		return o(self, name, ...)
	else
		return
	end
end)

hijack(backuper, 'PlayerInventory.add_unit_by_name',function(o,self,name, ...)
	dyn_resource_load(M_dyn_resource, ids_unit, name, "packages/dyn_resources", false)
	return o(self, name, ...)
end)

--Husk == Client side unit (not on server!)
hijack(backuper, 'HuskPlayerInventory.add_unit_by_name',function(o,self,name, ...)
	dyn_resource_load(M_dyn_resource, ids_unit, name, "packages/dyn_resources", false)
	return o(self, name, ...)
end)

hijack(backuper, 'HuskPlayerInventory.add_unit_by_factory_name',function(o,self,name, ...)
	local factory_data = T_W_factory[name]
	local unit_name = factory_data and factory_data.unit
	if unit_name then
		dyn_resource_load(M_dyn_resource, ids_unit, unit_name:id(), "packages/dyn_resources", false)
		return o(self, name, ...)
	end
end)

--For weapon list menu. Fixes crashes, when you attempt to use not fully loaded weapon.
secure_debug_class(PlayerStandard, void)