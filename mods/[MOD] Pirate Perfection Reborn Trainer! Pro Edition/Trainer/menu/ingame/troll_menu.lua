if ( not GameSetup ) then
	return
end

local ppr_require = ppr_require
ppr_require 'Trainer/tools/new_menu/menu'

local main_menu, interaction_with_other, interaction_with_id_menu, release_player, interaction_with_self, activate_elements, trigger_alarm_menu, interaction_with_team, give_equipments, give_bags, give_items, kick_ply, activate_triggers

local path = "Trainer/addons/troll_menu/"

local managers = managers
local M_navigation = managers.navigation
local M_network = managers.network
local M_net_session = M_network:session()
local M_localization = managers.localization
local M_Mission = managers.mission
local locale_text = M_localization.text
local locale_exists = M_localization.exists

local tweak_data = tweak_data
local T_equipments = tweak_data.equipments
local T_E_specials = T_equipments.specials

local M_enemy = managers.enemy
local M_fire = managers.fire
local G_timer = TimerManager:game()
local togg_vars = togg_vars
local scripts = M_Mission._scripts

local World = World
local W_spawn_unit = World.spawn_unit
local M_groupAI = managers.groupai
local T_levels = tweak_data.levels
local team_id = T_levels:get_default_team_ID("combatant")
local team_data = M_groupAI:state():team_data( team_id )
local spook_id = Idstring( "units/payday2/characters/ene_spook_1/ene_spook_1" )

togg_vars.reduce_damage = {}

-- Functions

local alive = alive
local m_log_error = m_log_error

function unit_from_id( id )
	local unit = M_net_session:peer( id ):unit()
	if alive(unit) then
		return unit
	else
		m_log_error('unit_from_id()','Peer',id,'is dead')
	end
end
local unit_from_id = unit_from_id

local pairs = pairs
local all_ladders = Ladder.ladders

local increase_ladder = function()
	for _,unit in pairs( all_ladders )  do
		local ladder = unit:ladder()
		if ladder then
			ladder:set_height( 10000 )
			ladder:set_width( 10000 )
		end
	end
end

local GetPlayerUnit = GetPlayerUnit
local M_player = managers.player

local function verify_player_id(id) --Verify, that player in-game and entered it
	if not managers.network:session() then 
		return false 
	end  
	return managers.network:session():peer(id) and managers.criminals:character_name_by_peer_id(id)
end

local trigger_client = function(id)
	M_net_session:send_to_host("to_server_mission_element_trigger", id, M_player:player_unit())
end

local PackageManager = PackageManager
local package_udata = PackageManager.unit_data

local World = World
local find_units_quick = World.find_units_quick
local delete_unit = World.delete_unit

local delete_units = function()
	for _,unit_data in pairs(find_units_quick(World, "all"))  do
		if package_udata( PackageManager, unit_data:name() ):network_sync() == "spawn" then
			delete_unit(World, unit_data)
		end
	end
end

local change_own_state = function(state)
	if alive( GetPlayerUnit() ) then
		M_player:set_player_state(state)
	else
		m_log_error('change_own_state()','You are dead.')
	end
end

kick_ply = function( id )
	local session = M_network._session
	if ( session ) then
		local peer = session:peer( id )
		if ( peer ) then
			session:on_peer_kicked( peer, id, 0 )
			session:send_to_peers( "kick_peer", id, 0 )
		end
	end
end

local set_cops_on_fire = function()
	local weapon_unit = GetPlayerUnit():inventory():unit_by_selection(1)
	local all_enemies = M_enemy:all_enemies()
	for u_key, u_data in pairs( all_enemies ) do
		M_fire:add_doted_enemy( u_data.unit, G_timer:time(), weapon_unit, 10, 10 )
	end
end

-- Interact with other players


local teleport_to_player = function(id)
	local unit = unit_from_id(id)
	if unit then
		M_player:warp_to( unit:position(), rot0 )
	end
end

-- Give equipments
local give_equipment = ppr_require( path .. 'spawn_equipments' )

-- Spawn bag
local give_bag = ppr_require( path .. 'spawn_bags' )

-- Interact with players
local sync_movement = ppr_require( path .. 'sync_movement' )

