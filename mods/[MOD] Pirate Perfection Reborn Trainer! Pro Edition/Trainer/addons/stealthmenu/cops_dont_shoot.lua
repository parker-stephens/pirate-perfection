-- Cops don't shoot at you
-- Author: Remade by Simplity, original by Transcend

local backuper = backuper
local backup = backuper.backup
local restore = backuper.restore

local CopMovement = CopMovement

plugins:new_plugin('cops_dont_shoot')

VERSION = '1.0'

function MAIN()
	local setAllowFire = backup(backuper, 'CopMovement.set_allow_fire')
	local setAllowFireClient = backup(backuper, 'CopMovement.set_allow_fire_on_client')
	
	function CopMovement:set_allow_fire( state )
	   if not state then
		   setAllowFire(self, state)
	   end   
	end
	
	function CopMovement:set_allow_fire_on_client( state, unit )
	   if not state then
		   setAllowFireClient(self, state, unit)
	   end   
	end
end

function UNLOAD()
	restore(backuper, 'CopMovement.set_allow_fire')
	restore(backuper, 'CopMovement.set_allow_fire_on_client')
end

FINALIZE()