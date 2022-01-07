--Purpose: lets you quickly host the heist or change it if you're hosting already.
--Notes: Different approach of grabbing jobs. Now I use tweak_data.narrative.jobs to grab all heists.
--Authors: baldwin, Simplity & JazzyDude

local ppr_require = ppr_require
ppr_require 'Trainer/tools/new_menu/menu'
ppr_require 'Trainer/job_stuff/host_game'

local io_open = ppr_io.open
local pairs = pairs
local tab_insert = table.insert

local managers = managers
local M_custom_safehouse = managers.custom_safehouse
local M_localization = managers.localization
local locale_text = M_localization.text
local locale_exists = M_localization.exists
local M_N_matchmake = managers.network.matchmake
local ppr_config = ppr_config
local tweak_data = tweak_data
local T_narrative = tweak_data.narrative
local T_N_contacts = T_narrative.contacts
local T_N_jobs = T_narrative.jobs
local T_levels = tweak_data.levels
local T_escape_levels = T_levels.escape_levels

local SwapJobQuick = SwapJobQuick
local G_game_settings = Global.game_settings
local NetworkMatchMakingSTEAM = NetworkMatchMakingSTEAM

local togg_vars = togg_vars

local Menu = Menu
local Menu_open = Menu.open

local def_difficulty = ppr_config.jobmenu_def_difficulty
local is_singleplayer = ppr_config.jobmenu_singleplayer

local contact_menus = {} --Here will be preloaded contact menus

local main,contact_menu,heist_menu,stage_menu,escapes_menu,crewfinder_menu

--local odd_heists = ppr_config.jobmenu_odd_jobs or {}

local tr = Localization.translate --Shortened Localization.translate

local patch_heists = { safehouse = 'ukrainian_job' } --List of heists, these needs fake_name in order to properly host.
													 --TO DO: Add heists, that aren't supposed to be pro jobs and turn them into pro jobs here and vice versa


local swap_job = function(job_name,name_id,stage)
	SwapJobQuick(job_name,name_id,patch_heists[name_id],def_difficulty or 'overkill_145',nil,true, is_singleplayer, stage)
end

local function change_diff(new)
	ppr_config.jobmenu_def_difficulty = new
end

local escape_menu_data

escapes_menu = function()
	local _text = locale_text
	local data = escape_menu_data
	if (not data) then
		data = {}
		local levels = T_levels
		for _, level_name in pairs( T_escape_levels ) do
			local level = levels[ level_name ]
			if level then
				local name_id = level.name_id
				if (name_id) then
					tab_insert(data, { text = _text(M_localization, name_id), callback = function() swap_job('ukrainian_job', level_name) end })
				end
			end
		end
		data = { title = tr.job_menu_escapes, button_list = data, back = main }
		escape_menu_data = data
	end
	
	Menu_open( Menu, data )
end

stage_menu = function(job_name, job_name_id, job_chain, contact)
	local _text = locale_text
	local data = {}
	local chain_data = job_chain[1]
	for i in pairs( job_chain ) do
		tab_insert(data, { text = "Day " .. i, callback = function() swap_job(job_name, chain_data.level_id, i) end })
	end
	
	Menu_open( Menu, { title = _text(M_localization, job_name_id), button_list = data, back = function() contact_menu(contact) end } )
end

contact_menu = function(contact)
	local data = contact_menus[contact]
	local _text = locale_text
	if ( not data ) then
		-- Not preloaded menu, load it now
		data = {}
		local locale_exists = locale_exists
		local get_job_chain = T_narrative.job_chain
		for job_name,job in pairs(T_N_jobs) do
			local job_name_id = job.name_id
			if job_name_id and job.contact == contact and locale_exists(M_localization, job_name_id) and job_name ~= "welcome_to_the_jungle_wrapper" then --Obviously, If heist don't have its localization string, this means it isn't fully implemented into game (odd heist)
				local job_chain = get_job_chain( T_narrative, job_name )
				local callback_func
				if #job_chain > 1 then
					callback_func = function() stage_menu(job_name, job_name_id, job_chain, contact) end
				else
					callback_func = function() swap_job(job_name, job_chain[1].level_id) end
				end
				
				tab_insert(data, { text = _text(M_localization, job_name_id)..(job.region == "professional" and tr.tpro or ''), callback = callback_func })
			end
		end
		data = { title = _text(M_localization, T_N_contacts[contact].name_id), button_list = data, back = main }
		contact_menus[contact] = data
	end
	
	Menu_open( Menu, data )
