-- AIMBOT
	if	not	SDSA_IsActivated	then
		SDSA_IsActivated	=	false;
	end
	if	not	SDSA_FoundTarget	then
		SDSA_FoundTarget	=	false;
	end
	if	not	SDSA_TargetDir	then
		SDSA_TargetDir	=	Vector3();
	end

	if	mvector3	then
		if	not	SDST_Orig_mvector3_spread	then
			SDST_Orig_mvector3_spread	=	mvector3.spread;
		end
		function	mvector3.spread(Direction,	Spread)
			if	SDSA_IsActivated	and	SDSA_FoundTarget	then
				mvector3.set(Direction,	SDSA_TargetDir);
				SDSA_FoundTarget	=	false;
				return	SDST_Orig_mvector3_spread(Direction,	0);
				else
				return	SDST_Orig_mvector3_spread(Direction,	Spread);
			end
		end
	end

	function	SDSA_SilverAim(ThisPtr,	t,	input)
		if	SDSA_IsActivated	and	managers	and	managers.enemy	and	ThisPtr._ext_camera	and	ThisPtr._equipped_unit	and	ThisPtr._equipped_unit:base()	and	not	ThisPtr:_is_reloading()	and	not	ThisPtr:_changing_weapon()	and	not	ThisPtr:_is_meleeing()	and	not	ThisPtr._use_item_expire_t	and	not	ThisPtr:_interacting()	and	not	ThisPtr:_is_throwing_grenade()	then
			for	k,	MyUnitBase	in	pairs(managers.enemy:all_enemies())	do	
				if	MyUnitBase.unit	and	alive(MyUnitBase.unit)	and	not	MyUnitBase.is_converted	and	not	IsHostage(MyUnitBase.unit)	and	MyUnitBase.unit:movement()	and	MyUnitBase.unit:movement():m_head_pos()	then
					local	MyEye	=	Vector3();
					local	MyTarget	=	Vector3();
					mvector3.set(MyEye,	ThisPtr._ext_camera:position());
					mvector3.set(MyTarget,	MyUnitBase.unit:movement():m_head_pos());
					if	not	World:raycast("ray",	MyEye,	MyTarget,	"slot_mask",	managers.slot:get_mask("AI_visibility"),	"ray_type",	"ai_vision")	then
						local	MyRay	=	World:raycast("ray",	MyEye,	MyTarget,	"slot_mask",	ThisPtr._equipped_unit:base()._bullet_slotmask,	"ignore_unit",	ThisPtr._equipped_unit:base()._setup.ignore_units)
						if	MyRay	and	MyRay.unit	and	MyRay.body	then
							if	MyRay.unit:character_damage()	and	MyRay.unit:character_damage().is_head	and	MyRay.unit:character_damage():is_head(MyRay.body)	or	(MyRay.unit:base()	and	MyRay.unit:base()._tweak_table	==	"tank")	then
								mvector3.set(SDSA_TargetDir,	MyTarget);
								mvector3.subtract(SDSA_TargetDir,	MyEye);
								input.btn_primary_attack_state	=	true;
								input.btn_primary_attack_press	=	true;
								SDSA_FoundTarget	=	true;
								break;
							end	--	unit	hit
						end	--	hitray
					end	--	visible
				end	--	unit	valid
			end	--	for	enemies
		end	--	valid
	end	--	SDSA_SilverAim
	if	PlayerStandard	then
		if	not	SDSP_Orig_PlayerStandard_check_action_primary_attack	then	
			SDSP_Orig_PlayerStandard_check_action_primary_attack	=	PlayerStandard._check_action_primary_attack;
		end
		function	PlayerStandard:_check_action_primary_attack(t,	input)
			SDSA_SilverAim(self,	t,	input);
			return	SDSP_Orig_PlayerStandard_check_action_primary_attack(self,	t,	input);
		end
	end