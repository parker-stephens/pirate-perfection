-- Sync movement to other players
-- Author: Movement methods: Simplity. Jail release/send: baldwin

local pairs = pairs
local managers = managers
local M_network = managers.network
local unit_from_id = unit_from_id
local m_log_error = m_log_error
local request_player_spawn = IngameWaitingForRespawnState.request_player_spawn

local switch_movement, sync_movement_to_all, send_to_custody, release_player, session, sync_movement

local function verify_player_id( id ) --Verify, that player in-game and entered it
	if not session then 
		return false 
	end  
	
	return session:peer(id) and managers.criminals:character_name_by_peer_id(id)
end

sync_movement = function( peer_id, movement_name ) -- global function
	session = M_network:session()
	if not session then
		m_log_error('sync_movement()', 'No network')
		return
	end
	
	if switch_movement( peer_id, movement_name ) then -- check for special movement
		return
	end
	
	if peer_id == "all" then
		sync_movement_to_all( sync_movement, movement_name )
		return
	end
	
	local player = unit_from_id( peer_id )
	if player then
		player:network():send_to_unit( { "sync_player_movement_state", player, movement_name, 0, player:id() } )
	end
end

switch_movement = function( peer_id, movement_name )
	if movement_name == "dead" then
		send_to_custody( peer_id )
		return true
	elseif movement_name == "release" then
		release_player( peer_id )
		return true
	end
end

sync_movement_to_all = function( func, ... )
	for _,peer in pairs( session._peers ) do
		local peer_id = peer:id()
		if peer_id ~= session:local_peer():id() and verify_player_id( peer_id ) then
			func( peer_id, ... )
		end
	end
end

send_to_custody = function( peer_id )
	if peer_id == "all" then
		sync_movement_to_all( send_to_custody )
		return
	end
	
	local player = unit_from_id( peer_id )
	if player then
		local network = player:network()
		local send = network.send
		send(network, "sync_player_movement_state", "dead", 0, peer_id )
		send(network, "set_health", 0)
		network:send_to_unit( { "spawn_dropin_penalty", true, nil, 0, nil, nil } )
		managers.groupai:state():on_player_criminal_death( peer_id )
	end
end

release_player = function( peer_id )
	if peer_id == "all" then
		sync_movement_to_all( release_player )
		return
	end
	
	request_player_spawn( peer_id )
end

return sync_movement