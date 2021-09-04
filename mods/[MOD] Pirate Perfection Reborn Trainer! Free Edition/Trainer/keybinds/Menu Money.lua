-- MONEY DUOMENU SCRIPT v1.1
-- IN GAME CHECK
	function	inGame()
		if	not	game_state_machine	then
			return	false
		end
		return
		string.find	(game_state_machine:current_state_name(),	"game")
	end
--	SIMPLE	MENU	V1
	if	not	SimpleMenu	then
		SimpleMenu	=	class()
		
		function	SimpleMenu:New(title,	message,	options)
			return	self:Init(title,	message,	options)
		end
		
		function	SimpleMenu:init(title,	message,	options)
			self.dialog_data	=	{	title	=	title,
										text	=	message,
										button_list	=	{},
										id	=	tostring	(math.random(0,0xFFFFFFFF))
									}
			self.visible	=	false	
			for	_,opt	in	ipairs	(options)	do
				local	elem	=	{}
				elem.text	=	opt.text
				opt.data	=	opt.data	or	nil
				opt.callback	=	opt.callback	or	nil
				elem.callback_func	=	callback	(self,	self,	"_do_callback",{	data	=	opt.data,callback	=	opt.callback})
				elem.cancel_button	=	opt.is_cancel_button	or	false
				if	opt.is_focused_button	then
					self.dialog_data.focus_button	=	#self.dialog_data.button_list+1
				end
				table.insert	(self.dialog_data.button_list,	elem)
			end
			return	self
		end

		function	SimpleMenu:_do_callback(info)
			if	info.callback	then
				if	info.data	then
					info.callback(info.data)
					else
					info.callback()
				end
			end
			self.visible	=	false
		end

		function	SimpleMenu:show()
			if	self.visible	then
				return
			end
			self.visible	=	true	managers.system_menu:show(self.dialog_data)
		end
		
		function	SimpleMenu:hide()
			if	self.visible	then
				managers.system_menu:close(self.dialog_data.id)
				self.visible	=	false
				return
			end
		end
	end

	patched_update_input	=	patched_update_input	or	function	(self,	t,	dt	)
		if	self._data.no_buttons	then
			return
		end
		local	dir,	move_time
		local	move	=	self._controller:get_input_axis(	"menu_move"	)
		if	(	self._controller:get_input_bool(	"menu_down"	))	then
			dir	=	1
			elseif	(	self._controller:get_input_bool(	"menu_up"	))	then
			dir	=	-1
		end
		if	dir	==	nil	then
			if	move.y	>	self.MOVE_AXIS_LIMIT	then
				dir	=	1
				elseif	move.y	<	-self.MOVE_AXIS_LIMIT	then
				dir	=	-1
			end
		end
		if	dir	~=	nil	then
			if(	(	self._move_button_dir	==	dir	)	and
				self._move_button_time	and
				(	t	<	self._move_button_time	+	self.MOVE_AXIS_DELAY	)	)	then
				move_time	=	self._move_button_time	or	t
				else
				self._panel_script:change_focus_button(	dir	)	move_time	=	t
			end
		end
		
		self._move_button_dir	=	dir
		self._move_button_time	=	move_time
		
		local	scroll	=	self._controller:get_input_axis(	"menu_scroll"	)
		if(	scroll.y	>	self.MOVE_AXIS_LIMIT	)	then
			self._panel_script:scroll_up()
			elseif(	scroll.y	<	-self.MOVE_AXIS_LIMIT	)	then
			self._panel_script:scroll_down()
		end
	end
	
	Hooks:Add(	"MenuManagerInitialize",	"MenuManagerInitialize_InitSimpleMenu",	function(	menu_manager	)
		managers.system_menu.DIALOG_CLASS.update_input	=	patched_update_input
		managers.system_menu.GENERIC_DIALOG_CLASS.update_input	=	patched_update_input
	end	)

