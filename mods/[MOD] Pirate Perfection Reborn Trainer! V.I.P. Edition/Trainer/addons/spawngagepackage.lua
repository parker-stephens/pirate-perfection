--Purpose: function for spawning random gage package. ppr_require it somewhere, where SpawngagaPackage being called.

local ray_pos = ray_pos
local tweak_data = tweak_data
local T_gage_assignment = tweak_data.gage_assignment
local Idstring = Idstring
local Rotation = Rotation
local math_random = math.random
local World = World
local W_spawn_unit = World.spawn_unit

local id_table = {
	Idstring("units/pd2_dlc_gage_jobs/pickups/gen_pku_gage_green/gen_pku_gage_green"),
	Idstring("units/pd2_dlc_gage_jobs/pickups/gen_pku_gage_yellow/gen_pku_gage_yellow"),
	Idstring("units/pd2_dlc_gage_jobs/pickups/gen_pku_gage_red/gen_pku_gage_red"),
	Idstring("units/pd2_dlc_gage_jobs/pickups/gen_pku_gage_blue/gen_pku_gage_blue"),
	Idstring("units/pd2_dlc_gage_jobs/pickups/gen_pku_gage_purple/gen_pku_gage_purple"),
}

function T_gage_assignment:get_num_assignment_units() --Patches limit on spawning units. World:spawn_unit somehow obey this value.
	return 9999
end

return function(id) --Don't pass any argument for random package
	local pos,rot = ray_pos()
	if ( pos ) then
		W_spawn_unit(World, id_table[id or math_random(1,5)], pos, rot )
	end
end