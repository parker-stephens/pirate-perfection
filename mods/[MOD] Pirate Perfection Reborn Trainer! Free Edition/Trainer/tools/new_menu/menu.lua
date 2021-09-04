-- Menu class by Simplity 

local pairs = pairs
local ipairs = ipairs
local ppr_require = ppr_require
local type = type
local safecall = safecall
local unpack = unpack
local table = table
local tab_insert = table.insert
--local tab_remove = table.remove
local math_max = math.max
local io_open = ppr_io.open

local tr = Localization.translate

ppr_require 'Trainer/tools/new_menu/tickbox'
ppr_require 'Trainer/tools/new_menu/slider'
ppr_require 'Trainer/tools/new_menu/multi_choice'
ppr_require 'Trainer/tools/new_menu/text_input'
ppr_require 'Trainer/tools/new_menu/save_button'
ppr_require 'Trainer/experimental/dev/pluginmanager'

local Tickbox = Tickbox
local MultiChoice = MultiChoice
local Slider = Slider
local TextInput = TextInput
local SaveButton = SaveButton

local mouse = Input:mouse()
local mouse_pressed = mouse.pressed
local Idstring = Idstring
local left_click = Idstring('0')
local right_click = Idstring('1')

local clone = clone
local managers = managers
local M_mouse_pointer = managers.mouse_pointer
local M_controller = managers.controller

local tweak_data = tweak_data
local T_menu = tweak_data.menu
local T_gui = tweak_data.gui
local callback = callback
local __load_plugin = load_plugin
local OverlayGui = Overlay:gui()
local RunNewLoopIdent = RunNewLoopIdent
local StopLoopIdent = StopLoopIdent
local executewithdelay = executewithdelay
local backuper = backuper
local restore = backuper.restore
local backup = backuper.backup
local m_log_error = m_log_error
local m_log_vs = m_log_vs
local plugins = plugins
local is_client = is_client
--local s_freeflight = setup:freeflight()

local void = void

--Tweak data
local description_font_size = 18
 
local Menu = class()

function Menu:init( data )
	local active_menu = tweak_data.menu_active
	if active_menu then
		active_menu:close()
	end
		
	self._data = data
	local ws = OverlayGui:create_screen_workspace()
	self._ws = ws
	managers.gui_data:layout_1280_workspace( ws )
	tweak_data.menu_active = self
	self.close_clbks = {}
	
	self:create_menu()
	self:setup_mouse()
	self:disable_controllers( true )
	self:add_controller()
	RunNewLoopIdent( "menu_update", self.update, self )
	
	if data.plugin_path then
		self.load_plugin = __load_plugin( data.plugin_path )
	end
	
--Stop disable_controllers delayed callback, created by previous menu to prevent stupid bugs
	StopLoopIdent( 'disable_cont_clbk' )
end

local preload_plugin = plugins.pre_require

function Menu.open( _, data, n ) -- sorted dialog
	--local clock = os.clock
	--local st = clock()
	local max_entries = 22
	
	if not n or n < 1 then
		n = 1
	end
	
	local n_data = {}
	local menu_data = clone( data )
	local button_list = menu_data.button_list
	local open = Menu.open
	if n > 1 then
		menu_data.back = function() open( Menu, data, n - max_entries ) end
	end
	
	local delta = 0 --This will help to resort list, if some button failed validation
	local plug_path = data.plugin_path
	for i = n, #button_list do
		local button = button_list[i]
		if ( delta ~= 0 ) then
			i = i - delta
			button_list[i] = button
		end
		--This will validate if some plugin exists on harddrive. If not, button will not be added.
		--Also it preloads plugins
		local have_plugin = button.plugin
		local selected_path = button.plugin_path or plug_path
		if (not have_plugin or not selected_path or preload_plugin( plugins, selected_path..have_plugin )) then
			if i >= ( max_entries + n ) then
				menu_data.next = function() open( Menu, data, i ) end
				break
			end
			tab_insert( n_data, button )
		else
			delta = delta + 1
			--m_log_vs('(warning) Failed to preload plugin', have_plugin)
		end
	end
	
	menu_data.button_list = n_data
	return Menu:new( menu_data )
	--st = clock() - st
	--m_log_v('It took me ', st, ' ticks in order to open this menu')
end

-- Draw menu

