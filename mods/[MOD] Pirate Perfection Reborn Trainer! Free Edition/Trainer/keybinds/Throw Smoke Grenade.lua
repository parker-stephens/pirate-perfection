----- Made by Simplity -----
if ( managers.hud._chat_focus == false ) then
function QuickSmokeGrenade:init( unit )
        self._state = 0
        self._unit = unit
        self._new_pos = unit:position() --stores the newly calculated position after self:_upd_movement( t )
        self._collision_slotmask = managers.slot:get_mask( "bullet_impact_targets" )
        self._spawn_pos = unit:position()
        --self._hidden = true
        --self._unit:set_visible( false )
end
 
function QuickSmokeGrenade:launch( params )
        self._state = 1
        self._timer = 0.5
        self._shoot_position = params.position
        self._duration = 15
        self._owner = params.owner
        self._user = params.user
        self._curve_pow = 5
       
        self._velocity = params.dir * 2200
       
        self._last_pos = self._unit:position()
        self._last_last_pos = mvector3.copy( self._last_pos )
        self._upd_interval = 0.03      
        self._last_upd_t = TimerManager:game():time()
        self._next_upd_t = self._last_upd_t + self._upd_interval
        self._auto_explode_t = self._last_upd_t + 3
       
        self:_play_sound_and_effects()
end
 
function QuickSmokeGrenade:update( unit, t, dt )
        if not alive( self._owner ) or not alive( self._user ) then
                return
        end
        if self._remove_t and self._remove_t < t then
                self._unit:set_slot( 0 )
                return
        end
        if TimerManager:game():time() < self._next_upd_t then   -- do not update too often
                return
        end
        local dt = TimerManager:game():time() - self._last_upd_t
        self._last_last_pos = mvector3.copy( self._last_pos )
       
        mvector3.set( self._last_last_pos, self._last_pos )
        mvector3.set( self._last_pos, self._new_pos )   -- self._last_pos is now same as unit:position()
       
        self:_upd_velocity( dt ) -- calculate self._velocity and self._new_pos
       
       
        self:_upd_position()
       
        if self._hidden then
                local safe_dis_sq = 120
                safe_dis_sq = safe_dis_sq*safe_dis_sq
                if mvector3.distance_sq( self._spawn_pos, self._last_pos ) > safe_dis_sq then
                        --self._hidden = false
                        --self._unit:set_visible( true )
                end
        end
       
       
       
        if self:_chk_collision() then
                self._state = 3
                self:_detonate()
                return
        end
       
        if self._state == 1 then
                self._timer = self._timer - dt
       
                if self._timer <= 0 then
                        self._timer = self._timer + 0.5
                        self._state = 2
                        --self:_play_sound_and_effects()
                end
        elseif self._state == 2 then
                self._timer = self._timer - dt
       
                if self._timer <= 0 then
                        self._state = 3
                        self:_detonate()
                        self._unit:set_slot( 0 )
                end    
        end
        self._last_upd_t = t
        self._next_upd_t = t + self._upd_interval
end
 
function QuickSmokeGrenade:_upd_velocity( dt )
        local new_vel_z = mvector3.z( self._velocity ) - dt * 981
        mvector3.set_z( self._velocity, new_vel_z )
 
        -- the following threee lines are: self._new_pos = self._last_pos + self._velocity * dt
        mvector3.set( self._new_pos, self._velocity )
        mvector3.multiply( self._new_pos, dt )
        mvector3.add( self._new_pos, self._last_pos )
end
 
-----------------------------------------------------------------------------------
function QuickSmokeGrenade:_chk_collision()
        local col_ray = World:raycast( "ray", self._last_pos, self._new_pos, "slot_mask", self._collision_slotmask )
        --Draw:brush( Color( 1, 0, 0, 1 ), nil, 1 ):line( self._last_pos, self._new_pos )
        col_ray = col_ray or World:raycast( "ray", self._last_last_pos, self._new_pos, "slot_mask", self._collision_slotmask )
        --Draw:brush( Color( 1, 0, 1, 0 ), nil, 1 ):line( self._last_last_pos, self._new_pos )
        if col_ray then
                self._col_ray = col_ray
                return true
        end