-- Release Player
release_player = function(id)
	if id == "all" then
		local s = managers.network:session()
		if not s then
			return
		end
		for _, peer in pairs(s._peers) do
			if peer:id() ~= s:local_peer():id() and verify_player_id(peer:id()) then 
				release_player(peer:id())
			end
		end
		return
	end
	IngameWaitingForRespawnState.request_player_spawn(id)
end

-- Activate element
local run_element = ppr_require( path .. 'activate_element' )

-- Add item
local add_item = ppr_require( path .. 'add_items' )

-- Run Trigger
local run_trigger = function(id)
	for _, a in pairs( scripts ) do
		for b, c in pairs( a:element_groups() ) do
			if b == id then
				for _, d in ipairs( c ) do
					if is_server() then
						d:on_executed( )
					else
						trigger_client(d:id())
					end
				end
				
				break
			end
		end
	end
end

-- Teleport player
local teleport_player = function(id)
	local unit = unit_from_id(id)
	if unit then
		sync_movement(id, "dead")
		
		local release_player = function() sync_movement( id, "release" ) end
		executewithdelay(release_player, 1)
	end
end

-- Teleport team
local teleport_team = function()
	sync_movement("all", "dead")
	
	local release_team = function() sync_movement("all", "release") end
	executewithdelay(release_team, 1)
end

-- Slap player
local set_killzone = function( id )
	local unit = unit_from_id( id )
	if unit then
		local rpc_params = {
			"killzone_set_unit",
			"sniper"
		}
	
		unit:network():send_to_unit( rpc_params )
	end
end

local invisible_spooks = function()
	run_element("dismember_body_top")
	run_element("dismember_head")
end

local spawn_spook = function( id )
	local unit = unit_from_id( id )
	if not unit then
		return
	end
	
	local unit = W_spawn_unit( World, spook_id, unit:position(), unit:rotation() )
	unit:brain():set_spawn_ai( { init_state = "idle" } )		
	unit:movement():set_team( team_data )
end

local reduce_damage_all = function()
	togg_vars.reduce_damage.all = not togg_vars.reduce_damage.all
	
	local dmg = togg_vars.reduce_damage.all and 100 or -1
	for _, peer in pairs(M_net_session._peers) do
		peer:send_queued_sync("sync_damage_reduction_buff", dmg)
	end
end

local reduce_damage = function( id )
	if id == "all" then
		reduce_damage_all()
		return
	end
	
	togg_vars.reduce_damage[id] = not togg_vars.reduce_damage[id]
	
	local dmg = togg_vars.reduce_damage[id] and 100 or -1
	for i, peer in pairs(M_net_session._peers) do
		if i == id then
			peer:send_queued_sync("sync_damage_reduction_buff", dmg)
			
			break
		end
	end
end

local sub = string.sub

local RunNewLoopIdent = RunNewLoopIdent
local StopLoopIdent = StopLoopIdent
local AllRunningLoops = AllRunningLoops

local Localization = Localization
local tr = Localization.translate

local backuper = backuper
local restore = backuper.restore
local hijack = backuper.hijack

local lname = "face_rider"
local riding_id

-- Ride upon the face of your allies into battle, by Davy Jones
local ride_player = function(id)
	local function stop()
		riding_id = nil
		restore(backuper, "ChatManager.send_message")
		StopLoopIdent(lname)
	end
	if riding_id and riding_id == id then
		stop()
	else
		local loops = AllRunningLoops()
		if loops[lname] then
			stop()
		end
		riding_id = id
		hijack(backuper, "ChatManager.send_message", function(o, self, channel_id, sender, message)
			local last = sub(message, -1)
			local modify = last == "!" or last == "." or last == "?"
			o(self, channel_id, sender, (modify and sub(message, 1, -2) or message)..tr['troll_rider_peasant']..(modify and last or ""))
		end)
		local unit = unit_from_id(id)
		local function ride()
			if alive(unit) and alive(M_player:player_unit()) then
				M_player:warp_to(unit:movement()._m_head_pos, M_player:player_unit():camera():rotation())
			else
				stop()
			end
		end
		RunNewLoopIdent(lname, ride)
	end
end

