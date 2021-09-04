--Purpose: small interaction menu to instantly interact with some kind of things.
--Author: 1st version ****, 2nd version baldwin, 3d version Simplity & Jazzman
if ( not GameSetup ) then
	return
end

local ppr_require = ppr_require
ppr_require('Trainer/tools/new_menu/menu')
ppr_require('Trainer/addons/ply_equip_fix')

local is_server = is_server

local pairs = pairs
local insert = table.insert
local tab_contains = table.contains
local select = select
local executewithdelay = executewithdelay

local clone = clone

local Vector3 = Vector3
local Rotation = Rotation
local alive = alive
local managers = managers
local M_network = managers.network
local M_player = managers.player
local ply_list = M_player._players
local M_interaction = managers.interaction
local plugins = plugins
local plug_require = plugins.ppr_require
local plug_unload = plugins.unload
local plug_g_loaded = plugins.g_loaded

local tweak_data = tweak_data
local T_carry = tweak_data.carry

local m_log_error = m_log_error
local is_client = is_client

local vec0 = Vector3(0,0,0)
local vec1 = Vector3(0,0,50)

local rot0 = Rotation(0,0,0)

local peer_id = M_network:session():local_peer():id()

local Menu = Menu
local Menu_open = Menu.open

local G_game_settings = Global.game_settings
local function level(l)
	return G_game_settings.level_id == l
end

local BaseInteractionExt = BaseInteractionExt
local tr = Localization.translate --Shortened Localization.translate.id
local function st(t) --Shortened switch text check for interactions
	return BaseInteractionExt.speed_changed == t
end

local open_menu,patch_menu

local path = "Trainer/addons/interactions/"

local function interactbytweak(...)
	local player = ply_list[1]
	if not player then
		m_log_error("interactbytweak()", "Local player isn't alive!")
		return
	end
	local unload = false
	local interactives = {}
	
	if not plug_g_loaded( plugins, "interact_with_all" ) then
		plug_require( plugins, path .. 'interact_with_all', true )
		unload = true
    end
	
	local tweaks = {}
	for _,arg in pairs({...}) do
		tweaks[arg] = true
	end
	
	for key,unit in pairs(M_interaction._interactive_units) do
		local interaction = unit.interaction
		interaction = interaction and interaction( unit )
		if interaction and tweaks[interaction.tweak_data] then
			insert(interactives, interaction)
		end
	end
	for _,i in pairs(interactives) do
		i:interact(player)
	end
	if ( unload ) then
		plug_unload( plugins, "interact_with_all" )
	end
end
---------------------------------------------------------------------------------------------------
local function testopenallvaults()
	interactbytweak("pick_lock_hard","pick_lock_hard_no_skill","pick_lock_deposit_transport")
end
---------------------------------------------------------------------------------------------------
local function openalldoors()
	interactbytweak("pick_lock_easy_no_skill", "pick_lock_hard_no_skill", "pick_lock_hard", "open_from_inside", "open_train_cargo_door")
end
---------------------------------------------------------------------------------------------------
local function testshapeinteract()
	interactbytweak("shaped_sharge", "shaped_charge_single", "c4_mission_door")
end
---------------------------------------------------------------------------------------------------
local function removeallbags()
	interactbytweak("carry_drop", "painting_carry_drop")
	M_player:clear_carry()
end
---------------------------------------------------------------------------------------------------
local function bag_people()
	local ply = ply_list[1]
	if ( alive( ply ) ) then
		local session = M_network._session
		local interactions = {}
		for _,unit in pairs(M_interaction._interactive_units) do
			local interaction = unit:interaction()
			if interaction and interaction.tweak_data == 'corpse_dispose' then
				interactions[unit:position()+vec1] = interaction
			end
		end
		
		local ply_clear_carry = M_player.clear_carry
		local send_to_host = session.send_to_host
		local server_drop_carry = M_player.server_drop_carry
		
		local is_client = is_client()
		
		local name = 'person'
		local carry_data = T_carry[ name ]
		
		local multiplier = carry_data.multiplier
		local dye_initiated = carry_data.dye_initiated
		local has_dye_pack = carry_data.has_dye_pack
		local dye_value_multiplier = carry_data.dye_value_multiplier
		
		for pos,interaction in pairs(interactions) do
			interaction:interact( ply )
			
			local unit = interaction._unit
			local u_id = managers.enemy:get_corpse_unit_data_from_key(unit:key()).u_id
			
			if is_client then
				send_to_host(session,
					"server_drop_carry",
					name,
					multiplier,
					dye_initiated,
					has_dye_pack,
					dye_value_multiplier,
					pos,
					rot0,
					vec0,
					100,
					nil
				)
				
				send_to_host(session, "sync_interacted_by_id", u_id, "corpse_dispose")
			else
				server_drop_carry(M_player,
					name,
					multiplier,
					dye_initiated,
					has_dye_pack,
					dye_value_multiplier,
					pos,
					rot0,
					vec0,
					100,
					nil,
					nil
				)
				
				unit:set_slot(0)
				session:send_to_peers_synched("remove_corpse_by_id", u_id, true, peer_id)
			end
			ply_clear_carry(M_player)
		end
	end
