--Author: Simplity

local ppr_require = ppr_require
ppr_require 'Trainer/tools/new_menu/menu'

local ppr_dofile = ppr_dofile
local pairs = pairs
local ipairs = ipairs
local io_open = ppr_io.open
local tab_insert = table.insert

local managers = managers

local Global = Global
local G_S_trees = Global.skilltree_manager.trees
local G_blackmarket = Global.blackmarket_manager

local tweak_data = tweak_data
local T_S_trees = tweak_data.skilltree.trees
local T_S_skills = tweak_data.skilltree.skills

local M_blackmarket = managers.blackmarket
local M_experience = managers.experience
local M_money = managers.money
local M_skilltree = managers.skilltree
local M_infamy = managers.infamy
local M_achievement = managers.achievment
local M_localization = managers.localization
local M_safehouse = managers.custom_safehouse

local G_safehouse = Global.custom_safehouse_manager
local G_specs = Global.skilltree_manager.specializations

local tr = Localization.translate
local tr_trees = {
	M_localization:text('st_menu_mastermind'),
	M_localization:text('st_menu_enforcer'),
	M_localization:text('st_menu_technician'),
	M_localization:text('st_menu_ghost'),
	M_localization:text('st_menu_hoxton_pack')
}

local togg_vars = togg_vars

local Menu = Menu
local Menu_open = Menu.open

local main_menu, crimespree_menu, safehouse_menu, inventory_menu, infamy_menu, skill_menu, money_menu, level_menu, remove_items_menu, secret_skills_menu

local path = "Trainer/addons/main_menu/"

-- Functions
-- Level
local function change_level( level )
	M_experience:_set_current_level( level )
end

local function add_exp( value )
	M_experience:debug_add_points( value, false )
end

-- Money
local function add_money( value )
	M_money:_add_to_total( value )
end

local function reset_money()
	M_money:reset()
end

-- Skill points
local function set_skillpoints( value )
	M_skilltree:_set_points( value )
end

local function unlock_all_skills()
	local unlock_skill_tree = M_skilltree.unlock_tree
	local unlock_skill = M_skilltree.unlock
	for tree_id, tree_data in pairs( Global.skilltree_manager.trees ) do
		unlock_skill_tree(M_skilltree, tree_id)
		for _, skills in ipairs( T_S_trees[ tree_id ].tiers ) do
			for _, skill_id in ipairs( skills ) do
				unlock_skill(M_skilltree, skill_id)
			end
		end
	end
end

local function set_perk_points( points )
	G_specs.total_points = points
	G_specs.points = points
end

local function reset_perks()
	M_skilltree:reset_specializations()
end

-- Infamy
local function set_infamy_level(level)
	M_experience:set_current_rank(level)
end

local function set_infamy_points(value)
	M_infamy:_set_points(value)
end

-- Inventory
local function unlock_slots()
	local unlocked_mask_slots = G_blackmarket.unlocked_mask_slots
	local unlocked_weapon_slots = G_blackmarket.unlocked_weapon_slots
	local unlocked_primaries = unlocked_weapon_slots.primaries
	local unlocked_secondaries = unlocked_weapon_slots.secondaries
	for i = 1, 500 do
		unlocked_mask_slots[i] = true 
		unlocked_primaries[i] = true
		unlocked_secondaries[i] = true
	end
end

local unlock_items = function( item_type )
	ppr_require ( path .. 'unlock_items' )
	for i = 1, 10 do
		unlock_items( item_type )
	end
end

local function delete_items()
	ppr_require ( path .. 'clear_inventory' )
end

local clear_slots = function( category )
	ppr_require ( path .. 'clear_slots' )
	
	clear_slots( category )
end

local remove_exclamation = function()
	Global.blackmarket_manager.new_drops = {}
end

-- Unlock Achievemtents
local function unlock_achievements()
	local _award = M_achievement.award
	for id in pairs(M_achievement.achievments) do
		_award(M_achievement, id)
	end
end

-- Lock Achievemtents
local function lock_achievements()
	M_achievement:clear_all_steam()
