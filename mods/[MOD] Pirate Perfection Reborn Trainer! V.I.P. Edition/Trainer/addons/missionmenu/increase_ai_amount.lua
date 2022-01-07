-- Increase enemies amount
-- Author: Simplity

local spawn_groups = tweak_data.group_ai.enemy_spawn_groups

plugins:new_plugin('increase_ai_amount')

VERSION = '1.0'

function MAIN()
	for _, data in pairs(spawn_groups) do
		data.amount[1] = data.amount[1] * 2
		data.amount[2] = data.amount[2] * 2
	end
end	

function UNLOAD()
	for _, data in pairs(spawn_groups) do
		data.amount[1] = data.amount[1] / 2
		data.amount[2] = data.amount[2] / 2
	end
end

FINALIZE()