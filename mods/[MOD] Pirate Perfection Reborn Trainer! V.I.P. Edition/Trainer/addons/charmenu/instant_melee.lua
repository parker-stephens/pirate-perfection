--Purpose: instantly charges melee weapon
--Author: baldwin

plugins:new_plugin('instant_melee')

local pairs = pairs
local T_B_melee_weapons = tweak_data.blackmarket.melee_weapons

VERSION = '1.0'

CATEGORY = 'character'

local function toggle_charge_time()
	for k,t in pairs(T_B_melee_weapons) do
		local stats = t.stats
		local charge_time = stats and stats.charge_time
		if k ~= 'weapon' and charge_time then
			if not stats.old_charge_time then
				stats.old_charge_time = charge_time
				stats.charge_time = 0.001
			else
				stats.charge_time = stats.old_charge_time
				stats.old_charge_time = nil
			end
		end
	end
end

function MAIN()
	toggle_charge_time()
end

function UNLOAD()
	toggle_charge_time()
end

FINALIZE()