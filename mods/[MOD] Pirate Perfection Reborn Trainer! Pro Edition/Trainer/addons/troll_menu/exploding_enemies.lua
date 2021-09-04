-- Makes cops exploding on death
-- Author: *

plugins:new_plugin('exploding_enemies')

VERSION = '1.0'

local backuper = backuper
local Vector3 = Vector3
local spawn_grenade = ProjectileBase.throw_projectile

function FragGrenade:set_params()
	self._custom_params.sound_muffle_effect = false
	self._custom_params.camera_shake_max_mul = 0
	self._custom_params.sound_event = "trip_mine_explode"
	self._custom_params.effect = "effects/payday2/particles/explosions/bag_explosion"
end
	
function MAIN()
	local _die = backuper:backup('CopDamage.die')
	function CopDamage:die( ... )
		local result = _die( self, ... )
		local unit = self._unit
		
		for i = 1, 4 do
			local u = spawn_grenade( 1, unit:position(), Vector3(0,0,0) ):base()
			u._death_unit = self._unit
			u._timer = 0.4
		end
		
		return result
	end
		
	local __detonate = backuper:backup('FragGrenade._detonate')
	function FragGrenade:_detonate( ... )
		if self._death_unit then
			self:set_params()
		end
		
		return __detonate( self, ... )
	end
	
	local __detonate_on_client = backuper:backup('FragGrenade._detonate_on_client')
	function FragGrenade:_detonate_on_client( ... )
		if not self._thrower_unit then
			self:set_params()
		end
		
		return __detonate_on_client( self, ... )
	end
end

function UNLOAD()
	backuper:restore("CopDamage.die")
	backuper:restore("FragGrenade._detonate")
	backuper:restore("FragGrenade._detonate_on_client")
end

FINALIZE()