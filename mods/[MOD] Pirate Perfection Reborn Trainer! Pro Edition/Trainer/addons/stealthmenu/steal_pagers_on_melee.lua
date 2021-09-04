-- Steal pagers on melee kill
-- Author: Harfatus

plugins:new_plugin('steal_pagers_on_melee')

VERSION = '1.0'

ppr_require('Trainer/addons/plyupgradehack')

local PlayerManager = PlayerManager
local hack_upgrade_value = assert( PlayerManager.hack_upgrade_value, 'Failed to load plyupgradehack.' )

function MAIN()
	hack_upgrade_value( PlayerManager, 'player', 'melee_kill_snatch_pager_chance', 1 )
end

function UNLOAD()
	hack_upgrade_value( PlayerManager, 'player', 'melee_kill_snatch_pager_chance' )
end

FINALIZE()