function Menu:create_menu()
	local scaled_size = managers.gui_data:scaled_size()
	local data = self._data
	local w_mul = data.w_mul or 2.2 --3.2
	local h_mul = data.h_mul or 2.0 --2.8
	local w = scaled_size.width/w_mul 
	local h = scaled_size.height/h_mul

	self.main = self._ws:panel():panel( { visible = true, x = 0, y = 0, w = w, h = h, layer = T_gui.DIALOG_LAYER, valign = "center" } ) -- main panel
	
	self:add_title()
	self:add_description()
	self:add_lines()
	self:add_info_area()
	self:add_buttons()
	self:add_navigation()
	
	self.info_area:set_h( math_max( self.buttons_panel:h() + self.title_text:h() + self.desc_panel:h() + 60, h ) )
	self.buttons_panel:set_top( self.title_text:h() + self.desc_panel:h() + 5 )
	
	self.bottom_line:set_top( self.info_area:h() - self.title_text:h() )
	self.navigation_panel:set_top( self.info_area:h() - self.title_text:h()/1.5 )
	
	self.title_text:set_center_x( self.navigation_panel:w() / 2 )
	self.desc_panel:set_center_x( self.navigation_panel:w() / 2 )

	self.main:set_h( self.info_area:h() )
	self.main:set_center( self._ws:panel():center() )
end

function Menu:add_title()
	local main = self.main
	local title = self._data.title
	
	local title_text = main:text( { name = "title", text = title or "", layer = 2, wrap = false, word_wrap = false, visible = true,
								   font = T_menu.pd2_large_font, font_size = 20,color = Color.Free,
								   align="center", halign="center", vertical="top", valign="top", x = 0, y = 10 } )
	self.title_text = title_text
										
	local _,_,tw,th = title_text:text_rect()
	title_text:set_size( tw, th + 15 )
end

function Menu:add_description()
	local main = self.main
	local description = self._data.description
	
	local desc_panel = main:text( { name = "description", text = description or "", layer = 2, wrap = true, word_wrap = true, visible = true,
							   font = T_menu.pd2_medium_font, font_size = description_font_size, color = Color.Free,
							   align="center", halign="center", vertical="top", valign="top", x = 0, y = 40 } )
	self.desc_panel = desc_panel
	
	local _,_,tw,th = desc_panel:text_rect()
	desc_panel:set_size( main:w()-10, th+20 )
end

function Menu:add_lines() -- add top and bottom lines
	local main = self.main
	
	local w = self.main:w()
	local th = self.title_text:h()
	local dh = self.desc_panel:h()
	
	local mid_line = main:bitmap( { name = "mid_line", texture = "guis/textures/headershadow", layer = 1, color = Color.Free:with_alpha(1.0), w = w } )
	mid_line:set_bottom( th + dh + 2 )
	self.bottom_line = main:bitmap( { name = "bottom_line", texture = "guis/textures/headershadow", rotation = 180, layer = 1, color = Color.Free:with_alpha(1.0), w = w } )
end

function Menu:add_info_area() -- background
	local main = self.main
	
	self.info_area = self.main:panel( { name="info_area", x = 0, y = 0, w = main:w(), h = main:h(), layer = 0 } )
	local info_bg = self.info_area:rect( { name="info_bg", layer=0, color=Color.black, alpha=0.90, halign="grow", valign="grow" } ) 
end

