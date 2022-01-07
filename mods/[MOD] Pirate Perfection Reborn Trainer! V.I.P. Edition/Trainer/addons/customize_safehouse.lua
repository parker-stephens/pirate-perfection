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
				local sub_vault_idstring = '90afe5ce16756044'
				local van_idstring = '1c4a1fbb6f2ede15'
				local bulter_idstring = '86a4e72059d258d3'
				local prop_anims = {
					anim_door_open = {
						{'open_door'},
						{'anim_door_close'}
					},
					open_door = {
						{'open_door'},
						{'close_door', 'deactivate_door'}
					},
					state_door_open = {
						{'open_door'},
						{'anim_close_door', 'deactivate_door'}
					},
					[sub_vault_idstring] = {
						{'open_door'},
						{'anim_close'}
					},
					
				}
				prop_anims.state_door_close = prop_anims.state_door_open
				local anim_vault = {
					closed = {'state_closed'},
					disabled = {'state_interaction_disabled'},
					enabled = {'state_interaction_enabled'},
					opened = {'state_opened_75'},
				}
				local anim_van = {
					{
						{'anim_door_side_left_open'},
						{'anim_door_side_left_close'}
					},
					{
						{'anim_door_side_right_open'},
						{'anim_door_side_right_close'}
					},
					{
						{'anim_door_rear_both_open'},
						{'anim_door_rear_both_close'}
					}
				}
				local detector_offsets = {
					['1b73fe17caa2d3b9'] = {180, 100},
					['b2928ed7d5b8797e'] = {90, 50},
					[sub_vault_idstring] = {180, 200},
					[van_idstring] = {
						{0, 120},
						{180, 120},
						{90, 250}
					}
				}
				detector_offsets['e653b95736abc583'] = detector_offsets['b2928ed7d5b8797e']
				local butler_scan = true
				local butler
				local detect_shape = 'sphere'
				local detect_radius = 300
				local detect_slots_players = M_slot:get_mask('players')
				local detect_slots_flesh = M_slot:get_mask('flesh')
				local function get_nearby_units_amount(pos)
					if butler_scan and is_playing() then
						local all_people = World:find_units_quick('all', detect_slots_flesh)
						if #all_people >= 15 then
							for _, unit in pairs(World:find_units_quick('all', detect_slots_flesh)) do
								if unit:name():key() == bulter_idstring then
									butler = unit
									butler_scan = nil
								end
							end
						end
					end
					if butler and not alive(butler) then
						butler = nil
					end
					return #World:find_units_quick(detect_shape, pos, detect_radius, detect_slots_players) + (butler and mvector3_distance(butler:position(), pos) < 300 and 1 or 0)
				end
				local run_sequence = 'run_mission_door_device_sequence'
				local function set_animation(unit, anim_group)
					local unit_damage = unit:damage()
					for _, anim in pairs(anim_group) do
						unit_damage:run_sequence_simple(anim)
						M_N_session:send_to_peers_synched(run_sequence, unit, anim)
					end
				end
				local doors = {}
				local vault
				local sub_vault_scan = true
				local reset_closed = {}
				local function unit_parser(unit)
					local unit_check = unit:unit_data()
					if unit_check then
						local unit_mesh = unit_check.mesh_variation
						local unit_name_key = unit:name():key()
						unit_check = prop_anims[unit_mesh] or prop_anims[unit_name_key]
						if unit_check then
							local detect_offset = detector_offsets[unit_name_key]
							if detect_offset then
								if sub_vault_scan and not unit_mesh and unit_name_key == sub_vault_idstring then
									tab_insert(reset_closed, {unit, unit_check[2]})
								end
								set_animation(unit, unit_check[2])
								local detect_yaw = unit:rotation():yaw() + detect_offset[1]
								tab_insert(doors, {unit:position() + Vector3(math_cos(detect_yaw) * detect_offset[2], math_sin(detect_yaw) * detect_offset[2], 100), unit, nil, unit_check})
							end
						elseif unit_mesh == anim_vault.opened[1] then
							set_animation(unit, anim_vault.closed)
							vault = {unit:position() + Vector3(50, 300, 100), unit, nil}
						elseif unit_name_key == van_idstring then
							local detect_offset, detect_yaw
							for i = 1, 3 do
								tab_insert(reset_closed, {unit, anim_van[i][2]})
								detect_offset = detector_offsets[van_idstring][i]
								detect_yaw = unit:rotation():yaw() + detect_offset[1]
								tab_insert(doors, {unit:position() + Vector3(math_cos(detect_yaw) * detect_offset[2], math_sin(detect_yaw) * detect_offset[2], 100), unit, nil, anim_van[i]})
							end
						elseif unit_name_key == bulter_idstring then
							butler = unit
							butler_scan = nil
						end
					end
				end
				local door_loop_init
				local function door_loop()
					for i, data in pairs(doors) do
						if alive(data[2]) then
							if not data[2]:moving() then
								if data[3] then
									if get_nearby_units_amount(data[1]) == 0 then
										data[3] = nil
										set_animation(data[2], data[4][2])
									end
								else
									if get_nearby_units_amount(data[1]) > 0 then
										data[3] = true
										set_animation(data[2], data[4][1])
									end
								end
							end
						else
							tab_remove(doors, i)
						end
					end
					if vault then
						if not alive(vault[2]) or vault[2]:moving() then
							vault = nil
							if sub_vault_scan then
								for _, unit in pairs(World:find_units_quick('all')) do
									if unit:name():key() == sub_vault_idstring then
										unit_parser(unit)
									end
								end
								sub_vault_scan = nil
							end
						else
							if vault[3] then
								if get_nearby_units_amount(vault[1]) == 0 then
									vault[3] = nil
									set_animation(vault[2], anim_vault.disabled)
								end
							else
								if get_nearby_units_amount(vault[1]) > 0 then
									vault[3] = true
									set_animation(vault[2], anim_vault.enabled)
								end
							end
						end
					end
				end
				local tag_door_loop = 'safehouse_door_loop'
				PiratePerfection_safehouse.SafeHouseDoors_exec = function()
					for _, unit in pairs(World:find_units_quick('all')) do
						unit_parser(unit)
					end
					if sub_vault_scan then
						for _, data in pairs(doors) do
							if data[2]:name():key() == sub_vault_idstring then
								sub_vault_scan = nil
								break
							end
						end
					end
					RunNewLoopIdent(tag_door_loop, door_loop)
				end
				PiratePerfection_safehouse.SafeHouseDoors_stop = function()
					StopLoopIdent(tag_door_loop)
					door_loop_init = nil
					for _, data in pairs(doors) do
						set_animation(data[2], data[4][1])
					end
					butler = nil
					doors = {}
					if vault then
						set_animation(vault[2], anim_vault.opened)
						set_animation(vault[2], anim_vault.disabled)
						vault = nil
					end
					for _, data in pairs(reset_closed) do
						set_animation(data[1], data[2])
					end
					reset_closed = {}
				end
			end
			PiratePerfection_safehouse.SafeHouseDoors_exec()
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