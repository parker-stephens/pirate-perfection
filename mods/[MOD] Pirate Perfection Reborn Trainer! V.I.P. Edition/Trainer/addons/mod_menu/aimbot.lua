--Aimbot script
--Author: Main code: Simplity, fixes: **** & baldwin

local plugins = plugins
plugins:new_plugin('aimbot')

CATEGORY = 'mods'

VERSION = '1.0'

local aim_rotation

local managers = managers
local get_ray = get_ray
local ppr_config = ppr_config
local pmanager = managers.player
local pairs = pairs
local mvector3 = mvector3
local Rotation = Rotation
local alive = alive

local mouse = Input:mouse()
local mouse_down = mouse.down
local rmb = Idstring("1")

local get_safe_ray, check_wall, auto_shoot, auto_aim, aimbot_update

--Private methods
function get_safe_ray()
	local col_ray = get_ray(nil, "enemies")
	local unit = col_ray and col_ray.unit
	if alive( unit ) then
		local team = unit:movement():team()
		local team_id = team.id
		local in_slot = unit:in_slot( managers.slot:get_mask( "enemies" ) )
		
		if ( team_id == "mobster1" or team_id == "law1" ) and in_slot then
			return col_ray
		end
	end
	
	return nil
end

function check_wall( _unit )
	local unit	
	if _unit then
		unit = _unit
	else
		local col_ray = get_safe_ray()
		unit = col_ray and col_ray.unit
	end
	local check = unit and ( ppr_config.ShootThroughWalls and true or not unit:raycast( "ray", unit:movement():m_com(), managers.viewport:get_current_camera_position(), "slot_mask", managers.slot:get_mask( "world_geometry" ), "report" ) )
	return check
end

function auto_shoot( player )
	local camera = player:camera()
	local equipped_unit_base = player:inventory():equipped_unit():base()
	local _, ammo = equipped_unit_base:ammo_info()
	
	if ppr_config.AimbotInfAmmo then
		equipped_unit_base:replenish()
	end
	
	if ammo == 0 then
		return
	end
	
	local damage_mul = ppr_config.AimbotDamageMul or equipped_unit_base:damage_multiplier()
	equipped_unit_base:trigger_held( camera:position(), camera:forward(), damage_mul, nil, 0, 0, 0 )
	managers.rumble:play("weapon_fire")
	camera:play_shaker( "fire_weapon_rot", 1 )
	camera:play_shaker( "fire_weapon_kick", 1, 1, 0.15 )
	equipped_unit_base:tweak_data_anim_play( "fire", 20)
	managers.hud:set_ammo_amount( equipped_unit_base:selection_index(), equipped_unit_base:ammo_info() )
end

function auto_aim( player )
	for _,data in pairs( managers.enemy:all_enemies() ) do
		local u = data.unit
		local team = data.unit:movement():team()
		local team_id = team.id
		if team_id == "mobster1" or team_id == "law1" then
			local u_pos = u:position()
			local dist = mvector3.distance( player:position(), u_pos )
			if dist < (ppr_config.MaxAimDist or 5000) and check_wall( u ) then
				local char_damage = u:character_damage()
				local body = char_damage and u:body(char_damage._head_body_name)
				local head_pos = body and body:position()
				local target = head_pos or u_pos
				local camera = player:camera()
				mvector3.subtract( target, camera:position() )
				aim_rotation = Rotation:look_at( target, math.UP )
				camera:set_rotation(aim_rotation) --Use this variant for silent and not annoying aimbot :-)
				break
			end
		end
	end
end

function aimbot_update()
	if not ppr_config.RightClick or mouse_down(mouse, rmb) then
		local player = pmanager:player_unit()
		if not alive( player ) then
			return
		end

		if ppr_config.AimMode ~= 2 and check_wall() then
			auto_shoot( player )
		end

		if ppr_config.AimMode ~= 1 then
			auto_aim( player )
		end
	end
end

local function start_aimbot()
	backuper:hijack('FPCameraPlayerBase._update_rot', function( o, self, ... )
		--I made it shorter.
		local ret = o(self, ...)
		if aim_rotation then
			self._parent_unit:camera():set_rotation( aim_rotation )
			self:set_rotation( aim_rotation )
			aim_rotation = nil
		end
		return ret
	end)
	
	
	local player = pmanager:player_unit()
	if alive( player ) then
		player:inventory():equipped_unit():base()._can_shoot_through_shield = true
	end

	if ppr_config.ShootThroughWalls and not plugins:g_loaded( "shoot_through_walls" ) then
		plugins:ppr_require( 'Trainer/addons/charmenu/shoot_through_walls', true )
	end
	
	RunNewLoopIdent("aimbot", aimbot_update)
end

local function stop_aimbot()
	backuper:restore('FPCameraPlayerBase._update_rot')
	StopLoopIdent( "aimbot" )
end

function MAIN()
	start_aimbot()
end

function UNLOAD()
	stop_aimbot()
end

FINALIZE()