-- INCREASED PICKUP AMMO
if not RaycastWeaponBase then return nil end
	function	RaycastWeaponBase:add_ammo()
		if	self:ammo_max()	then
			return	false
		end
		local	multiplier_min	=	1	*	(self._ammo_data	and	self._ammo_data.ammo_pickup_min_mul	or	1)	*	managers.player:upgrade_value("player",	"pick_up_ammo_multiplier",	1)
		local	multiplier_max	=	1	*	(self._ammo_data	and	self._ammo_data.ammo_pickup_max_mul	or	1)	*	managers.player:upgrade_value("player",	"pick_up_ammo_multiplier",	1)
		local	add_amount	=	math.max(0,	math.round(math.lerp(self._ammo_pickup[1]	*	multiplier_min,	self._ammo_pickup[2]	*	multiplier_max,	math.random())))
		self:set_ammo_total(math.clamp(self:get_ammo_total()	+	add_amount,	5,	self:get_ammo_max()))
		return	true
	end