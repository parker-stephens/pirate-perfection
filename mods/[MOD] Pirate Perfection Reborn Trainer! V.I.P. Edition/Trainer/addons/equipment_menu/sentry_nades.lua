-- Sentry gun shoots grenades
-- Author: baldwin

plugins:new_plugin('sentry_nades')

local managers = managers
local mvector3 = mvector3
local mvec_set = mvector3.set
local mvec_mul = mvector3.multiply
local mvec_add = mvector3.add
local mvec_dist = mvector3.distance
local Vector3 = Vector3
local T_weapon = tweak_data.weapon
local togg_vars = togg_vars
local World = World
local W_raycast = World.raycast
local throw_projectile = ProjectileBase.throw_projectile
local peer_id = managers.network:session():local_peer():id()

VERSION = '1.1'

function MAIN()
	local mvec_to = Vector3()
	backuper:backup('SentryGunWeapon._fire_raycast')
	function SentryGunWeapon:_fire_raycast( from_pos, direction, shoot_player )
		mvec_set( mvec_to, direction )
		mvec_mul( mvec_to, T_weapon[ self._name_id ].FIRE_RANGE )
		mvec_add( mvec_to, from_pos )

		local col_ray = W_raycast( World, "ray", from_pos, mvec_to, "slot_mask", self._bullet_slotmask )
		if col_ray then
			local mul = mvec_dist(self._unit:position(), col_ray.unit:position()) / 800
			mvec_mul( direction, mul )
			
			throw_projectile( togg_vars.sentry_ammo or 1, from_pos, direction, peer_id )
		end

		if not col_ray or col_ray.distance > 600 then
			self:_spawn_trail_effect( direction, col_ray )
		end

		return {}
	end
end

function UNLOAD()
	backuper:restore('SentryGunWeapon._fire_raycast')
end

FINALIZE()