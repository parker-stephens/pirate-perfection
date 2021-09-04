--  Mask Clean-up Menu
--  Remove those pesky "return to stash" masks
--  Written by AidenP

local pairs = pairs
local tab_insert = table.insert

local in_game = in_game

local managers = managers
local M_blackmarket = managers.blackmarket
local M_localization = managers.localization

local Global = Global
local G_savefile = Global.savefile_manager

local tweak_data = tweak_data
local T_B_masks = tweak_data.blackmarket.masks

local Menu = Menu
local Menu_open = Menu.open

local mask_cleanup, verify_remove

local function remove_masks(group_name, mask)
	local save_blackmarket = G_savefile.meta_data_list[98].cache.blackmarket
	M_blackmarket._global.inventory[group_name].masks[mask] = nil
	M_blackmarket._global.global_value_items[group_name].inventory.masks[mask] = nil
	save_blackmarket.inventory[group_name].masks[mask] = nil
	save_blackmarket.global_value_items[group_name].inventory.masks[mask] = nil
end

verify_remove = function(group_name, mask)
	local data = {
		{},
		{},
		{text = "Confirm Remove Masks", callback = remove_masks, data = {group_name, mask}},
	}

	Menu_open(Menu, {title = "Mask Clean-up WARNING", description = "Are you sure you want to remove all of "..M_localization:text(T_B_masks[mask].name_id).." masks from your stash?", button_list = data, back = mask_cleanup})
end

mask_cleanup = function()
	local data = {}
	local override_desc
	if not in_game() then
		for group_name, group_table in pairs(M_blackmarket._global.inventory) do
			if group_table.masks then
				for mask, count in pairs(group_table.masks) do
					if T_B_masks[mask].value == 0 then
						tab_insert(data, {text = M_localization:text(T_B_masks[mask].name_id).."    ("..count..")", callback = function() verify_remove(group_name, mask) end})
					end
				end
				tab_insert(data, {})
			end
		end
	else
		override_desc = "I recommend using this from the game's main menu, as modifying both inventory and save data here could introduce complications."
	end

	Menu_open(Menu, {title = "Mask Clean-up Menu", description = override_desc or "This will remove the selected masks from your stash.", button_list = data})
end

return mask_cleanup