local insert = table.insert
local sort = table.sort
local Idstring = Idstring
local backuper = backuper

local M_player = managers.player
local M_groupAI = managers.groupai
local AI_state = M_groupAI:state()
local player = M_player:player_unit()
local player_damage = player:character_damage()
local player_camera = player:camera()
local OV_gui = Overlay:newgui()
local M_network = managers.network
local M_game = M_network:session()
local M_chat = managers.chat
local M_hud = managers.hud
local M_timer = TimerManager:main()
local M_criminals = managers.criminals
local UnitNetworkHandler = UnitNetworkHandler

local kb = Input:keyboard()
local chat_colors = tweak_data.chat_colors
local my_name = player:base():nick_name()
local pvp_slot_mask = World:make_slot_mask( 3, 12, 16, 17, 25, 1, 8, 11, 35 )
local raycastable_characters = managers.slot:get_mask("raycastable_characters")
local level = managers.job:current_level_id()
local random = math.random

ppr_require 'Trainer/addons/no_invisible_walls'
ppr_require 'Trainer/pvp/pvp_skills'

local Deathmatch = class()

function Deathmatch:init()
	self.score_table = {}
	self.death_score_table = {}
	self.special_skills = { 12, 21, 31 }
	
	-- Timer
	self.dance_interval = 2
	
	local pvp = self
	self.skills = Skills:new( pvp )
	
	local update = function() self:update() end
	RunNewLoopIdent( 'update_deathmatch', update )
	
	M_chat:send_message(1, my_name, my_name .. " ready!" )
end

-- Update

function Deathmatch:update()	
	local player = M_player:player_unit()
	if not alive( player ) then
		return
	end
	
	self:update_keybinds()
	
	self:create_score()
	self:update_skills()
	self:check_skill()
	
	------------------------------
	
	for i = 1, 4 do
		M_hud:_remove_name_label( i )
	end
	
	local hp = player_damage:get_real_health()
	if hp <= 0 then
		self:killed()
	end
end

function Deathmatch:update_keybinds()
	if kb:pressed( Idstring("z") ) then
		self:use_skill()
	end
end

function Deathmatch:update_skills()
	local t, dt = M_timer:time(), M_timer:delta_time()
	
	if self.death_timer and self.death_timer > 0 then
		self.death_timer = self.death_timer - dt
		player_damage:replenish()
	end
	
	if self.dance_timer and self.dance_timer > 0 then
		self.dance_timer = self.dance_timer - dt
		self.dance_interval = self.dance_interval - dt
				
		if self.dance_interval < 0 then
			self.dance_interval = 2
			player:mover():set_velocity( Vector3(90,90,800) )
		end
	end
	
	if self.drunk_timer and self.drunk_timer > 0 then
		self.drunk_timer = self.drunk_timer - dt
		player_camera:play_shaker( "player_melee", 2 )
	end
end

-- Score table

function Deathmatch:create_score()
	local players = { }
	
	local all_players = AI_state:all_player_criminals()
	for pl_key, pl_record in pairs( all_players ) do
		local unit = all_players[ pl_key ].unit
		
		if unit and unit:base() and unit:base():nick_name() then
			insert( players, { unit = unit, score = self:score_by_unit( unit ) } )
		end
	end
	
	sort( players, function(a, b) return a.score > b.score end )
	
	-- GUI
	
	if self.score and self.score.ws then
		OV_gui:destroy_workspace( self.score.ws )
	end
	
	self.score = {}
	local i = 0
	self.score.ws = OV_gui:create_screen_workspace()
	for _, val in ipairs( players ) do
		local color_id = val.unit:network():peer():id()
		local color = chat_colors[ color_id ] or chat_colors[ 1 ]
		self.score.lbl = self.score.ws:panel():text{ x = 270 + 0.5 * RenderSettings.resolution.x, y = -300 + i + 0.5 * RenderSettings.resolution.y, text = val.unit:base():nick_name()..": Kills - "..val.score.." Deaths - "..self:death_score_by_unit( val.unit ), font = tweak_data.menu.pd2_large_font, font_size = 36, color = color, layer=2000 }
		i = i + 40
	end
end

function Deathmatch:score_by_unit( unit )	
	local name = unit:base():nick_name()
	local score = self.score_table[ name ] or 0
	
	return score
