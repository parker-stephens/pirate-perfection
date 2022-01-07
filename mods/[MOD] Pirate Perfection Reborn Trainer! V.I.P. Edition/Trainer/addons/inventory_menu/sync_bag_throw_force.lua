-- Increase bag throw force for all
-- Author: Simplity

plugins:new_plugin('sync_bag_throw_force')

local togg_vars = togg_vars
local PlayerManager = PlayerManager
local backuper = backuper
local restore = backuper.restore

VERSION = '1.0'

function MAIN()
	local o__server_drop_carry = restore(backuper, "PlayerManager.server_drop_carry")
	function PlayerManager:server_drop_carry( carry_id, carry_multiplier, dye_initiated, has_dye_pack, dye_value_multiplier, position, rotation, dir, throw_distance_multiplier_upgrade_level, zipline_unit, peer_id )
		local bag_throw = togg_vars.bag_throw
		dir = dir * (bag_throw and bag_throw/2 or 1)
		return o__server_drop_carry( self, carry_id, carry_multiplier, dye_initiated, has_dye_pack, dye_value_multiplier, position, rotation, dir, throw_distance_multiplier_upgrade_level, zipline_unit, peer_id )
	end
end

function UNLOAD()
	restore(backuper, "PlayerManager.server_drop_carry")
end

FINALIZE()