end
---------------------------------------------------------------------------------------------------
local function grabsmallloot()
	interactbytweak("safe_loot_pickup","diamond_pickup","tiara_pickup","money_wrap_single_bundle","invisible_interaction_open","mus_pku_artifact")
end
---------------------------------------------------------------------------------------------------
local function graballbigloot()
	if not is_server() then
		return
	end
	ppr_require("Trainer/addons/carrystacker")
	interactbytweak("carry_drop","painting_carry_drop","money_wrap","gen_pku_jewelry","taking_meth","gen_pku_cocaine","take_weapons","gold_pile","hold_take_painting","invisible_interaction_open","gen_pku_artifact","gen_pku_artifact_statue","gen_pku_artifact_painting")
end
---------------------------------------------------------------------------------------------------
local function grabeverything()
	grabsmallloot()
	graballbigloot()
	interactbytweak("gage_assignment")
end
---------------------------------------------------------------------------------------------------
local function quicklyrobstuff()
	interactbytweak('weapon_case','cash_register','requires_ecm_jammer_atm','pick_lock_hard','pick_lock_hard_no_skill','pick_lock_deposit_transport','gage_assignment')
	executewithdelay(grabsmallloot,1)
end
---------------------------------------------------------------------------------------------------
local function drillupgall()
	interactbytweak("drill", "drill_upgrade", "drill_jammed", "lance_upgrade", "lance_jammed", "huge_lance_jammed")
end
---------------------------------------------------------------------------------------------------
local function barricade_stuff()
	interactbytweak('stash_planks','need_boards')
end
---------------------------------------------------------------------------------------------------
local function testclearrats1()
	local remove_special = M_player.remove_special
	remove_special( M_player,"acid" )
	remove_special( M_player,"caustic_soda" )
	remove_special( M_player,"hydrogen_chloride" )
end

local function testclearrats0()
	interactbytweak("hydrogen_chloride","caustic_soda","muriatic_acid")
	if is_server() then
		testclearrats1()
	else
		executewithdelay( testclearrats1, 1 ) --Due sync delays, we gotta clear our inventory as fast as possible.
	end
end

local function quick_elday_2()
	interactbytweak('crate_loot_crowbar', 'crate_loot')
	
	local start_vote = function() interactbytweak('votingmachine1','votingmachine2','votingmachine3','votingmachine4','votingmachine5','votingmachine6') end
	executewithdelay( start_vote, 3 )
end

local function hack_all_computers()
	interactbytweak('big_computer_hackable','big_computer_not_hackable')
end

local function openatms()
	interactbytweak('requires_ecm_jammer_atm')
end

local function quick_ff3()
	interactbytweak('pickup_phone','pickup_tablet','use_computer','stash_server_pickup')
end

-- invisible_interaction_searching, search FBI files in Hoxton Breakout
local function pickup_files()
	interactbytweak('invisible_interaction_searching')
end

-- hold_open_xmas_present presents in Vlad's winter heist
local function open_gift_boxes()
	interactbytweak('hold_open_xmas_present')
end

-- gen_pku_cocaine_pure, pure meth
local function pure_meth()
	interactbytweak('gen_pku_cocaine_pure')
end

-- Diamond heist
local function rewire_circuit()
	interactbytweak('invisible_interaction_open')
	
	local rewire_electric_box = function() interactbytweak('rewire_electric_box') end
	executewithdelay( rewire_electric_box, 5 )
end

local function cut_glasses()
	interactbytweak('cut_glass')
end

-- The Whitehouse: Cut right wires
local function cut_wires()
	interactbytweak('invisible_interaction_open_box')
	
	local done_cable_cut = function() interactbytweak('done_cable_cut') end
	executewithdelay( done_cable_cut, 3 )
	interactbytweak('set_text_open')
	interactbytweak('disable_leds')
end

-- The Whitehouse: Search for clues
local function start_hack()
	interactbytweak('start_hack')
end

-- The Whitehouse: Quick Find USB
local function state_interaction_enabled_usb()
	interactbytweak('state_interaction_enabled_usb')
end

-- The Whitehouse: Screw books
local function tumble_books()
	local scripts = managers.mission:scripts()
	for _, script in pairs( scripts ) do
		 local elements = script:elements()
		 for id, element in pairs( elements ) do
			  local trigger_list = element:values().trigger_list or {}
			  for _, trigger in pairs( trigger_list ) do
					if trigger.notify_unit_sequence == "tumble_books" then
						 element:on_executed()
					end
			  end
		 end
	end
end

-- The bomb: dockyard
local function place_explosives()
	interactbytweak('shape_charge_plantable')
end

