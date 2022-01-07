-- Interact with all
-- Author: Transcend

ppr_require('Trainer/addons/ply_equip_fix')
local set_infinite = PlayerManager.set_infinite_equipment
local backuper = backuper
local backup = backuper.backup
local restore = backuper.restore

local BaseInteractionExt = BaseInteractionExt

plugins:new_plugin('interact_with_all')

VERSION = '1.0'

CATEGORY = 'interaction'

function MAIN()
	backup(backuper, 'BaseInteractionExt._has_required_upgrade')
	backup(backuper, 'BaseInteractionExt._has_required_deployable')
	backup(backuper, 'BaseInteractionExt.can_interact')

	function BaseInteractionExt._has_required_upgrade() return true end
	function BaseInteractionExt._has_required_deployable() return true end
	function BaseInteractionExt.can_interact() return true end
end

function UNLOAD()
	restore(backuper, 'BaseInteractionExt._has_required_upgrade')
	restore(backuper, 'BaseInteractionExt._has_required_deployable')
	restore(backuper, 'BaseInteractionExt.can_interact')
end

FINALIZE()