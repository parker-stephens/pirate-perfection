--Purpose: menu for scripts specific for several heists

if ( not GameSetup ) then
	return
end

local World = World
local W_spawn_unit = World.spawn_unit
local managers = managers
local M_experience = managers.experience
local M_player = managers.player
local Idstring = Idstring
local ppr_dofile = ppr_dofile
local ppr_require = ppr_require
ppr_require('Trainer/tools/new_menu/menu')
local is_server = is_server()
local togg_vars = togg_vars

local green = Color( 200, 000, 255, 000 ) /255
local red 	= Color( 200, 255, 000, 000 ) /255

local tr = Localization.translate

local path = "Trainer/addons/missionmenu/"

local Global = Global
local G_game_settings = Global.game_settings
local current_level = G_game_settings.level_id

local main, customize_safehouse

local Menu = Menu
local Menu_open = Menu.open

local spawn_plan = function()
	local player = M_player:player_unit()
    W_spawn_unit( World, Idstring("units/payday2/props/gen_prop_loot_confidential_folder_event/gen_prop_loot_confidential_folder_event"), player:position(), player:rotation() )
end

-- Overlever
local Overlever = function()
	local scripts = managers.mission:scripts()
    for _, script in pairs( scripts ) do
		local elements = script:elements()
        for id, element in pairs( elements ) do
			local trigger_list = element:values().trigger_list or {}
            for _, trigger in pairs( trigger_list ) do
                if trigger.notify_unit_sequence == "glowing" then
                    element:on_executed()
                end
            end
        end
    end
end

-- Overlever Gate
local Overlevergate = function()
	for _, unit in pairs(World:find_units_quick("all")) do
		local elem = unit.damage and unit:damage() and unit:damage()._unit_element
		if elem then
			for id in pairs(elem._sequence_elements) do
				if id == "all_riddles_solved" then
					unit:damage():run_sequence_simple(id) 
					managers.network:session():send_to_peers_synched("run_mission_door_device_sequence", unit, id)
				end
			end
		end
	end
end

-- Overdrill
local overdrill = function()
	local scripts = managers.mission:scripts()
    for _, script in pairs( scripts ) do
		local elements = script:elements()
        for id, element in pairs( elements ) do
			local trigger_list = element:values().trigger_list or {}
            for _, trigger in pairs( trigger_list ) do
                if trigger.notify_unit_sequence == "light_on" then
                    element:on_executed()
                end
            end
        end
    end
end
-- Overdrill Waypoints
local overdrillwaypoints = function()
function ppr_waypoints()
	if pcall(ppr_RefreshWaypoints) then end
end

_toggleOverdrill = not _toggleOverdrill
if _toggleOverdrill then ppr_waypoints() end

managers.hud.__update_waypoints = managers.hud.__update_waypoints or managers.hud._update_waypoints 
function HUDManager:_update_waypoints( t, dt ) 
	local result = self:__update_waypoints(t,dt) 
	for id,data in pairs( self._hud.waypoints ) do 
		id = tostring(id) 
		data.move_speed = 0.01
		if id:sub(1,6) == 'rtile_' then 
			data.bitmap:set_color( green )
		elseif id:sub(1,6) == 'wtile_' then 
			data.bitmap:set_color( red )
		end 
	end 
	return result 
end  
 
function ppr_RefreshWaypoints()
	for id,_ in pairs( clone( managers.hud._hud.waypoints ) ) do
		id = tostring(id)
		if id:sub(1,6) == 'rtile_' or id:sub(1,6) == 'wtile_' then
			managers.hud:remove_waypoint( id ) 
		end
	end
	if _toggleOverdrill then
		for k,v in pairs(managers.interaction._interactive_units) do
			if v:interaction().tweak_data == 's_cube' then
				local pos = v:position()
				if pos == Vector3(7832.7104492188, 1325.0007324219, -25) 
				or pos == Vector3(7868.0703125, 1360.3607177734, -25)
				or pos == Vector3(7902.7104492188, 1325.7106933594, -25)
				or pos == Vector3(7902.7104492188, 1255.0007324219, -25)
				or pos == Vector3(7938.7802734375, 1218.9307861328, -25)
				or pos == Vector3(7974.1303710938, 1254.2907714844, -25)
				then
					managers.hud:add_waypoint( 'rtile_'..k, { icon = 'wp_target', distance = false, position = v:position()+Vector3(-25,0,0), no_sync = true, present_timer = 0, state = "present", radius = 10000, color = Color.Free, blend_mode = "add" }  )
				else
					managers.hud:add_waypoint( 'wtile_'..k, { icon = 'wp_target', distance = false, position = v:position()+Vector3(-25,0,0), no_sync = true, present_timer = 0, state = "present", radius = 10000, color = Color.Free, blend_mode = "add" }  )
				end
			end
		end
	end
end
ppr_waypoints()
 
managers.interaction._remove_unit = managers.interaction._remove_unit or managers.interaction.remove_unit
function ObjectInteractionManager:remove_unit( unit )
	local interacted = unit:interaction().tweak_data
	local result = self:_remove_unit(unit)
	if managers.job:current_level_id() == 'red2' and interacted == 's_cube' then
		ppr_waypoints()
	end
	return result
