-- Interact through walls
-- Author: baldwin

plugins:new_plugin('ignore_walls')

CATEGORY = 'interaction'

VERSION = '1.0'

function MAIN()
	backuper:backup('ObjectInteractionManager._raycheck_ok')
	function ObjectInteractionManager._raycheck_ok() return true end
end

function UNLOAD()
	backuper:restore('ObjectInteractionManager._raycheck_ok')
end

FINALIZE()