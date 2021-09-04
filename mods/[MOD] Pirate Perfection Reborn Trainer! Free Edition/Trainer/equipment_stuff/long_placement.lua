--Author: ThisJazzman

plugins:new_plugin('long_placement')

VERSION = '1.0'

DESCRIPTION = 'Allows you to place equipments without distance limits'

local backuper = backuper
local backup = backuper.backup
local restore = backuper.restore
local get_ray = get_ray

local PlayerEquipment = PlayerEquipment

local main = function()
	backup(backuper, 'PlayerEquipment.valid_shape_placement')
	backup(backuper, 'PlayerEquipment.valid_look_at_placement')
	function PlayerEquipment.valid_shape_placement()
		return get_ray()
	end
	function PlayerEquipment.valid_look_at_placement()
		return get_ray()
	end
end

local unload = function()
	restore(backuper, 'PlayerEquipment.valid_shape_placement')
	restore(backuper, 'PlayerEquipment.valid_shape_placement')
end

MAIN = main
UNLOAD = unload

FINALIZE()