if inGame() and isPlaying() then
	----------------
	-- GAME --
	----------------
	if not _uvSmallLoot then _uvSmallLoot = PlayerManager.upgrade_value 
	end
	if not _uvlSmallLoot then _uvlSmallLoot = PlayerManager.upgrade_value_by_level 
	end
	function secure(name)
		managers.loot:secure( name, managers.money:get_bag_value( name ) )
	end
	secureright = function()
		local jobid = managers.job:current_level_id()
			if jobid == "alex_1" or jobid == "alex_2" then
				secure("meth")
			elseif jobid == "watchdogs_1" or jobid == "watchdogs_2" or jobid == "nightclub" or jobid == "welcome_to_the_jungle_1" then
				secure("coke")
			elseif jobid == "firestarter_1" or jobid == "firestarter_2" then 
				secure("weapons")
			elseif jobid == "jewelry_store" or jobid == "mallcrasher" then
				secure("diamonds")
			elseif jobid == "arm_for" then
				secure("ammo")
			elseif jobid == "arm_hcm" or jobid == "arm_cro" or jobid == "arm_fac" or jobid == "arm_par" or jobid == "arm_und" or jobid == "framing_frame_3" then
				secure("gold")
			else
				secure("money")
			end
	end
	lootx10 = lootx10 or function()
		function PlayerManager:upgrade_value( category, upgrade, default ) 
			if category == "player" and upgrade == "small_loot_multiplier" then 
				return 10
			else 
				return _uvSmallLoot(self, category, upgrade, default) 
			end 
		end
		function PlayerManager:upgrade_value_by_level( category, upgrade, level, default ) 
			if category == "player" and upgrade == "small_loot_multiplier" then 
				return 10
			else 
				return _uvlSmallLoot(self, category, upgrade, level, default) 
			end 
		end
	end
	lootx100 = lootx100 or function()
		function PlayerManager:upgrade_value( category, upgrade, default ) 
			if category == "player" and upgrade == "small_loot_multiplier" then 
				return 100
			else 
				return _uvSmallLoot(self, category, upgrade, default) 
			end 
		end
		function PlayerManager:upgrade_value_by_level( category, upgrade, level, default ) 
			if category == "player" and upgrade == "small_loot_multiplier" then 
				return 100
			else 
				return _uvlSmallLoot(self, category, upgrade, level, default) 
			end 
		end
	end
	lootx255 = lootx255 or function()
		function PlayerManager:upgrade_value( category, upgrade, default ) 
			if category == "player" and upgrade == "small_loot_multiplier" then 
				return 255
			else 
				return _uvSmallLoot(self, category, upgrade, default) 
			end 
		end
		function PlayerManager:upgrade_value_by_level( category, upgrade, level, default ) 
			if category == "player" and upgrade == "small_loot_multiplier" then 
				return 255
			else 
				return _uvlSmallLoot(self, category, upgrade, level, default) 
			end 
		end
	end
end

if not inGame() then
	---------------
	-- MAIN --
	---------------
	-- ADD 1 MILLION AND 4 MILLION OFFSHORE
	add1mill = function()
		managers.money : _add_to_total(5000000)
	end
	-- ADD 10 MILLION AND 40 MILLION OFFSHORE
	add10mill = function()
		managers.money : _add_to_total(50000000)
	end
	-- ADD 100 MILLION AND 400 MILLION OFFSHORE
	add100mill = function()
		managers.money : _add_to_total(500000000)
	end
	-- ADD 1 BILLION AND 4 BILLION OFFSHORE
	add1bill = function()
		managers.money : _add_to_total(5000000000)
	end
	-- RESET CASH AND OFFSHORE FUND
	cashoffreset = function()
		managers.money:_deduct_from_total(999999999999999999999)
		managers.money:_deduct_from_offshore(999999999999999999999)
	end
	-- FREE OFFSHORE PAYDAY(CASINO) PURCHASING
	freeplay = freeplay or function()
		function MoneyManager:get_cost_of_casino_fee( secured_cards, increase_infamous, preferred_card )  
		return 0 
		end
	end
	-- ENABLE CASINO
	opencasino = opencasino or function()
		local casino_enabled = false
		for index, special_contract in ipairs( tweak_data.gui.crime_net.special_contracts ) do
			if string.find(special_contract.id, "casino") and not no_casino then casino_enabled = true 
			end
		end
		if not casino_enabled then
			tweak_data.gui.crime_net.special_contracts[#tweak_data.gui.crime_net.special_contracts+1] = { id="casino", name_id="menu_cn_casino", desc_id="menu_cn_casino_desc", menu_node="crimenet_contract_casino", x=347, y=716, icon="guis/textures/pd2/crimenet_casino", unlock="unlock_level", pulse=true, pulse_color=Color( 204, 255, 209, 32 )/255 }
		end
	end	
	--FULL BLACK MARKET
	adeptbarter = adeptbarter or function()
		dofile("Trainer/assets/fullblackmarket.lua")
	end
	-----------------
	-- MENU --
	-----------------
	moneyrootopt = moneyrootopt or {
		{ text = "Exit", is_cancel_button = true},
		{},
		{ text = "-- !! Reset cash and offshore account !! --", callback = cashoffreset },
		{},
		{ text = "Add 1 billion cash + 4 billion offshore", callback = add1bill },
		{ text = "Add 100 mill cash + 400 mill offshore", callback = add100mill },
		{ text = "Add 10 mill cash + 40 mill offshore", callback = add10mill },
		{ text = "Add 1 mill cash + 4 mill offshore", callback = add1mill },
		{},
		{ text = "Full blackmarket", callback = adeptbarter },
		{},
		{ text = "Free play in the casino", callback = freeplay },
		{ text = "Force casino open", callback = opencasino },
		}
	if not moneyrootmenu then
		moneyrootmenu = moneyrootmenu or SimpleMenu:new("MONEY MENU", "Add/remove cash and offshore funds and more", moneyrootopt)
	end
else
	moneyrootopt = moneyrootopt or {
		{ text = "Exit", is_cancel_button = true},
		{},
		{ text = "Loot value x10", callback = lootx10 },
		{ text = "Loot value x100", callback = lootx100 },
		{ text = "Loot value x255", callback = lootx255 },
		{},
		{ text = "Secure loot", callback = secureright },
		}
	if not moneyrootmenu then
		moneyrootmenu = moneyrootmenu or SimpleMenu:new("MONEY MENU", ".. the get rich quick", moneyrootopt)
	end
end
moneyrootmenu:show()