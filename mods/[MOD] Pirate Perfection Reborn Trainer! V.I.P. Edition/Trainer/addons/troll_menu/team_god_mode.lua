-- Enable god mode for your team
-- Author: Simplity

plugins:new_plugin('team_god_mode')

local backuper = backuper

VERSION = '1.0'
	
function MAIN()
	local UnitNetworkHandler = UnitNetworkHandler
	local o__set_health = backuper:backup("UnitNetworkHandler.set_health")
	local verify_sender = UnitNetworkHandler._verify_sender
	local alive = alive
	function UnitNetworkHandler:set_health( unit, percent, max_mul, sender )
		local peer = verify_sender( sender )
		if not peer or not unit or not alive( unit ) then
			return
		end
		
		if percent < 100 then
			unit:network():send_to_unit( { "spawn_dropin_penalty", false, false, 1, 0, 0, 0 } )
		end
		
		return o__set_health( self, unit, percent, max_mul, sender )
	end
end

function UNLOAD()
	backuper:restore("UnitNetworkHandler.set_health")
end

FINALIZE()