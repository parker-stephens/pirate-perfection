--Purchase all preplanning by baldwin.
--Require: infinite and free preplaning elements (or else money will be greatly drained)
--Purpose: purchases all preplanning elements once script activated. Also it randomises equipments being placed in preplaning.

local managers = managers
local M_preplanning = managers.preplanning

if M_preplanning then
	local pairs = pairs
	local contains = table.contains
	local random = math.random
	local equipments = { 
		'bodybags_bag',
		'grenade_crate',
		'ammo_bag',
		'health_bag',
	}
	local reserve_mission_element = M_preplanning.reserve_mission_element
	for type,array in pairs(M_preplanning._mission_elements_by_type) do
		for _,element in pairs(array) do
			if contains(equipments, type) then
				type = equipments[random(2, #equipments)] --Instead of placing bodybags, we will place random equipment.
			end
			reserve_mission_element(M_preplanning, type, element:id())
		end
	end
end