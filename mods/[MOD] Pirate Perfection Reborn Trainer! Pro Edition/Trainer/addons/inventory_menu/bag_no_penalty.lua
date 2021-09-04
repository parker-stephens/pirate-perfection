-- No penalty movement with bag
-- Author: v00d00

plugins:new_plugin('bag_no_penalty')

local pairs = pairs
local types = tweak_data.carry.types

VERSION = '1.0'

function MAIN()
	for carry_type in pairs( types ) do
		local data = types[ carry_type ]
		
		-- backup
		data._move_speed_modifier = data.move_speed_modifier
		data._jump_modifier = data.jump_modifier
		data._can_run = data.can_run
		
		data.move_speed_modifier = 1
		data.jump_modifier = 1
		data.can_run = true
	end
end

function UNLOAD()
	for carry_type in pairs( types ) do
		local data = types[ carry_type ]
		
		data.move_speed_modifier = data._move_speed_modifier
		data.jump_modifier = data._jump_modifier
		data.can_run = data._can_run
	end
end

FINALIZE()