-- Give equipments
-- Author: Simplity

local pairs = pairs
local unit_from_id = unit_from_id
local alive = alive

local Network = Network
local managers = managers
local M_network = managers.network
local lpeer --Mutable
local M_player = managers.player
local session --Mutable
local is_client --Mutable
local player_unit --Mutable
local DoctorBagBase = DoctorBagBase
local AmmoBagBase = AmmoBagBase
local ECMJammerBase = ECMJammerBase
local TripMineBase = TripMineBase
local SentryGunBase = SentryGunBase
local BodyBagsBagBase = BodyBagsBagBase

local give_bag, give_equipment_to_all, give_ecm, give_tripmine, give_sentry

give_equipment_to_all = function( func, ... )
	for _,peer in pairs( session._peers ) do
		func( peer:id(), ... )
	end
end

give_bag = function( peer_id, class, type )
	if peer_id == "all" then
		give_equipment_to_all( give_bag, class, type )
		return
	end
	
	local unit = unit_from_id( peer_id )
	if unit then
		local upgrade_lvl = 1
		if is_client then
			session:send_to_host( "place_deployable_bag", type, unit:position(), unit:rotation(), upgrade_lvl )
		else
			class.spawn( unit:position(), unit:rotation(), upgrade_lvl )
		end
	end
end

give_ecm = function( peer_id )
	if peer_id == "all" then
		give_equipment_to_all( give_ecm )
		return
	end
	
	local unit = unit_from_id( peer_id )
	if unit then
		local upgrade_value = M_player.upgrade_value
		local duration_multiplier = upgrade_value(M_player, "ecm_jammer", "duration_multiplier", 1 ) * upgrade_value(M_player, "ecm_jammer", "duration_multiplier_2", 1 )
		if is_client then
			session:send_to_host( "request_place_ecm_jammer", unit:position(), unit:rotation(), duration_multiplier )
		else
			local ecm_unit = ECMJammerBase.spawn( unit:position(), unit:rotation(), duration_multiplier, player_unit, lpeer:id() )
			ecm_unit:base():set_active(true)
		end
	end
end

give_tripmine = function( peer_id )
	if peer_id == "all" then
		give_equipment_to_all( give_tripmine )
		return
	end
	
	local unit = unit_from_id( peer_id )
	if unit then
		local sensor_upgrade = M_player:has_category_upgrade( "trip_mine", "sensor_toggle" )
		if is_client then
			session:send_to_host( "attach_device", unit:position(), unit:rotation(), sensor_upgrade )
		else
			local trip_unit = TripMineBase.spawn( unit:position(), unit:rotation(), sensor_upgrade, lpeer:id() )
			trip_unit:base():set_active( true, player_unit )
		end
	end
end

give_sentry = function( peer_id )
	local player = player_unit
	if not alive( player ) then
		return
	end
	
	if peer_id == "all" then
		give_equipment_to_all( give_sentry )
		return
	end
	
	local unit = unit_from_id( peer_id )
	if unit then
		local upgrade_value = M_player.upgrade_value
		local ammo_multiplier = upgrade_value( M_player, "sentry_gun", "extra_ammo_multiplier", 1 )
		local armor_multiplier = upgrade_value( M_player, "sentry_gun", "armor_multiplier", 1 )
		local damage_multiplier = upgrade_value( M_player, "sentry_gun", "damage_multiplier", 1 )
		local shield = M_player:has_category_upgrade( "sentry_gun", "shield" )
		if is_client then
			session:send_to_host( "place_sentry_gun", unit:position(), unit:rotation(), ammo_multiplier, armor_multiplier, damage_multiplier, nil, player )
		else
			local id = lpeer:id()
			local sentry_unit = SentryGunBase.spawn( player, unit:position(), unit:rotation(), ammo_multiplier, armor_multiplier, damage_multiplier, id )
			session:send_to_peers( "from_server_sentry_gun_place_result", id, nil, sentry_unit, sentry_unit:movement()._rot_speed_mul, sentry_unit:weapon()._setup.spread_mul, shield )
		end
	end
end

return function( peer_id, equipment_name ) -- global function
	session = M_network:session()
	if not session then
		m_log_error('give_equipment()', 'No network')
		return
	end
	is_client = Network:is_client()
	lpeer = session:local_peer()
	player_unit = M_player:player_unit()
	
	if equipment_name == "medic" then
		give_bag( peer_id, DoctorBagBase, "DoctorBagBase" )
	elseif equipment_name == "ammo" then
		give_bag( peer_id, AmmoBagBase, "AmmoBagBase" )
	elseif equipment_name == "ecm" then
		give_ecm( peer_id )
	elseif equipment_name == "sentry" then
		give_sentry( peer_id )
	elseif equipment_name == "trip_mine" then
		give_tripmine( peer_id )
	elseif equipment_name == "bodybag" then
		give_bag( peer_id, BodyBagsBagBase, "BodyBagsBagBase" )
	end
end