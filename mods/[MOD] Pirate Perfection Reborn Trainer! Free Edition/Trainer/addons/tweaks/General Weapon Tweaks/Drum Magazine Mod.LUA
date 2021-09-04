-- DRUM MAGAZINE MOD
	if	not	WeaponFactoryTweakData	then
		return
	end
	local	old_m4_init	=	WeaponFactoryTweakData._init_m4
	function	WeaponFactoryTweakData:_init_m4()
		old_m4_init(self)
		self.parts.wpn_fps_upg_m4_m_drum.pcs	=	{	20,
														30,
														40
													}
	end
	local	old_mp5_init	=	WeaponFactoryTweakData._init_mp5
	function	WeaponFactoryTweakData:_init_mp5()
		old_mp5_init(self)
		self.parts.wpn_fps_smg_mp5_m_drum.pcs	=	{	20,
														30,
														40
													}
	end
	local	old_saiga_init	=	WeaponFactoryTweakData._init_saiga
--[[	function	WeaponFactoryTweakData:_init_saiga()
		old_saiga_init(self)
		self.parts.wpn_upg_saiga_m_20rnd.pcs	=	{	20,
														30,
														40
													}
	end]]