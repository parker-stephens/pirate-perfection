--Purpose: here will be function, that will allow you to switch or host new job.
--Author: baldwin

local Network = Network
local managers = managers

local tweak_data = tweak_data
local T_levels = tweak_data.levels
local T_narrative = tweak_data.narrative

local M_job = managers.job
local M_network = managers.network
local M_menu = managers.menu
local M_menu_component = managers.menu_component
local MenuCallbackHandler = MenuCallbackHandler
local Global = Global
local G_game_settings = Global.game_settings

local is_server = is_server

local function start_single_player(job_data, stage)
	if not M_job:activate_job(job_data.job_id, stage or 1) then
		return
	end
	G_game_settings.level_id = stage and M_job:current_level_id() or job_data.level_id
	G_game_settings.mission = M_job:current_mission()
	G_game_settings.difficulty = job_data.difficulty
	G_game_settings.world_setting = M_job:current_world_setting()
	MenuCallbackHandler:start_the_game()
end

local function ChangeHostGame(job_data, attributes, is_joinable, singleplayer, stage)
	if singleplayer then
		G_game_settings.single_player = true --Init single player session
		M_network:host_game()
		Network:set_server()
		start_single_player( job_data, stage )
		MenuCallbackHandler:save_progress()
		return
	end

	if not M_job:activate_job( job_data.job_id, stage or 1 ) then
		return
	end

	G_game_settings.level_id = stage and M_job:current_level_id() or job_data.level_id
	G_game_settings.mission = M_job:current_mission()
	G_game_settings.difficulty = job_data.difficulty
	G_game_settings.world_setting = M_job:current_world_setting()
	local matchmake = M_network.matchmake --I'm not sure, but matchmake maybe mutable
	matchmake:set_server_joinable(is_joinable)
	
	local matchmake_attributes = attributes --or self:get_matchmake_attributes()

	if is_server() then -- Allready hosting, update information
		local job_id_index = T_narrative:get_index_from_job_id( M_job:current_job_id() )
		local level_id_index = T_levels:get_index_from_level_id( G_game_settings.level_id )
		local difficulty_index = tweak_data:difficulty_to_index( G_game_settings.difficulty )
		local session = M_network._session
		
		session:send_to_peers( "sync_game_settings", job_id_index, level_id_index, difficulty_index ) -- Let everyone know
		matchmake:set_server_attributes( matchmake_attributes )
		M_menu_component:on_job_updated()
		
		local active_menu_logic = M_menu:active_menu().logic
		active_menu_logic:navigate_back( true )
		active_menu_logic:refresh_node( "lobby", true )
	else
		matchmake:create_lobby( matchmake_attributes )
	end
end

local m_log_error = m_log_error
local tab_insert = table.insert

--Instructions: job_name is the key of the element in tweak_data.narrative.jobs. level_name is the key of the tweak_data.levels element, fake_name is optional feature, that lets you publish into matchmaking other level_name, but having hosted other. Difficulties: 'easy','normal','hard','overkill','overkill_145','overkill_290'. Permission: 1 - Public, 2 - Friends Only, 3 - Private. is_joinable - test feature, may prevent your game from publishing to crime.net
function SwapJobQuick(job_name,level_name,fake_name,difficulty,permission,is_joinable, singleplayer, stage)
	local level_id = T_levels:get_index_from_level_id( fake_name or level_name )
	if not level_id then
		m_log_error('SwapJobQuick()',fake_name or level_name,'index isn\'t found!')
		return
	end
	local difficulty_id = tweak_data:difficulty_to_index( difficulty )
	local permission_id = tweak_data:permission_to_index(G_game_settings.permission)--permission
	local min_lvl = 0
	local drop_in = 1
	local job_id = T_narrative:get_index_from_job_id( fake_name or level_name )

	local attributes = { numbers = { level_id+(1000*job_id), difficulty_id, permission_id, nil, nil, drop_in, min_lvl } } --Attributes is array of numbers.

	local kicking_allowed = --[[G_game_settings.kicking_allowed and 1 or]] 0
	tab_insert( attributes.numbers, kicking_allowed )
	local job_class = M_job:calculate_job_class( job_name, difficulty_id )
	tab_insert( attributes.numbers, job_class )

	ChangeHostGame({ job_id = job_name, level_id = level_name, difficulty = difficulty },attributes,is_joinable, singleplayer, stage)
end