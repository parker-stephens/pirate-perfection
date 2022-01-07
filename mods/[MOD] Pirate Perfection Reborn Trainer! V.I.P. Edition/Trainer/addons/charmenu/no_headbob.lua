-- No headbob
-- Author:

plugins:new_plugin('no_headbob')

VERSION = '1.0'

CATEGORY = 'character'

local backuper = backuper
local PlayerStandard = PlayerStandard

function MAIN()
	backuper:backup('PlayerStandard._get_walk_headbob')
	function PlayerStandard._get_walk_headbob()return 0 end
end

function UNLOAD()
	backuper:restore('PlayerStandard._get_walk_headbob')
end

FINALIZE()