end

-- Set Continental Coins
local function set_continental_coins(value)
	Global.custom_safehouse_manager.total = Application:digest_value(value, true)
end

-- Max out all Safehouse Rooms
local function max_rooms_tier()
	for room_id, data in pairs(G_safehouse.rooms) do
		local max_tier = data.tier_max
		
		local current_tier = M_safehouse:get_room_current_tier(room_id)
		while max_tier > current_tier do
			current_tier = current_tier + 1
			
			local unlocked_tiers = M_safehouse._global.rooms[room_id].unlocked_tiers
			tab_insert(unlocked_tiers, current_tier)
		end
		
		M_safehouse:set_room_tier(room_id, max_tier)
	end
end

-- Unlock all Safehouse Trophies
local function unlock_safehouse_trophies()
	local trophies = M_safehouse:trophies()
	for _, trophy in pairs(trophies) do
		for objective_id in pairs (trophy.objectives) do
			local objective = trophy.objectives[objective_id]
			objective.verify = false
			M_safehouse:on_achievement_progressed(objective.progress_id, objective.max_progress)
		end
	end
end

-- Automatically Complete All Challenges
local function Auto_Complete_All_Challenges()
	local AutoCompleteChallenge = AutoCompleteChallenge or ChallengeManager.activate_challenge
	function ChallengeManager:activate_challenge(id, key, category)
		if self:has_active_challenges(id, key) then
			local active_challenge = self:get_active_challenge(id, key)
			active_challenge.completed = true
			active_challenge.category = category
			return true
		end
		return AutoCompleteChallenge(self, id, key, category)
	end
end

-- Automatically Complete The Safehouse Daily Challenge
local function Auto_Complete_Safehouse_Challenge()
	if not CustomSafehouseManager then return end
	function CustomSafehouseManager:set_active_daily(id)
		if self:get_daily_challenge() and self:get_daily_challenge().id ~= id then
			self:generate_daily(id)
		end
		self:complete_daily(id)
	end
end

-- Crime Spree
local function set_crimespree_spree_level(value)
	function CrimeSpreeManager:spree_level()
		return self:in_progress() and (value) or -1
	end
end

local function set_crimespree_reward_level(value)
	function CrimeSpreeManager:reward_level()
		return self:in_progress() and (value) or -1
	end
end

local function set_crimespree_catchup_bonus(value)
	function CrimeSpreeManager:catchup_bonus()
		return math.floor(value)
	end
end

local function set_crimespree_winning_streak_bonus(value)
	function CrimeSpreeManager:winning_streak_bonus()
		return math.floor(value or 0)
	end
end

-- Secret Skills by AidenP
local secert_skills_ver = 2
local secret_skills

do
	togg_vars['secret_skills_save'] = true

	local skills_path = "Trainer/configs/secret_skills/skills_config.lua"
	local f = io_open(skills_path, "r")
	if f then
		f:close()
		local secret_skills_temp, _, ver = ppr_dofile(skills_path)
		if ver == secert_skills_ver then
			secret_skills = secret_skills_temp
		end
	end
	if secret_skills == nil then
		secret_skills = {}
	end
end

local function check_skill(skill, level)
	return secret_skills[skill] and secret_skills[skill][level]
end

local function toggle_skill(skill, level)
	if not secret_skills[skill] then
		secret_skills[skill] = {}
	end
	secret_skills[skill][level] = not secret_skills[skill][level]
	if not secret_skills[skill][level] then
		secret_skills[skill][level] = nil
	end
	if not secret_skills[skill][1] and not secret_skills[skill][2] then
		secret_skills[skill] = nil
	end
end

local function create_secret_skills_sub_menu(name, skilltree)
	local data = {}
	for _, row in pairs(skilltree.tiers) do
		for _, skill in pairs(row) do
			for i = 1, 2 do
				tab_insert(data, {
					text = M_localization:text(T_S_skills[skill].name_id)..(i == 2 and " "..tr['aced'] or ""),
					type = "toggle",
					toggle = function() return check_skill(skill, i) end,
					callback = function() toggle_skill(skill, i) end,
					switch_back = true,
				})
			end
		end
	end
	Menu_open(Menu, {title = name, button_list = data, back = secret_skills_menu})
