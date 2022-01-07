-- Purpose: different scripts for stealth
--Author: Simplity

if ( not GameSetup ) then
	return
end

local ppr_require = ppr_require

ppr_require 'Trainer/tools/new_menu/menu'

local ppr_dofile = ppr_dofile

local managers = managers
local M_player = managers.player
local game_state_machine = game_state_machine
local change_state_by_name = game_state_machine.change_state_by_name
local can_change_state_by_name = game_state_machine.can_change_state_by_name

local Menu = Menu
local Menu_open = Menu.open

local main_menu, stealth_inf_menu, additional_stealth_menu

local tr = Localization.translate

local path = "Trainer/addons/stealthmenu/"

-- Functions

local remote_camera = function()
	if ( can_change_state_by_name( game_state_machine, "ingame_access_camera" ) ) then
		change_state_by_name( game_state_machine, "ingame_access_camera" )
	end
end
 
local add_ecm = function() -- by Harfatus
	M_player:clear_equipment()
	M_player._equipment.selections = {}
	M_player:add_equipment({ equipment = "ecm_jammer" })
end

-- Menu

additional_stealth_menu = function()
	local data = {
		{ text = tr['people_dont_call_police'], plugin = "dont_call_police", host_only = true, switch_back = true },
		{ text = tr['prevent_panic_buttons'], plugin = "prevent_panic_buttons", host_only = true, switch_back = true },
		{ text = tr['dis_pagers'], plugin = "disable_pagers", host_only = true, switch_back = true },
		{},
		{ text = tr['cops_dont_shoot'], plugin = "cops_dont_shoot", host_only = true, switch_back = true },
	}
	
	Menu_open( Menu, { title = tr['npc_menu'], button_list = data, plugin_path = path, back = main_menu } )
end

stealth_inf_menu = function()
	local data = {
		{ text = tr['inf_cable'], plugin = "inf_cable_activated", switch_back = true },
		{ text = tr['inf_ecm_battery'], plugin = "inf_battery_activated", host_only = true, switch_back = true },
		{ text = tr['inf_body_bags'], plugin = "inf_body_bags", switch_back = true },
		{},
		{ text = tr['inf_pager_answ'], plugin = "inf_pager_answers", host_only = true, switch_back = true },
		{},
		{ text = tr['inf_converts'], plugin = "inf_converts", switch_back = true },
		{ text = tr['inf_follow_hostages'], plugin = "inf_follow_hostages", switch_back = true },
	}
	
	Menu_open( Menu, { title = tr['stealth_inf_menu'], button_list = data, plugin_path = path, back = main_menu } )
end

main_menu = function()
	local data = {
		{ text = tr['npc_menu'], callback = additional_stealth_menu, menu = true },
		{ text = tr['stealth_inf_menu'], callback = stealth_inf_menu, menu = true },
		{},
		{ text = tr['add_ecm'], callback = add_ecm, switch_back = true },
		{ text = tr['remote_camera_access'], callback = remote_camera },
		{},
		{ text = tr['change_fov'], plugin = "change_fov" },
		{ text = tr['dis_cams'], plugin = "disable_cams", host_only = true, switch_back = true },
		{ text = tr['steal_pagers'], plugin = "steal_pagers_on_melee", switch_back = true },
		{},
		{ text = tr['lobotomize_ai'], plugin = "lobotomize_ai", host_only = true, switch_back = true },
		{ text = tr['invisible_player'], plugin = "invisible_player", host_only = true, switch_back = true },
		{},
		{text = tr['kill_all_npc'], callback = ppr_dofile, data = path .. "kill_all_npc" },
	}
	
	Menu_open( Menu, { title = tr['stealth_menu'], button_list = data, plugin_path = path } )
end

return main_menu