end

function Deathmatch:death_score_by_unit( unit )
	local name = unit:base():nick_name()
	local score = self.death_score_table[ name ] or 0
	
	return score
end

function Deathmatch:add_score( unit )	
	local name = unit:base():nick_name()
	self.score_table[ name ] = self.score_table[ name ] and self.score_table[ name ] + 1 or 1
end

function Deathmatch:add_death_score( unit )
	local name = unit:base():nick_name()
	self.death_score_table[ name ] = self.death_score_table[ name ] and self.death_score_table[ name ] + 1 or 1
end

function Deathmatch:unit_from_id( id )
	local unit = M_game:unit_from_peer_id( id )
	
	return unit
end

-- Skills

function Deathmatch:check_skill()
	local special_skills = self.special_skills
	local my_score = self:score_by_unit( player )
	self._next_skill = self._next_skill or my_score + 3
		
	if not self._available_skill and my_score >= self._next_skill then
		self._next_skill = nil
		
		if in_table( special_skills, my_score ) then
			self:show_skill( my_score )
			return
		end
		
		local rnd = math.random(1,7)
		self:show_skill( rnd )
	end
end

function Deathmatch:show_skill( id )
	local skills = self.skills
	local text = skills.all_skills[id].text .. " available - Z"
	
	self._available_skill = id
	self:show_skill_gui( text )
end

function Deathmatch:show_skill_gui( text )
	self.skill_gui = {}
	self.skill_gui.ws = OV_gui:create_screen_workspace()
	self.skill_gui.lbl = self.skill_gui.ws:panel():text{ x = 270 + 0.5 * RenderSettings.resolution.x, y = -160 + 0.5 * RenderSettings.resolution.y, text = text, font = tweak_data.menu.pd2_large_font, font_size = 37, color = Color.VIP, layer = 2000 }
end

function Deathmatch:use_skill()
	local skills = self.skills
	local id = self._available_skill
	
	if not id then
		return
	end

	if skills.all_skills[id].callback( skills ) then
		self:delete_hint()
		self._available_skill = nil
	end
end

function Deathmatch:delete_hint()
	OV_gui:destroy_workspace( self.skill_gui.ws )
	self.skill_gui = nil
end

-- Sync

local sync_player_movement_state = backuper:backup("UnitNetworkHandler.sync_player_movement_state")
function UnitNetworkHandler:sync_player_movement_state( unit, state, down_time, unit_id_str )
	if state == "damage" then		
		local unit = DM:unit_from_id( down_time )
		
		if not unit then
			return
		end
		
		local dmg = tonumber( unit_id_str )
		local new_hp = DM:do_damage( dmg )
		
		if new_hp <= 0 then
			DM:killed( unit )
		end
		
		return
	end
	
	if state == "sync_killed" then
		local unit1 = DM:unit_from_id( tonumber(unit_id_str) )
		local unit2 = DM:unit_from_id( tonumber(down_time) )
		DM:add_score( unit2 )
		DM:add_death_score( unit1 )
		
		for i = 1, 3 do
			World:effect_manager():spawn( { effect = Idstring( "effects/payday2/particles/explosions/bag_explosion" ), position = unit1:position(), normal = Rotation(0,0,0) } )
		end		
		return
	end 
	
	if state:find("system_mess") then
		state = state:gsub("system_mess:", "")
		M_chat:feed_system_message( 1, state )
		return
	end
	
	--Skills
	
	if state == "push" then
		World:play_physic_effect( Idstring("core/physic_effects/sequencemanager_push"), player, Vector3(10,10,5000), player:mass(), 0 )
		DM:do_damage( 10 )
		return
	end
	
	if state == "dance" then
		DM.dance_timer = 10
		return
	end
	
	if state == "drunk" then
		DM.drunk_timer = 3
		return
	end
		
	return sync_player_movement_state( self, unit, state, down_time, unit_id_str )
end

function Deathmatch:do_damage( damage )
	local hp = player_damage:get_real_health()
	local new_hp = hp - damage
	
	player_damage:set_health( new_hp )
	
	return new_hp
end

function Deathmatch:system_mess( text )
	M_chat:feed_system_message( 1, text )
	
	local skills = self.skills
	skills:send_to_all({ "system_mess:" .. text })
end

