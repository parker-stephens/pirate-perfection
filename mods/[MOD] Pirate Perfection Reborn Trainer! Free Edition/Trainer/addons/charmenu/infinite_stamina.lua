-- Infinite stamina
-- Author: Simplity

plugins:new_plugin('infinite_stamina')

local PlayerMovement = PlayerMovement

VERSION = '1.0'

CATEGORY = 'character'

local backuper = backuper
local backup = backuper.backup
local restore = backuper.restore

function MAIN()
	
	backup(backuper, 'PlayerMovement._change_stamina')
	backup(backuper, 'PlayerMovement.is_stamina_drained')
	function PlayerMovement._change_stamina()end
	function PlayerMovement.is_stamina_drained()return false end
end

function UNLOAD()
	restore(backuper, 'PlayerMovement._change_stamina')
	restore(backuper, 'PlayerMovement.is_stamina_drained')
end

FINALIZE()