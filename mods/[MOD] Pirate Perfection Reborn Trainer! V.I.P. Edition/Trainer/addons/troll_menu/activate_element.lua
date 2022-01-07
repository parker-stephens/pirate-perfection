-- Run element
-- Author: Simplity

local pairs = pairs
local pcall = pcall
local managers = managers
local M_network = managers.network
local math_random = math.random

local activate_element = function( unit, ext, name )
	local session = M_network:session()
	ext:run_sequence_simple( name ) 
	session:send_to_peers_synched( "run_mission_door_device_sequence", unit, name )
end

local World = World
local find_units_quick = World.find_units_quick
local run_element_with_chance = function( name, chance )
	for _,unit in pairs( find_units_quick(World, "all") ) do
		local damage = unit:damage()
		if damage and damage:has_sequence( name ) and math_random(1, chance) == 1 then
			activate_element( unit, damage, name )
		end
	end
end

return function( name, chance )
	if chance then
		run_element_with_chance( name, chance )
		return
	end
	
	for _,unit in pairs( find_units_quick(World, "all") ) do
		local damage = unit:damage()
		if damage and damage:has_sequence( name ) then
			pcall( activate_element, unit, damage, name ) --Sometimes unit have sequence, but still "protected" by engine.
		end
	end
end