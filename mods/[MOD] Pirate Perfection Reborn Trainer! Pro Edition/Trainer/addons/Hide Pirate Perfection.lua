--Purpose: Hides a certain mod
--Author: The Joker (Beyond Cheats)

local pairs = pairs
local table_insert = table.insert
local MenuCallbackHandler = MenuCallbackHandler
local backuper = backuper

local tag = '[MOD] Pirate Perfection Reborn Trainer! Pro Edition'

backuper:hijack('MenuCallbackHandler.build_mods_list', function(o, s)
	local orig_mods = o(s)
	local new_mods = {}
	for _, mod in pairs(orig_mods) do
		if mod[1]~= tag and mod[2] ~= tag then
			table_insert(new_mods, mod)
		end
	end
	return new_mods
end)