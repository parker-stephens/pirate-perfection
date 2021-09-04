-- Purpose:  Execution file of Safe House customizations
-- Author:  The Joker

local date = os.date
local math = math
local math_cos = math.cos
local math_random = math.random
local math_randomseed = math.randomseed
local math_round = math.round
local math_sin = math.sin
local pairs = pairs
local table = table
local tab_insert = table.insert
local tab_remove = table.remove
local tostring = tostring

local managers = managers
local M_custom_safehouse = managers.custom_safehouse
local M_experience = managers.experience
local M_N_session = managers.network:session()
local M_money = managers.money
local M_slot = managers.slot
local M_sync = managers.sync

local alive = alive
local mvector3_distance = mvector3.distance
local OG_update_offshore = OffshoreGui.update_offshore
local Vector3 = Vector3
local World = World

local level_id = Global.game_settings.level_id

local ppr_require = ppr_require
local executewithdelay = executewithdelay
local is_playing = is_playing
local RunNewLoopIdent = RunNewLoopIdent
local send_message = send_message
local StopLoopIdent = StopLoopIdent

local tr = Localization.translate

local ppr_config = ppr_config
local togg_vars = togg_vars

togg_vars.SafeHouseDoors = togg_vars.SafeHouseDoors == nil and ppr_config.SafeHouseDoors or togg_vars.SafeHouseDoors
togg_vars.SafeHouseInvest = togg_vars.SafeHouseInvest == nil and ppr_config.SafeHouseInvest or togg_vars.SafeHouseInvest
togg_vars.SafeHouseInvestAmt = togg_vars.SafeHouseInvestAmt == nil and ppr_config.SafeHouseInvestAmt or togg_vars.SafeHouseInvestAmt
togg_vars.SafeHouseLego = togg_vars.SafeHouseLego == nil and ppr_config.SafeHouseLego or togg_vars.SafeHouseLego

if not PiratePerfectionSafeHouse then
	PiratePerfectionSafeHouse = {}
end
local PiratePerfection_safehouse = PiratePerfectionSafeHouse

