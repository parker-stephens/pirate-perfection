-- HOLY HANDGRENADE v2	
-- INIT NO EFFECT???? MORE TEST NEEDED
function inGame() 
  if not game_state_machine then return false end 
	return string.find(game_state_machine:current_state_name(), "game") 
end 
if inGame() and managers.platform:presence() == "Playing" and not inChat() then
	function FragGrenade:init( unit )
		FragGrenade.super.init( self, unit )
		self._range = 3000
		self._effect_name = "effects/payday2/particles/explosions/grenade_explosion"
		self._curve_pow = 45
		self._damage = 150
		self._player_damage = 10
		
		self._custom_params = { effect = self._effect_name, feedback_range = self._range * 1, camera_shake_max_mul = 2, sound_muffle_effect = true }
	end
	function PlayerEquipment:throw_grenade()
	local from = self._unit:movement():m_head_pos()
	local pos = from + self._unit:movement():m_head_rot():y() * 50 + Vector3( 0, 0, 0 )
	local dir = self._unit:movement():m_head_rot():y()
		if Network:is_client() then
			--managers.network:session():send_to_host( "server_throw_grenade", 1, pos, dir )
			managers.network:session():send_to_host("request_throw_projectile", 1, pos, dir)
			managers.network:session():send_to_host("request_throw_projectile", 1, pos, dir)
			managers.network:session():send_to_host("request_throw_projectile", 1, pos, dir)
			--managers.network:session():send_to_host("request_throw_projectile", 1, pos, dir)
			--managers.network:session():send_to_host("request_throw_projectile", 1, pos, dir)
		else
			--GrenadeBase.server_throw_grenade( 1, pos, dir )
			ProjectileBase.throw_projectile(1, pos, dir, managers.network:session():local_peer():id())
			ProjectileBase.throw_projectile(1, pos, dir, managers.network:session():local_peer():id())
			ProjectileBase.throw_projectile(1, pos, dir, managers.network:session():local_peer():id())
			--ProjectileBase.throw_projectile(1, pos, dir, managers.network:session():local_peer():id())
			--ProjectileBase.throw_projectile(1, pos, dir, managers.network:session():local_peer():id())
		end
	end
	managers.player:player_unit():camera():play_redirect( Idstring( "throw_grenade" ) )
else
	--PlayMedia("Trainer/media/effects/access.mp3")
end	