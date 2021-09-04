-- Purpose: spawn units
--Author: Simplity

if ( not GameSetup ) then
	return
end

local ppr_require = ppr_require

ppr_require 'Trainer/tools/new_menu/menu'
ppr_require 'Trainer/other/all_units'

local ppr_dofile = ppr_dofile
local random = math.random
local insert = table.insert
local gsub = string.gsub
local find = string.find
local match = string.match
local pairs = pairs
local tostring = tostring

local World = World
local W_spawn_unit = World.spawn_unit
local KeyInput = KeyInput
local edit_key = KeyInput.edit_key

local mrotation = mrotation
local mrot_turn = mrotation.turn
local Idstring = Idstring
local managers = managers
local M_groupAI = managers.groupai
local M_network = managers.network
local M_player = managers.player
local M_localization = managers.localization
local in_table = in_table
local all_units = all_units
local unit_on_map = unit_on_map
local ppr_config = ppr_config
local ray_pos = ray_pos
local CopActionAct = CopActionAct
local PackageManager = PackageManager
local PackageLoad = PackageManager.load
local tweak_data = tweak_data

local bound_key = ppr_config.SpawnUnitKey or '7' --Key, to what spawn unit will be bound

local plugins = plugins

local tr = Localization.translate

local Menu = Menu
local Menu_open = Menu.open

local main_menu, spawn_settings, spawn_position_menu, spawn_amount_menu, load_unit_menu, load_anim_menu, spawn_civ_anim_menu, spawn_ene_anim_menu, spawn_other_anim_menu, spawn_load_packages, load_package, get_random_spawn_pos, spawn_props_menu, set_team

-- Functions

local get_category_data = function( category )
	local category_data = { 
		civilians = { unit_table = all_units.all_civs, translation = "spawn_civs_menu" },
		cops = { unit_table = all_units.all_cops, translation = "spawn_cops_menu" },
		fbi = { unit_table = all_units.all_fbi, translation = "spawn_fbi_menu" },
		swats = { unit_table = all_units.all_swats, translation = "spawn_swats_menu" },
		gangs = { unit_table = all_units.all_gangs, translation = "spawn_gangs_menu" },
		anim_civs = { unit_table = CopActionAct._act_redirects.civilian_spawn, translation = "spawn_civ_anim_menu", anim_type = "civilians" },
		anim_enemies = { unit_table = CopActionAct._act_redirects.enemy_spawn, translation = "spawn_ene_anim_menu", anim_type = "enemies" },
		anim_other = { unit_table = CopActionAct._act_redirects.SO, translation = "spawn_other_anim_menu", anim_type = "other" },
	}
	
	return category_data[ category ]
end

load_package = function(name)
	PackageLoad(PackageManager, name)
end

-- Parse functions

local parse_unit_name = function( unit_name )
	local _,_,_,name = find(unit_name, "(.+)/(.+)$")
	return gsub(name, "_", " ")
end

local parse_anim_name = function( anim_name )
	return gsub(anim_name, "_", " ")
end

-- Spawn functions

local set_anim = function( unit, unit_type )
	local variant = unit_type == 'civilians' and ( ppr_config.SpawnCivsAnim or "cm_sp_stand_idle" ) or ( ppr_config.SpawnEnemyAnim or "idle" )
	local action_data = { type = "act", body_part = 1, variant = variant, align_sync = true }
	unit:brain():action_request( action_data )
end

local set_spawn_anim = function( anim_name, anim_type )
	if anim_type == 'civilians' then
		ppr_config.SpawnCivsAnim = anim_name 
	elseif anim_type == 'enemies' then
		ppr_config.SpawnEnemyAnim = anim_name
	else
		ppr_config.SpawnEnemyAnim = anim_name 
		ppr_config.SpawnCivsAnim = anim_name
	end
end

local set_spawn_options = function( unit, unit_type )
	local AIState = M_groupAI:state()
	if AIState then
		if unit_type == 'friendly' then
			if not plugins:g_loaded( "inf_converts" ) then
				plugins:ppr_require( 'Trainer/addons/stealthmenu/inf_converts', true )
			end
			
			set_team( unit, "player" )
			AIState:convert_hostage_to_criminal( unit )
		elseif unit_type == 'civilians' then
			set_anim( unit, 'civilians' )
			set_team( unit, "non_combatant" )
		elseif unit_type == 'enemy' then
			set_anim( unit, 'enemy' )
			set_team( unit, unit:base():char_tweak().access == "gangster" and "gangster" or "combatant" )
		end
		
		local brain = unit:brain()
		if brain then
			brain:set_spawn_ai( { init_state = "idle" } )
		end
	end
