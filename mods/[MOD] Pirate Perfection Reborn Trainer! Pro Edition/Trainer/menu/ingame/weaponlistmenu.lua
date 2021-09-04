--Purpose: weapon menu
--Network sync fix very messy and still may crash other sometimes!
--Please test this and improve sync part if you can!
--Author: *******

if ( not GameSetup ) then
	return
end

local allow_send_interval = 5

local managers = managers
local GetPlayerUnit = GetPlayerUnit
local alive = alive

local ppr_require = ppr_require
ppr_require 'Trainer/tools/new_menu/menu'
ppr_require 'Trainer/addons/invfix' -- In case if it isn't loaded

local Global = Global
local armors = Global.blackmarket_manager.armors
local crafted_items = Global.blackmarket_manager.crafted_items
local all_dlc_data = Global.dlc_manager.all_dlc_data

local M_network = managers.network
local M_weapon_factory = managers.weapon_factory
local M_blackmarket = managers.blackmarket
local BlackMarketManager = BlackMarketManager
local M_localization = managers.localization
local M_dlc = managers.dlc
local locale_text = M_localization.text
local locale_exists = M_localization.exists
local query_execution_testfunc = query_execution_testfunc

local Application = Application
local A_time = Application.time

local pairs = pairs
local tab_insert = table.insert
local str_find = string.find

local Menu = Menu
local Menu_open = Menu.open

local main_menu, custom_menu, weapons_from_inventory, weapons_menu, melee_weapons_menu, armors_menu

local tweak_data = tweak_data
local T_weapon = tweak_data.weapon
local T_melee_weapons = tweak_data.blackmarket.melee_weapons
local T_armors = tweak_data.blackmarket.armors

local MenuCallbackHandler = MenuCallbackHandler
local update_outfit_information = MenuCallbackHandler._update_outfit_information

local clone = clone

local tr = Localization.translate

local path = "Trainer/addons/weapon_menu/"

local weapon_factory = T_weapon.factory
local function wf(t) -- Shortened request below
	return weapon_factory[t]
end

local function w(t) -- Shortened request below
	return M_weapon_factory:get_weapon_id_by_factory_id(t)
end

local function f(t) -- Shortened request below
	return M_weapon_factory:get_factory_id_by_weapon_id(t)
end

-- Messy attempt to fix blackmarket sync data
-- Section start
local function _setup()
	local backuper = backuper
	local hijack = backuper.hijack
	-- Hacks to properly rebuild outfit string
	hijack(backuper, 'BlackMarketManager.equipped_primary',function(o, self, ...)
		local hack_data = self._hack_data
		if hack_data then
			local primary = hack_data.primary
			if ( primary ) then
				return primary
			end
		end
		return o(self, ...)
	end)
	hijack(backuper, 'BlackMarketManager.equipped_secondary',function(o, self, ...)
		local hack_data = self._hack_data
		if hack_data then
			local secondary = hack_data.secondary
			if ( secondary ) then
				return secondary
			end
		end
		return o(self, ...)
	end)
	hijack(backuper, 'PlayerInventory._send_equipped_weapon', function(o, self, ...)
		if self.not_synched then -- It isn't safe to update our weapon yet.
			if not self.queried then -- Query request, If it wasn't queried before.
				query_execution_testfunc(
					function()
						return A_time(Application) - self.not_synched >= allow_send_interval
					end,
					{
						f = function( ... )
							self.not_synched = false
							self.queried = false
							if alive(GetPlayerUnit()) then -- Probably you may die during this delay
								self:_send_equipped_weapon( ... )
							end
						end,
						a = { ... }
					} )
				self.queried = true
			end
			return
		end
		return o(self, ...)
	end)
	-- Function for easier injecting our new weapon data
	BlackMarketManager._hack_weap = function(self, i, hack_data)
		if hack_data then
			local _hack_data = self._hack_data
			if not _hack_data then
				_hack_data = {}
				self._hack_data = _hack_data
			end
			if i == 2 then
				_hack_data.primary = hack_data
			elseif i == 1 then
				_hack_data.secondary = hack_data
			end
		end
	end
end

local function fix_sync( weapon_name, weap_data, custom_blueprint, ply )
	if not custom_blueprint then
		custom_blueprint = wf(weapon_name).default_blueprint
	end
	
	if not BlackMarketManager._hack_weap then
		_setup()
	end
	
	local session = M_network._session
	if session then
		local new_data = { weapon_id = w(weapon_name), factory_id = weapon_name, blueprint = custom_blueprint, eqiupped = true, global_values = {} }
		M_blackmarket:_hack_weap( weap_data.use_data.selection_index, new_data )
		
		update_outfit_information(MenuCallbackHandler)
		local l_peer = session:local_peer()
		session:send_to_peers_synched( "set_unit", ply, l_peer:character(), M_blackmarket:outfit_string(), l_peer:outfit_version(), l_peer:id() ) -- This will send our current outfit string and will force preload of new outfit for other players.
		
		ply:inventory().not_synched = A_time(Application) -- Due "set_unit" request being heavy, we have to wait before it fully sends to every peer here.
	end
end
--Section ended
local function swap_weapon( weapon_name, weap_data, custom_blueprint, no_sync )
	local ply = GetPlayerUnit()
	if not no_sync then
		fix_sync( weapon_name, weap_data, custom_blueprint, ply )
	end

	if not ( custom_blueprint ) then	-- Fixes bug, preventing you from changing your weapon
		custom_blueprint = clone(wf(weapon_name).default_blueprint)
	end
	ply:inventory():add_unit_by_factory_name( weapon_name, true, false, custom_blueprint )
