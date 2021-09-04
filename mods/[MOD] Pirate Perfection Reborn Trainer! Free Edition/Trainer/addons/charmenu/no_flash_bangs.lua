-- No flash bangs
-- Author:

plugins:new_plugin('no_flash_bangs')

VERSION = '1.0'

CATEGORY = 'character'

function MAIN()
	backuper:backup('CoreEnvironmentControllerManager.set_flashbang')
	function CoreEnvironmentControllerManager.set_flashbang() end
end

function UNLOAD()
	backuper:restore('CoreEnvironmentControllerManager.set_flashbang')
end

FINALIZE()