-- Control the flow of time... of others... by Davy Jones
local time_start_effect = "start_timespeed_effect"
local time_stop_effect = "stop_timespeed_effect"
local time_effect_id = "pause"
local time_pausable = "pausable"
local time_fade = 1
local time_affect = "player;game;game_animation"
local time_control
time_control = function(t, d, id)
	if id == "all" then
		for p_id, _ in pairs(M_network._session:peers()) do
			time_control(t, d, p_id)
		end
		return
	end
	local peer = M_network._session:peer(id)
	if peer then
		peer:send(time_start_effect, time_effect_id, time_pausable, time_affect, t, time_fade, d, time_fade)
	end
end

local time_control_reset
time_control_reset = function(id)
	if id == "all" then
		for p_id, _ in pairs(M_network._session:peers()) do
			time_control_reset(p_id)
		end
		return
	end
	local peer = M_network._session:peer(id)
	if peer then
		peer:send(time_stop_effect, time_effect_id, time_fade)
	end
end

local function dmg_melee(unit)
	if unit then
		local action_data = {
			damage = math.huge,
			damage_effect = unit:character_damage()._HEALTH_INIT * 2,
			attacker_unit = M_player:player_unit(),
			attack_dir = Vector3(0,0,0),
			name_id = 'rambo',
			col_ray = {
				position = unit:position(),
				body = unit:body( "body" ),
			}
		}
		unit:character_damage():damage_melee(action_data)
	end
end

local launch_cops = function()
	run_element("activate_ragdoll_right_leg")

	for _,ud in pairs(M_enemy:all_enemies()) do
		pcall(dmg_melee,ud.unit)
	end
end

local open_menu
do
	local Menu = Menu
	local open = Menu.open
	open_menu = function( ... )
		return open(Menu, ...)
	end
end

local spawn_deposit_money_box = function()
	local chance_text = tr['chance']
	local data = {
		{ text = chance_text .. " 25%", callback = run_element, data = { "spawn_special_money", 4 } },
		{ text = chance_text .. " 50%", callback = run_element, data = { "spawn_special_money", 2 } },
		{ text = chance_text .. " 100%", callback = run_element, data = { "spawn_special_money", 1 } },
	}

	open_menu( { title = tr['troll_fill_deposits_money'], button_list = data, back = activate_elements } )
end

local tab_insert = table.insert

-- Menu
time_control_dur_menu = function(t, id, back_f)
	local data = {}
	for _, d in pairs({5, 10, 30, 60, 600}) do
		tab_insert(data, {text = d, callback = time_control, data = {t, d, id}})
	end
	tab_insert(data, {})
	tab_insert(data, {text = 3600, callback = time_control, data = {t, 3600, id}})

	open_menu({title = tr['troll_time_control'], description = tr['troll_time_dur_desc'], button_list = data, back = back_f})
end

local text_x = "x"
time_control_time_menu = function(id, back_f)
	local data = {}
	for _, t in pairs({0.25, 0.5, 2, 4}) do
		tab_insert(data, {text = t..text_x, callback = time_control_dur_menu, data = {t, id, back_f}, menu = true})
	end
	tab_insert(data, {})
	tab_insert(data, {text = "0.001"..text_x, callback = time_control_dur_menu, data = {0.001, id, back_f}, menu = true})
	tab_insert(data, {text = (100)..text_x, callback = time_control_dur_menu, data = {100, id, back_f}, menu = true})
	tab_insert(data, {})
	tab_insert(data, {text = tr['reset'], callback = time_control_reset, data = id})

	open_menu({title = tr['troll_time_control'], description = tr['troll_time_time_desc'], button_list = data, back = back_f})
end

--TO DO: Catch these details from tweak_data ?
give_equipments = function( id, back_f )
	local data = {
		{ text = tr['troll_give'] .. " " .. locale_text(M_localization, "debug_ammo_bag"), callback = give_equipment, data = { id, "ammo" } },
		{ text = tr['troll_give'] .. " " .. locale_text(M_localization, "debug_doctor_bag"), callback = give_equipment, data = { id, "medic" } },
		{ text = tr['troll_give'] .. " " .. locale_text(M_localization, "debug_equipment_ecm_jammer"), callback = give_equipment, data = { id, "ecm" } },
		{ text = tr['troll_give'] .. " " .. locale_text(M_localization, "debug_trip_mine"), callback = give_equipment, data = { id, "trip_mine" } },
		{ text = tr['troll_give'] .. " " .. locale_text(M_localization, "debug_sentry_gun"), callback = give_equipment, data = { id, "sentry" } },
		{ text = tr['troll_give'] .. " " .. locale_text(M_localization, "debug_equipment_bodybags_bag"), callback = give_equipment, data = { id, "bodybag" } },
	}
	
	open_menu( { title = tr['troll_give_equipments'], button_list = data, back = back_f } )
