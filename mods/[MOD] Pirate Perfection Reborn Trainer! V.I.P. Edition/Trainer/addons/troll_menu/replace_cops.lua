-- Replace all cops with bulldozers
-- Author: Simplity

--TO DO: Rework, tends to glitch
plugins:new_plugin('replace_cops')

local pairs = pairs
local Idstring = Idstring

local managers = managers
local M_enemy = managers.enemy
local World = World
local W_spawn_unit = World.spawn_unit
local M_groupAI = managers.groupai
local T_levels = tweak_data.levels
local team_id = T_levels:get_default_team_ID("combatant")
local team_data = M_groupAI:state():team_data( team_id )

local unit_name = "units/payday2/characters/ene_bulldozer_3/ene_bulldozer_3"

local function replace_new_cops()
	local produce = backuper:backup('ElementSpawnEnemyDummy.produce')
	
	function ElementSpawnEnemyDummy:produce( params )
		self._enemy_name = unit_name
		if params then
			params.name = unit_name
		end
		return produce( self, params )
	end
end

local function unspawn_unit( unit )
	unit:brain():set_active( false )
	unit:base():set_slot( unit, 0 )
end

local function replace_spawned_cops()	
	local unit_id = Idstring( unit_name )
	for _, data in pairs( M_enemy:all_enemies() ) do
		local unit = data.unit
		
		if unit:name() ~= unit_id then
			unspawn_unit( unit )
			local new_unit = W_spawn_unit(World, unit_id, unit:position(), unit:rotation() )
			new_unit:brain():set_spawn_ai( unit:brain()._spawn_ai )
			new_unit:movement():set_team( team_data )
		end
	end
end

VERSION = '1.0'

function MAIN()
	replace_new_cops()
	replace_spawned_cops()
end

function UNLOAD()
	backuper:restore('ElementSpawnEnemyDummy.produce')
end

FINALIZE()