end

local function create_secret_skills_menu(tree)
	local data = {}
	local offset = 3 * (tree - 1)
	for _ = 1, 3 do
		offset = offset + 1
		local skilltree = T_S_trees[offset]
		local name = M_localization:text(skilltree.name_id)
		tab_insert(data, {
			text = name,
			callback = create_secret_skills_sub_menu,
			data = {name, skilltree},
			menu = true,
		})
	end
	Menu_open(Menu, {title = tr_trees[tree], button_list = data, back = secret_skills_menu})
end

local function save_skills()
	local save_file = io_open("Trainer/configs/secret_skills/skills_config.lua", "w")
	local menu_write = "return {\n"
	local ingame_write = "}, {\n"
	for skill, skill_levels in pairs(secret_skills) do
		menu_write = menu_write.."\t"..skill.." = {\n"
		for level, _ in pairs(skill_levels) do
			menu_write = menu_write.."\t\t["..level.."] = true,\n"
			for _, upgrade in pairs(T_S_skills[skill][level].upgrades) do
				ingame_write = ingame_write.."\t\""..upgrade.."\",\n"			
			end
		end
		menu_write = menu_write.."\t},\n"
	end
	save_file:write(menu_write..ingame_write.."},"..secert_skills_ver)
	save_file:close()
end

-- Menu
level_menu = function()	
	local data = { 
		{ text = tr['level_revolver'], plugin = "level_revolver" },
		{},
		{},
		{ text = tr['set_level'] .. ":", type = "slider", slider_data = { name = "set_level", value = 0, max = 255 }, switch_back = true },
		{ text = tr['save'], type = "save_button", callback = change_level, name = "set_level" },
		{},
		{ text = tr['add_exp'] .. ":", type = "slider", slider_data = { name = "add_exp", value = 0, max = 1000000 }, switch_back = true },
		{ text = tr['save'], type = "save_button", callback = add_exp, name = "add_exp" },
	}
	
	Menu_open(Menu,  { title = tr['level_title'], description = tr['level_desc'], button_list = data, plugin_path = path, back = main_menu } )
end

money_menu = function()
	local data = { 
		{ text = tr['add_money_1'], callback = function() add_money(5000000) end },
		{ text = tr['add_money_2'], callback = function() add_money(50000000) end },
		{ text = tr['add_money_3'], callback = function() add_money(500000000) end },
		{},
		{ text = tr['add_money_4'], callback = function() add_money(5000000000) end },
		{ text = tr['add_money_5'], callback = function() add_money(50000000000) end },
		{ text = tr['add_money_6'], callback = function() add_money(500000000000) end },
		{},
		{ text = tr['add_money_7'], callback = function() add_money(9999999999999) end },
		{},
		{ text = tr['add_money'] .. ":", type = "slider", slider_data = { name = "add_money", value = 0, max = 5000000 }, switch_back = true },
		{ text = tr['save'], type = "save_button", callback = add_money, name = "add_money" },
		{},
		--{ text = tr['add_money'] ..":", type = "input", callback_input = function() add_money() end, switch_back = true },
		{},
		{ text = tr['reset_money'], callback = reset_money },
	}
	
	Menu_open(Menu,  { title = tr['money_title'], description = tr['money_desc'], button_list = data, back = main_menu } )
end

