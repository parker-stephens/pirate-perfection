--Purpose: initiates autostart in game scripts here, depending on configuration.

local ppr_require = ppr_require
local ppr_dofile = ppr_dofile

local is_client = is_client()
local is_server = is_server()

local managers = managers
local M_player = managers.player
local M_blackmarket = managers.blackmarket

local level_id = Global.game_settings.level_id

local in_game = in_game
local is_playing = is_playing

local backuper = backuper
local backup = backuper.backup
local plugins = plugins
local plug_require = plugins.ppr_require

local query_execution_testfunc = query_execution_testfunc

local path = "Trainer/addons/"
local load_plugin = load_plugin( path )

local cfg = ppr_config

ppr_require("Trainer/addons/weap_fix1")

ppr_dofile('Trainer/Setup/auto_config')

--ppr_require depending on ppr_config scripts
if not cfg.DisableBulletFix then
	ppr_require('Trainer/addons/bulletfix')
end

local ControlLevel = cfg.ControlCheats
if ControlLevel and ((is_client and ControlLevel == 1) or ControlLevel >= 2) then --Autostart equipment control
	plug_require(plugins, 'Trainer/equipment_stuff/equipment_control', true)
end

if cfg.NoInvisibleWalls and is_server then -- No invisible walls (Host only)
	query_execution_testfunc(is_playing,{ f = function() ppr_dofile 'Trainer/addons/no_invisible_walls.lua' end })
end

if cfg.RestartProMissions and is_server then -- Restart pro missions (it also includes RestartJobs)
	ppr_require('Trainer/addons/restart_pro_missions.lua')
end

if cfg.RestartJobs and is_server then
	ppr_require('Trainer/addons/restart_jobs')
end

if cfg.NoEscapeTimer and is_server then -- No escape timer (Host only) (By Harfatus)
	backup(backuper, 'ElementPointOfNoReturn.on_executed')
	function ElementPointOfNoReturn.on_executed() end
end

if cfg.NoCivilianPenality then
	ppr_require('Trainer/addons/freecivilians')
end

if cfg.DontFreezeRagdolls then
	backup(backuper, 'CopActionHurt._freeze_ragdoll')
	function CopActionHurt._freeze_ragdoll()end
end

if cfg.DontDisposeRagdolls then
	backup(backuper, 'EnemyManager._upd_corpse_disposal')
	function EnemyManager._upd_corpse_disposal()end
end

if cfg.LaserColorR then
	ppr_require('Trainer/weapon_stuff/lasercolor')
end

if not cfg.DisableInvFix then
	ppr_require('Trainer/addons/invfix')
end

if cfg.PreventEquipDetecting and is_server then
	ppr_require('Trainer/experimental/stealth_v2')
end

if cfg.ReduceDetectionLevel then
	load_plugin('tools/spoof_detection_lvl')
end

if cfg.far_placements then
	plug_require(plugins, 'Trainer/equipment_stuff/long_placement', true)
end

if is_server and cfg.SecureAll then
	ppr_require('Trainer/addons/secureall')
end

if cfg.HUD then
	ppr_require("Trainer/addons/ppr_text")
end

if cfg.Crosshair then
	ppr_require("Trainer/addons/crosshair")
end

if is_server and (level_id == "chill" or level_id == "chill_combat") then
	ppr_dofile("Trainer/addons/customize_safehouse")
end

--Requires user scripts

ppr_require('Trainer/custom_game')