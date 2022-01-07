--  The "I Want That" Menu (v1.1 Release)
--  Author:  Davy Jones
--  Creates a large interface for the sole purpose of copying other player's masks and weapons

local deep_clone = deep_clone
local tab_delete = table.delete
local tab_insert = table.insert
local tab_size = table.size

local managers = managers
local M_achievment = managers.achievment
local M_blackmarket = managers.blackmarket
local M_dlc = managers.dlc
local M_infamy = managers.infamy
local M_localization = managers.localization
local M_network = managers.network
local M_weapon_factory = managers.weapon_factory

local tweak_data = tweak_data
local T_blackmarket = tweak_data.blackmarket
local T_B_weapon_skins = T_blackmarket.weapon_skins
local T_dlc = tweak_data.dlc
local T_E_bonuses = tweak_data.economy.bonuses
local T_E_qualities = tweak_data.economy.qualities
local T_infamy = tweak_data.infamy
local T_gui = tweak_data.gui
local T_weapon = tweak_data.weapon

local WeaponDescription = WeaponDescription

local backuper = backuper

local in_game = in_game

local Menu = Menu
local Menu_open = Menu.open

local tr = Localization.translate

local player_menu, inventory_menu, mask_menu, weapon_menu, weapon_stats_menu

local function add_single_item(category, item, not_new)
	M_blackmarket:add_to_inventory(M_blackmarket:get_global_value(category, item), category, item, not_new)
end

local function add_all_items(item_list, not_new)
	for _, item in pairs(item_list) do
		add_single_item(item[1], item[2], not_new)
	end
end

local function craft_item(items, items_override, custom_name, factory_id, weapon_type)
	local check_type = not weapon_type and "masks" or weapon_type
	local slot
	for i = 1, (check_type == "masks" and T_gui.MAX_MASK_SLOTS or T_gui.MAX_WEAPON_SLOTS) do
		if (check_type == "masks" and M_blackmarket:is_mask_slot_unlocked(i) or M_blackmarket:is_weapon_slot_unlocked(check_type, i)) and not M_blackmarket._global.crafted_items[check_type][i] then
			slot = i
			break
		end
	end
	add_all_items(items_override or items, true)
	if factory_id then
		backuper:backup('MoneyManager.on_buy_weapon_platform')
		function MoneyManager:on_buy_weapon_platform() end
		M_blackmarket:on_buy_weapon_platform(weapon_type, M_weapon_factory:get_weapon_id_by_factory_id(factory_id), slot)
		for _, item in pairs(items) do
			M_blackmarket:buy_and_modify_weapon(weapon_type, slot, M_blackmarket:get_global_value(item[1], item[2]), item[2])
			local factory = tweak_data.weapon.factory.parts[item[2]]
			if factory then
				if factory.texture_switch then
					M_blackmarket:set_part_texture_switch(weapon_type, slot, item[2], "1 1")
				end
			end
		end
		backuper:restore('MoneyManager.on_buy_weapon_platform')
	else
		backuper:backup('BlackMarketManager.view_mask')
		function BlackMarketManager:view_mask() end
		backuper:backup('MoneyManager.on_buy_mask')
		function MoneyManager:on_buy_mask() end
		M_blackmarket:on_buy_mask_to_inventory(items[1][2], M_blackmarket:get_global_value(items[1][1], items[1][2]), slot)
		M_blackmarket:start_customize_mask(slot)
		for i = 2, #items do
			if items[i] then
				M_blackmarket:select_customize_mask(items[i][1], items[i][2], M_blackmarket:get_global_value(items[i][1], items[i][2]))
			end
		end
		M_blackmarket:finish_customize_mask()
		backuper:restore('BlackMarketManager.view_mask')
		backuper:restore('MoneyManager.on_buy_mask')
	end
	M_blackmarket:set_crafted_custom_name(check_type, slot, custom_name)
end

local function get_blackmarket_name(category, id)
	return M_localization:text(T_blackmarket[category][id].name_id)
end

local function get_dlc_name(global_value)
	for _, dlc in pairs(T_gui.content_updates.item_list) do
		if dlc.id == global_value then
			return M_localization:text(dlc.name_id)
		end
	end
	return false
end

