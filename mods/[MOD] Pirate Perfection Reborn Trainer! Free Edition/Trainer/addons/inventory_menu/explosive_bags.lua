-- Make all bags explosive
-- Author: Simplity

plugins:new_plugin('explosive_bags')

local pairs = pairs
local types = tweak_data.carry.types

VERSION = '1.0'

function MAIN()
	for carry_type in pairs( types ) do
		local carry = types[carry_type]
		local can_explode = carry.can_explode
		carry._can_explode = can_explode -- backup
		carry.can_explode = true
	end
end

function UNLOAD()
	for carry_type in pairs( types ) do
		local carry = types[carry_type]
		local backuped_can_explode = carry._can_explode
		if backuped_can_explode then
			carry.can_explode = backuped_can_explode
		end
	end
end

FINALIZE()