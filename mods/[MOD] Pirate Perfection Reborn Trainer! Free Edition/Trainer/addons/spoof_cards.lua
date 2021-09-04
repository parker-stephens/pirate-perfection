--  Author:  Davy Jones
--  Purpose:  Spoofs your loot drop in multiplayer to always be a random safe or drill
local insert = table.insert
local rand = math.random
local randseed = math.randomseed
local os = os

local Color = Color

local managers = managers
local M_chat = managers.chat
local M_localization = managers.localization
local M_lootdrop = managers.lootdrop

local tweak_data = tweak_data
local T_blackmarket = tweak_data.blackmarket
local T_economy = tweak_data.economy

local ppr_config = ppr_config

local backuper = backuper
local hijack = backuper.hijack

local tr = Localization.translate

local def_items = {}

do
	for _, typ_n in pairs({"safes", "drills"}) do
		for _, id in pairs({"weapon_01", "dallas_01", "surf_01", "pack_01"}) do
			insert(def_items, {typ_n, id})
		end
	end
end

hijack(backuper, "IngameLobbyMenuState.set_lootdrop", function(o, self, drop_category, drop_item_id)
	if drop_item_id and drop_category then
		o(self, drop_category, drop_item_id)
		return
	end
	local temp = {}
	M_lootdrop:new_make_drop(temp)
	M_chat:_receive_message(1, tr.loot_spoof_name, tr.loot_spoof_actual..M_localization:text(T_blackmarket[temp.type_items][temp.item_entry].name_id), Color.Free)
	local spoofs = {}
	for typ_n, typ in pairs({safes = T_economy.safes, drills = T_economy.drills}) do
		for id, _ in pairs(typ) do
			if ppr_config[typ_n..id] then
				insert(spoofs, {typ_n, id})
			end
		end
	end
	if #spoofs == 0 then
		spoofs = def_items
	end
	local t = os.date("*t")
	randseed(t.yday * t.hour * t.min * t.sec)
	local spoofed = spoofs[rand(#spoofs)]
	o(self, spoofed[1], spoofed[2])
end)