if level_id == 'chill' then
	if togg_vars.SafeHouseDoors then
		if not PiratePerfection_safehouse.SafeHouseDoors then
			PiratePerfection_safehouse.SafeHouseDoors = true
			if not PiratePerfection_safehouse.SafeHouseDoors_init then
				PiratePerfection_safehouse.SafeHouseDoors_init = true
				show_hint("(automated Safehouse doors are V.I.P. Only )")
			end
		end
	else
		if PiratePerfection_safehouse.SafeHouseDoors then
			PiratePerfection_safehouse.SafeHouseDoors = nil
			PiratePerfection_safehouse.SafeHouseDoors_stop()
		end
	end

	if togg_vars.SafeHouseInvest then
		if not PiratePerfection_safehouse.SafeHouseInvest then
			PiratePerfection_safehouse.SafeHouseInvest = true
			if not PiratePerfection_safehouse.SafeHouseInvest_init then
				PiratePerfection_safehouse.SafeHouseInvest_init = true
				local offshore_guis = {}
				local text_offshore_gui = 'offshore_gui'
				local synced_units = M_sync._synced_units
				for unit_id, data in pairs(synced_units) do
					if data.type == text_offshore_gui and M_sync._units[unit_id] and M_sync._units[unit_id]._visible then
						offshore_guis[unit_id] = M_sync._units[unit_id]
					end
				end
				local offshore_limit = 1000000000000000000
				local function message_display(text)
					send_message(tr.safehouse_invest_title.." - "..text)
				end
				local previous_SafeHouseInvestAmt
				local invest_minimum
				local invest_big_pass
				local text_sep = ":  "
				local text_add = "+"
				local text_spacer = "    -    "
				local tag_invest_loop = 'safehouse_invest_loop'
				local function invest_process()
					if is_playing() then
						local offshore = M_money:offshore()
						if offshore < offshore_limit then
							if offshore > 0 then
								if togg_vars.SafeHouseInvestAmt ~= previous_SafeHouseInvestAmt then
									previous_SafeHouseInvestAmt = togg_vars.SafeHouseInvestAmt
									invest_minimum = 100 * (10^togg_vars.SafeHouseInvestAmt)
									invest_big_pass = togg_vars.SafeHouseInvestAmt > 5
								end
								if offshore >= invest_minimum then
									local now_date = date('!*t')
									math_randomseed(now_date.yday * (now_date.hour + 1) * (now_date.min + 1) * (now_date.sec + 1) * math_random())
									local ret_amount = math_round(math_random(-invest_minimum, invest_minimum), 100)
									if ret_amount ~= 0 then
										if ret_amount > 0 then
											local spending = M_money:total()
											if ret_amount == 1337 then
												M_custom_safehouse:add_coins(10)
												message_display(tr.safehouse_invest_lucky)
											elseif invest_big_pass and ret_amount > 1000000 and math_random() < 0.50 then
												M_custom_safehouse:add_coins(1)
												message_display(tr.safehouse_invest_coin)
											end
											M_money:_add_to_total(ret_amount)
											message_display(tr.cash..text_sep..text_add..M_experience:cash_string(M_money:total() - spending)..text_spacer..tr.offshore..text_sep..text_add..M_experience:cash_string(M_money:offshore() - offshore))
										else
											M_money:deduct_from_offshore(-ret_amount)
											message_display(tr.offshore..text_sep..M_experience:cash_string(M_money:offshore() - offshore))
										end
										local new_offshore = M_money:offshore()
										local remove_guis = {}
										for unit_id, data in pairs(offshore_guis) do
											if alive(data._unit) then
												OG_update_offshore(data, new_offshore)
												M_sync:add_synced_offshore_gui(unit_id, true, new_offshore)
											else
												tab_insert(remove_guis, unit_id)
											end
										end
										if #remove_guis > 0 then
											for _, unit_id in pairs(remove_guis) do
												tab_remove(offshore_guis, unit_id)
											end
										end
										executewithdelay(PiratePerfection_safehouse.SafeHouseInvest_exec, 2, tag_invest_loop)
									end
								else
									message_display(tr.safehouse_invest_min)
								end
							else
								message_display(tr.safehouse_invest_empty)
							end
						else
							message_display(tr.safehouse_invest_max)
						end
					else
						togg_vars.SafeHouseInvest = nil
						PiratePerfection_safehouse.SafeHouseInvest = nil
					end
				end
				local tag_invest_delay = 'safehouse_invest_delay'
				PiratePerfection_safehouse.SafeHouseInvest_exec = function()
					executewithdelay(invest_process, (270 * math_random()) + 28, tag_invest_delay)
				end
				PiratePerfection_safehouse.SafeHouseInvest_stop = function()
					StopLoopIdent(tag_invest_loop)
					StopLoopIdent(tag_invest_delay)
				end
			end
			local now_date = date('!*t')
			math_randomseed(now_date.yday * (now_date.hour + 1) * (now_date.min + 1) * (now_date.sec + 1) * math_random())
			PiratePerfection_safehouse.SafeHouseInvest_exec()
		end
	else
		if PiratePerfection_safehouse.SafeHouseInvest then
			PiratePerfection_safehouse.SafeHouseInvest = nil
			PiratePerfection_safehouse.SafeHouseInvest_stop()
		end
	end
end

if togg_vars.SafeHouseLego and not PiratePerfection_safehouse.SafeHouseLego then
	ppr_config.LegoFile = 'custom_safehouse'
	local _, load_lego = ppr_require('Trainer/menu/ingame/lego_menu')
	if load_lego() then
		PiratePerfection_safehouse.SafeHouseLego = true
	else
		togg_vars.SafeHouseLego = nil
	end
end