--[[function PlayerMaskOff:init( unit )
	PlayerMaskOff.super.init( self, unit )
	self._ids_unequip = Idstring( "unequip" )
end]]

local PlayerMaskOff = PlayerMaskOff

--------------------------------------------------------------------------------------

function PlayerMaskOff:enter( state_data, enter_data )
	PlayerMaskOff.super.enter( self, state_data, enter_data )
end

--------------------------------------------------------------------------------------

function PlayerMaskOff:_enter( enter_data )
	--PlayerMaskOff.super._enter( self, enter_data )
	local equipped_selection = self._unit:inventory():equipped_selection()
	if equipped_selection ~= 1 then
		self._previous_equipped_selection = equipped_selection
		self._ext_inventory:equip_selection( 1, false )
		managers.upgrades:setup_current_weapon()
	end
	
	if self._unit:camera():anim_data().equipped then
		self._unit:camera():play_redirect( self._ids_unequip )
	end
	self._unit:base():set_slot( self._unit, 4 )
	
	self._ext_movement:set_attention_settings( { "pl_law_susp_peaceful", "pl_gangster_cur_peaceful", "pl_team_cur_peaceful", "pl_civ_idle_peaceful" } )
	
	if not managers.groupai:state():enemy_weapons_hot() then
		self._enemy_weapons_hot_listen_id = "PlayerMaskOff"..tostring( self._unit:key() )
		managers.groupai:state():add_listener( self._enemy_weapons_hot_listen_id, { "enemy_weapons_hot" }, callback( self, self, "clbk_enemy_weapons_hot" ) )
	end
	
	self._ext_network:send( "set_stance", 1, false, false ) -- ntl
	
	self._show_casing_t = Application:time() + 4
end

--------------------------------------------------------------------------------------

function PlayerMaskOff:exit( state_data, new_state_name )
	PlayerMaskOff.super.exit( self, state_data )
	
	managers.hud:hide_casing()
	
	if self._previous_equipped_selection then
		self._unit:inventory():equip_selection( self._previous_equipped_selection, false )
		self._previous_equipped_selection = nil
	end
	
	self._unit:base():set_slot( self._unit, 2 )
	
	self._ext_movement:chk_play_mask_on_slow_mo( state_data )
	
	if self._enemy_weapons_hot_listen_id then
		managers.groupai:state():remove_listener( self._enemy_weapons_hot_listen_id )
	end
	
	self:_interupt_action_start_standard()
end

--------------------------------------------------------------------------------------

function PlayerMaskOff:interaction_blocked()
	return PlayerMaskOff.super.interaction_blocked(self)
end

--------------------------------------------------------------------------------------

function PlayerMaskOff:update( t, dt )
	PlayerMaskOff.super.update( self, t, dt )
	
	if self._show_casing_t then
		if self._show_casing_t < t then
			self._show_casing_t = nil
			managers.hud:show_casing()
		end
	end
end

function PlayerMaskOff:_update_check_actions( t, dt )
	self:_update_start_standard_timers( t )
	return PlayerMaskOff.super._update_check_actions( self, t, dt )
end

function PlayerMaskOff:_get_walk_headbob()
	return 0.0125
end

function PlayerMaskOff:_check_action_interact( t, input )
	return PlayerMaskOff.super._check_action_interact( self, t, input )
end

function PlayerMaskOff:mark_units( line, t, no_gesture, skip_alert )
	local mark_sec_camera = managers.player:has_category_upgrade( "player", "sec_camera_highlight_mask_off" )
	local mark_special_enemies = managers.player:has_category_upgrade( "player", "special_enemy_highlight_mask_off" )
	
	local voice_type, plural, prime_target = self:_get_unit_intimidation_action( mark_special_enemies, false, false, false, false )
	
	local interact_type
	local sound_name
	
	if voice_type == "mark_cop" or voice_type == "mark_cop_quiet" then
		interact_type = "cmd_point"
		
		if voice_type == "mark_cop_quiet" then
			sound_name = tweak_data.character[ prime_target.unit:base()._tweak_table ].silent_priority_shout .. "_any"
		else
			sound_name = tweak_data.character[ prime_target.unit:base()._tweak_table ].priority_shout .. "x_any"
		end
		
		if managers.player:has_category_upgrade( "player", "special_enemy_highlight" ) then
			prime_target.unit:contour():add( managers.player:has_category_upgrade( "player", "marked_enemy_extra_damage" ) and "mark_enemy_damage_bonus" or "mark_enemy", true, managers.player:upgrade_value( "player", "mark_enemy_time_multiplier", 1 ) )
		end
	elseif voice_type == "mark_camera" and mark_sec_camera then
		sound_name = "f39_any"
		interact_type = "cmd_point"
		
		prime_target.unit:contour():add( "mark_unit", true )
	end
	
	if interact_type then
		self:_do_action_intimidate( t, not no_gesture and interact_type or nil, sound_name, skip_alert )
		return true
	end
	
	return mark_sec_camera or mark_special_enemies
end


function PlayerMaskOff:_check_action_jump( t, input )
	return PlayerMaskOff.super._check_action_jump( self, t, input )
end

function PlayerMaskOff:_check_action_duck( t, input )
	return PlayerMaskOff.super._check_action_duck(self, t, input )
end

function PlayerMaskOff:_check_use_item( t, input )
	local new_action
	local action_wanted = input.btn_use_item_press
	if action_wanted then
		local action_forbidden = self._use_item_expire_t or self:_changing_weapon() or self:_interacting()
		if not action_forbidden then
			self:_start_action_state_standard( t )
		end
	end
	
	if input.btn_use_item_release then
		self:_interupt_action_start_standard()
	end
end

function PlayerMaskOff:_start_action_state_standard( t )
	self._start_standard_expire_t = t + tweak_data.player.put_on_mask_time
	managers.hud:show_progress_timer_bar( 0, tweak_data.player.put_on_mask_time )
	managers.hud:show_progress_timer( { text = managers.localization:text( "hud_starting_heist" ), icon = nil } )
	
	managers.network:session():send_to_peers_loaded( "sync_teammate_progress", 3, true, "mask_on_action", tweak_data.player.put_on_mask_time, false )
end

function PlayerMaskOff:_interupt_action_start_standard( t, input, complete )
	if self._start_standard_expire_t then
		self._start_standard_expire_t = nil
		
		managers.hud:hide_progress_timer_bar( complete )
		managers.hud:remove_progress_timer()
		
		managers.network:session():send_to_peers_loaded( "sync_teammate_progress", 3, false, "mask_on_action", 0, complete and true or false )
	end
end

function PlayerMaskOff:_end_action_start_standard()
	self:_interupt_action_start_standard( nil, nil, true )
	
	PlayerStandard.say_line( self, "a01x_any", true )
	managers.player:set_player_state( "standard" )
		
	managers.achievment:award( "no_one_cared_who_i_was" )
end

function PlayerMaskOff:_update_start_standard_timers( t )
	if self._start_standard_expire_t then
		managers.hud:set_progress_timer_bar_width( tweak_data.player.put_on_mask_time-(self._start_standard_expire_t - t), tweak_data.player.put_on_mask_time )
		if self._start_standard_expire_t <= t then
			self:_end_action_start_standard( t )
			self._start_standard_expire_t = nil
		end
	end
	--PlayerMaskOff.super._update_start_standard_timers(self, t)
end

local G = getfenv(0)
G.PlayerMaskOff = PlayerMaskOff
G.PlayerClean = PlayerMaskOff