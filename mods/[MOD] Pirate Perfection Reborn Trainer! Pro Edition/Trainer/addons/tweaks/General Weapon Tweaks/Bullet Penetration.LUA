--BULLET PENETRATION FOR ALL WEAPONS
	if	not	FullPenetration	then	FullPenetration	=	true
		local	old_init	=	WeaponTweakData.init
		function	WeaponTweakData:init(tweak_data)
			old_init(self,	tweak_data)
			for	k,v	in	pairs(self)	do
				if	type(v)	==	"table"	and	v.category	then
					self[k].can_shoot_through_shield	=	true
					self[k].can_shoot_through_enemy	=	true
					self[k].can_shoot_through_wall	=	true
				end
			end
		end
	end