local function get_weapon_info(weapon)
	local equipped_mods = deep_clone(weapon.blueprint)
	for _, default_part in pairs(M_weapon_factory:get_default_blueprint_by_factory_id(weapon.factory_id)) do
		tab_delete(equipped_mods, default_part)
	end
	local weapon_id = M_weapon_factory:get_weapon_id_by_factory_id(weapon.factory_id)
	local base_stats = WeaponDescription._get_base_stats(weapon_id)
	local skin_bonus = weapon.cosmetics and weapon.cosmetics.bonus and T_E_bonuses[T_B_weapon_skins[weapon.cosmetics.id].bonus]
	local mods_stats = WeaponDescription._get_mods_stats(weapon_id, base_stats, equipped_mods, M_weapon_factory:has_perk("bonus", weapon.factory_id, weapon.blueprint) or (skin_bonus and skin_bonus.stats))
	local _, max_ammo, ammo_data = WeaponDescription.get_weapon_ammo_info(weapon_id, T_weapon[weapon_id].stats.extra_ammo, base_stats.totalammo.index + mods_stats.totalammo.index)
	base_stats.totalammo.value = ammo_data.base
	mods_stats.totalammo.value = ammo_data.mod
	local my_clip = base_stats.magazine.value + mods_stats.magazine.value
	if max_ammo < my_clip then
		mods_stats.magazine.value = mods_stats.magazine.value + (max_ammo - my_clip)
	end
	local stats = {}
	for _, stat in pairs(WeaponDescription._stats_shown) do
		stats[stat.name] = math.max(base_stats[stat.name].value + mods_stats[stat.name].value, 0)
	end
	return stats, M_weapon_factory:get_perks(weapon.factory_id, equipped_mods), M_weapon_factory:get_custom_stats_from_weapon(weapon.factory_id, weapon.blueprint), skin_bonus
end

local function pass_craft(items, custom_name, factory_id, weapon_type)
	local failed_start = tr['want_that_craft_lock']
	local failed_item
	local failed_reason
	if in_game() then
		failed_item = tr['want_that_in_game']
		failed_reason = tr['want_that_rsn_play']
	end
	if not failed_reason then
		local check_type = not weapon_type and "masks" or weapon_type
		for _, item in pairs(M_blackmarket._global.crafted_items[check_type]) do
			if item.custom_name and item.custom_name == custom_name then
				failed_item = check_type == "masks" and tr['want_that_mask'] or tr['want_that_weapon']
				failed_reason = tr['want_that_rsn_already']
			end
		end
	end
	if not failed_reason and M_blackmarket._global.crafted_items[check_type] then
		local slot_available
		for i = 1, (check_type == "masks" and T_gui.MAX_MASK_ROWS or (check_type == "primaries" or check_type == "secondaries") and T_gui.MAX_WEAPON_ROWS or 3) * 3 do
			if (check_type == "masks" and M_blackmarket:is_mask_slot_unlocked(i) or M_blackmarket:is_weapon_slot_unlocked(check_type, i)) and not M_blackmarket._global.crafted_items[check_type][i] then
				slot_available = true
				break
			end
		end
		if not slot_available then
			failed_item = tr['want_that_slots']
			failed_reason = tr['want_that_rsn_space']
		end
	end
	if not failed_reason and factory_id then
		local weapon_id = M_weapon_factory:get_weapon_id_by_factory_id(factory_id)
		local global_value = T_weapon[weapon_id].global_value
		if not M_blackmarket:weapon_unlocked(weapon_id) then
			failed_reason = tr['want_that_rsn_level']
		elseif global_value and not M_dlc:is_dlc_unlocked(global_value) then
			failed_reason = get_dlc_name(global_value)
		end
		if failed_reason then
			failed_item = M_weapon_factory:get_weapon_name_by_weapon_id(weapon_id)
		end
	elseif not failed_reason then
		for _, item in pairs(items) do
			local item_name = get_blackmarket_name(item[1], item[2])
			local global_value = M_blackmarket:get_global_value(item[1], item[2])
			local infamy_lock = T_blackmarket[item[1]][item[2]].infamy_lock
			local ach_name = M_dlc._achievement_locked_content[item[1]] and M_dlc._achievement_locked_content[item[1]][item[2]]
			local achievement = T_dlc[ach_name] and T_dlc[ach_name].achievement_id
			if global_value == "infamy" and infamy_lock and not M_infamy:owned(infamy_lock) then
				failed_reason = M_localization:text(T_infamy.items[infamy_lock].name_id).." "..M_localization:text("menu_infamytree")
			elseif not infamy_lock and global_value ~= "normal" and global_value ~= "infamous" and global_value ~= "halloween" and not M_dlc:is_dlc_unlocked(global_value) then
				local dlc_name = get_dlc_name(global_value)
				if dlc_name then
					failed_reason = dlc_name
				else
					failed_reason = global_value == "pd2_clan" and tr['want_that_rsn_clan'] or tr['want_that_rsn_unknown']
				end
			elseif M_achievment.achievments[achievement] and not M_achievment.achievments[achievement].awarded then
				failed_reason = tr['want_that_rsn_achieve']
			end
			if failed_reason then
				failed_item = item_name
				break
			end
		end
	end
	return failed_reason and failed_start.." - "..failed_item.." - "..failed_reason or true