--[[ Set Interaction Speed
local function patch_int_speed()
	BaseInteractionExt:toggle_int_speed(value)
end

local set_patch_int_speed = function( new_speed )
	BaseInteractionExt:toggle_int_speed = new_speed
end]]

-- MENU
patch_menu = function()
	plug_require( plugins, path .. 'interactionspeed', true )
	
	local contents = {
		{ text = tr.patch_int_speed1,
			type = "toggle",
			toggle = function()
				return st(0.01)
			end,
			callback = function()
				BaseInteractionExt:toggle_int_speed(0.01)
				local game_config = game_config
				if (st(0.01)) then
					game_config.instant_interaction = true
					game_config.fast_interaction = false
				else
					game_config.instant_interaction = false
				end
			end,
			switch_back = patch_menu },
		{ text = tr.patch_int_speed2,
			type = "toggle",
			toggle = function()
				return st(0.5) 
			end,
			callback = function()
				BaseInteractionExt:toggle_int_speed(0.5)
				local game_config = game_config
				if (st(0.5)) then
					game_config.instant_interaction = false
					game_config.fast_interaction = true
				else
					game_config.fast_interaction = false
				end
			end,
			switch_back = patch_menu },
		{ text = tr.patch_int_normal,
			callback = function()
				BaseInteractionExt:restore_speed()
				local game_config = game_config
				game_config.instant_interaction = false
				game_config.fast_interaction = false
			end,
			switch_back = patch_menu },
		{},
		{ text = tr.patch_int_all, plugin = 'interact_with_all', switch_back = true },
		{ text = tr.patch_int_distance, plugin = 'infinite_distance', switch_back = true },
		{ text = tr.patch_int_nowalls, plugin = 'ignore_walls', switch_back = true },
		{ text = tr.patch_interact_and_look, plugin = 'interact_and_look', switch_back = true },
		{},
		{ text = tr.patch_instant_intimidation, plugin = 'instant_intimidation', host_only = true, switch_back = true },
		{},
		{ text = tr.patch_instant_lootpile, plugin = 'instant_lootpile', host_only = true, switch_back = true },
		{ text = tr.patch_int_reboard, plugin = 'reboard', switch_back = true },
		{ text = tr.patch_int_team, plugin = 'interact_team', switch_back = true },
		{ text = tr.patch_noone_downs, plugin = 'noone_shall_down', switch_back = true },
	}
	
	Menu_open( Menu,  { title = tr.intm_patches, button_list = contents, plugin_path = path, back = open_menu } )
end

local special_interactions = { 
	rats				= { { "pure_meth", pure_meth } },
	big				= { { "hack_computers", hack_all_computers } },
	mus				= { { "rewire_circuit", rewire_circuit }, { "cut_glasses", cut_glasses } },
	vit				= { { "cut_wires", cut_wires }, { "start_hack", start_hack }, { "state_interaction_enabled_usb", state_interaction_enabled_usb }, { "tumble_books", tumble_books } },
	alex_1			= { { "no_rats_for_you", testclearrats0 } },
	election_day_2	= { { "hack_machines", quick_elday_2 } },
	pines				= { { "open_gift_boxes", open_gift_boxes } },
	hox_2				= { { "pickup_files", pickup_files } },
	crojob2			= { { "place_explosives", place_explosives } },
}

open_menu = function()
	local M_localization = managers.localization
	local T_levels = tweak_data.levels
	local contents = {
		{ text = tr.intm_patches, callback = patch_menu, menu = true },
		{},
		{ text = tr.speedy_the_robber, callback = quicklyrobstuff },
		{ text = tr.opn_all_vaults, callback = testopenallvaults },
		{ text = tr.open_doors, callback = openalldoors },
		{ text = tr.c4_doors, callback = testshapeinteract },
		{ text = tr.remove_bags, callback = removeallbags },
		{ text = tr.restore_drills, callback = drillupgall },
		{ text = tr.grab_everything, callback = grabeverything },
		{ text = tr.grab_small_loot, callback = grabsmallloot },
		{ text = tr.grab_bags, callback = graballbigloot },
		{ text = tr.grab_packages, callback = interactbytweak, data = "gage_assignment" },
		{ text = tr.bag_people, callback = bag_people },
		{ text = tr.barricade_windows, callback = barricade_stuff },
		{ text = tr.ecm_kiddie, callback = openatms },
		{ text = tr.answer_phones, callback = interactbytweak, data = 'hospital_phone' },
		{ text = tr.revive, callback = interactbytweak, data = 'revive' },
	}

	for level_id, level_data in pairs( special_interactions ) do
		if level( level_id ) then
			local level_name = M_localization:text( T_levels[ level_id ].name_id )

			insert( contents, #level_data + 1, {} )
			for _, interaction_data in pairs( level_data ) do
				insert( contents, 3, { text = level_name .. " - " .. tr[ interaction_data[1] ], callback = interaction_data[2] } )
			end

			break
		end
	end

	Menu_open( Menu,  { title = tr.intm_title, button_list = contents } )
end

return open_menu