-- SHOTGUN WITH PHYSICS PUSH
if not NewShotgunBase then return nil end
	local	factor_table	=	{	default	=	{	damage_factor	=	5,	spread_factor	=	5	},							--	Standard Ammo
									wpn_fps_upg_a_custom	=	{	damage_factor	=	5,	spread_factor	=	5	},			--	000 Buckshots
									wpn_fps_upg_a_custom_free	=	{	damage_factor	=	5,	spread_factor	=	5	},		--	000 Buckshots (non-DLC Version)
									wpn_fps_upg_a_piercing	=	{	damage_factor	=	5,	spread_factor	=	5	},			--	Flechettes
									wpn_fps_upg_a_explosive	=	{	damage_factor	=	100,	spread_factor	=	5	},		--	HE Rounds
									wpn_fps_upg_a_slug	=	{	damage_factor	=	5,	spread_factor	=	5	}				--	AP Slugs
								}
	function	NewShotgunBase:_fire_raycast(user_unit,	from_pos,	direction,	dmg_mul,	shoot_player,	spread_mul,	autohit_mul,	suppr_mul,	shoot_through_data)
		if	not	self._ammo_type_id	then
			self._ammo_type_id	=	"default"
			if	self._ammo_data	then
				for	_,	id	in	pairs(managers.weapon_factory:get_assembled_blueprint(self._factory_id,	self._blueprint))	do
					if	tweak_data.weapon.factory.parts[id].type	==	"ammo"	and	factor_table[id]	then
						self._ammo_type_id	=	id
					end
				end
			end
		end
		local	damage_factor	=	factor_table[self._ammo_type_id].damage_factor
		local	spread_factor	=	factor_table[self._ammo_type_id].spread_factor
		local	result
		for	i	=	self._rays,	1,	-1	do
			result	=	NewShotgunBase.super._fire_raycast(self,	user_unit,	from_pos,	direction,	(dmg_mul	or	1)	*	damage_factor,	shoot_player,	(spread_mul	or	1)	*	spread_factor,	autohit_mul,	suppr_mul,	shoot_through_data)
			if	result	and	result.hit_enemy	and	result.hit_enemy.type	==	"death"	and	result.rays	and	result.rays[1]	then
				local	col_ray	=	result.rays[1]
				managers.game_play_central:do_shotgun_push(col_ray.unit,	col_ray.position,	col_ray.ray,	col_ray.distance)
			end
		end
		return	result
	end