end

local function get_free_cosmetic_id()
	local i = 1
	while M_blackmarket._global.inventory_tradable[i] ~= nil do
		i = i + 1
	end
	return i
end

mask_menu = function(mask, peer)
	local items = {
		{'masks', mask.mask_id},
		{'materials', mask.blueprint.material.id},
		{'textures', mask.blueprint.pattern.id},
		{'colors', mask.blueprint.color.id},
	}
	local addable_items = deep_clone(items)
	local data
	if items[1][2] == "character_locked" then
		data = {{text = tr['want_that_stock_mask'], switch_back = true}}
	else
		local mask_name = get_blackmarket_name(items[1][1], items[1][2])
		local custom_name = peer:name().." - "..mask_name
		data = {
			{text = tr['want_that_add_all'], callback = add_all_items, data = {addable_items}, switch_back = true},
			{},
			{text = tr['want_that_add_mask']..":  "..mask_name, callback = add_single_item, data = addable_items[1], switch_back = true},
			{},
		}
		if addable_items[2][2] == 'plastic' then
			addable_items[2] = nil
		end
		if addable_items[3][2] == 'no_color_no_material' or addable_items[3][2] == 'no_color_full_material' then
			addable_items[3] = nil
		end
		if addable_items[4][2] == 'nothing' then
			addable_items[4] = nil
		end
		local labels = {[2] = tr['want_that_add_mat'], [3] = tr['want_that_add_pat'], [4] = tr['want_that_add_color']}
		for i = 4, 2, -1 do
			if addable_items[i] then
				tab_insert(data, 5, {text = labels[i]..":  "..get_blackmarket_name(addable_items[i][1], addable_items[i][2]), callback = add_single_item, data = addable_items[i], switch_back = true})
			end
		end
		local craft_enabled = pass_craft(addable_items, custom_name)
		if craft_enabled == true then
			tab_insert(data, 2, {text = tr['want_that_craft_mask'], callback = craft_item, data = {items, addable_items, custom_name}, switch_back = function() mask_menu(mask, peer) end})
		else
			tab_insert(data, 2, {text = craft_enabled, switch_back = true})
		end
	end

	Menu_open(Menu, {title = peer:name().." - "..tr['want_that_mask'], description = tr['want_that_item_desc'], button_list = data, back = function() inventory_menu(peer) end})
end

weapon_stats_menu = function(weapon, peer, weapon_type)
	local stats, perks, custom_stats, skin_bonus = get_weapon_info(weapon)
	data = {
		{},
		{text = perks.silencer and "+ "..tr['want_that_silenced'] or "", switch_back = true},
		{text = perks.scope and "+ "..tr['want_that_scope'] or "", switch_back = true},
		{text = perks.gadget and "+ "..tr['want_that_gadget'] or "", switch_back = true},
		{text = perks.bipod and "+ "..tr['want_that_bipod'] or "", switch_back = true},
		{text = perks.highlight and "+ "..tr['want_that_auto_hi'] or "", switch_back = true},
		{text = perks.fire_mode_single and "+ "..tr['want_that_lock_single'] or perks.fire_mode_auto and "+ "..tr['want_that_lock_auto'] or "", switch_back = true},
		{text = custom_stats.can_shoot_through_shield and custom_stats.can_shoot_through_wall and "+ "..tr['want_that_bullet_pen'] or "", switch_back = true},
		{text = custom_stats.armor_piercing_add and "+ "..tr['want_that_armor_pierce'] or "", switch_back = true},
		{text = custom_stats.movement_speed and "+ "..tr['want_that_move_speed'] or "", switch_back = true},
		{text = skin_bonus and "+ "..tr['want_that_skin_bonus']..":  "..M_localization:text(skin_bonus.name_id, {team_bonus = ((skin_bonus.exp_multiplier or skin_bonus.money_multiplier or 1) * 100 - 100).."%"}), switch_back = true},
	}
	for i = 8, 1, -1 do
		local stat_name = WeaponDescription._stats_shown[i].name
		tab_insert(data, 1, {text = M_localization:text("bm_menu_"..stat_name)..":  "..stats[stat_name], switch_back = true})
	end

	Menu_open(Menu, {title = peer:name().." - "..M_weapon_factory:get_weapon_name_by_factory_id(weapon.factory_id), description = "* "..tr['want_that_stats_desc'], button_list = data, back = function() weapon_menu(weapon, peer, weapon_type) end})
end

