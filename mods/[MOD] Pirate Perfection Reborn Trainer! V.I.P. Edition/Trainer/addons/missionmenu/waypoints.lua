--Purpose: Adds waypoint to every interactable object
--Author: Simplity

plugins:new_plugin('waypoints')

local pairs = pairs
local tostring = tostring
local in_table = in_table
local insert = table.insert
local lines = ppr_io.lines

local tweak_data = tweak_data
local TD_interaction = tweak_data.interaction
local TD_E_Specials = tweak_data.equipments.specials

local managers = managers
local M_hud = managers.hud
local M_interaction = managers.interaction

local waypoint_items = {}
local file_name = "Trainer/configs/waypoints/waypoints_config.lua"

local replace_items = {
	['pickup_keycard'] = "equipment_bank_manager_key",
}

local function add_waypoint( unit )
	
	local tweak = unit:interaction().tweak_data
	local icon = replace_items[tweak] or TD_interaction[tweak].icon
	
	if not icon then
		local interaction_tweak = TD_interaction[tweak]
		local special_equipment = interaction_tweak.special_equipment or interaction_tweak.special_equipment_block
		local special_tweak = TD_E_Specials[ special_equipment ]
		icon = special_tweak and special_tweak.icon
	end	
	
	if in_table( waypoint_items, tweak ) then
		M_hud:add_waypoint( tostring( unit:key() ), { icon = icon or 'wp_standard', distance = true, position = unit:position(), no_sync = true, present_timer = 0, state = "present", radius = 500, color = Color.VIP, blend_mode = "add" }  )
	end
end

local function clear_waypoint( obj )
	M_hud:remove_waypoint( tostring( obj:key() ) )
end

VERSION = '1.2'

function MAIN()
	local backuper = backuper
	local backup = backuper.backup
	local ObjectInteractionManager = ObjectInteractionManager
	
	--Load saved waypoints
	waypoint_items = {}
	for line in lines( file_name ) do
		insert( waypoint_items, line )
	end

	for id, unit in pairs( M_interaction._interactive_units ) do
		add_waypoint(unit)
	end
	
	local remove_unit = backup(backuper, 'ObjectInteractionManager.remove_unit')
	function ObjectInteractionManager:remove_unit( obj )
		local result = remove_unit(self, obj)
		if obj:interaction().tweak_data ~= "corpse_dispose" then
			clear_waypoint( obj )
		end
		return result
	end

	local add_unit = backup(backuper, 'ObjectInteractionManager.add_unit')
	function ObjectInteractionManager:add_unit( obj )
		local result = add_unit(self, obj)
		if obj:interaction().tweak_data ~= "corpse_dispose" then
			add_waypoint( obj )
		end
		return result
	end
end

function UNLOAD()
	local backuper = backuper
	local restore = backuper.restore
	for id, unit in pairs( M_interaction._interactive_units ) do
		clear_waypoint( unit )
	end
	restore(backuper, 'ObjectInteractionManager.remove_unit')
	restore(backuper, 'ObjectInteractionManager.add_unit')
end

FINALIZE()