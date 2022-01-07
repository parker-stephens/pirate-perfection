-- Spawn bags
-- Author: Simplity

local pairs = pairs
local is_client = is_client
local alive = alive
local ppr_config = ppr_config
local unit_from_id = unit_from_id
local m_log_error = m_log_error
local managers = managers
local M_player = managers.player
local M_network = managers.network
local tweak_data = tweak_data
local T_carry = tweak_data.carry
local Vector3 = Vector3
local UP = math.UP

local vec0 = Vector3(0,0,0)
local vec1 = Vector3(0,0,50)
local vec2 = Vector3(0,0,100)

local spawn_bag, spawn_bag_to_all, spawn_bags_amount

spawn_bags_amount = function( unit, bag_name )
	for i = 1, ppr_config.TrollAmountBags do
		spawn_bag( unit, bag_name ) 
	end
end

spawn_bag = function( unit, bag_name )
	local session = M_network._session
	
	local carry_data = T_carry[ bag_name ]
	if is_client() then
		session:send_to_host("server_drop_carry", bag_name, carry_data.multiplier, carry_data.dye_initiated, carry_data.has_dye_pack, carry_data.dye_value_multiplier, unit:position(), unit:rotation(), UP, vec0, nil)
	else
		M_player:server_drop_carry( bag_name, carry_data.multiplier, carry_data.dye_initiated, carry_data.has_dye_pack, carry_data.dye_value_multiplier, unit:position() + vec2, unit:rotation(), UP, vec1, nil, session:local_peer():id() )
	end
end

spawn_bag_to_all = function( bag_name, session )
	for _,peer in pairs( session._peers ) do
		local unit = unit_from_id( peer:id() )
		if alive( unit ) then
			spawn_bags_amount( unit, bag_name )
		end
	end
end

return function( peer_id, bag_name )
	local session = M_network:session()
	if not session then
		m_log_error('give_bag()', 'No network')
		return
	end
	
	if peer_id == "all" then
		spawn_bag_to_all( bag_name, session )
		return
	end
	
	local unit = unit_from_id( peer_id )
	if alive( unit ) then
		spawn_bags_amount( unit, bag_name, session )
	end
end