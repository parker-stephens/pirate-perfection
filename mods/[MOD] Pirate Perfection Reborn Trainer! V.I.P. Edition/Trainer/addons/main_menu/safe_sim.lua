--  Author:  The Joker
--  Purpose:  Open an unlimited number of safes completely under your control
local os = os
local pairs = pairs
local tostring = tostring

local rand = math.random
local randseed = math.randomseed
local tab_insert = table.insert

local managers = managers
local M_blackmarket = managers.blackmarket
local M_localization = managers.localization

local tweak_data = tweak_data
local T_economy = tweak_data.economy
local T_B_weapon_skins = tweak_data.blackmarket.weapon_skins

local T_E_armor_skins = T_economy.armor_skins
local T_E_contents = T_economy.contents
local T_E_qualities = T_economy.qualities
local T_E_rarities = T_economy.rarities
local T_E_safes = T_economy.safes

local togg_vars = togg_vars

local Menu = Menu
local Menu_open = Menu.open

local tr = Localization.translate

local main_menu, chance_menu

local r_index_armor = {"uncommon", "rare", "epic"}
local r_index_weapon = {"common", "uncommon", "rare", "epic", "legendary"}
local q_index = {"poor", "fair", "good", "fine", "mint"}
local sim_chances = {
	r = {65, 20, 10, 4, 1},
	q = {20, 20, 20, 20, 20},
	stat = 10
}

local function get_total(index, t)
	local total = 0
	for i, n in pairs(index) do
		total = total + (togg_vars["sim_"..n] and togg_vars["sim_"..n] or sim_chances[t][i])
	end
	return total
end

local function random_choice(index, t)
	local total = get_total(index, t)
	local rand_n = rand(total)
	local track = 0
	for i, n in pairs(index) do
		local var = togg_vars["sim_"..n]
		local prob = var or sim_chances[t][i]
		if prob > 0 and rand_n > track and rand_n <= track + prob then
			return n
		end
		track = track + prob
	end
	return index[1]
end

local function choose_item(safe)
	local is_weapon = T_E_contents[safe.content].contains.weapon_skins
	local r_index_over = is_weapon and safe.content == "overkill_01" and {"rare", "epic", "legendary"} or nil
	local data = {amount = 1, category = is_weapon and "weapon_skins" or "armor_skins"}
	local now = os.date("!*t")
	randseed(now.yday * (now.hour + 1) * (now.min + 1) * (now.sec + 1))
	data.bonus = is_weapon and rand(100) <= (togg_vars["sim_stat"] or sim_chances.stat)
	local rarity = random_choice(is_weapon and r_index_weapon or r_index_over or r_index_armor, "r")
	local skin_index = {}
	if rarity == "legendary" then
		local legend_contents = T_E_contents[safe.content].contains.contents
		for _, skin in pairs(T_E_contents[legend_contents[rand(#legend_contents)]].contains[data.category]) do
			tab_insert(skin_index, skin)
		end
	else
		local group = is_weapon and T_B_weapon_skins or T_E_armor_skins
		for _, skin in pairs(T_E_contents[safe.content].contains[data.category]) do
			if group[skin].rarity == rarity then
				tab_insert(skin_index, skin)
			end
		end
	end
	data.entry = skin_index[rand(#skin_index)]
	data.quality = is_weapon and random_choice(q_index, "q") or nil
	data.def_id = 101
	local i = 1
	while M_blackmarket._global.inventory_tradable[tostring(i)] ~= nil do
		i = i + 1
	end
	data.instance_id = tostring(i)
	return data
end

local function start_open(name, data)
	local function ready_clbk()
		managers.menu:back()
		managers.system_menu:force_close_all()
		managers.menu_component:set_blackmarket_enabled(false)
		managers.menu:open_node("open_steam_safe", {data.content})
	end
	managers.menu_component:set_blackmarket_disable_fetching(true)
	managers.menu_component:set_blackmarket_enabled(false)
	managers.menu_scene:create_economy_safe_scene(name, ready_clbk)
	local item = choose_item(data)
	MenuCallbackHandler:_safe_result_recieved(nil, {item}, {})
	if togg_vars.sim_add then
		M_blackmarket:tradable_add_item(item.instance_id, item.category, item.entry, item.quality, item.bonus, 1)
	end
end

chance_menu = function()
	local r_total = get_total(r_index_weapon, "r")
	local data = {{text = tr.safe_sim_rarity..r_total, switch_back = true}}
	for i, r in pairs(r_index_weapon) do
		tab_insert(data, {text = M_localization:text(T_E_rarities[r].name_id), type = "slider", slider_data = {name = "sim_"..r, value = sim_chances.r[i], max = 100}, switch_back = true})
	end
	tab_insert(data, {})
	tab_insert(data, {})
	local q_total = get_total(q_index, "q")
	tab_insert(data, {text = tr.safe_sim_quality..q_total, switch_back = true})
	for i, q in pairs(q_index) do
		tab_insert(data, {text = M_localization:text(T_E_qualities[q].name_id), type = "slider", slider_data = {name = "sim_"..q, value = sim_chances.q[i], max = 100}, switch_back = true})
	end
	tab_insert(data, {})
	tab_insert(data, {})
	tab_insert(data, {text = tr.safe_sim_stat, type = "slider", slider_data = {name = "sim_stat", value = sim_chances.stat, max = 100}, switch_back = true})
	tab_insert(data, {})
	tab_insert(data, {text = tr.reset, callback = function() for _, t in pairs({r_index_weapon, q_index}) do for _, i in pairs(t) do togg_vars["sim_"..i] = nil end end togg_vars["sim_stat"] = nil chance_menu() end})

	Menu_open(Menu, {title = tr.safe_sim_chances, description = tr.safe_sim_chances_desc, button_list = data, back = main_menu})
end

main_menu = function()
	local data = {
		{text = tr.safe_sim_add_skin, type = "toggle", toggle = "sim_add", callback = function() togg_vars.sim_add = not togg_vars.sim_add end, switch_back = true},
		{text = tr.safe_sim_chances, callback = chance_menu, menu = true},
		{},
	}
	for safe, safe_d in pairs(T_E_safes) do
		tab_insert(data, {text = M_localization:text(safe_d.name_id), callback = start_open, data = {safe, safe_d}})
	end

	Menu_open(Menu, {title = tr.safe_sim, description = tr.safe_sim_desc, button_list = data})
end

main_menu()