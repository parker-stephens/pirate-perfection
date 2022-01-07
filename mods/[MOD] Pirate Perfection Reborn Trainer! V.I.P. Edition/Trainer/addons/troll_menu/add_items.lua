-- Add items to players

local add_items_to_all
local unit_from_id = unit_from_id
local M_network = managers.network
local m_log_error = m_log_error
local alive = alive
local pairs = pairs

add_items_to_all = function( item_id, session )	
	for _, peer in pairs( session._peers ) do
		local unit = unit_from_id( peer._id )
		if alive( unit ) then
			unit:network():send_to_unit( { "give_equipment", item_id, 1 } )
		end
	end
end

return function( peer_id, item_id )
	local session = M_network._session
	if not session then
		m_log_error('add_items()', 'No network')
		return
	end
	
	if peer_id == "all" then
		return add_items_to_all( item_id, session )
	end
	
	local unit = unit_from_id( peer_id )
	
	if alive( unit ) then		
		unit:network():send_to_unit( { "give_equipment", item_id, 1 } )
	end
end