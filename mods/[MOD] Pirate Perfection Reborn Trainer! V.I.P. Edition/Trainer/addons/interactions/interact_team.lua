--Purpose: instant interaction for team
--Note: premiums release only!

plugins:new_plugin('interact_team')

VERSION = '1.0'

CATEGORY = 'interaction'

local M_interaction = managers.interaction
local backuper = backuper
local backup = backuper.backup

function MAIN()
	local interactive_objects = M_interaction._interactive_units
	local session = managers.network:session()

	for _,unit in pairs( interactive_objects ) do
		local interaction = unit:interaction()
		local contour = unit:contour()
		if interaction then
			interaction.__tweak_data = interaction.tweak_data
			interaction:set_tweak_data( "money_wrap_single_bundle" )
			session:send_to_peers_synched( "interaction_set_active", unit, unit:id(), interaction:active(), "money_wrap_single_bundle", contour and contour:is_flashing() or false )
		end
	end
	
	local add_unit = backup(backuper, 'ObjectInteractionManager.add_unit')
	function ObjectInteractionManager:add_unit( obj )
		local result = add_unit(self, obj)
		
		local interaction = obj:interaction()
		local contour = obj:contour()
		if interaction then
			interaction.__tweak_data = interaction.tweak_data
			interaction:set_tweak_data( "money_wrap_single_bundle" )
			session:send_to_peers_synched( "interaction_set_active", obj, obj:id(), interaction:active(), "money_wrap_single_bundle", contour and contour:is_flashing() or false )
		end
		
		return result
	end
end

function UNLOAD()
	local interactive_objects = M_interaction._interactive_units
	local session = managers.network:session()

	for _,unit in pairs( interactive_objects ) do
		local interaction = unit:interaction()
		local contour = unit:contour()
		if interaction and interaction.__tweak_data then
			interaction:set_tweak_data( interaction.__tweak_data )
			session:send_to_peers_synched( "interaction_set_active", unit, unit:id(), interaction:active(), interaction.__tweak_data, contour and contour:is_flashing() or false )
		end
	end
end

FINALIZE()