skill_menu = function()
	local data = {
		{ text = tr['unlock_all_skills'], callback = function() for i = 1, 2 do unlock_all_skills() end end },
		{ text = tr['unlock_tiers'], callback = ppr_dofile, data = path .. "unlock_tiers" },
		{},
		{ text = tr['set_points'] .. ":", type = "slider", slider_data = { name = "skill_points", value = 0, max = 690 }, switch_back = true },
		{ text = tr['save'], type = "save_button", callback = set_skillpoints, name = "skill_points" },
		{},
		{ text = tr['reset_points'], callback = set_skillpoints, data = 0 },
		{},
		{ text = tr['unlock_perks'], callback = function() ppr_dofile(path..'unlock_all_specs') end },
		{ text = tr['lock_perks'], callback = reset_perks },
		{},
		{ text = tr['set_perks'] .. ":", type = "slider", slider_data = { name = "perk_points", value = 0, max = 205500 }, switch_back = true },
		{ text = tr['save'], type = "save_button", callback = set_perk_points, name = "perk_points" },
		{},
		{ text = tr['reset_perk_points'], callback = function() G_specs.points = 0 end },
	}
	
	Menu_open(Menu,  { title = tr['skill_title'], description = tr['skill_desc'], button_list = data, back = main_menu } )
end

infamy_menu = function()
	local data = { 
		{ text = tr['set_inf'] .. ':', type = "slider", slider_data = { name = "inf_level", value = 0, max = 25 }, switch_back = true },
		{ text = tr['save'], type = "save_button", callback = set_infamy_level, name = "inf_level" },
		{},
		{ text = tr['set_inf_points'] .. ':', type = "slider", slider_data = { name = "inf_points", value = 0, max = 25 }, switch_back = true },
		{ text = tr['save'], type = "save_button", callback = set_infamy_points, name = "inf_points" },
		{},
		{ text = tr['reset_inf'], callback = function() set_infamy_level(0) end },
	}
		
	Menu_open(Menu,  { title = tr['inf_title'], description = tr['inf_desc'], button_list = data, back = main_menu } )
end

inventory_menu = function()
	local data = {
		{ text = tr['safe_sim'], callback = ppr_dofile, data = path.."safe_sim", menu = true},
		{},
		{ text = tr['remove_exclamation'], callback = remove_exclamation, switch_back = true},
		{ text = tr['no_weap_mod_limit'], plugin = "no_weap_mod_limit", switch_back = true},
		{},
		{ text = tr['unlock_slots'], callback = unlock_slots },
		{ text = tr['unlock_all'], callback = unlock_items, data = "all" },
		{},
		{ text = tr['unlock_weapons'], callback = unlock_items, data = "weapons" },
		{ text = tr['unlock_weap_mods'], callback = unlock_items, data = "weapon_mods" },
		{ text = tr['unlock_all_weapon_skins'], callback = ppr_dofile, data = "Trainer/addons/all_weaponskins.lua" },
		{},
		{ text = tr['unlock_masks'], callback = unlock_items, data = "masks" },
		{ text = tr['unlock_materials'], callback = unlock_items, data = "materials" },
		{ text = tr['unlock_textures'], callback = unlock_items, data = "textures" },
		{ text = tr['unlock_colors'], callback = unlock_items, data = "colors" },
		{ text = tr['unlock_all_armor_skins'], callback = ppr_dofile, data = "Trainer/addons/all_armorskins.lua" },
		{},
		{ text = tr['clear_inventory_menu'], callback = remove_items_menu, menu = true },
	}

	Menu_open(Menu,  { title = tr['inv_title'], description = tr['inv_desc'], button_list = data, plugin_path = path, back = main_menu } )
end

remove_items_menu = function()
	local data = {
		{ text = tr['lock_all_items'], callback = delete_items },
		{},
		{ text = tr['clear_all_slots'], callback = clear_slots, data = "all" },
		{},
		{ text = tr['clear_primaries_slots'], callback = clear_slots, data = "primaries" },
		{},
		{ text = tr['clear_secondaries_slots'], callback = clear_slots, data = "secondaries" },
		{},
		{ text = tr['clear_masks_slots'], callback = clear_slots, data = "masks" },
	}

	Menu_open(Menu,  { title = tr['clear_inventory_menu'], description = tr['clear_inventory_desc'], button_list = data, back = inventory_menu } )
end

