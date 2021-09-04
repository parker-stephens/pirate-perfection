-- Purpose: menu for spawning bags and adding equipments

if ( not GameSetup ) then
	return
end

local ppr_require = ppr_require
ppr_require('Trainer/tools/new_menu/menu')
ppr_require('Trainer/addons/inventory_menu/rainbags')
local RainBags = RainBags

local pairs = pairs
local ppr_dofile = ppr_dofile
local rawget = rawget
local in_table = in_table
local table = table
local insert = table.insert
local sort = table.sort
local find = string.find

local Application = Application
local digest_value = Application.digest_value --(number, false[convert back to number]/true[convert to string])

local Global = Global
local G_game_settings = Global.game_settings
local managers = managers
local M_player = managers.player
local add_special = M_player.add_special
local add_equipment = M_player.add_equipment
local clear_equipment = M_player.clear_equipment
local player_list = M_player._players
local M_network = managers.network
local M_localization = managers.localization
local M_loot = managers.loot
local secure_small_loot = M_loot.secure_small_loot
local get_secured_bonus_bags_amount = M_loot.get_secured_bonus_bags_amount
local alive = alive
local tweak_data = tweak_data
local T_carry = tweak_data.carry
local T_levels = tweak_data.levels
local T_equipments = tweak_data.equipments
--local T_money = tweak_data.money_manager
local T_M_bag_values = tweak_data.money_manager.bag_values
local T_E_specials = T_equipments.specials
local KeyInput = KeyInput
local edit_key = KeyInput.edit_key
local togg_vars = togg_vars

local is_client = is_client
local ppr_config = ppr_config

local bound_key = ppr_config.SpawnBagKey or '8' --Key, to what spawn bag will be bound

local Menu = Menu
local Menu_open = Menu.open


local tr = Localization.translate --Shortened Localization.translate.id

local path = "Trainer/addons/inventory_menu/"

local main_menu, add_items_menu,money_menu, modifiers_menu, spawn_bag_menu, equipment_changer_menu, add_some_cash

-- Functions

local _spawn_bag = function( name, amount )
	local ply = player_list[1]
	if ( alive( ply ) ) then
		local camera_ext = ply:camera()
		local carry_data = T_carry[ name ]
		local session = M_network._session
		local multiplier = carry_data.multiplier
		local dye_initiated = carry_data.dye_initiated
		local has_dye_pack = carry_data.has_dye_pack
		local dye_value_multiplier = carry_data.dye_value_multiplier
		local cam_pos = camera_ext:position()
		local cam_rot = camera_ext:rotation()
		local cam_dir = camera_ext:forward()
		amount = amount or 1
		if is_client() then
			local send_to_host = session.send_to_host
			for i = 1, amount do
				send_to_host( session, "server_drop_carry", name, multiplier, dye_initiated, has_dye_pack, dye_value_multiplier, cam_pos, cam_rot, cam_dir, 100, nil )
			end
		else
			local server_drop_carry = M_player.server_drop_carry
			for i = 1, amount do
				server_drop_carry( M_player, name, multiplier, dye_initiated, has_dye_pack, dye_value_multiplier, cam_pos, cam_rot, cam_dir, 100, nil, nil )
			end
		end
	end
end

local spawn_bag = function( name )
	local ppr_config = ppr_config
	if togg_vars.is_rain then
		return RainBags(name, ppr_config.rain_bags_amount)
	end
	_spawn_bag(name, ppr_config.SpawnBagsAmount or 1)
end

local add_item = function( name )
	add_special( M_player, { name = name, silent = true, amount = 1 } )
end

local BEST_BAG = false

local get_the_most_expensive_bag = function()
	local best_val = 0
	local best_bag = ''
	local A = Application
	local digest_value = digest_value
	for name,val in pairs(T_M_bag_values) do
		val = digest_value( A, val, false ) --Why OVERKILL do that ?
		if ( val>best_val ) then
			best_val = val
			best_bag = name
		end
	end
	if ( best_bag == '' ) then
		m_log_error('{inventory_menu.lua}->get_the_most_expensive_bag()', 'best_bag is empty string. Mustn\'t happen actually.')
		best_bag = 'hope_diamond'
	end
	BEST_BAG = best_bag --Preload to don't iterate over again
	return best_bag
end

local secure_rupies = function()
	local level = G_game_settings.level_id
	if ( level ) then
		local bag_limit = T_levels[level].max_bags or 20 --This will be pointless to secure more than limit
		local best_bag = BEST_BAG or get_the_most_expensive_bag() --Detects the most expensive bag. Better than rechecking tweak datas again after update
		local secure = M_loot.secure
		for i = get_secured_bonus_bags_amount(M_loot) + 1, bag_limit do --To prevent oversecuring
			secure(M_loot, best_bag, 1, true)
		end
	end
