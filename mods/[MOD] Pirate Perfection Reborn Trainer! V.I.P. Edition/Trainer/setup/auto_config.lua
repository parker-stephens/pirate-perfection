--Purpose: script file that executes scripts, these are realyed on game_config

local ppr_require = ppr_require
local ppr_dofile = ppr_dofile
local type = type
local assert = assert
local rawget = rawget

local is_client = is_client()
local is_server = is_server()

local managers = managers
local M_blackmarket = managers.blackmarket

local in_game = in_game
local is_playing = is_playing

local backuper = backuper
local plugins = plugins

local query_execution_testfunc = query_execution_testfunc
local ppr_config = ppr_config
local DEFAULT_CONFIG="Trainer/configs/default_config.lua"
local BLANK_CONFIG  ="Trainer/configs/blank_config/blank.lua"

local config_path
do
	--Load game config
	local default_config = ppr_config.DefaultConfig
	if ( type(default_config) == "string" ) then
		config_path = "Trainer/configs/".. default_config..".lua"
		
		if ( not file_exists(config_path) ) then
			m_log_error('get_config_name() in auto_ingame.lua', "Config ".. default_config .." doesn't exists. Create it ?")
			config_path = DEFAULT_CONFIG
		end
	else
		m_log_error('get_config_name() in auto_ingame.lua', 'DefaultConfing is not string type. Check your config.lua and fix problems.')
		config_path = DEFAULT_CONFIG
	end
end

local cfg = ppr_dofile(BLANK_CONFIG)
assert(cfg, "Trainer lacks of blank config. Was it removed?")
game_config = cfg
--Set path to itself for configuration saving
cfg.auto_config=config_path
--Apply extensions first, so __cloned config will be clear
ApplyConfigExtension(cfg, config_path)
do
	--Check for file containing config changes
	local modify_func=ppr_dofile(config_path)
	if ( type(modify_func) == 'function' ) then
		modify_func(cfg)
	elseif ( modify_func ) then
		m_log_error("auto_config.lua", "Config structure changed, please remove old configuration files. Debug ( type(modify_func) ==", type(modify_func), ")")
	else
		m_log_error("auto_config.lua", "Trainer lacks of default configuration. Was it removed?")
	end
end

local path = "Trainer/addons/"
local load_plugin = load_plugin( path )

local GetPlayerUnit = GetPlayerUnit

-- Character menu
if cfg.god_mode then
	load_plugin( 'charmenu/god_mode' )
end

if cfg.high_jump then
	load_plugin( 'charmenu/high_jump' )
end

if cfg.increase_speed then
	load_plugin( 'charmenu/increase_speed' )
end

if cfg.infinite_ammo then
	load_plugin( 'charmenu/infinite_ammo' )
end

if cfg.kill_in_one_hit then
	load_plugin( 'charmenu/kill_in_one_hit' )
end

if cfg.increase_melee_dmg then 
	load_plugin( 'charmenu/increase_melee_dmg' )
end

if cfg.explosive_bullets then
	load_plugin( 'charmenu/explosive_bullets' )
end

if cfg.shoot_through_walls then
	load_plugin( 'charmenu/shoot_through_walls' )
end

if cfg.extreme_firerate then
	load_plugin( 'charmenu/extreme_firerate' )
end

if cfg.no_recoil then
	load_plugin( 'charmenu/no_recoil' )
end

if cfg.max_accurate then
	load_plugin( 'charmenu/max_accurate' )
end

if cfg.long_melee_range then
	load_plugin( 'charmenu/long_melee_range' )
end

if cfg.instant_melee then
	load_plugin( 'charmenu/instant_melee' )
end

if cfg.no_delay_melee then
	load_plugin( 'charmenu/no_delay_melee' )
end

if cfg.grenade_weapon then
	load_plugin( 'charmenu/grenade_weapon' )
end

if cfg.nodelaytalk then
	load_plugin( 'charmenu/nodelaytalk' )
end

if cfg.hacked_maskoff then
	ppr_require( path..'charmenu/hacked_maskoff' )
end

-- Character menu - Additional options
if cfg.less_damage then
	load_plugin( 'charmenu/less_damage' )
end

if cfg.buddha_mode then
	load_plugin( 'charmenu/buddha_mode' )
end

if cfg.no_hit then
	load_plugin( 'charmenu/no_hit' )
end

if cfg.no_fall_damage then
	load_plugin( 'charmenu/no_fall_damage' )
end

if cfg.no_flash_bangs then
	load_plugin( 'charmenu/no_flash_bangs' )
end

if cfg.infinite_stamina then
	load_plugin( 'charmenu/infinite_stamina' )
end

if cfg.inf_ammo_reload then
	load_plugin( 'charmenu/inf_ammo_reload' )
end

if cfg.no_headbob then
	load_plugin( 'charmenu/no_headbob' )
end

if cfg.increase_standard_speed then
	load_plugin( 'charmenu/increase_standard_speed' )
end

if cfg.no_bag_cooldown then
	load_plugin( 'charmenu/no_bag_cooldown' )
end

-- Stealth menu - NPC options
if cfg.dont_call_police and is_server then
	load_plugin( 'stealthmenu/dont_call_police' )
end

