-- Purpose: Gives you all skins
-- Authors: Written by Simplity, fixes by Davy Jones
local insert = table.insert
local pairs = pairs
local tonumber = tonumber
local tostring = tostring
local type = type

local M_blackmarket = managers.blackmarket
local weapon_skins = tweak_data.blackmarket.weapon_skins
local inventory_tradable = M_blackmarket._global.inventory_tradable

local backuper = backuper

local limiter = 1000000000

local i = 1
local j = tostring(i)
for id, data in pairs( weapon_skins ) do
	while inventory_tradable[j] ~= nil do
		i = i + 1
		j = tostring(i)
	end
	if not M_blackmarket:have_inventory_tradable_item( "weapon_skins", id ) then
		M_blackmarket:tradable_add_item( j, "weapon_skins", id, "mint", true, 1 )
	end
end

-- Temporary fix for the temporary fix
local convert
convert = function()
	for inst, data in pairs(inventory_tradable) do
		if type(inst) == "number" then
			inventory_tradable[tostring(inst)] = data
			inventory_tradable[inst] = nil
		end
	end
	convert = nil
end

backuper:hijack('BlackMarketManager.tradable_update', function(o, s, tradable_list, r)
	if convert then
		convert()
	end
	tradable_list = tradable_list or {}
	for inst, data in pairs(inventory_tradable) do
		if tonumber(inst) < limiter then
			insert(tradable_list, {instance_id = inst, category = data.category, entry = data.entry, quality = data.quality, bonus = data.bonus, amount = data.amount})
		end
	end
	o(s, tradable_list, r)
end)

function BlackMarketGui:sell_tradable_item(data)
	if tonumber(data.instance_id) > limiter then
		MenuCallbackHandler:steam_sell_item(data)
	end
end

-- Modifiable Legendary Skins
local weapon_skins = tweak_data.blackmarket.weapon_skins
for _, data in pairs(weapon_skins) do
	data.locked = false
end

local crafted = managers.blackmarket._global.crafted_items
for _, cat in pairs({crafted.primaries, crafted.secondaries}) do
	for _, data in pairs(cat) do
		if data.cosmetics then
			data.customize_locked = nil
		end
	end
end

-- Inspect All Safes
for _, safe in pairs(tweak_data.economy.safes) do
	if not safe.market_link then
		safe.market_link = "https://www.PiratePerfection.com"
	end
end