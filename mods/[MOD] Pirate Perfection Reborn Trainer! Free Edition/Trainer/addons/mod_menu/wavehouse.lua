local M_player = managers.player
local player = M_player:player_unit()
local random = math.random
local World = World
local W_spawn_unit = World.spawn_unit
local Rotation = Rotation
local M_groupAI = managers.groupai
local pairs = pairs
local M_enemies = managers.enemy

local AIState = M_groupAI:state()
local team_data = AIState:team_data("law1")

local wave_timer = 20
local units_amount = 10
local spawn_enemy, get_unit_name, cops_left, update

plugins:new_plugin('wavehouse')

CATEGORY = 'mods'

VERSION = '1.0'

local units = {
	{"units/payday2/characters/ene_cop_1/ene_cop_1", 12},
	{"units/payday2/characters/ene_cop_2/ene_cop_2", 12},
	{"units/payday2/characters/ene_cop_3/ene_cop_3", 12},
	{"units/payday2/characters/ene_cop_4/ene_cop_4", 12},
	{"units/payday2/characters/ene_fbi_1/ene_fbi_1", 10},
	{"units/payday2/characters/ene_fbi_2/ene_fbi_2", 10},
	{"units/payday2/characters/ene_fbi_3/ene_fbi_3", 10},
	{"units/payday2/characters/ene_fbi_heavy_1/ene_fbi_heavy_1", 8},
	{"units/payday2/characters/ene_fbi_swat_1/ene_fbi_swat_1", 8},
	{"units/payday2/characters/ene_fbi_swat_2/ene_fbi_swat_2", 8},
	{"units/payday2/characters/ene_shield_1/ene_shield_1", 5},
	{"units/payday2/characters/ene_sniper_1/ene_sniper_1", 8},
	{"units/payday2/characters/ene_bulldozer_1/ene_bulldozer_1", 3},
	{"units/payday2/characters/ene_city_swat_1/ene_city_swat_1", 8},
	{"units/payday2/characters/ene_city_swat_2/ene_city_swat_2", 8},
	{"units/payday2/characters/ene_city_swat_3/ene_city_swat_3", 8},
	{"units/payday2/characters/ene_shield_2/ene_shield_2", 5},
	{"units/payday2/characters/ene_sniper_2/ene_sniper_2", 7},
	{"units/payday2/characters/ene_spook_1/ene_spook_1", 3},
	{"units/payday2/characters/ene_swat_1/ene_swat_1", 5},
	{"units/payday2/characters/ene_swat_2/ene_swat_2", 5},
	{"units/payday2/characters/ene_swat_heavy_1/ene_swat_heavy_1", 5},
	{"units/payday2/characters/ene_tazer_1/ene_tazer_1", 5},
	{"units/payday2/characters/ene_bulldozer_2/ene_bulldozer_2", 2},
	{"units/payday2/characters/ene_bulldozer_3/ene_bulldozer_3", 1},
	{"units/pd2_dlc_vip/characters/ene_phalanx_1/ene_phalanx_1", 1}
}

local poses = { 
	Vector3(-3021.05, 5728.87, -18.8991), Vector3(-1445.11, 3457, 1.10002), Vector3(-4409, 4110.26, 1.10003), Vector3(-4506.25, 1182.61, 1.10003), Vector3(-1232, 4412, -397),
	Vector3(94, 3912, -397), Vector3(-2267, 4232, -397)
}

local Timer = TimerManager:main()
update = function()
	local dt = Timer:delta_time()
	
	wave_timer = wave_timer - dt
	
	if wave_timer < 0 then
		wave_timer = 20
		local cops_amount = cops_left()
				
		if cops_amount < 2 then
			spawn_enemy()
			
			if units_amount <= 50 then
				units_amount = units_amount + 3
			end
		end
	end
end

cops_left = function()
	local i = 0
	local all_enemies = M_enemies:all_enemies()
	for u_key, u_data in pairs( all_enemies ) do
		i = i + 1
	end
	
	return i
end

spawn_enemy = function()
	for i = 1, units_amount do
		local position = poses[ random(#poses) ]
		local unit_name = get_unit_name()
		
		local unit = W_spawn_unit( World, Idstring(unit_name), position, Rotation(0,0,0) )
		unit:movement():set_team( team_data )
		
		local brain = unit:brain()
		local objective = {
			type = "follow",
			follow_unit = player,
			scan = true,
			is_default = true
		}
		
		brain:set_spawn_ai( { init_state = "idle" } )
		brain:set_objective( objective )
	end
end

get_unit_name = function()
	local weights_summ = 0
	for _, data in pairs( units ) do
		weights_summ = weights_summ + data[2]
	end
	
	local num = random( 1, weights_summ )
	
	local n = 0
	for _, data in pairs( units ) do
		n = n + data[2]
		
		if n >= num then
			return data[1]
		end
	end
end

function MAIN()
	ppr_require 'Trainer/addons/no_invisible_walls'
	RunNewLoopIdent('safehouse_update', update)
end

function UNLOAD()
	StopLoopIdent('safehouse_update')
end

FINALIZE()