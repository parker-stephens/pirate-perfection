-- SENTRY GUN TWEAKS
	tweak_data.weapon.sentry_gun.base_ammo					=	1000
	tweak_data.weapon.sentry_gun.base_armor					=	1000
	tweak_data.weapon.sentry_gun.reload_ratio				=	100	
	tweak_data.weapon.sentry_gun.DAMAGE						=	10000													--	Default	=	1				--	Damage	per	shot	dealt	by	the	sentry	gun
	tweak_data.weapon.sentry_gun.SPREAD						=	1														--	Default	=	5				--	maximum	spread(degrees)
	tweak_data.weapon.sentry_gun.FIRE_RANGE					=	10000													--	Default	=	5000			--	How	far	bullets	reach(cm)
	tweak_data.weapon.sentry_gun.DETECTION_RANGE			=	10000													--	Default	=	1800			--	How	far	away	can	the	sentry	gun	detect	targets	(cm)
	
	tweak_data.weapon.sentry_gun.auto.fire_rate				=	0.5														--	Default	=	0.15			--	this	takes	to	account	both	weapons
	tweak_data.weapon.sentry_gun.alert_size					=	1														--	Default	=	2500
	tweak_data.weapon.sentry_gun.suppression				=	1														--	Default	=	0.8
	
	tweak_data.weapon.sentry_gun.BAG_DMG_MUL				=	1														--	Default	=	0.25			--	enemy	shots	hitting	the	shield	get	this	damage	multiplier
	tweak_data.weapon.sentry_gun.SHIELD_DMG_MUL				=	1														--	Default	=	0				--	enemy	shots	hitting	the	shield	get	this	damage	multiplier
	tweak_data.weapon.sentry_gun.LOST_SIGHT_VERIFICATION	=	0.01													--	Default	=	0.1				--	How	long	it	takes	the	sentry	gun	to	realize	that	it	has	lost	sight	of	a	target.
	tweak_data.weapon.sentry_gun.DEATH_VERIFICATION			=	{0.01,	0.02}											--	Default	=	{0.4,	0.75}	--	How	long	it	takes	the	sentry	gun	to	realize	that	its	target	has	died.	min,	max	(sec)

	tweak_data.weapon.sentry_gun.KEEP_FIRE_ANGLE			=	1														--	Default	=	0.8				--	if	the	angle	from	the	target	is	smaller	than	this	value,	keep	shooting	(dot).
	tweak_data.weapon.sentry_gun.recoil						=	{}														--	Default	=	{}
	tweak_data.weapon.sentry_gun.recoil.horizontal			=	{1,1,1,1}												--	Default	=	{2,3,0,3}		--	{	a,	b,	c,	d	}	=>	math.rand(	a,	b	)	*	math.random(	c,	d	)
	tweak_data.weapon.sentry_gun.recoil.vertical			=	{1,1,1,1}												--	Default	=	{1,2,0,4}		--	example:	{	2,	3,	0,	3	}	=>	values:	0,	2-3,	4-6,	6-9	--	recoils	to	the	left
	
	tweak_data.weapon.sentry_gun.SLOWDOWN_ANGLE_SPIN		=	50														--	Default	=	30				--	slow	down	if	target	angle	error	is	smaller	than	this	value	(deg)
	tweak_data.weapon.sentry_gun.MAX_VEL_SPIN				=	1000													--	Default	=	120				--	max	angular	velocity	of	turret	(deg/sec)
	tweak_data.weapon.sentry_gun.MIN_VEL_SPIN				=	tweak_data.weapon.sentry_gun.MAX_VEL_SPIN	*	1		--	Default	=	0.05			--	min	angular	velocity	of	turret	(deg/sec)
	tweak_data.weapon.sentry_gun.ACC_SPIN					=	tweak_data.weapon.sentry_gun.MAX_VEL_SPIN	*	10		--	Default	=	5				--	angular	acceleration/decceleration	(dec/sec^2)

	tweak_data.weapon.sentry_gun.SLOWDOWN_ANGLE_PITCH		=	50														--	Default	=	20				--	slow	down	if	target	angle	error	is	smaller	than	this	value	(deg)
	tweak_data.weapon.sentry_gun.MAX_VEL_PITCH				=	1000													--	Default	=	100				--	max	angular	velocity	of	turret	(deg/sec)
	tweak_data.weapon.sentry_gun.MIN_VEL_PITCH				=	tweak_data.weapon.sentry_gun.MAX_VEL_PITCH	*	0.01	--	Default	=	0.05			--	min	angular	velocity	of	turret	(deg/sec)
	tweak_data.weapon.sentry_gun.ACC_PITCH					=	tweak_data.weapon.sentry_gun.MAX_VEL_PITCH	*	100		--	Default	=	5				--	angular	acceleration/decceleration	(dec/sec^2)
	
	tweak_data.weapon.sentry_gun.challenges					=	{}														--	Default	=	{}
--	tweak_data.weapon.sentry_gun.name_id					=	"LuPeYs_Turret"	
	tweak_data.weapon.sentry_gun.challenges.group			=	"sentry_gun"
	tweak_data.weapon.sentry_gun.challenges.weapon			=	"sentry_gun"
	tweak_data.weapon.sentry_gun.muzzleflash				=	"effects/payday2/particles/weapons/9mm_auto"
	tweak_data.weapon.sentry_gun.muzzleflash_silenced		=	"effects/payday2/particles/weapons/9mm_auto_silence"
	
	tweak_data.weapon.sentry_gun.ammo_multiplier			=	1000	*	managers.player:upgrade_value(	"sentry_gun",	"extra_ammo_multiplier",	1	)	--	infinite	ammo
	tweak_data.weapon.sentry_gun.armor_multiplier			=	1000	*	managers.player:upgrade_value(	"sentry_gun",	"armor_multiplier",	1	)			--	infinite	health
	tweak_data.weapon.sentry_gun.damage_multiplier			=	1000	*	managers.player:upgrade_value(	"sentry_gun",	"damage_multiplier",	1	)		--	extra	Damage