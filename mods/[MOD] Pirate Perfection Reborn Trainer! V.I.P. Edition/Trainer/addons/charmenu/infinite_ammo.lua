-- Infinite ammo, without reloading by ThisJazzman

plugins:new_plugin('infinite_ammo')

VERSION = '1.0'

CATEGORY = 'character'

ppr_require('Trainer/addons/plyupgradehack')

local PlayerManager = PlayerManager
local hack_upgrade_value = PlayerManager.hack_upgrade_value

function MAIN()
	hack_upgrade_value(PlayerManager, "", "consume_no_ammo_chance", 2)
end

function UNLOAD()
	hack_upgrade_value(PlayerManager, "", "consume_no_ammo_chance")
end

FINALIZE()