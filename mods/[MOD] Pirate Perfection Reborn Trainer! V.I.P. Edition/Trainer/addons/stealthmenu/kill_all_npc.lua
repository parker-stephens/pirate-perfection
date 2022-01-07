--Purpose: kills everyone on the map, depending on configuration. Killing enemies during stealth will steal pagers aswell.
--Author: ****

local pairs = pairs
local pcall = pcall
local ppr_require = ppr_require

ppr_require('Trainer/addons/plyupgradehack')

local Vector3 = Vector3
local managers = managers
local M_player = managers.player
local M_enemy = managers.enemy
local session = managers.network:session()
local ppr_config = ppr_config
local is_hostage = is_hostage
local HUGE = math.huge
local plugins = plugins

local function dmg_melee(unit)
	if unit then
		local action_data = {
			damage = HUGE, --(Ultra * math.huge) damage.
			damage_effect = unit:character_damage()._HEALTH_INIT * 2,
			attacker_unit = M_player:player_unit(),
			attack_dir = Vector3(0,0,0),
			name_id = 'rambo', --Only in rambo style bulldosers can be killed
			col_ray = {
				position = unit:position(),
				body = unit:body( "body" ),
			}
		}
		unit:unit_data().has_alarm_pager = false
		unit:character_damage():damage_melee(action_data)
	end
end

local function dmg_cam(unit)
	local col_ray = {}
	col_ray.ray = Vector3(1,0,0)
	col_ray.position = unit:position()
	local body
	do
		local i = -1
		repeat
			i = i+1
			body = unit:body(i)
		until (body and body:extension()) or i >= 5
		if not body then
			return
		end
	end
	col_ray.body = body
	col_ray.body:extension().damage:damage_melee( unit, col_ray.normal, col_ray.position, col_ray.direction, 10000 )
	managers.network:session():send_to_peers_synched( "sync_body_damage_melee", col_ray.body, unit, col_ray.normal, col_ray.position, col_ray.direction, 10000 )
end

local PlayerManager = PlayerManager
local hack_upg_val = PlayerManager.hack_upgrade_value

local need_hack = hack_upg_val and not plugins:g_loaded('steal_pagers_on_melee')
if (need_hack) then
	hack_upg_val(PlayerManager, "", "melee_kill_snatch_pager_chance", 1.1)
end

--Note: pcalls here for 100% chance, that upgrade_value will be restored back.
if not ppr_config.KillAllIgnoreEnemies then
	for _,ud in pairs(M_enemy:all_enemies()) do
		if not ppr_config.KillAllIgnoreTied or not is_hostage(ud.unit) then
			pcall(dmg_melee,ud.unit)
		end
	end
end
if not ppr_config.KillAllIgnoreCivilians then
	for _,ud in pairs(M_enemy:all_civilians()) do
		local unit = ud.unit
		if not ppr_config.KillAllIgnoreTied or not is_hostage(ud.unit) then
			for i = 1, 2 do
				pcall(dmg_melee,ud.unit)
			end
		end
	end
end
if ppr_config.KillAllTouchCameras then
	for _,unit in pairs(SecurityCamera.cameras) do
		pcall(dmg_cam,unit)
	end
end

if (need_hack) then
	hack_upg_val(PlayerManager, "", "melee_kill_snatch_pager_chance")
end