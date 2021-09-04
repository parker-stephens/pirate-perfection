-- FREE MARKET
-- Set any of these to "false" to disable them.
	freeSkills		=	true
	freeContracts	=	true
	freeWeapons		=	true
	freeWeaponMods	=	true
	freeSlots		=	true
	freeMasks		=	true

	local function expect_yes( self, params ) params.yes_func()
	end

	if	MoneyManager	then	
		if	freeSkills	==	true	then
			function	MoneyManager:get_skillpoint_cost()
				return	0
				end
			function	MoneyManager:on_respec_skilltree()
				return
			end
		end

		if	freeContracts	==	true	then
			function	MoneyManager:get_cost_of_premium_contract()
				return	0
				end
		end

		if	freeWeapons	==	true	then
			function	MoneyManager:get_weapon_price()
				return	0
			end
			function	MoneyManager:get_weapon_price_modified()
				return	0
			end
			function	MoneyManager:on_sell_weapon()
				return
			end
		end

		if	freeWeaponMods	==	true	then
			function	MoneyManager:get_weapon_modify_price()
				return	0
			end
			function	MoneyManager:get_weapon_part_sell_value()
				return	0
			end
		end

		if	freeSlots	==	true	then
			function	MoneyManager:get_buy_mask_slot_price()
				return	0
			end
			function	MoneyManager:get_buy_weapon_slot_price()
				return	0
			end
		end

		if	freeMasks	==	true	then
			function	MoneyManager:get_mask_part_price_modified()
				return	0
			end
			function	MoneyManager:get_mask_crafting_price_modified()
				return	0
			end
			function	MoneyManager:get_mask_sell_value()
				return	0
			end
		end
	end

	if	MenuManager	then
		if	freeSkills == true then
			MenuManager.show_confirm_skillpoints = expect_yes
			MenuManager.show_confirm_respec_skilltree = expect_yes
		end

		if	freeContracts == true then
			MenuManager.show_confirm_buy_premium_contract = expect_yes
		end

		if	freeWeapons	== true then
			MenuManager.show_confirm_blackmarket_buy = expect_yes
			MenuManager.show_confirm_blackmarket_sell = expect_yes
		end

		if	freeWeaponMods == true then
			MenuManager.show_confirm_blackmarket_mod = expect_yes
		end

		if	freeSlots == true then
			MenuManager.show_confirm_blackmarket_buy_mask_slot = expect_yes
			MenuManager.show_confirm_blackmarket_buy_weapon_slot = expect_yes
		end

		if	freeMasks == true then
			MenuManager.show_confirm_blackmarket_finalize = expect_yes
			MenuManager.show_confirm_blackmarket_assemble = expect_yes
			MenuManager.show_confirm_blackmarket_mask_sell = expect_yes
			MenuManager.show_confirm_blackmarket_mask_remove = expect_yes
			MenuManager.show_confirm_blackmarket_sell_no_slot = expect_yes
		end
	end