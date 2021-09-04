if (not GameSetup) then
	return
end

ppr_require 'Trainer/tools/new_menu/menu'

local main_menu, interaction_with_other, interaction_with_id_menu, release_player, interaction_with_self

local M_enemy = managers.enemy
local M_fire = managers.fire
local G_timer = TimerManager:game()

-- Functions

local function unit_from_id( id )
	local unit = M_net_session:peer( id ):unit()
	if alive(unit) then
		return unit
	else
		m_log_error('unit_from_id()','Peer',id,'is dead')
	end
end

local function verify_player_id(id) --Verify, that player in-game and entered it
	if not managers.network:session() then 
		return false 
	end  
	return managers.network:session():peer(id) and managers.criminals:character_name_by_peer_id(id)
end

local change_own_state = function(state)
	if alive(managers.player:local_player()) then
		managers.player:set_player_state(state)
	else
		m_log_error('change_own_state()','You are dead, not big surprise.')
	end
end

local set_cops_on_fire = function()
	local weapon_unit = GetPlayerUnit():inventory():unit_by_selection(1)
	
	local all_enemies = M_enemy:all_enemies()
	for u_key, u_data in pairs( all_enemies ) do
		M_fire:add_doted_enemy( u_data.unit, G_timer:time(), weapon_unit, 10, 10 )
	end
end

-- Interact with players

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

-- Menu

interaction_with_self = function()
	local data = {}
	for _,state in pairs(managers.player:player_states()) do
		if state ~= "fatal" and state ~= "bleed_out" and state ~= "bipod" then
			table.insert(data, { text = state, callback = change_own_state, data = state })
		end
	end
	Menu:open( { title = Localization.translate['troll_change_own_state'], button_list = data, back = main_menu } )
end

interaction_with_id_menu = function(id, name)
	local data = { 
		{ text = Localization.translate['troll_release_player'], callback = release_player, data = id },
	}
	
	Menu:open( { title = Localization:text('troll_interact_with', name, id), button_list = data, back = interaction_with_other } )
end

interaction_with_other = function()
	local data = { 
		{},
		{ text = Localization.translate['troll_release_tm_from_jail'], callback = release_player, data = "all" },
		{},
	}
	local count_data = #data
	local s = managers.network:session()
	if not s then
		return
	end
	for _, peer in pairs(s._peers) do
		if peer:id() ~= s:local_peer():id() then
			table.insert(data, { text = Localization:text('troll_interact_with', peer:name(), peer:id()), callback = function() interaction_with_id_menu(peer:id(), peer:name()) end })
		end
	end
	if #data == count_data then
		table.insert(data, { text = Localization.translate['troll_no_players'], callback = void })
	end
	
	Menu:open( { title = Localization.translate['troll_interaction_with_other'], button_list = data, back = main_menu } )
end

main_menu = function()
	local data = { 
		{ text = Localization.translate['troll_interaction_with_other'], callback = interaction_with_other },
		{},
		{ text = Localization.translate['troll_change_own_state'], callback = interaction_with_self },
		{ text = Localization.translate['troll_set_cops_on_fire'], callback = set_cops_on_fire },
	}
	
	Menu:open( { title = Localization.translate['troll_menu'], button_list = data } )
end

return main_menu