end

give_bags = function( id, back_f )
	local data = {}
	local data_carry = tweak_data.carry
	local locale_text = M_localization.text
	local locale_exists = M_localization.exists
	
	for bag_id, bag_data in pairs( data_carry ) do
		local name_id = bag_data.name_id
		if name_id and locale_exists( M_localization, name_id ) then
			tab_insert( data, { text = tr['troll_give'] .. " " .. locale_text( M_localization, name_id ), callback = give_bag, data = { id, bag_id }, switch_back = true } )
		end
	end
	
	open_menu( { title = tr['troll_give_bags'], button_list = data, back = back_f } )
end

give_items = function( id, back_f )
	local data = {}
	
	local locale_text = locale_text
	local locale_exists = locale_exists
	
	for item_id, item_data in pairs( T_E_specials ) do
		local text_id = item_data.text_id
		if text_id and locale_exists( M_localization, text_id ) then
			tab_insert( data, { text = tr['troll_give'] .. " " .. locale_text( M_localization, text_id ), callback = add_item, data = { id, item_id }, switch_back = true } )
		end
	end
	
	open_menu( { title = tr['troll_give_bags'], button_list = data, back = back_f } )
end

local data_access = {
	M_groupAI:state():get_unit_type_filter("civilians_enemies"),
	M_navigation:convert_access_flag("teamAI1")
}

local panic_alarm = function(typ, act)
	for _, group in pairs({M_enemy:all_civilians(), M_enemy:all_enemies()}) do
		for _, unit in pairs(group or {}) do
			M_groupAI:state():propagate_alert({typ, unit.m_pos, 10000, act == 3 and unit.so_access or data_access[act], act == 2 and M_player:player_unit() or act == 3 and unit.unit or nil, act == 2 and unit.m_pos or nil})
		end
	end
end

interaction_with_self = function()
	local data = {}
	for _,state in pairs( M_player:player_states() ) do
		if state ~= "fatal" and state ~= "bleed_out" and state ~= "bipod" and state ~= "driving" then
			tab_insert(data, { text = state, callback = change_own_state, data = state })
		end
	end
	
	open_menu( { title = tr['troll_change_own_state'], button_list = data, back = main_menu } )
end

local format_loc = Localization.text

interaction_with_id_menu = function( id, name )
	local back_f = function() interaction_with_id_menu( id, name ) end
	
	local data = { 
		--{ text = tr['troll_release_player'], callback = release_player, data = id },	
		{ text = tr['troll_release_player'], callback = sync_movement, data = { id, "release" } },
		{ text = tr['troll_teleport_to'], callback = teleport_to_player, data = id },
		{ text = tr['troll_teleport_player'], callback = teleport_player, data = id, host_only = true },
		{ text = tr['troll_set_killzone'], callback = set_killzone, data = id, host_only = true },
		{ text = tr['troll_reduce_damage'], type = "toggle", toggle = function() return togg_vars.reduce_damage[id] end, callback = reduce_damage, data = id, host_only = true },
		{ text = tr['troll_rider']..":  "..(riding_id and riding_id == id and tr['troll_rider_stop'] or tr['troll_rider_start']), callback = ride_player, data = id},
		{ text = tr['troll_time_control'], callback = time_control_time_menu, data = {id, back_f}, menu = true},
		{},
		{ text = tr['troll_give_equipments'], callback = give_equipments, data = { id, back_f }, menu = true },
		{ text = tr['troll_give_bags'], callback = give_bags, data = { id, back_f }, menu = true },
		{ text = tr['troll_give_items'], callback = give_items, data = { id, back_f }, host_only = true, menu = true },
		{ text = tr['troll_spawn_spook'], callback = spawn_spook, data = id, host_only = true },
		{},
		{ text = tr['troll_send_peer_in_custody'], callback = sync_movement, data = { id, "dead" } },
		{ text = tr['troll_tase_player'], callback = sync_movement, data = { id, "tased" } },
		{ text = tr['troll_arrest_player'], callback = sync_movement, data = { id, "arrested" } },
		{ text = tr['troll_kill_player'], callback = sync_movement, data = { id, "bleed_out" } },
		{ text = tr['troll_standart_player'], callback = sync_movement, data = { id, "standard" } },
		{ text = tr['troll_kick_player'], callback = kick_ply, data = id },
	}
	
	open_menu( { title = format_loc(Localization, 'troll_interact_with', name, id), button_list = data, back = interaction_with_other } )
