-- Remove items from inventory
-- Author: Simplity

local pairs = pairs

local clear_slot_category, clear_all_slots, no_money

clear_slots = function( category )
	if category == "all" then
		clear_all_slots()
	else
		clear_slot_category( category )
	end
end

clear_all_slots = function()
	local types = { "masks", "primaries", "secondaries" }
	
	for _, item_type in pairs( types ) do
		clear_slot_category( item_type )
	end
end

clear_slot_category = function( category )
	no_money()
	
	local crafted_items = Global.blackmarket_manager.crafted_items
	local M_blackmarket = managers.blackmarket
	local on_sell_mask = M_blackmarket.on_sell_mask
	local on_sell_weapon = M_blackmarket.on_sell_weapon

	for slot in pairs( crafted_items[ category ] ) do
		if slot ~= 1 then -- items from first slot cannot be deleted
			if category == "masks" then
				on_sell_mask( M_blackmarket, slot )
			else
				on_sell_weapon( M_blackmarket, category, slot )
			end
		end
	end
	
	local backuper = backuper
	backuper:restore('MoneyManager.on_sell_weapon')
	backuper:restore('MoneyManager.on_sell_mask')
end

no_money = function()
	local backuper = backuper
	local MoneyManager = MoneyManager
	
	backuper:backup('MoneyManager.on_sell_weapon')
	function MoneyManager:on_sell_weapon() end
	
	backuper:backup('MoneyManager.on_sell_mask')
	function MoneyManager:on_sell_mask() end
end