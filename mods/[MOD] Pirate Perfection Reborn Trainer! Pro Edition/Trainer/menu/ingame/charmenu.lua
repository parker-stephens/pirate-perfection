--Purpose: different scripts for character
--Author: baldwin/Simplity

local ppr_require = ppr_require
ppr_require 'Trainer/tools/new_menu/menu'

local ppr_dofile = ppr_dofile
local insert = table.insert

local in_custody = in_custody
local alive = alive
local managers = managers
local M_player = managers.player
local get_my_carry_data = M_player.get_my_carry_data
local M_statistics = managers.statistics
local M_loot = managers.loot
local request_player_spawn = IngameWaitingForRespawnState.request_player_spawn
local on_local_player_dead = IngameFatalState.on_local_player_dead

local tr = Localization.translate --Shortened Localization.translate
local main_menu,secure_carry,outta_jail,going_to_jail,_going_to_jail,additional_option --Declare local variable first, then assign function to it

local path = "Trainer/addons/charmenu/"

local Menu = Menu

local Menu_open = Menu.open

-- Functions

secure_carry = function() --Secures carry, that you're currently carring.
	local carry_data = get_my_carry_data(M_player)
	if ( carry_data ) then
		M_loot:secure(carry_data.carry_id, carry_data.multiplier, true)
		M_player:clear_carry()
	end
end

outta_jail = function()
	request_player_spawn()
end

local game_state_machine = game_state_machine
going_to_jail = function()
	local player = M_player:local_player()
	M_player:force_drop_carry()
	M_statistics:downed( { death = true } )
	on_local_player_dead()
	game_state_machine:change_state_by_name( "ingame_waiting_for_respawn" )
	local char_damage = player:character_damage()
	char_damage:set_invulnerable( true )
	char_damage:set_health( 0 )
	local ply_base = player:base()
	ply_base:_unregister()
	ply_base:set_slot( player, 0 )
end

_going_to_jail = function()
	M_player:set_player_state('arrested') --Hehehe
	executewithdelay(going_to_jail, 1.5)
end

-- Menu

additional_option = function()
	local data = {
		{ text = tr.less_damage, plugin = 'less_damage', switch_back = true },
		{ text = tr.buddha_mode, plugin = 'buddha_mode', switch_back = true },
		{ text = tr.togg_no_hit, plugin = 'no_hit', switch_back = true },
		{ text = tr.togg_no_fall_damage, plugin = 'no_fall_damage', switch_back = true },
		{ text = tr.togg_no_flash_bangs, plugin = 'no_flash_bangs', switch_back = true },
		{ text = tr.togg_infinite_stamina, plugin = 'infinite_stamina', switch_back = true },
		{ text = tr.inf_ammo_reload, plugin = 'inf_ammo_reload', switch_back = true },
		{ text = tr.no_headbob, plugin = 'no_headbob', switch_back = true },
		{ text = tr.increase_standard_speed, plugin = 'increase_standard_speed', switch_back = true },
		{ text = tr.togg_no_bag_cooldown, plugin = 'no_bag_cooldown', switch_back = true },
	}
	
	Menu_open(Menu, { title = tr.additional_option, button_list = data, plugin_path = path, back = main_menu } )
end

main_menu = function()
	local data = {
		{ text = tr.additional_option, callback = additional_option, menu = true },
		{},
		{ text = tr.togg_godmode, plugin = 'god_mode', switch_back = true },
		{ text = tr.togg_jumping, plugin = 'high_jump', switch_back = true },
		{ text = tr.togg_speed, plugin = 'increase_speed', switch_back = true },
		{ text = tr.togg_ammo, plugin = 'infinite_ammo', switch_back = true },
		{ text = tr.togg_kill_in_one_hit, plugin = 'kill_in_one_hit', switch_back = true },
		{ text = tr.togg_increase_melee_dmg, plugin = 'increase_melee_dmg', switch_back = true },
		{ text = tr.togg_bullets, plugin = 'explosive_bullets', switch_back = true }, 
		{ text = tr.togg_shoot_through_walls, plugin = 'shoot_through_walls', switch_back = true }, 
		{ text = tr.togg_crazyness, plugin = 'extreme_firerate', switch_back = true },
		{ text = tr.togg_recoil, plugin = 'no_recoil', switch_back = true },
		{ text = tr.togg_accurate, plugin = 'max_accurate', switch_back = true },
		{ text = tr.togg_melee_range, plugin = 'long_melee_range', switch_back = true },
		{ text = tr.togg_melee_charge, plugin = 'instant_melee', switch_back = true },
		{ text = tr.togg_melee_no_delay, plugin = 'no_delay_melee', switch_back = true },
		{ text = tr.grenade_bullets, plugin = 'grenade_weapon', switch_back = true },
		{ text = tr.annoyer_mode, plugin = 'nodelaytalk', switch_back = true },
		{},
		{ text = tr.hacked_maskoff, callback = ppr_dofile, data = path .. 'hacked_maskoff' },
	}
	
	if get_my_carry_data(M_player) then
		insert(data,{ text = tr.secure_carry, callback = secure_carry })
	end

	if in_custody() then
		insert(data, { text = tr.outta_jail, callback = outta_jail })
	else
		insert(data, { text = tr.going_to_jail, callback = _going_to_jail}) --Just add "_" before function to go to the jail with effect
	end
	
	Menu_open(Menu, { title = tr.char_menu, button_list = data, plugin_path = path } )
end

--TO DO: Reoptimise it wisely
return main_menu