function Menu:add_buttons()
	local info_area = self.info_area
	local button_list = self._data.button_list
	
	local buttons_panel = info_area:panel( { name = "buttons_panel", x = 15, w = 100, h = info_area:h(), layer = 1 } )
	self.buttons_panel = buttons_panel
	local ws = self._ws
	
	if not button_list then 
		return
	end
	
	local text_config = { layer = 2, wrap = "true", word_wrap = "true", visible = true,
						  font = T_menu.pd2_medium_font, font_size = 20, color = Color.Free,
						  align="left", halign="left", vertical="top", valign="top", blend_mode = "add" }
	
	local max_w = 0
	local max_h = 0
	
	local is_client = is_client()
	
	local plug_path = self._data.plugin_path
	for i, button in ipairs( button_list ) do
		local have_plugin = button.plugin
		local selected_path = button.plugin_path or plug_path
		local selected_color = Color.Free
		
		if button.host_only and is_client then
			self:host_only_button( button )
			selected_color = Color.Free
		end
		
		text_config.name = "button_text_" .. i
		local button_panel = self:_add_button( buttons_panel, button.text, text_config )
		button_panel:set_bottom( i * button_panel:h() )
		button_panel:set_w( math_max( button_panel:w(), info_area:w() ) - 12 )
		
		if have_plugin or button.type == "toggle" then
			button.tickbox = Tickbox:new( button_panel, button, selected_path )
		end
		
		if button.type == "multi_choice" then
			button.multi_choice = MultiChoice:new( button_panel, button )
		end
		
		if button.type == "slider" then
			button.slider = Slider:new( button_panel, button )
		elseif button.type == "input" then
			button.input = TextInput:new( button_panel, button, ws )
		else
			button_panel:rect( { name = "selected", blend_mode = "add", color = selected_color, alpha = 0.3, visible = false } ) -- highlight
		end
		
		if button.type == "save_button" then
			button.save_button = SaveButton:new( button_panel, button )
		end
		
		if button.menu then
			button_panel:bitmap( { texture = "guis/textures/pd2/crimenet_legend_join", color = Color.Free, y = 3, x = button_panel:w() - 20 } )
		end
		
		if button.box then
			button_panel:bitmap( { texture = "guis/textures/pd2/blackmarket/inv_newdrop", color = Color.Free, y = 3, x = button_panel:w() - 20 } )
		end
		
		max_w = math_max( max_w, button_panel:w() )
		max_h = math_max( max_h, button_panel:h() )
	end

	buttons_panel:set_h( #button_list * max_h )
	buttons_panel:set_w( math_max( max_w, 400 ) )
end

function Menu:add_navigation()
	local main = self.main
	local info_area = self.info_area
	local th = self.title_text:h()
	
	local navigation_panel = main:panel( { name = "navigation_panel", w = info_area:w(), h = 20, layer = 1 } )
	self.navigation_panel = navigation_panel
		
	local text_config = { layer = 2, wrap = "true", word_wrap = "true", visible = true,
						  font = T_menu.pd2_medium_font, font_size = 20, color = Color.Free,
						  align="left", halign="left", vertical="top", valign="top", blend_mode = "add" }
	
	if self._data.back then
		local prev_page = self:_add_button( navigation_panel, tr['prev_page'], text_config )
		prev_page:set_name("previous_page")
		prev_page:set_left( 10 )
	end
	
	if self._data.next then	
		local next_page = self:_add_button( navigation_panel, tr['next_page'], text_config )
		next_page:set_name("next_page")
		next_page:set_right( navigation_panel:w() - 10 )
	end
	
	local close_button = self:_add_button( navigation_panel, tr['exit'], text_config )
	close_button:set_name("close_button")
	close_button:set_x( navigation_panel:w()/2 )
end

function Menu:_add_button( panel, text, text_config )
	local button_panel = panel:panel( { name = text_config.name, h = 20 } )
	
	text_config.name = "text"
	local button = button_panel:text( text_config )
	button:set_text( text or "" )
	local _,_,w,h = button:text_rect()	
	button_panel:set_size( w, h )
	button:set_size( w, h )
		
	return button_panel
end

function Menu:host_only_button( button )
	button.text = tr['host_only'] .. button.text
	button.callback = void
	button.plugin = nil
end

-- Set up menu

function Menu:setup_mouse()
	self._mouse_id = M_mouse_pointer:get_id()
	local data = {}
	data.id = self._mouse_id
	M_mouse_pointer:use_mouse( data )
end

function Menu:add_controller()	
	self.controller = M_controller:get_controller_by_name( "Menu" ) or M_controller:create_controller( "Menu", M_controller:get_default_wrapper_index(), false )
	self.controller:enable()
	
	self._cancel_func = callback( self, self, "close" )
	self._confirm_func = callback( self, self, "enter_button_pressed" )
	
	self.controller:add_trigger( "cancel", self._cancel_func )
	self.controller:add_trigger( "confirm", self._confirm_func )
end

local GenSysMenuManager = SystemMenuManager.GenericSystemMenuManager
local o__is_active = GenSysMenuManager.o__is_active
if ( not o__is_active ) then
	o__is_active = GenSysMenuManager.is_active
	GenSysMenuManager.o__is_active = o__is_active
end

function Menu:disable_controllers( state )
	if state then
		GenSysMenuManager.is_active = function()
			return true
		end
		
--		if s_freeflight._state == 0 then
--			s_freeflight._con:disable()
--		end
	elseif not state then
		GenSysMenuManager.is_active = o__is_active
		
--		if s_freeflight._state == 0 then
--			s_freeflight._con:enable()
--		end
	end
end

function Menu:update()
	if self:mouse_update() then
		M_mouse_pointer:set_pointer_image( "link" )
	else
		M_mouse_pointer:set_pointer_image( "arrow" )
	end
	
	--self:disable_controllers( true )
end

function Menu:mouse_update()
	local x, y = M_mouse_pointer._mouse:x(), M_mouse_pointer._mouse:y()
	
	local is_left_click		=	mouse_pressed( mouse, left_click )
	local is_right_click	=	not is_left_click and mouse_pressed( mouse, right_click )
	
	if self:_navigation_button_moved( x, y, is_left_click ) then
		return true
	end
	if self:_button_moved( x, y, is_left_click, is_right_click ) then
		return true
	end
end

function Menu:_navigation_button_moved( x, y, clicked )
	for i, panel in ipairs( self.navigation_panel:children() ) do
		if panel.child and panel:inside( x, y ) then
			if clicked then
				self:navigation_button_pressed(i)
			end
			return true
		end
	end
end

function Menu:_button_moved( x, y, clicked, alt_clicked )
	for i, panel in ipairs( self.buttons_panel:children() ) do
		if panel.child and panel:inside( x, y ) then
			self._focus_button = i
			self:enable_highlight_button()

			if clicked or alt_clicked then
				self:button_pressed(i,  alt_clicked)
			end
			return true
		end
	end
end

function Menu:enable_highlight_button()
	local prev_focus_button = self._prev_focus_button
	if prev_focus_button and prev_focus_button ~= self._focus_button then
		self:disable_highlight_button()
	end
		
	local button = self.buttons_panel:child( "button_text_" .. self._focus_button )
	if button then
		local rect = button:child("selected")
		if rect then
			rect:set_visible( true )
		end
		
		self._prev_focus_button = self._focus_button
	end
end

function Menu:disable_highlight_button()
	local button = self.buttons_panel:child( "button_text_" .. self._prev_focus_button )
	if button then
		local rect = button:child("selected")
		if rect then
			rect:set_visible( false )
		end
	end
end

function Menu:navigation_button_pressed( button_index )
	local navigation_buttons = self.navigation_panel:children()
	local button = navigation_buttons[ button_index ]
	local button_name = button:name()
	
	if button_name == "close_button" then
		self:close()
	elseif button_name == "previous_page" then
		self._data.back()
	elseif button_name == "next_page" then
		self._data.next()
	end
end

function Menu:enter_button_pressed()
	if self._focus_button then
		self:button_pressed( self._focus_button )
	end
end

function Menu:button_pressed( button_index, alt )
	local button = self._data.button_list[ button_index ]
	
	if not button then
		return
	end
	
	if alt then --Right click, use alternative callback
		local clbk = button.alt_callback
		if clbk then
			local data = button.data
			if type(data) == 'table' then
				safecall( clbk, unpack( data ) )
			else
				safecall( clbk, data )
			end
			local switch_back = button.switch_back_alt
			if not switch_back then
				self:close()
			elseif type( switch_back ) == "function" then
				switch_back()
			end
		end
		return --And stop here
	end
		
	if button.type == "save_button" then
		button.save_button:save()
		button.callback = nil
	end
	
	local have_plugin = button.plugin
	local custom_path = button.plugin_path
	local load_plugin = custom_path and __load_plugin( custom_path ) or self.load_plugin
	if have_plugin and load_plugin then
		load_plugin( have_plugin )
	end
	
	local btn_callback = button.callback
	if btn_callback then
		local data = button.data
		if type(data) == 'table' then
			safecall( btn_callback, unpack( data ) )
		else
			safecall( btn_callback, data )
		end
	end
	
	local switch_back = button.switch_back
	if switch_back and ( button.type == "toggle" or have_plugin ) then
		button.tickbox:toggle()
	end
	
	--if btn_callback then
	if not switch_back then
		--Very dirty fix
		if button.type ~= 'input' then
			self:close()
		end
	elseif type( switch_back ) == "function" then
		switch_back()
	end
	--end
end

function Menu:close()
	if not self._ws then
		return
	end
	
	M_mouse_pointer:remove_mouse( self._mouse_id )
	self.controller:remove_trigger( "cancel", self._cancel_func )
	self.controller:remove_trigger( "confirm", self._confirm_func )
	self.controller:disable()
	executewithdelay( { func = self.disable_controllers, params = {self} }, 0.23, 'disable_cont_clbk' )
	
	self:stop_loops()
	self._ws:panel():remove( self.main )
	OverlayGui:destroy_workspace( self._ws )
	self._ws = nil
	tweak_data.menu_active = nil
	for id,clbk in pairs(self.close_clbks) do
		clbk()
	end
end

function Menu:stop_loops()
	StopLoopIdent("menu_update")
	
	for _, button in pairs( self._data.button_list ) do
		local slider = button.slider
		if slider then
			slider:close()
		else
			local multi_choice = button.multi_choice
			if multi_choice then
				multi_choice:close()
			else
				local input = button.input
				if input then
					input:close()
				end
			end
		end
	end
end

local G = getfenv(0)
G.Menu = Menu
return Menu