-- Other

function Deathmatch:killed( unit )
	local my_pos = player:position()
	
	for i = 1, 3 do
		World:effect_manager():spawn( { effect = Idstring( "effects/payday2/particles/explosions/bag_explosion" ), position = my_pos, normal = Rotation(0,0,0) } )
	end
	
	M_player:add_grenade_amount(2)
	local pos = self:get_random_pos()
	player:movement():warp_to( pos, Rotation(0,0,0) )
	
	local name
	if unit then
		name = unit:base():nick_name()
		self:add_score( unit )
		
		local id = player:network():peer():id()	
		local skills = self.skills
		local killer_id = unit:network():peer():id()
		skills:send_to_all({ "sync_killed", killer_id, id })
	end
	
	self:add_death_score( player )
	
	local available_selections = player:inventory():available_selections()
	for id, weapon in pairs( available_selections ) do
		if alive( weapon.unit ) then
			weapon.unit:base():replenish()
			M_hud:set_ammo_amount( id, weapon.unit:base():ammo_info() )
		end
	end
	
	player_damage:replenish()
	self.death_timer = 3
	
	if self.tank_mode then
		self.tank_mode = false
		backuper:restore('PlayerDamage._max_health')
	end
	
	if name then
		local mtext = player:base():nick_name().." has been killed by "..name
		self:system_mess( mtext )
	end
end

-- Hook fire method
local mvec_to = Vector3()
local mvec_spread_direction = Vector3()
local RaycastWeaponBase_fire_raycast = backuper:backup("RaycastWeaponBase._fire_raycast")
function RaycastWeaponBase:_fire_raycast( user_unit, from_pos, direction, dmg_mul, shoot_player, spread_mul, autohit_mul, suppr_mul, shoot_through_data )
	local spread = self:_get_spread( user_unit )
   
	mvector3.set( mvec_spread_direction, direction )
	if spread then
		mvector3.spread( mvec_spread_direction, spread * ( spread_mul or 1 ) )
	end
		   
	mvector3.set( mvec_to, mvec_spread_direction )
	mvector3.multiply( mvec_to, 20000 )
	mvector3.add( mvec_to, from_pos )
	local damage = self:_get_current_damage( dmg_mul )
	local col_ray = World:raycast( "ray", from_pos, mvec_to, "slot_mask", pvp_slot_mask )
	if col_ray and col_ray.unit and col_ray.unit:in_slot( raycastable_characters ) and col_ray.unit:base() and col_ray.unit:base():nick_name() then
		local id = player:network():peer():id()
		
		if col_ray.body and col_ray.body:name() and col_ray.body:name() == Idstring("head") then
			M_hud:on_headshot_confirmed()
			damage = damage*2
		else
			M_hud:on_hit_confirmed()
		end

		col_ray.unit:network():send_to_unit( { "sync_player_movement_state", col_ray.unit, "damage", id, damage } )
	end

	return RaycastWeaponBase_fire_raycast( self, user_unit, from_pos, direction, dmg_mul, shoot_player, spread_mul, autohit_mul, suppr_mul, shoot_through_data )
end

local do_melee_damage = backuper:backup("PlayerStandard._do_melee_damage")
function PlayerStandard:_do_melee_damage( t )
	local melee_entry = managers.blackmarket:equipped_melee_weapon()
	local instant_hit = tweak_data.blackmarket.melee_weapons[ melee_entry ].instant
	local melee_damage_delay = tweak_data.blackmarket.melee_weapons[ melee_entry ].melee_damage_delay or 0
	local charge_lerp_value = instant_hit and 0 or self:_get_melee_charge_lerp_value( t, melee_damage_delay )
	local damage, damage_effect = managers.blackmarket:equipped_melee_weapon_damage_info( charge_lerp_value )
	
	local range = tweak_data.blackmarket.melee_weapons[ melee_entry ].stats.range or 175
	local from = self._unit:movement():m_head_pos()
	local to = from + self._unit:movement():m_head_rot():y() * range
	local sphere_cast_radius = 20
	local col_ray = self._unit:raycast( "ray", from, to, "slot_mask", managers.slot:get_mask( "raycastable_characters" ), "sphere_cast_radius", sphere_cast_radius, "ray_type", "body melee" )

	if col_ray and col_ray.unit and col_ray.unit:base() and col_ray.unit:base():nick_name() then
		local id = player:network():peer():id()
		
		M_hud:on_crit_confirmed()
		col_ray.unit:network():send_to_unit( { "sync_player_movement_state", col_ray.unit, "damage", id, damage_effect } )
	end
	
	return do_melee_damage( self, t )
