-- Dead cops turn to bulldozers
-- Author: Simplity

plugins:new_plugin('cops_to_bulld')

VERSION = '1.0'

local World = World
local W_spawn_unit = World.spawn_unit
local M_groupAI = managers.groupai
local T_levels = tweak_data.levels
local team_id = T_levels:get_default_team_ID("combatant")
local team_data = M_groupAI:state():team_data( team_id )

local buld_id = Idstring( "units/payday2/characters/ene_bulldozer_2/ene_bulldozer_2" )

function MAIN()
	
	local die = backuper:backup('CopDamage.die')
	function CopDamage:die( ... )
		local sunit = self._unit
		if not sunit:base().bulldozer then
			local unit = W_spawn_unit( World, buld_id, sunit:position(), sunit:rotation() )
			unit:base().bulldozer = true
			unit:brain():set_spawn_ai( { init_state = "idle" } )		
			unit:movement():set_team( team_data )
		end
		return die( self, ... )
	end
end

function UNLOAD()
	backuper:restore('CopDamage.die')
end

FINALIZE()