--Purpose: allows user to edit waypoints filters
--Author: Simplity
--BUG & TO DO: Game configs and waypoint configs in same folder. Not good. Will be great to make them recognizable during scan or just place waypoint configs to different folder.

if (not GameSetup) then
	return
end

local Menu = Menu
local Menu_open = Menu.open
local M_interaction = managers.interaction
local M_interactive_units = M_interaction._interactive_units
local M_localization = managers.localization
local locale_exists = M_localization.exists
local tweak_data = tweak_data
local TD_interaction = tweak_data.interaction
local tr = Localization.translate

local in_table = in_table
local insert = table.insert
local delete = table.delete
local str_gsub = string.gsub
local lines = ppr_io.lines
local open_file = ppr_io.open
local togg_vars = togg_vars
local type = type
local pairs = pairs

local file_name = "Trainer/configs/waypoints/waypoints_config.lua"
local waypoint_items = {}
local main_menu

--Load saved waypoints
for line in lines( file_name ) do
	waypoint_items[ line ] = true
end

local save = function()
	local file = open_file( file_name, 'w' )
	
	for line in pairs( waypoint_items ) do
		file:write( line .. "\n" )
	end
	
	file:close()
end

local toggle_icon = function( id )
	if waypoint_items[ id ] then
		waypoint_items[ id ] = nil
	else
		waypoint_items[ id ] = true
	end
end

-- Menu

main_menu = function()
	local data = {
		{ text = tr.wp_show_all, type = "toggle", toggle = "all_waypoints", callback = function() togg_vars.all_waypoints = not togg_vars.all_waypoints end },
		{ text = tr.save, callback = save },
		{},
	}
	
	local interactive_units = {}
	for id, unit in pairs( M_interactive_units ) do
		local tweak = unit:interaction().tweak_data
		insert( interactive_units, tweak )
	end
	local locale_exists = locale_exists
	for id, tweak in pairs( TD_interaction ) do
		local filter = togg_vars.all_waypoints or in_table( interactive_units, id )
		
		if type( tweak ) == "table" and filter then
			local text_id = tweak.text_id
			if text_id and locale_exists( M_localization, text_id ) then
				local name = str_gsub(id, "_", " ")
				insert( data, { text = name, type = "toggle", toggle = function() return waypoint_items[ id ] end, callback = toggle_icon, data = id, switch_back = true } )
			end
		end
	end
	
	Menu_open(Menu, { title = tr.wp_title, button_list = data } )
end

return main_menu