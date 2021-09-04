-- TERMINATOR HUD SCRIPT v1.1
-- Author: Poco
plugins:new_plugin('Terminator_HUD')

CATEGORY = 'mods'

VERSION = '1.0'
function MAIN()	
if	inGame()	and	isPlaying()	then
if not TerminatorHud then TerminatorHud = true
	function	RayTest	(len,noUnit)
		local	from	=	managers.player:player_unit():movement():m_head_pos()
		local	to	=	from	+	managers.player:player_unit():movement():m_head_rot():y()	*	(len	or	300000)
		if	noUnit	then
			return	managers.player:player_unit():raycast(	"ray",	from,	to,	"slot_mask",	managers.slot:get_mask(	"trip_mine_placeables"	),	"ignore_unit",	{}	)
		else
			return	World:raycast(	"ray",	from,	to,	"slot_mask",	managers.slot:get_mask(	"bullet_impact_targets"	),	"ignore_unit",	{}	)
		end
	end
	if	not	_G._HDmg	then
		_HDmg	=	{}
		_HDmg.ws	=	Overlay:newgui():create_screen_workspace()
		_HDmg.lbl	=	_HDmg.ws:panel():text{	name="lbl_"..tostring(math.random())	,	x	=	-900	+	0.5	*	RenderSettings.resolution.x,	y	=	-150	+	0.5	*	RenderSettings.resolution.y,	text="PPR-TH",	font=tweak_data.menu.pd2_large_font,	font_size	=	25,	color	=	Color.Free,	layer=2000	}
		_HDmg.lbl:show()
		_HDmg.txts	=	{}
		_HDmg.lastTxt	=	''
	else
		Overlay:gui():destroy_workspace(	_HDmg.ws)
		_HDmg	=	nil
	end
	local	ff	=	function(f)
		return	f	and	(f>100	and	tostring(math.floor(f))	or	string.format("%.2g",	f))	or	"0"
	end
	function	__updateTxt(t)
		local	txt	=	''
		local	pos	=	0
		local	posEnd	=	0
		local	ranges	=	{}
		local	txts	=	{}
		local	dmgNumDecay	=	5
		for	_,txtObj	in	ipairs(_HDmg.txts)	do
			table.insert(txts,txtObj)
		end
		if	_HDmg.dmgTxt	then
			for	_,DmgObj	in	ipairs(_HDmg.dmgTxt)	do
				if	not	DmgObj[3]	then
					DmgObj[3]	=	t	+	dmgNumDecay
				end
				if	DmgObj[3]	<	t	then
					table.remove(_HDmg.dmgTxt,_)
				else
					if	DmgObj[3]	then
						DmgObj[2]	=	DmgObj[2]:with_alpha((DmgObj[4]	or	1)*(DmgObj[3]	-	t)/dmgNumDecay)
					end
					table.insert(txts,DmgObj)
				end
			end
		end
		for	_,txtObj	in	ipairs(txts)	do
			if	not	txtObj[3]	or	txtObj[3]	>	t	then
				txt	=	txt..txtObj[1].."	"
				posEnd	=	pos	+	#(txtObj[1]	or	"")+1
				table.insert(ranges,{pos,posEnd,txtObj[2]	or	Color.blue})
				pos	=	posEnd
			end
		end
		if	_HDmg.lastTxt	~=	txt	then
			_HDmg.lastTxt	=	txt
			_HDmg.lbl:set_text(txt)
		end
		for	_,range	in	ipairs(ranges)	do
			_HDmg.lbl:set_range_color(	range[1],	range[2],	range[3]	or	Color.green)
		end
	end
	local	upgNames	=	{}
	upgNames.combat_medic_damage_multiplier	=	"Good	Samaritan	Bonus"
	upgNames.no_ammo_cost	=	"Ammo	Critical"
	upgNames.dmg_multiplier_outnumbered	=	"Underdog"
	upgNames.dmg_dampener_outnumbered	=	"Critical	Damage"
	upgNames.overkill_damage_multiplier	=	"Damage	Buff"

	function	_drawInspector(t,dt)		
		if	not	(_G._HDmg	and	_G.RayTest)	then	return	end
		local	txts	=	{}
		if	managers	and	managers.player	and	managers.player:player_unit()	and	World	and	managers.slot	then
			local	ray	=	RayTest()
			if	(ray	and	ray.unit)	then
				local	hitunit	=	ray.unit
				local	cHealth	=	hitunit:character_damage()	and	hitunit:character_damage()._health	or	false

				if	false	and	hitunit	and	hitunit:id()	then	
					table.insert(txts,{"["..hitunit:id().."]",Color.yellow:with_alpha(1.0)})
				end

					if	cHealth	then
					local	full	=	hitunit:character_damage()._HEALTH_INIT
					local	supp	=	hitunit:character_damage()._suppression_data
					if	full	and	(cHealth	>	0)	then	
						table.insert(txts,{ff(cHealth).."/"..ff(full),math.lerp(	Color.red,	Color.green,	cHealth/full	)})
					else
						table.insert(txts,{"Terminated\n",Color.red:with_alpha(1.0)})
					end

					if	full	and	cHealth	then
						table.insert(txts,{"("..	string.format("%.0f",cHealth/full*100).."%)",Color.white:with_alpha(1.0)})
					end

					if	supp	and	supp.value	then
						local	t	=	TimerManager:game():time()
						table.insert(txts	,	{	ff(supp.value)		,math.lerp(	Color.yellow,	Color.red,	supp.value/supp.brown_point	):with_alpha((supp.decay_t-t)/supp.duration)})
					end
				end

				if	hitunit	and	hitunit:interaction()	and	hitunit:interaction().tweak_data	and	hitunit:interaction()._active	then
					table.insert(txts,{hitunit:interaction().tweak_data,Color.white:with_alpha(1.3)})
					if	hitunit:interaction()._global_event	then
						table.insert(txts,{hitunit:interaction()._global_event,Color.red:with_alpha(1.3)})
					end
				end
			end	--	end	ray
			if	managers.player	then
				local	tUp	=	managers.player._temporary_upgrades
				if	tUp	then
					for	category,val1	in	pairs(tUp)	do
						for	upgrade,val2	in	pairs(val1)	do
							local	expT	=	tUp[	category	][	upgrade	][	"expire_time"	]
							if	expT	>	t	then
								upgrade	=	upgNames[upgrade]	or	upgrade
								if	upgrade	~=	""	then	--	underdog	dupe
									table.insert(txts,{"\n"..upgrade,math.lerp(	Color.red,	Color.green,	(expT-t)/3	)})
									table.insert(txts,{ff(expT-t),math.lerp(	Color.red,	Color.green,	(expT-t)/3	):with_alpha(1.5)})
								end
							end
						end
					end
				end
				local	tMoral	=	managers.player:player_unit():movement():rally_skill_data()
				tMoral	=	tMoral	and	tMoral.morale_boost_delay_t
				if	tMoral	and	tMoral	>	t	then
					table.insert(txts,{"\n\nMORAL	BOOST",math.lerp(	Color.green,	Color.red,	(tMoral-t)/3	)})
					table.insert(txts,{ff(tMoral-t),math.lerp(	Color.green,	Color.red,	(tMoral-t)/3	):with_alpha(1.5)})
				end
			end
			_HDmg.txts	=	txts
			__updateTxt(t)
		else
			if	_HDmg	then
				Overlay:gui():destroy_workspace(	_HDmg.ws)
				_HDmg	=	nil
			end
		end
	end
	if	managers	and	managers.hud	then
		managers.hud:add_updator(	"drawInspector",	_drawInspector	)
	end
	if	_G.CopDamage	then
		function	check_dmg(self,	attack_data,	cbk)
			local	before	=	self._health
			local	skip	=	self._dead	or	self._invulnerable
			local	result	=	cbk(self,	attack_data)
			if	skip	then	return	result	end
			local	delta	=	before	-	(self	and	self._health	or	0)	--	
			local	isCrit	=	false
			local	dmgType	=	attack_data	and	attack_data.result	and	attack_data.result.type	or	false
			if	attack_data.attacker_unit	~=	managers.player:player_unit()	then	return	result	end
			if	_HDmg	then
				if	not	_HDmg.dmgTxt	then	_HDmg.dmgTxt={}	end
				if	self._head_body_name	and	attack_data.col_ray	and	attack_data.col_ray.body	and	(attack_data.col_ray.body:name()	==	self._ids_head_body_name)	then
					managers.hud:on_crit_confirmed()
					isCrit	=	true
				end
				if	(delta	>	0)	or	(self._dead)	then
					if	dmgType	then
						table.insert(_HDmg.dmgTxt	,	1,	{dmgType	,Color.white,nil,0.2})
					end
					table.insert(_HDmg.dmgTxt	,	1,	{"\n"..(self	and	self._dead	and	(ff(before).."+")	or	ff(delta))	,isCrit	and	Color.red	or	Color.white,nil,0.5})
				end
			end
			return	result
		end

		if	not	_copDmgBlt	then	_copDmgBlt	=	CopDamage.damage_bullet	end
		function	CopDamage:damage_bullet(	attack_data	)
			return	check_dmg(self,	attack_data,_copDmgBlt)
		end
		if	not	_copDmgExp	then	_copDmgExp	=	CopDamage.damage_explosion	end
		function	CopDamage:damage_explosion(	attack_data	)
			return	check_dmg(self,	attack_data,_copDmgExp)
		end
		if	not	_copDmgMle	then	_copDmgMle	=	CopDamage.damage_melee	end
		function	CopDamage:damage_melee(	attack_data	)
			return	check_dmg(self,	attack_data,_copDmgMle)
		end
	end
	beep()
	end
else
end
end

function UNLOAD()

end

FINALIZE()