end
 
function QuickSmokeGrenade:_upd_position()
        self._unit:set_position( self._new_pos )
       
        --Do we care about the rotation?
                --local new_rotation = Rotation( self._velocity, math.UP )
                --self._unit:set_rotation( new_rotation )
       
end
 
-----------------------------------------------------------------------------------
 
function QuickSmokeGrenade:_detonate()
        self:_play_sound_and_effects()
        self._remove_t = TimerManager:game():time() + self._duration
end
 
-----------------------------------------------------------------------------------
 
function QuickSmokeGrenade:preemptive_kill()
        self._unit:sound_source():post_event( "grenade_gas_stop" )
        if self._detonated then
                if self._unit:slot() == 0 then
                        --self._unit:set_slot( 14 ) -- workaround for the unit not being deleted for some reason
                end
                self._unit:set_slot( 0 )
                return
        end
        self._detonated = true
        self._unit:set_slot( 0 )
end
 
-----------------------------------------------------------------------------------
 
function QuickSmokeGrenade:_play_sound_and_effects()
        if self._state == 1 then
                local sound_source = SoundDevice:create_source( "grenade_fire_source" )
                sound_source:set_position(self._shoot_position)
       
        --      sound_source:post_event( "grenade_gas_npc_fire" )
        elseif self._state == 2 then
       
                -- Play bounce at some mid-point
                local bounce_point = Vector3()
               
                -- Don't bounce at the exact mid-point, bounce at around 65% between origin and end position
                mvector3.lerp(bounce_point, self._shoot_position, self._unit:position(), 0.65)
               
                --local sound_source = SoundDevice:create_source( "grenade_bounce_source" )
                --sound_source:set_position(bounce_point)
               
                --sound_source:post_event( "grenade_gas_bounce" )
       
--              self._unit:sound_source():post_event( "grenade_gas_bounce" )
               
        elseif self._state == 3 then
                if self._detonated then
                self._unit:set_slot( 0 )
               
        else
        self._detonated = true
                World:effect_manager():spawn( { effect = Idstring( "effects/particles/explosions/explosion_smoke_grenade" ), position = self._unit:position(), normal = self._unit:rotation():y() } )
                self._unit:sound_source():post_event( "grenade_gas_explode" )
               
                local parent = self._unit:orientation_object()
                self._smoke_effect = World:effect_manager():spawn( { effect = Idstring( "effects/particles/explosions/smoke_grenade_smoke" ), parent = parent } ) -- position = self._unit:position(), normal = self._unit:rotation():y() } )
                managers.groupai:state():teammate_comment( nil, "g40x_any", self._unit:position(), true, 2000, false )
                managers.network:session():send_to_peers( "sync_smoke_grenade", self._unit:position(), managers.player:player_unit():position(), 15, false )
        end     end
end
 
-----------------------------------------------------------------------------------
 
function QuickSmokeGrenade:destroy()
        if self._smoke_effect then
                World:effect_manager():fade_kill( self._smoke_effect )
        end
end
 
-----------------------------------------------------------------------------------
 
 
-----------------------------------------------------------------------------------
        function throw_grenade(d5c1ff98dde9b6059d5bf4969f1aef71)
        local number = 5
        local from = managers.player:player_unit():movement():m_head_pos()
        local to = from + managers.player:player_unit():movement():m_head_rot():y() * 50 + Vector3( 0, 0, 0 )
 
        local unit = GrenadeBase.spawn( "units/weapons/smoke_grenade_quick/smoke_grenade_quick", to, Rotation( managers.player:player_unit():movement():m_head_rot():y(), math.UP ), d5c1ff98dde9b6059d5bf4969f1aef71 )
        unit:base():launch( { position = managers.player:player_unit():position(), owner = unit, user = managers.player:player_unit(), dir = managers.player:player_unit():movement():m_head_rot():y(), duration = 15 } )
        end
-----------------------------------------------------------------------------------
 
throw_grenade(d5c1ff98dde9b6059d5bf4969f1aef71)

io.stdout:write("PLAY Trainer/wav/effects/throwsmoke.wav\n")
io.stdout:write("PLAY Trainer/wav/effects/blowit.wav\n")
end