end

local mvec_to = Vector3()
local mvec_spread_direction = Vector3()
local NewShotgunBase_fire_raycast = backuper:backup("NewShotgunBase._fire_raycast")
function NewShotgunBase:_fire_raycast( user_unit, from_pos, direction, dmg_mul, shoot_player, spread_mul, autohit_mul, suppr_mul, shoot_through_data )
	local spread = self:_get_spread( user_unit )
   
	mvector3.set( mvec_spread_direction, direction )
	if spread then
		mvector3.spread( mvec_spread_direction, spread * ( spread_mul or 1 ) )
	end
		   
	mvector3.set( mvec_to, mvec_spread_direction )
	mvector3.multiply( mvec_to, 20000 )
	mvector3.add( mvec_to, from_pos )
	local damage = self:_get_current_damage( dmg_mul )
	local col_ray = World:raycast( "ray", from_pos, mvec_to, "slot_mask", managers.slot:get_mask( "raycastable_characters" ) )
	if col_ray and col_ray.unit and col_ray.unit:base() and col_ray.unit:base():nick_name() then
		local id = player:network():peer():id()
		
		if col_ray.body and col_ray.body:name() and col_ray.body:name() == Idstring("head") then
			M_hud:on_headshot_confirmed()
			damage = damage*2
		else
			M_hud:on_hit_confirmed()
		end

		col_ray.unit:network():send_to_unit( { "sync_player_movement_state", col_ray.unit, "damage", id, damage } )
	end
	
	return NewShotgunBase_fire_raycast( self, user_unit, from_pos, direction, dmg_mul, shoot_player, spread_mul, autohit_mul, suppr_mul, shoot_through_data )
end

local _detonate = backuper:backup("FragGrenade._detonate")
function FragGrenade:_detonate()
	local thrower_unit = self._unit:base():thrower_unit()
	if thrower_unit then
		local distance = mvector3.distance( self._unit:position(), player:position() )
		if distance < self._range then		
			local damage = (self._player_damage or 1) * (1 - distance / self._range)
			local peer_id = M_game:member_from_unit( thrower_unit ):peer():id()
			
			UnitNetworkHandler.sync_player_movement_state( UnitNetworkHandler, player, "damage", peer_id, damage )
		end
	end
	
	return _detonate( self )
end

local _detonate_on_client = backuper:backup("FragGrenade._detonate_on_client")
function FragGrenade:_detonate_on_client()
	local thrower_unit = self._unit:base():thrower_unit()
	if thrower_unit then
		local distance = mvector3.distance( self._unit:position(), player:position() )
		if distance < self._range then		
			local damage = (self._player_damage or 1) * (1 - distance / self._range)
			local peer_id = M_game:member_from_unit( thrower_unit ):peer():id()
			
			UnitNetworkHandler.sync_player_movement_state( UnitNetworkHandler, player, "damage", peer_id, damage )
		end
	end
	
	return _detonate_on_client( self )
end

function Deathmatch:get_random_pos()
	local area_data = M_groupAI:state()._area_data
	local rnd = random(#area_data) or 1
	local pos = area_data[ rnd ].pos
	
	return pos
end

-- Fixes
local shot_fired = backuper:backup("StatisticsManager.shot_fired")
function StatisticsManager:shot_fired( data )
	if not data.weapon_unit or not data.name_id then
		return
	end
	
	return shot_fired( self, data )
end
	
function ExplosionManager:give_local_player_dmg() end

function HuskPlayerMovement:_get_max_move_speed()
	return 1500
end

tweak_data.grenades.frag.damage = 100
tweak_data.grenades.frag.player_damage = 100
tweak_data.grenades.launcher_frag.player_damage = 100
tweak_data.grenades.launcher_frag.range = 500
tweak_data.grenades.launcher_frag.init_timer = 2

function ContourExt:add() end
function ContourExt:update() end
function PlayerBase:replenish() end

return function()
	DM = DM or Deathmatch:new()
end