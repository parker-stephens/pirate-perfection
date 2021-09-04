-- Weapon fires grenades

plugins:new_plugin('grenade_weapon')

VERSION = '1.0'

CATEGORY = 'character'

local backuper = backuper

function MAIN()
--	local GrenadeBase = GrenadeBase
	local session = managers.network:session()
	local Network = Network
	local throw_projectile = ProjectileBase.throw_projectile

	local shot_fired = backuper:backup("StatisticsManager.shot_fired")
	function StatisticsManager:shot_fired( data )
		if not data.weapon_unit or not data.name_id then
			return
		end

		return shot_fired( self, data )
	end

	backuper:backup("RaycastWeaponBase._fire_raycast")
	function RaycastWeaponBase:_fire_raycast( user_unit, from_pos, direction, dmg_mul, shoot_player, spread_mul, autohit_mul, suppr_mul--[[, shoot_through_data ]] )
		local mvec_spread_direction = direction * 5

		if Network:is_client() then
			session:send_to_host( "request_throw_projectile", 2, from_pos, mvec_spread_direction )
		else
			local local_peer_id = session:local_peer():id()
			throw_projectile(--[[2]] 'frag', from_pos, mvec_spread_direction, local_peer_id )
		end
	end
end

function UNLOAD()
	backuper:restore('StatisticsManager.shot_fired')
	backuper:restore('RaycastWeaponBase._fire_raycast')
end

FINALIZE()