if cfg.prevent_panic_buttons and is_server then
	load_plugin( 'stealthmenu/prevent_panic_buttons' )
end

if cfg.disable_pagers and is_server then
	query_execution_testfunc(is_playing,{ f = load_plugin, a = { ( 'stealthmenu/disable_pagers' ) } })
end

if cfg.cops_dont_shoot and is_server then
	load_plugin( 'stealthmenu/cops_dont_shoot' )
end

-- Stealth menu - Infinite options
if cfg.inf_cable_activated then
	load_plugin( 'stealthmenu/inf_cable_activated' )
end

if cfg.inf_battery_activated and is_server then
	load_plugin( 'stealthmenu/inf_battery_activated' )
end

if cfg.inf_body_bags then
	load_plugin( 'stealthmenu/inf_body_bags' )
end

if cfg.inf_pager_answers and is_server then
	load_plugin( 'stealthmenu/inf_pager_answers' )
end

if cfg.inf_converts then
	load_plugin( 'stealthmenu/inf_converts' )
end

if cfg.inf_follow_hostages then
	load_plugin( 'stealthmenu/inf_follow_hostages' )
end

-- Stealth menu
if cfg.change_fov then
	load_plugin( 'stealthmenu/change_fov' )
end

if cfg.disable_cams and is_server then
	query_execution_testfunc(is_playing,{ f = load_plugin, a = { ( 'stealthmenu/disable_cams' ) } })
end

if cfg.steal_pagers_on_melee then
	load_plugin( 'stealthmenu/steal_pagers_on_melee' )
end

if cfg.lobotomize_ai then
	load_plugin( 'stealthmenu/lobotomize_ai' )
end

if cfg.invisible_player then
	load_plugin( 'stealthmenu/invisible_player' )
end

-- Interaction menu
if cfg.instant_interaction then
	load_plugin( 'interactions/interactionspeed' )
	BaseInteractionExt:toggle_int_speed(0.01)
elseif cfg.fast_interaction then
	load_plugin( 'interactions/interactionspeed' )
	BaseInteractionExt:toggle_int_speed(0.5)
end

if cfg.interact_with_all then
	load_plugin( 'interactions/interact_with_all' )
end

if cfg.infinite_distance then
	load_plugin( 'interactions/infinite_distance' )
end

if cfg.ignore_walls then
	load_plugin( 'interactions/ignore_walls' )
end

if cfg.interact_and_look then 
	load_plugin( 'interactions/interact_and_look' )
end

if cfg.instant_intimidation and is_server then
	load_plugin( 'interactions/instant_intimidation' )
end

if cfg.instant_lootpile then 
	load_plugin( 'interactions/instant_lootpile' )
end

if cfg.reboard then 
	load_plugin( 'interactions/reboard' )
end

if cfg.interact_team then 
	load_plugin( 'interactions/interact_team' )
end

if cfg.noone_shall_down then 
	load_plugin( 'interactions/noone_shall_down' )
end

-- Mission menu
if cfg.waypoints then 
	load_plugin( 'missionmenu/waypoints' )
end

if cfg.debug_hud then 
	load_plugin( 'missionmenu/debug_hud' )
end

if cfg.trigger_recorder then 
	load_plugin( 'missionmenu/trigger_recorder' )
end

if cfg.intimidator then 
	load_plugin( 'missionmenu/intimidator' )
end

if cfg.shutdown_dialogs then 
	load_plugin( 'missionmenu/shutdown_dialogs' )
end

if cfg.reduce_ai_health then 
	load_plugin( 'missionmenu/reduce_ai_health' )
end

if cfg.increase_ai_amount then 
	load_plugin( 'missionmenu/increase_ai_amount' )
end

if cfg.pointless_medics then 
	load_plugin( 'missionmenu/pointless_medics' )
end

if cfg.Auto_counter_Cloakers then 
	load_plugin( 'missionmenu/Auto_counter_Cloakers' )
end

-- Inventory menu
if cfg.bag_throw_force then
	load_plugin( 'inventory_menu/bag_throw_force' )
end

if cfg.bag_no_penalty then
	load_plugin( 'inventory_menu/bag_no_penalty' )
end

if cfg.explosive_bags then
	load_plugin( 'inventory_menu/explosive_bags' )
end

-- Equipment menu
if cfg.invulnerable_sentry and is_server then
	load_plugin( 'equipment_menu/invulnerable_sentry' )
end

if cfg.sentry_infinite_ammo and is_server then
	load_plugin( 'equipment_menu/sentry_infinite_ammo' )
end

if cfg.drill_auto_service then
	load_plugin( 'equipment_menu/drill_auto_service' )
end

if cfg.instant_deployments then
	load_plugin( 'equipment_menu/instant_deployments' )
end

if cfg.non_consumable_equipments and is_server then
	load_plugin( 'equipment_menu/non_consumable_equipments' )
end

if cfg.inf_equipments then
	load_plugin( 'equipment_menu/inf_equipments' )
end

if cfg.instantdrills and is_server then
	load_plugin( 'equipment_menu/instantdrills' )
end

-- Weapons menu
if cfg.always_dismember then
	load_plugin( 'weapon_menu/always_dismember' )
end

-- Tools menu
if cfg.ReduceDetectionLevel then
	load_plugin( 'tools/ReduceDetectionLevel' )
end