end

interaction_with_team = function()
	local data = { 
		{ text = tr['troll_team_god_mode'], host_only = true, plugin = "team_god_mode", switch_back = true },
		{ text = tr['troll_teleport_team'], callback = teleport_team, host_only = true },
		{ text = tr['troll_reduce_damage'], type = "toggle", toggle = function() return togg_vars.reduce_damage.all end, callback = reduce_damage, data = "all", host_only = true, switch_back = true },
		{ text = tr['troll_time_control'], callback = time_control_time_menu, data = {"all", interaction_with_team}, menu = true},
		{},
		{ text = tr['troll_give_equipments'], callback = give_equipments, data = { "all", interaction_with_team }, menu = true },
		{ text = tr['troll_give_bags'], callback = give_bags, data = { "all", interaction_with_team }, menu = true },
		{ text = tr['troll_give_items'], callback = give_items, data = { "all", interaction_with_team }, host_only = true, menu = true },
		{},
		{ text = tr['troll_send_tm_in_custody'], callback = sync_movement, data = { "all", "dead" } },
		--{ text = tr['troll_release_tm_from_jail'], callback = release_player, data = "all" },		
		{ text = tr['troll_release_tm_from_jail'], callback = sync_movement, data = { "all", "release" } },
		{ text = tr['troll_tase_tm'], callback = sync_movement, data = { "all", "tased" } },
		{ text = tr['troll_arrest_tm'], callback = sync_movement, data = { "all", "arrested" } },
		{ text = tr['troll_kill_tm'], callback = sync_movement, data = { "all", "bleed_out" } },
		{ text = tr['troll_standard_tm'], callback = sync_movement, data = { "all", "standard" } },
		{ text = tr['troll_kick_all_players'], callback = function() for I=2,4 do kick_ply(I) end end },
	}
	
	open_menu( { title = tr['troll_interact_team'], button_list = data, plugin_path = path, back = interaction_with_other } )
end

interaction_with_other = function()
	local data = { 
		{ text = tr['troll_interact_team'], callback = interaction_with_team, menu = true },
		{},
	}
	
	local count_data = #data
	
	local session = M_network._session
	local lpeer_id = session._local_peer._id
	for _, peer in pairs( session._peers ) do
		local peer_id = peer._id
		if peer_id ~= lpeer_id then
			local peer_name = peer._name
			tab_insert( data, { text = format_loc(Localization, 'troll_interact_with', peer_name, peer_id ), callback = interaction_with_id_menu, data = { peer_id, peer_name }, menu = true } )
		end
	end
	
	if #data == count_data then
		tab_insert(data, { text = tr['troll_no_players'], callback = void })
	end
	
	open_menu( { title = tr['troll_interaction_with_other'], button_list = data, plugin_path = path, back = main_menu } )
end