weapon_menu = function(weapon, peer, weapon_type)
	local items = {}
	local def_blueprint = T_weapon.factory[weapon.factory_id].default_blueprint
	if not (weapon.cosmetics and T_B_weapon_skins[weapon.cosmetics.id].rarity == "legendary") then
		for _, mod in pairs(weapon.blueprint) do
			local add = true
			for _, def_item in pairs(def_blueprint) do
				if mod == def_item then
					add = false
					break
				end
			end
			if add then
				tab_insert(items, {'weapon_mods', mod})
			end
		end
	end
	local weapon_name = M_weapon_factory:get_weapon_name_by_factory_id(weapon.factory_id)
	local custom_name = peer:name().." - "..weapon_name
	local data = {
		{text = tr['want_that_add_all'], callback = add_all_items, data = {items}, switch_back = true},
		{text = tr['want_that_view_stats'], callback = weapon_stats_menu, data = {weapon, peer, weapon_type}, menu = true},
		{},
		{text = tr['want_that_weapon']..":  "..weapon_name, switch_back = true},
		{},
	}
	local craft_enabled = pass_craft(items, custom_name, weapon.factory_id, weapon_type)
	if craft_enabled == true then
		tab_insert(data, 2, {text = tr['want_that_craft_wep'], callback = craft_item, data = {items, nil, custom_name, weapon.factory_id, weapon_type}, switch_back = function() weapon_menu(weapon, peer, weapon_type) end})
	else
		tab_insert(data, 2, {text = craft_enabled, switch_back = true})
	end
	if #items == 0 then
		tab_insert(data, {text = tr['want_that_stock_weapon'], switch_back = true})
	else
		for _, item in pairs(items) do
			tab_insert(data, {text = tr['want_that_add_mod']..":  "..get_blackmarket_name(item[1], item[2]), callback = add_single_item, data = item, switch_back = true})
		end
	end
	if weapon.cosmetics then
		local has_skin = M_blackmarket:tradable_verify("weapon_skins", weapon.cosmetics.id, weapon.cosmetics.quality, weapon.cosmetics.bonus, M_blackmarket:get_inventory_tradable())
		tab_insert(data, {text = has_skin and "("..tr['want_that_have_skin']..")" or tr['want_that_add_skin']..":  "..get_blackmarket_name("weapon_skins", weapon.cosmetics.id).." - "..M_localization:text(T_E_qualities[weapon.cosmetics.quality].name_id)..(weapon.cosmetics.bonus and " - "..tr['want_that_skin_bonus'] or ""), callback = not has_skin and M_blackmarket:tradable_add_item(get_free_cosmetic_id(), "weapon_skins", weapon.cosmetics.id, weapon.cosmetics.quality, weapon.cosmetics.bonus, 1) or nil, switch_back = true})
	end

	Menu_open(Menu, {title = peer:name().." - "..(weapon_type == "primaries" and tr['want_that_primary'] or tr['want_that_secondary']), description = tr['want_that_item_desc'].." "..tr['want_that_item_desc_wep'], button_list = data, back = function() inventory_menu(peer) end})
end

inventory_menu = function(peer)
	local outfit = peer:blackmarket_outfit()
	local data = {
		{text = tr['want_that_mask']..":  "..get_blackmarket_name('masks', outfit.mask.mask_id), callback = mask_menu, data = {outfit.mask, peer}, menu = true},
		{text = tr['want_that_primary']..":  "..M_weapon_factory:get_weapon_name_by_factory_id(outfit.primary.factory_id), callback = weapon_menu, data = {outfit.primary, peer, "primaries"}, menu = true},
		{text = tr['want_that_secondary']..":  "..M_weapon_factory:get_weapon_name_by_factory_id(outfit.secondary.factory_id), callback = weapon_menu, data = {outfit.secondary, peer, "secondaries"}, menu = true},
	}

	Menu_open(Menu, {title = peer:name().." - "..tr['want_that_inventory'], button_list = data, back = player_menu})
end

player_menu = function()
	local peers = M_network and M_network:session() and M_network:session():peers()
	local data = {}
	if peers then
		if tab_size(peers) > 0 then
			for _, peer in pairs(peers) do
				tab_insert(data, {text = peer:name(), callback = inventory_menu, data = {peer}, menu = true})
			end
		else
			tab_insert(data, {text = tr['want_that_alone'], switch_back = true})
		end
		tab_insert(data, {})
		local yourself = M_network:session():local_peer()
		tab_insert(data, {text = tr['want_that_you']..":  "..yourself:name(), callback = inventory_menu, data = {yourself}, menu = true})
	else
		data = {
			{},
			{},
			{text = tr['want_that_offline'], switch_back = true}
		}
	end

	Menu_open(Menu, {title = tr['want_that_title'], description = tr['want_that_desc'], button_list = data})
end

player_menu()