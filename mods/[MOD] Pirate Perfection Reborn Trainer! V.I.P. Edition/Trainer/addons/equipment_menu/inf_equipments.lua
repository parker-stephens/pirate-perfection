--Infinite equipments
--Author: Simplity

ppr_require('Trainer/addons/ply_equip_fix')
local set_infinite = PlayerManager.set_infinite_equipment

plugins:new_plugin('inf_equipments')

VERSION = '1.0'

function MAIN()
	set_infinite( 0, true )
end

function UNLOAD()
	set_infinite( 0, false )
end

FINALIZE()