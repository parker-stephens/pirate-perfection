-- Lock black market items
-- Author: Simplity

local blackmarket_tweak_data = tweak_data.blackmarket
local pairs = pairs

for global_value, gv_table in pairs( Global.blackmarket_manager.inventory ) do
	for type_id, type_table in pairs( gv_table ) do
		local item_data = blackmarket_tweak_data[type_id]
		if item_data then
			for item_id, item_amount in pairs( type_table ) do
				type_table[item_id] = nil
			end
		end
	end
end

managers.blackmarket:_load_done()