end
 
managers.interaction._add_unit = managers.interaction._add_unit or managers.interaction.add_unit
function ObjectInteractionManager:add_unit( unit )
	local spawned = unit:interaction().tweak_data
	local result = self:_add_unit(unit)
	if managers.job:current_level_id() == 'red2' and spawned == 's_cube'  then
		ppr_waypoints()
	end
	return result
end
end

local function toggle_customization(option)
	togg_vars[option] = not togg_vars[option]
	ppr_dofile("Trainer/addons/customize_safehouse")
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

-- Menu
local safehouse_invest_amts = {}
local invest_amt
for i = 1, 7 do
	safehouse_invest_amts[#safehouse_invest_amts + 1] = {text = M_experience:cash_string(100 * (10^i)), value = i}
end

customize_safehouse = function()
	local data = {
		{text = tr.base_SafeHouseDoors, type = "toggle", toggle = 'SafeHouseDoors', callback = toggle_customization, data = 'SafeHouseDoors', switch_back = true},
		{text = tr.base_SafeHouseInvest, type = "toggle", toggle = 'SafeHouseInvest', callback = toggle_customization, data = 'SafeHouseInvest', switch_back = true},
		{text = tr.base_SafeHouseInvestAmt, type = "multi_choice", name = 'SafeHouseInvestAmt', multi_callback = function(n, v) togg_vars[n] = v end, multi_choice_data = safehouse_invest_amts, value = togg_vars.SafeHouseInvestAmt, switch_back = true},
		{text = tr.base_SafeHouseLego, type = "toggle", toggle = 'SafeHouseLego', callback = function() if not togg_vars.SafeHouseLego then toggle_customization('SafeHouseLego') end end},
		{},
		{ text = tr['Auto_Complete_All_Challenges'], callback = Auto_Complete_All_Challenges },
		{ text = tr['Auto_Complete_Safehouse_Challenge'], callback = Auto_Complete_Safehouse_Challenge },
		{},
	}

	Menu_open(Menu, {title = tr.base_custom_safehouse_Sub, description = tr.base_custom_safehouse_Sub_desc, button_list = data})
end
main = function()
	local data = {
		{ text = tr.way_pointing, plugin = 'waypoints', switch_back = true },
		{ text = tr.debug_hud, plugin = 'debug_hud', switch_back = true },
		{ text = tr.trigger_recorder, plugin = 'trigger_recorder', switch_back = true },
		{ text = tr.intimidator, plugin = 'intimidator', switch_back = true },
		{ text = tr.shutdown_dialogs, plugin = "shutdown_dialogs", switch_back = true },
		{ text = tr.convert_all, callback = ppr_require(path .. 'convert_all'), host_only = true },
		{ text = tr.tie_civs, callback = ppr_require(path .. 'tie_civilians'), host_only = true },
		{ text = tr.reduce_ai_health, plugin = 'reduce_ai_health', switch_back = true, host_only = true },
		{ text = tr.increase_ai_amount, plugin = 'increase_ai_amount', switch_back = true, host_only = true },
		{ text = tr.pointless_medics, plugin = 'pointless_medics', switch_back = true },
		{ text = tr.Auto_counter_Cloakers, plugin = 'Auto_counter_Cloakers', switch_back = true },
		{},
	}

	if current_level == "alex_1" or current_level == "rat" then
		data[#data+1] = { text = tr.auto_cooker, plugin = 'autocooker', switch_back = true }
	end

	if current_level == "welcome_to_the_jungle_2" and is_server then
		data[#data+1] = { text = tr.cengine_menu_title, callback = ppr_dofile, data = path .. 'correctengine', menu = true, host_only = true }
	end

	if ( current_level == "arm_hcm" or current_level == "arm_cro" or current_level == "arm_fac" or current_level == "arm_par" or current_level == "arm_und" ) and is_server then
		data[#data+1] = { text = tr.spawn_plan, callback = spawn_plan, host_only = true }
	end

	if Global.game_settings.difficulty == "overkill_145" or Global.game_settings.difficulty == "easy_wish" or Global.game_settings.difficulty == "overkill_290" or Global.game_settings.difficulty == "sm_wish" and current_level == "red2" --[[and is_server]] then
		data[#data+1] = { text = tr.overdrill, callback = overdrill, host_only = true }
		data[#data+1] = { text = tr.overdrillwaypoints, callback = overdrillwaypoints, host_only = true }
	end

	if Global.game_settings.difficulty == "overkill_145" or Global.game_settings.difficulty == "easy_wish" or Global.game_settings.difficulty == "overkill_290" or Global.game_settings.difficulty == "sm_wish" and current_level == "vit" --[[and is_server]] then
		data[#data+1] = { text = tr.Overlever, callback = Overlever, host_only = true }
		data[#data+1] = { text = tr.Overlevergate, callback = Overlevergate, host_only = true }
	end

	if current_level == "chill" and is_server then
		data[#data+1] = { text = tr.base_custom_safehouse_Sub, callback = customize_safehouse, menu = true, host_only = true }
	end
	Menu_open( Menu, { title = tr.mission_menu_title, button_list = data, plugin_path = path } )
end

return main