end

local function input_pass(character)
	togg_vars.add_string = togg_vars.add_string..character
	crewfinder_menu()
end

local function confirm_pass()
	local f = io_open("Trainer/configs/crew_finder/password", "w")
	if f then
		f:write(togg_vars.add_string)
		f:close()
	end
	if togg_vars.add_string == "" then
		M_N_matchmake._distance_filter = 1
	else
		M_N_matchmake._distance_filter = 3
	end
	NetworkMatchMakingSTEAM._BUILD_SEARCH_INTEREST_KEY = togg_vars.backup_key..togg_vars.add_string
end

crewfinder_menu = function()
	data = {
		{text = tr.job_menu_crew_pass..togg_vars.add_string, switch_back = true},
		{},
	}
	for i = 0, 9 do
		local input = tostring(i)
		tab_insert(data, {text = input, callback = input_pass, data = input})
	end
	tab_insert(data, {})
	tab_insert(data, {text = tr.reset, callback = function() togg_vars.add_string = "" confirm_pass() crewfinder_menu() end})
	tab_insert(data, {})
	tab_insert(data, {text = tr.job_menu_crew_confirm, callback = confirm_pass})

	Menu_open(Menu, {title = tr.job_menu_crew_finder, description = tr.job_menu_crew_desc, button_list = data, back = main})
end

--Difficulties list 
local diffs = {}
for diff,id in pairs(tweak_data.difficulty_name_ids) do
	tab_insert(diffs, { text = locale_text(M_localization, id), value = diff })
end

local m_permissions = {}
for _,item in pairs(tweak_data.permissions) do
	tab_insert(m_permissions, { text = item, value = item })
end

local m_kick_opts = {
	{ text = tr.job_menu_no_kick, value = 0 },
	{ text = tr.job_menu_kick, value = 1 },
	{ text = tr.job_menu_vote_kick, value = 2 },
}

local main_menu_data = {
	{ text = tr.job_menu_diff, type = "multi_choice", index = 1, multi_callback =
		function(_,val)
			if (val) then
				ppr_config.jobmenu_def_difficulty = val
				def_difficulty = val
			end
		end, 
		multi_choice_data = diffs,
		value_func = function() return def_difficulty end,
		switch_back = true },
	{ text = tr.job_menu_permission, type = "multi_choice", index = 1,
		multi_callback = function(_, val)
			G_game_settings.permission = val
		end,
		multi_choice_data = m_permissions,
		value_func =  function() return G_game_settings.permission end,
		switch_back = true },
	{ text = tr.job_menu_kick_opt, type = "multi_choice", index = 1,
		multi_choice_data = m_kick_opts,
		multi_callback = function(_, val)
			G_game_settings.kick_option = val
		end,
		value_func = function() return G_game_settings.kick_option end,
		index = 1,
		val_func = function() return G_game_settings.kick_option end,
		switch_back = true },
	{ text = tr.job_menu_single, type = "toggle",
	toggle = function() return is_singleplayer end,
	callback = function() 
		is_singleplayer = not is_singleplayer
		ppr_config.jobmenu_singleplayer = is_singleplayer
	end,
	index = #m_permissions,
	switch_back = true },
--	{},
	{ text = tr.job_menu_safehouse_raid, callback = function() M_custom_safehouse:spawn_safehouse_combat_contract() end},
--	{},
	{ text = tr.job_menu_crew_finder, callback = crewfinder_menu},
	{},
	{ text = tr.job_menu_escapes, callback = escapes_menu },
--	{},
	--{ text = tr.job_menu_contacts, callback = contact_menu },
}

for contact_name,contact in pairs(T_N_contacts) do
	local name_id = contact.name_id
	if name_id and locale_exists(M_localization, name_id) then
		tab_insert(main_menu_data, { text = locale_text(M_localization, name_id), callback = contact_menu, data = contact_name })
	end
end

local g__main_menu_data = { title = tr.job_menu_title, description = tr.job_menu_description, button_list = main_menu_data }

main = function()
	Menu_open(Menu, g__main_menu_data)
end

return main