end

local change_equipment = function( name )
	clear_equipment(M_player)
	M_player._equipment.selections = {}
	add_equipment(M_player, { equipment = name })
end

local set_bag_throw_distance = function( new_distance )
	local types = tweak_data.carry.types
	
	for carry_type in pairs( types ) do
		types[ carry_type ].throw_distance_multiplier = new_distance
	end
end

local switch_unit = function( bag_id )
	edit_key(KeyInput, bound_key, { callback = function() spawn_bag( bag_id ) end })
end

-- Menu

add_items_menu = function()
	local data = {}
	
	local locale_text = M_localization.text
	local locale_exists = M_localization.exists
	
	for id, item_data in pairs( T_E_specials ) do
		local text_id = item_data.text_id
		if text_id and locale_exists( M_localization, text_id ) then
			insert( data, { text = tr.btn_add .. " " .. locale_text( M_localization, text_id ), callback = add_item, data = id, switch_back = true } )
		end
	end
	
	Menu_open( Menu,  { title = tr.add_items_menu, button_list = data, back = main_menu } )
end

add_some_cash = function()
	for i = 1, 25 do
		secure_small_loot(M_loot, "gen_atm", 3)
	end
end

money_menu = function()
	local data = {
		{ text = tr.inventory_give_cash, callback = add_some_cash },
		{ text = tr.secure_turrets_lg, host_only = true, callback = secure_rupies },
	}
	
	Menu_open( Menu,  { title = tr.inventory_money_title, button_list = data, back = main_menu } )
end

equipment_changer_menu = function()
	local data = {}
	local locale_text  = M_localization.text
	local locale_exists = M_localization.exists
	
	for id, eq_data in pairs( T_equipments ) do
		local text_id = eq_data.text_id
		if text_id and locale_exists(M_localization, text_id) then
			insert( data, { text = tr.change_equipment .. locale_text( M_localization, text_id ), callback = change_equipment, data = id } )
		end
	end
	
	Menu_open( Menu,  { title = tr.equipment_changer, button_list = data, back = main_menu } )
end

modifiers_menu = function()
	local data = {
		{ text = tr.bag_throw_force, type = "slider", slider_data = { name = "bag_throw_power", value = game_config['bag_throw_power'], max = 30 }, plugin = 'bag_throw_force', slider_callback = set_bag_throw_distance, switch_back = true },
		--{ text = tr.sync_bag_throw_force, plugin = 'sync_bag_throw_force', host_only = true, switch_back = true }, **BROKEN**
		{ text = tr.bag_no_speed_penalty, plugin = 'bag_no_penalty', switch_back = true },
		{ text = tr.explosive_bags, plugin = 'explosive_bags', switch_back = true },
	}
	
	Menu_open( Menu,  { title = tr.modifiers, button_list = data, plugin_path = path, back = main_menu } )
end

spawn_bag_menu = function()
	local data = {}
	
	local locale_text = M_localization.text
	local locale_exists = M_localization.exists
	
	for bag_id, bag_data in pairs( T_carry ) do
		local name_id = bag_data.name_id
		if name_id and locale_exists( M_localization, name_id ) then
			insert( data, { text = tr['spawn'] .. " " .. locale_text( M_localization, name_id ), callback = spawn_bag, alt_callback = switch_unit, data = bag_id, switch_back = true } )
		end
	end
	
	sort( data, function(x,y) if x.text and y.text then return x.text < y.text end end )
	
	insert( data, 1, { text = tr.togg_rain_bags,
			type = "toggle",
			toggle = "is_rain",
			callback = function()
				togg_vars.is_rain = not togg_vars.is_rain
			end,
			switch_back = true } )
	insert( data, 2, {} )
	
	Menu_open( Menu,  { title = tr.inventory_menu_desc, button_list = data, description = tr.equip_desc .. " '" .. bound_key .."'", back = main_menu } )
end

main_menu = function()
	local data = {
	{ text = tr.inventory_money_title, callback = money_menu, menu = true },
	{ text = tr.equipment_changer, callback = equipment_changer_menu, menu = true },
	{},	
	{ text = tr.modifiers, callback = modifiers_menu, menu = true },
	{ text = tr.spawn_bag_menu, callback = spawn_bag_menu, menu = true },
	{ text = tr.weapon_menu_title, callback = ppr_require("Trainer/menu/ingame/weaponlistmenu"), menu = true },
	{ text = tr.add_items_menu, callback = add_items_menu, menu = true },
	}
	
	Menu_open( Menu,  { title = tr.inventory_menu, button_list = data } )
end

return main_menu