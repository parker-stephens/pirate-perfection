-- WEAPON PARTS TWEAKS
	for _,part in pairs( tweak_data.weapon.factory.parts ) do
		if ( part.stats ) then
			part.stats.damage			=	210
			part.stats.spread			=	26
			part.stats.recoil			=	26
			part.stats.spread_moving	=	26
			part.stats.zoom				=	10
			part.stats.concealment		=	1
			part.stats.suppression		=	20
			part.stats.alert_size		=	20	--Comment this out if you don't want every part to act like a silencer.
			part.stats.extra_ammo		=	50
			part.stats.total_ammo_mod	=	20
			part.stats.value			=	10
			part.stats.reload			=	21
			part.stats.fire_rate		=	00
		end
	end