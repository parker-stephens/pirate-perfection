-- INSTANT INTIMIDATE & CONVERT ULIMITED (500) ENEMIES ON CROSSHAIR
	-- Instant Intimidate
	if not _PlyUpgVal then
		_PlyUpgVal = PlayerManager.upgrade_value 
	end
	function	CopLogicIdle.on_intimidated(	data,	amount,	aggressor_unit	)
		if	aggressor_unit	==	managers.player:player_unit()	then
			CopLogicIdle._surrender(	data,	amount	)
			return	true
			else
			return	on_intimidated(data,	amount,	aggressor_unit)
		end
	end
	CopLogicAttack.on_intimidated	=	CopLogicIdle.on_intimidated
	CopLogicArrest.on_intimidated	=	CopLogicIdle.on_intimidated
	CopLogicSniper.on_intimidated	=	CopLogicIdle.on_intimidated
	CopBrain._logic_variants.shield.intimidated	=	CopLogicIntimidated
	function	CopLogicIntimidated.on_intimidated(	data,	amount,	aggressor_unit	)
		if	data.unit:base()._tweak_table	==	"shield"	then
			CopLogicIntimidated._do_tied(	data,	aggressor_unit	)
			CopInventory._chk_spawn_shield(	data.unit:inventory(),	nil	)
			else
			on_intimidated(data, amount, aggressor_unit)
		end
		CopBrain._logic_variants.sniper	=	clone(	CopBrain._logic_variants.security	)
		CopBrain._logic_variants.sniper.attack	=	CopLogicSniper
		function	CopLogicSniper.enter(	data,	new_logic_name,	enter_params	)
			if	data.unit:brain()._logic_data	and	data.unit:brain()._logic_data.objective	and	data.unit:brain()._logic_data.objective.type	==	"follow"	then
				data.char_tweak.weapon[	data.unit:inventory():equipped_unit():base():weapon_tweak_data().usage	]	=	tweak_data.character.presets.weapon.sniper.m4
				data.char_tweak.weapon[	data.unit:inventory():equipped_unit():base():weapon_tweak_data().usage	].	spread	=	0
				for	distance=1,	3	do
					for	interpolate=1,2	do
						data.char_tweak.weapon[	data.unit:inventory():equipped_unit():base():weapon_tweak_data().usage	].FALLOFF[distance].acc[interpolate]	=	1
					end
				end
			end
		_onSniperEnter(data,	new_logic_name,	enter_params)
		end
	end
--[[	-- Instant Convert
	function	PlayerManager:upgrade_value(	category,	upgrade,	default	)	
		if	category	==	"player"	and	upgrade	==	"convert_enemies"	then
			return	true
			elseif	category	==	"player"	and	upgrade	==	"convert_enemies_max_minions"	then
			return	500
			else	
			return	_PlyUpgVal(self,	category,	upgrade,	default)	
		end	
	end
	if	inGame()	and	isPlaying()	and	not	inChat()	and	not	InOverlay()	then
		local	colRay	=	get_crosshair_ray(false,	"enemies")
		if	colRay	and	colRay.unit	and	alive(colRay.unit)	then
			managers.groupai:state():convert_hostage_to_criminal(	colRay.unit	)
			managers.groupai:state():sync_converted_enemy(	colRay.unit	)
		end
	end
]]