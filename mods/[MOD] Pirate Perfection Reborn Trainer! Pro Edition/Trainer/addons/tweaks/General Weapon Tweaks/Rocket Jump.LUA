-- ROCKET JUMP
	local	old_damage_explosion	=	PlayerDamage.damage_explosion
	function	PlayerDamage:damage_explosion(attack_data)
		attack_data.damage	=	0
		old_damage_explosion(self,	attack_data)
		if	self._unit	and	self._unit:movement()	then
			local	distance	=	mvector3.distance(attack_data.position,	self._unit:position())
			if	distance	>	attack_data.range	then
				return
			end
			local	mvec_delta	=	Vector3()
			mvector3.set(mvec_delta,	self._unit:position())
			mvector3.subtract(mvec_delta,	attack_data.position)
			mvector3.multiply(mvec_delta,	(1000	/	distance)	*	2.5)
			self._unit:movement():push(mvec_delta)
		end
	end