end

--[[
local function test_custom()
	backuper:backup('WeaponFactoryManager._get_forbidden_parts')
	
	function WeaponFactoryManager._get_forbidden_parts() return {} end
	local blue = tweak_data.weapon.factory[f('deagle')].default_blueprint
	tab_insert(blue, 'wpn_fps_pis_rage_o_adapter')
	swap_weapon(f('deagle'),tweak_data.weapon['deagle'],blue)
	
	backuper:restore('WeaponFactoryManager._get_forbidden_parts')
end]]

local change_melee_weapon = function( weapon_id )
	local ply = GetPlayerUnit()
	M_blackmarket:equip_melee_weapon( weapon_id )
	ply:inventory():set_melee_weapon( weapon_id )
end

local change_armor = function( armor_id )
	local armor = armors[armor_id]
	local unlocked = armor.unlocked
	armor.unlocked = true
	M_blackmarket:equip_armor( armor_id )
	armor.unlocked = unlocked
end

local function dlc_check(weapon)
	local dlc = weapon.global_value or weapon.dlc
	if dlc and all_dlc_data[dlc] and all_dlc_data[dlc].app_id and not M_dlc:is_dlc_unlocked(dlc) then
		return "          [DLC]"
	end
	return ""
end

-- Reload Speed modifier
local function reload_speed_multiplier()
	tweak_data.values.weapon.reload_speed_multiplier(value)
end

local function on_reload_speed_multiplier()
	M_blackmarket._current_reload_speed_multiplier(value)
	M_blackmarket.reload_speed_multiplier(value)
end

local set_reload_speed_multiplier = function( new_reload_speed )
	local speed_multiplier = self:reload_speed_multiplier()
	reload_speed_multiplier = new_reload_speed
end

-- Menu
weapons_from_inventory = function( category )	
	local data = {}
	
	local locale_text = locale_text
	for _, slot_data in pairs( crafted_items[ category ] ) do
		local weapon_data = T_weapon[ slot_data.weapon_id ]
		tab_insert( data, { text = locale_text( M_localization, weapon_data.name_id )..dlc_check(weapon_data),
				callback = function() swap_weapon(slot_data.factory_id, weapon_data, slot_data.blueprint) end } )
	end
	
	Menu_open( Menu, { title = tr.weapons_from_inventory, button_list = data, back = function() weapons_menu( category ) end } )
end

weapons_menu = function( category )
	local data = {
		{ text = tr.weapons_from_inventory, callback = weapons_from_inventory, data = category, menu = true },
		{},
	}
	
	local is_primaries = (category == "primaries")
	local translation = is_primaries and "weapon_primaries" or "weapon_secondaries"
	local selection_index = is_primaries and 2 or 1
	
	local locale_text = locale_text
	for weapon,wdata in pairs( T_weapon ) do
		if ( not str_find(weapon,'npc') --[[Filtering npc's weapons]] ) and ( not str_find(weapon,'crew') --[[Filtering crew's weapons]] ) then
			local use_data = wdata.use_data
			if --[[wdata.name_id and]] ( use_data and use_data.selection_index == selection_index ) then
				tab_insert( data, { text = locale_text( M_localization, wdata.name_id )..dlc_check(wdata), callback = function() swap_weapon(f(weapon), wdata) end } )
			end
		end
	end
	
	Menu_open( Menu, { title = tr[ translation ], button_list = data, back = main_menu } )
end

melee_weapons_menu = function()
	local locale_exists = locale_exists
	local locale_text = locale_text
	
	local data = {}
	for melee_weapon_id, weapon_data in pairs( T_melee_weapons ) do
		local name_id = weapon_data.name_id
		if name_id and locale_exists( M_localization, name_id ) then
			tab_insert( data, { text = locale_text( M_localization, name_id )..dlc_check(weapon_data), callback = change_melee_weapon, data = melee_weapon_id } )
		end
	end
	
	Menu_open( Menu, { title = tr.melee_weapons, button_list = data, back = main_menu } )
end

armors_menu = function()
	local locale_exists = locale_exists
	local locale_text = locale_text
	
	local data = {}
	for armor_id, armor_data in pairs( T_armors ) do
		local name_id = armor_data.name_id
		if name_id and locale_exists( M_localization, name_id ) then
			tab_insert( data, { text = locale_text( M_localization, armor_data.name_id ), callback = change_armor, data = armor_id } )
		end
	end
	
	Menu_open( Menu, { title = tr.melee_weapons, button_list = data, back = main_menu } )
end

main_menu = function()
	if ( alive( GetPlayerUnit() ) ) then
		local data = {
			{ text = tr.weapon_primaries, callback = weapons_menu, data = "primaries", menu = true },
			{ text = tr.weapon_secondaries, callback = weapons_menu, data = "secondaries", menu = true },
			{ text = tr.melee_weapons, callback = melee_weapons_menu, menu = true },
			{ text = tr.armors, callback = armors_menu, menu = true },
			{},
			{ text = tr.always_dismember, plugin = "always_dismember", switch_back = true },
			{},
		}
		Menu_open( Menu, { title = tr.weapon_menu_title, button_list = data, plugin_path = path } )
	end
end

return main_menu