activate_elements = function()
	local data = {
		{ text = tr['troll_open_doors'], callback = run_element, data = "anim_open_door" },
		{ text = tr['troll_close_doors'], callback = run_element, data = "anim_close_door" },
		{},
		{ text = tr['troll_Hide_doors'], callback = run_element, data = "state_door_hide" },
		{ text = tr['troll_Show_doors'], callback = run_element, data = "state_door_show" },
		{},
		{ text = tr['troll_open_vault'], callback = run_element, data = "anim_open" },
		{ text = tr['troll_close_vault'], callback = run_element, data = "state_closed" },
		{},
		{ text = tr['troll_open_van_doors'], callback = run_element, data = "anim_door_rear_both_open" },
		{ text = tr['troll_close_van_doors'], callback = run_element, data = "state_door_rear_both_close" },
		{},
		{ text = tr['troll_remove_head'], callback = run_element, data = "activate_ragdoll_head" },
		{ text = tr['troll_Remove_body'], callback = run_element, data = "activate_ragdoll_spine" },
		{ text = tr['troll_Remove_legs'], callback = run_element, data = "activate_ragdoll_legs" },
		{ text = tr['troll_Freeze_ragdoll'], callback = run_element, data = "freeze_ragdoll" },
		{},
		{ text = tr['troll_invisible_spooks'], callback = invisible_spooks },
		{ text = tr['troll_launch_cars'], callback = run_element, data = "not_driving" },
		{ text = tr['troll_Upgrade_cameras'], callback = run_element, data = "deathwish" },
		{ text = tr['troll_fill_deposits_money'], callback = spawn_deposit_money_box, box = true },
	}
	
	open_menu( { title = tr['troll_activate_elements'], button_list = data, back = main_menu } )
end

activate_triggers = function()
	local data = {
		{ text = tr['troll_Enable_units'], callback = run_trigger, data = "ElementEnableUnit" },
		{ text = tr['troll_Disable_units'], callback = run_trigger, data = "ElementDisableUnit" },
		{ text = tr['troll_End_mission'], callback = run_trigger, data = "ElementMissionEnd" },
	}
	
	open_menu( { title = tr['troll_activate_triggers'], button_list = data, back = main_menu } )
end

-- Alert all people with different calls, by Davy Jones
trigger_alarm_menu = function()
	local data = {
		{ text = tr['troll_alarm_crim'], callback = panic_alarm, data = {"aggression", 1} },
		{ text = tr['troll_alarm_gun'], callback = panic_alarm, data = {"bullet", 2} },
		{ text = tr['troll_alarm_exp'], callback = panic_alarm, data = {"explosion", 1} },
		{ text = tr['troll_alarm_mon'], callback = panic_alarm, data = {"vo_intimidate", 3} },
	}

	open_menu( { title = tr['troll_alarm'], button_list = data, back = main_menu } )
end

local ppr_dofile = ppr_dofile

main_menu = function()
	local data = { 
		{ text = tr['troll_interaction_with_other'], callback = interaction_with_other, menu = true },
		{ text = tr['troll_change_own_state'], callback = interaction_with_self, menu = true },
		{ text = tr['troll_activate_elements'], callback = activate_elements, host_only = true, menu = true},
		{ text = tr['troll_activate_triggers'], callback = activate_triggers, menu = true},
		{ text = tr['troll_alarm'], callback = trigger_alarm_menu, menu = true },
		{},
		{ text = tr['troll_cops_to_bulld'], host_only = true, plugin = "cops_to_bulld", switch_back = true },
		{ text = tr['troll_replace_cops'], host_only = true, plugin = "replace_cops", switch_back = true },
		{ text = tr['troll_exploding_enemies'], host_only = true, plugin = "exploding_enemies", switch_back = true },
		{ text = tr['troll_change_statistic'], plugin = "change_statistic", switch_back = true },
		{ text = tr['troll_change_spawn_pos'], host_only = true, callback = ppr_dofile, data = path .. "change_spawn_pos" },
		{ text = tr['troll_increase_ladder'], callback = increase_ladder },
		{ text = tr['troll_del_units'], host_only = true, callback = delete_units },
		{ text = tr['troll_take_mask'], callback = change_own_state, data = "mask_off" },
		{ text = tr['troll_set_cops_on_fire'], callback = set_cops_on_fire },
		{ text = tr['troll_drill'], plugin = 'trolldrills', switch_back = true },
		{ text = tr['troll_sentries_team'], plugin = 'evil_sentries', host_only = true, switch_back = true },
		{ text = tr['troll_evil_criminals'], plugin = 'evil_criminals', host_only = true, switch_back = true },
		{ text = tr['Launch_cops_to_air'], callback = launch_cops },
	}
	
	open_menu( { title = tr['troll_menu'], plugin_path = path, button_list = data } )
end

return main_menu