end

set_team = function( unit, team )
	local AIState = M_groupAI:state()
	
	local team_id = tweak_data.levels:get_default_team_ID( team )
	unit:movement():set_team( AIState:team_data( team_id ) )
end

local get_spawn_pos = function()
	local spawn_pos = ppr_config.SpawnPos
	local pos
	
	if spawn_pos == "spawn_point" then
		pos = M_network:session():get_next_spawn_point().pos_rot[1]
	elseif spawn_pos == "random_spawn_point" then
		pos = get_random_spawn_pos()
	else
		pos = ray_pos()
	end
	
	return pos
end

get_random_spawn_pos = function()
	local area_data = M_groupAI:state()._area_data
	local pos = area_data[ random(#area_data) ].pos
	
	return pos
end

local spawn_unit = function( unit_name, unit_type )
	local rotation = mrot_turn( M_player:player_unit():camera():rotation() )
	local position = get_spawn_pos()
	
	for i = 1, ppr_config.SpawnUnitsAmount do
		local unit = W_spawn_unit( World, Idstring(unit_name), position, rotation )
		set_spawn_options( unit, unit_type )
	end
end

local spawn_gage_package = function()
	local SpawnGagePackage = ppr_require("Trainer/addons/spawngagepackage")
	SpawnGagePackage()
end

local spawn_car = function( car_name )
	local rotation = mrot_turn( M_player:player_unit():camera():rotation() )
	local position = ray_pos()
	
	W_spawn_unit( World, Idstring( car_name ), position, rotation )
end

local spawn_vehicle_turret = function( group )
	local rotation = mrot_turn( M_player:player_unit():camera():rotation() )
	local position = ray_pos()
	
	local unit_name = "units/payday2/vehicles/gen_vehicle_turret/gen_vehicle_turret"
	local unit_car = W_spawn_unit( World, Idstring("units/payday2/vehicles/anim_vehicle_van_swat/anim_vehicle_van_swat"), position, rotation )

	local module_id = random()
	unit_car:base():spawn_module( unit_name, "spawn_turret", module_id )
	unit_car:base():run_module_function( module_id, "base", "activate_as_module", group, "swat_van_turret_module" )
end

local spawn_set_amount = function( amount )
	ppr_config.SpawnUnitsAmount = amount
end

local switch_unit = function( unit_name, unit_type )
	edit_key(KeyInput, bound_key, { callback = function() spawn_unit( unit_name, unit_type ) end })
end

-- Load menu

load_unit_menu = function( category, unit_type )
	local category_data = get_category_data( category )
	local data = {}
	for _,unit_name in pairs( category_data.unit_table ) do
		if unit_on_map( unit_name ) then
			insert( data, { text = parse_unit_name(unit_name), callback = spawn_unit, alt_callback = switch_unit, data = { unit_name, unit_type } } )
		end
	end
	
	if #data == 0 then
		insert(data, { text = tr['no_units_on_map'], callback = void })
	end
	
	Menu_open( Menu, { title = tr[ category_data.translation ], button_list = data, description = tr.equip_desc .. " '" .. bound_key .."'", back = main_menu } )
end

load_anim_menu = function( category )
	local category_data = get_category_data( category )
	local data = {}
	local insert = insert
	for _,anim_name in pairs( category_data.unit_table ) do
		insert( data, { text = parse_anim_name(anim_name), callback = set_spawn_anim, data = { anim_name, category_data.anim_type }, switch_back = main_menu } )
	end
	
	Menu_open( Menu, { title = tr[ category_data.translation ], button_list = data, back = main_menu } )
end

-- Menu

spawn_settings = function()
	local data = { 
		{ text = tr['spawn_position_menu'], callback = spawn_position_menu, menu = true },
		{ text = tr['spawn_amount_menu'], callback = spawn_amount_menu, menu = true },
	}
	
	Menu_open( Menu, { title = tr['spawn_settings'], button_list = data, back = main_menu } )
end

spawn_load_packages = function()
	local data = { }
	local locale_exists = M_localization.exists
	local locale_text = M_localization.text
	for _,level in pairs( tweak_data.levels ) do
		local package = level.package
		local level_name_id = level.name_id
		if package and locale_exists(M_localization, level_name_id) then
			insert(data, { text = locale_text(M_localization, level_name_id), callback = load_package, data = package })
		end
	end
	
	Menu_open( Menu, { title = tr['spawn_load_packages'], button_list = data, back = main_menu } )
end

spawn_position_menu = function()
	local data = { 
		{ text = tr['spawn_on_spawn_point'], callback = function() ppr_config.SpawnPos = "spawn_point" end, switch_back = main_menu },
		{ text = tr['spawn_on_ray'], callback = function() ppr_config.SpawnPos = "ray" end, switch_back = main_menu },
		{ text = tr['spawn_on_random_point'], callback = function() ppr_config.SpawnPos = "random_spawn_point" end, switch_back = main_menu },
	}
	
	Menu_open( Menu, { title = tr['spawn_position_menu'], button_list = data, back = spawn_settings } )
end

spawn_amount_menu = function()
	local data = { 
		{ text = tr['spawn_set_to'] .. ":", type = "slider", slider_data = { name = "spawn_amount", value = 5, max = 50 }, switch_back = true },
		{ text = tr['save'], type = "save_button", callback = spawn_set_amount, name = "spawn_amount", switch_back = main_menu },
	}
	
	Menu_open( Menu, { title = tr['spawn_amount_menu'], button_list = data, back = spawn_settings } )
end

spawn_special_menu = function()
	local data = { 
		{ text = tr['spawn_gage_package'], callback = spawn_gage_package },
	}
	
	local falcogini = "units/pd2_dlc_cage/vehicles/fps_vehicle_falcogini_1/fps_vehicle_falcogini_1"
	local muscle = "units/pd2_dlc_shoutout_raid/vehicles/fps_vehicle_muscle_1/fps_vehicle_muscle_1"
	local forklift = "units/pd2_dlc_shoutout_raid/vehicles/fps_vehicle_forklift_1/fps_vehicle_forklift_1"
	
	if unit_on_map( falcogini ) then
		insert(data, { text = tr['spawn'] .. " falcogini", callback = spawn_car, data = falcogini })
	end
	
	if unit_on_map( muscle ) then
		insert(data, { text = tr['spawn'] .. " muscle", callback = spawn_car, data = muscle })
	end
	
	if unit_on_map( forklift ) then
		insert(data, { text = tr['spawn'] .. " forklift", callback = spawn_car, data = forklift })
	end
	
	if unit_on_map("units/payday2/vehicles/anim_vehicle_van_swat/anim_vehicle_van_swat") then
		insert(data, { text = tr['spawn_vehicle_turret_fr'], callback = spawn_vehicle_turret, data = "player" })
		insert(data, { text = tr['spawn_vehicle_turret_en'], callback = spawn_vehicle_turret, data = "combatant" })
	end
	
	Menu_open( Menu, { title = tr['spawn_special_menu'], button_list = data, back = main_menu } )
end

-- Main menu

main_menu = function()
	local data = { 
		{ text = tr['spawn_settings'],       callback = spawn_settings, menu = true },
		{ text = tr['spawn_load_packages'],  callback = spawn_load_packages, menu = true },
		{}, 
		{ text = tr['spawn_special_menu'],   callback = spawn_special_menu, menu = true },
		{ text = tr['spawn_civs_menu'],      callback = load_unit_menu, data = { "civilians", 'civilians' }, menu = true },
		{},
		{ text = tr['spawn_civ_anim_menu'],  callback = load_anim_menu, data = "anim_civs", menu = true },
		{ text = tr['spawn_ene_anim_menu'],  callback = load_anim_menu, data = "anim_enemies", menu = true },
		{ text = tr['spawn_other_anim_menu'],callback = load_anim_menu, data = "anim_other", menu = true },
		{},
		{ text = tr['spawn_cops_menu'],      callback = load_unit_menu, data = { "cops", 'enemy' }, menu = true },
		{ text = tr['spawn_fbi_menu'],       callback = load_unit_menu, data = { "fbi", 'enemy' }, menu = true },
		{ text = tr['spawn_swats_menu'],     callback = load_unit_menu, data = { "swats", 'enemy' }, menu = true },
		{ text = tr['spawn_gangs_menu'],     callback = load_unit_menu, data = { "gangs", 'enemy' }, menu = true },
		{},
		{ text = tr['spawn_bg_cops_menu'],   callback = load_unit_menu, data = { "cops", 'friendly' }, menu = true },
		{ text = tr['spawn_bg_fbi_menu'],    callback = load_unit_menu, data = { "fbi", 'friendly' }, menu = true },
		{ text = tr['spawn_bg_swats_menu'],  callback = load_unit_menu, data = { "swats", 'friendly' }, menu = true },
		{ text = tr['spawn_bg_gangs_menu'],  callback = load_unit_menu, data = { "gangs", 'friendly' }, menu = true },
	}
	
	Menu_open( Menu, { title = tr['spawn_menu'], button_list = data } )
end

return main_menu