safehouse_menu = function()
	local data = {
		{ text = tr['unlock_achievements'], callback = unlock_achievements },
		{ text = tr['lock_achievements'], callback = lock_achievements },
		{},
		{ text = tr['Auto_Complete_All_Challenges'], callback = Auto_Complete_All_Challenges },
		{ text = tr['Auto_Complete_Safehouse_Challenge'], callback = Auto_Complete_Safehouse_Challenge },
		{},
		{ text = tr['unlock_safehouse_trophies'], callback = unlock_safehouse_trophies },
		{ text = tr['unlock_tier_3_rooms'], callback = max_rooms_tier },
		{},
		{ text = tr['set_continental_coins'] .. ':', type = "slider", slider_data = { name = "set_continental_coins", value = 0, max = 1000 }, switch_back = true },
		{ text = tr['save'], type = "save_button", callback = set_continental_coins, name = "set_continental_coins" },
	}

	Menu_open(Menu,  { title = tr['safehouse_title'], description = tr['safehouse_desc'], button_list = data, back = main_menu } )
end

crimespree_menu = function()
	local data = {
		{},
		{ text = tr['set_crimespree_spree_level'] .. ":", type = "slider", slider_data = { name = "set_crimespree_spree_level", value = 0, max = 10000 }, switch_back = true },
		{ text = tr['save'], type = "save_button", callback = set_crimespree_spree_level, name = "set_crimespree_spree_level" },
		{},
		{ text = tr['set_crimespree_reward_level'] .. ":", type = "slider", slider_data = { name = "set_crimespree_reward_level", value = 0, max = 10000 }, switch_back = true },
		{ text = tr['save'], type = "save_button", callback = set_crimespree_reward_level, name = "set_crimespree_reward_level" },
		{},
		{ text = tr['set_crimespree_catchup_bonus'] .. ":", type = "slider", slider_data = { name = "set_crimespree_catchup_bonus", value = 0, max = 10000 }, switch_back = true },
		{ text = tr['save'], type = "save_button", callback = set_crimespree_catchup_bonus, name = "set_crimespree_catchup_bonus" },
		{},
		{ text = tr['set_crimespree_winning_streak_bonus'] .. ":", type = "slider", slider_data = { name = "set_crimespree_winning_streak_bonus", value = 0, max = 10000 }, switch_back = true },
		{ text = tr['save'], type = "save_button", callback = set_crimespree_winning_streak_bonus, name = "set_crimespree_winning_streak_bonus" },
	}

	Menu_open(Menu,  { title = tr['crimespree_title'], description = tr['crimespree_desc'], button_list = data, back = main_menu } )
end

secret_skills_menu = function()
	local data = {}
	for i = 1, 5 do
		tab_insert(data, {text = tr_trees[i], callback = create_secret_skills_menu, data = i, menu = true})
	end
	tab_insert(data, {})
	tab_insert(data, {text = tr['save'], type = "save_button", callback = save_skills, name = "secret_skills_save"})

	Menu_open(Menu, {title = tr['secret_skills_title'], description = tr['secret_skills_desc'], button_list = data, back = main_menu})
end

main_menu = function()
	local data = {
		{ text = tr['base_menu'], callback = ppr_dofile, data = 'Trainer/menu/pre-game/base_menu', menu = true },
		{ text = tr['safehouse_title'], callback = safehouse_menu, menu = true },
		{ text = tr['money_title'], callback = money_menu, menu = true },
		{ text = tr['level_title'], callback = level_menu, menu = true },
		{ text = tr['skill_title'], callback = skill_menu, menu = true },
		{ text = tr['secret_skills_title'], callback = secret_skills_menu, menu = true },
		{ text = tr['inf_title'], callback = infamy_menu, menu = true },
		{ text = tr['crimespree_title'], callback = crimespree_menu, menu = true },
		{ text = tr['inv_title'], callback = inventory_menu, menu = true },
		{ text = tr['inv_spec_menu'], callback = ppr_dofile, data = 'Trainer/menu/pre-game/allitemsmenu', menu = true },
	}
	
	Menu_open(Menu,  { title = tr['main_menu_title'], description = tr['main_menu_desc'], button_list = data } )
end

--TO DO: Reoptimise it wisely
return main_menu