-- Debug HUD
-- Author: Simplity

plugins:new_plugin('debug_hud')

-- GUI
DebugGui = DebugGui or class()

DebugGui.debug_x = 0.90
DebugGui.debug_y = 0.40
DebugGui.size = 0.010

function DebugGui:init()
	self.ws = Overlay:newgui():create_screen_workspace()
	self.panel = self.ws:panel():text{ x = self.debug_x * RenderSettings.resolution.x, y = self.debug_y * RenderSettings.resolution.y, text="", font="core/fonts/diesel", font_size = self.size * RenderSettings.resolution.x, color = Color.white, layer=2000 }
	self.last_upd_t = Application:time()
	self.upd_timer = 0
	self._panels = {}
	self.groups = { { group = managers.enemy:all_civilians(), color = Color.cyan }, { group = managers.enemy:all_enemies(), color = Color.red }, { group = managers.groupai:state():all_AI_criminals(), color = Color.green } }
	self.text = ""
end

function DebugGui.update(self)
	local t = Application:time()
	local dt = t - self.last_upd_t
	self.upd_timer = self.upd_timer - dt

	if self.upd_timer <= 0 then
		self.upd_timer = 0.5
		self.text = ""
		self:insert( "Map ID: ", managers.job:current_level_id() )
		self:insert( "Enemies on map: ", self:count_table( managers.enemy:all_enemies() ) )
		self:insert( "Civilians on map: ", self:count_table( managers.enemy:all_civilians() ) )
		self:insert( "Wave mode: ", managers.groupai:state()._wave_mode )
		self:insert( "Assault phase: ", managers.groupai:state()._task_data.assault.phase )

		self.panel:set_text(self.text)
	end

	--self:draw_hp()

	self.last_upd_t = t
end

-- Functions
function DebugGui:draw_hp()
	for _, data in pairs( self.groups ) do
		self:draw( data.group, data.color )
	end
end

function DebugGui:draw( group, color )
	local draw_data = managers.groupai:state()._AI_draw_data
	local panel = draw_data.panel
	local camera = managers.viewport:get_current_camera()
	local mid_pos1 = Vector3()
	
	for key, data in pairs( group ) do
		local c_panel = self._panels[key]
		local my_head_pos = mid_pos1
		mvector3.set( my_head_pos, data.unit:movement():m_head_pos() )
		mvector3.set_z( my_head_pos, my_head_pos.z + 30 )

		local my_head_pos_screen = camera:world_to_screen( my_head_pos )

		local screen_x = ( my_head_pos_screen.x + 1 ) * 0.5 * RenderSettings.resolution.x
		local screen_y = ( my_head_pos_screen.y + 1 ) * ( 0.53 ) * RenderSettings.resolution.y	

		local text = "Health: " .. math.ceil( data.unit:character_damage()._health ) .. " / " .. math.ceil( data.unit:character_damage()._HEALTH_INIT )

		if not c_panel then
			self._panels[key] = panel:text{ name = "text", x = screen_x, y = screen_y, text = text, font = tweak_data.hud.medium_font, font_size = 20, color = color or Color.white, layer = 1 }
		elseif my_head_pos_screen.z > 0 then
			c_panel:set_x( screen_x )
			c_panel:set_y( screen_y )
			c_panel:set_text( text )
			c_panel:show()
		else
			c_panel:hide()
		end
	end
	
	for key, gui in pairs( self._panels ) do
		local keep
		for u_key, data in pairs( self.groups ) do
			if data.group[key] then
				keep = true
				break
			end
		end

		if not keep then
			panel:remove( gui )
			self._panels[key] = nil
		end
	end
end

function DebugGui:count_table( table )
	local i = 0
	for _ in pairs( table ) do
		i = i + 1
	end
	return i
end

function DebugGui:insert( title, value )
	if value then
		self.text = self.text .. title .. " " .. tostring(value) .. "\n"
	end
end

VERSION = '1.0'

function MAIN()
	backuper:backup("GroupAIStateBase.update")
	backuper:backup("MissionManager.update")
	backuper:backup("MissionScript._debug_draw")

	if ppr_config.DebugDramaDraw then
		managers.groupai:state():set_drama_draw_state( true )
	end
	if ppr_config.DebugStateDraw then
		managers.groupai:state():set_debug_draw_state( true )
	end
	if ppr_config.DebugConsole then
		managers.mission:set_persistent_debug_enabled( true )
		console.CreateConsole()
	end
	if ppr_config.DebugNavDraw then
		managers.navigation._debug = true
		managers.navigation:set_debug_draw_state { quads = true, doors = true, vis_graph = true, coarse_graph = true, blockers = true, covers = true, pos_rsrv = true, nav_links = true }
	end
	if managers.debug then
		managers.debug:set_enabled_all(true, true)
		managers.debug.macro._check_fps = true
	end

	function GroupAIStateBase:update( t, dt )
		self._t = t
		
		self:_upd_criminal_suspicion_progress()
		
		if self._draw_drama then
			self:_debug_draw_drama( t )
		end
		
		self:_upd_debug_draw_attentions()
		if ppr_config.DebugAdditionalEsp then
			self:_draw_enemy_importancies()
		end
	end

	function MissionManager:update( t, dt )
		for _,script in pairs( self._scripts ) do
			script:update( t, dt )
			if ppr_config.DebugMissionElements then
				script:_debug_draw( t, dt )
			end
		end
	end

	function MissionScript:_debug_draw( t, dt )
		local name_brush = Draw:brush( Color.red )
		name_brush:set_font( Idstring( "fonts/font_medium" ), 16 )
		name_brush:set_render_template( Idstring( "OverlayVertexColorTextured" ) )
		for _,element in pairs( self._elements ) do
			name_brush:set_color( element:enabled() and Color.green or Color.red )
			if element:value( "position" ) then
				
				if managers.viewport:get_current_camera() then
					
					local cam_up = managers.viewport:get_current_camera():rotation():z()
					local cam_right = managers.viewport:get_current_camera():rotation():x()
					name_brush:center_text( element:value( "position" ) + Vector3( 0, 0, 30 ), element:editor_name(), cam_right, -cam_up )
				end
			end
			
			if element:value( "rotation" ) then
				
				local rotation = CoreClass.type_name( element:value( "rotation" ) ) == "Rotation" and element:value( "rotation" ) or Rotation( element:value( "rotation" ), 0, 0 )
			end
			if ppr_config.DebugElementsAdditional then
				element:debug_draw( t, dt )
			end
		end
	end
	
	debug_gui = DebugGui:new()
	RunNewLoopIdent("DebugHud", debug_gui.update, debug_gui )
end

function UNLOAD()
	managers.groupai:state():set_drama_draw_state( false )
	managers.groupai:state():set_debug_draw_state( false )
	managers.mission:set_persistent_debug_enabled( false )
	managers.navigation:set_debug_draw_state( false )
	backuper:restore("GroupAIStateBase.update")
	backuper:restore("MissionManager.update")
	backuper:restore("MissionScript._debug_draw")
	StopLoopIdent("DebugHud")
	if debug_gui and alive( debug_gui.ws ) then
		Overlay:gui():destroy_workspace( debug_gui.ws )
	end
	debug_gui = nil
end

FINALIZE()