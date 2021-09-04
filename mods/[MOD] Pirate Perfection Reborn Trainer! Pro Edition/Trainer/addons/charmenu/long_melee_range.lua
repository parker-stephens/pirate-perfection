--Purpose: increases melee hit distance. Toggleable.
--Author: baldwin

plugins:new_plugin('long_melee_range')

local pairs = pairs

local T_B_melee_weapons = tweak_data.blackmarket.melee_weapons

VERSION = '1.0'

CATEGORY = 'character'

function MAIN()
	for _,tweak in pairs(T_B_melee_weapons) do
		local stats = tweak.stats
		if stats then
			stats.old_range = tweak.stats.old_range or tweak.stats.range
			stats.range = 20000
		end
	end
end

function UNLOAD()
	for _,tweak in pairs(T_B_melee_weapons) do
		local stats = tweak.stats
		if stats then
			stats.range = tweak.stats.old_range or tweak.stats.range
		end
	end
end

FINALIZE()