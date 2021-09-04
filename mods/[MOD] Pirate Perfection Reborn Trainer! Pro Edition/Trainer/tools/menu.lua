-- Purpose: menu

ppr_require 'Trainer/experimental/dev/pluginmanager'

-- Patch

local add_text = function( button, button_text )
	local button_text = button_text or button.text or ""
	
	if button.host_only then 
		button_text = button_text .. Localization.translate['host_only']
	end
	
	local is_toggle = button.toggle
	local togg_handle = button.toggle_handler
	if is_toggle then
		local toggle_text = (togg_handle and togg_handle(is_toggle)) or (plugins and (plugins:g_loaded( button.data ) and Localization.translate['btn_off'] or Localization.translate['btn_on']) or '')
		button_text = button_text .. toggle_text
	end
	return button_text
end

function TextBoxGui:_setup_buttons_panel( info_area, button_list, focus_button, only_buttons )
	local has_buttons = button_list and #button_list > 0
	
	local buttons_panel = info_area:panel( { name = "buttons_panel", x = 10, w = has_buttons and 200 or 0, h = info_area:h(), layer = 1 } )
	
	buttons_panel:set_right( info_area:w() )
	self._text_box_buttons_panel = buttons_panel
	
	if has_buttons then
		local button_text_config = { x = 10, name = "button_text", font = tweak_data.menu.pd2_medium_font, font_size = tweak_data.menu.pd2_medium_font_size, vertical = "center", halign="right", layer = 2, wrap="true", word_wrap="true", blend_mode="add", color=Color.Pro} -- tweak_data.dialog.BUTTON_TEXT_COLOR
		local max_w = 0
		local max_h = 0
		
		if( button_list ) then
			for i,button in ipairs( button_list ) do
				local button_panel = buttons_panel:panel( { name = tostring(i), y = 100, h = 20, halign="grow" } )
				
				local button_text = add_text( button )
				
				button_text_config.text = utf8.to_upper( button_text )
				
				local text = button_panel:text( button_text_config )
				
				local _,_,w,h = text:text_rect()
				max_w = math.max( max_w, w )
				max_h = math.max( max_h, h )
				text:set_size( w, h )
				button_panel:set_h( h )
				text:set_right( button_panel:w() )
				
				button_panel:set_bottom( i * h )
			end
			buttons_panel:set_h( #button_list * max_h )
			buttons_panel:set_bottom( info_area:h() - 10 )
		end
		
		buttons_panel:set_w( only_buttons and info_area:w() or (math.max(max_w, 120) + 40) )
		buttons_panel:set_right( info_area:w() - 10 )
		
			local selected = buttons_panel:rect( { name="selected", blend_mode="add", color=tweak_data.screen_colors.Color.Pro, alpha=0.3 } )
			self:set_focus_button( focus_button )
	end
	
	return buttons_panel
end

function SystemMenuManager.GenericDialog:button_pressed_callback()
	if self._data.no_buttons then
		return
	end

	self:button_pressed( self._panel_script:get_focus_button() )
end

function SystemMenuManager.Dialog:change_text_callback( button_text )
	local button_panel = self._panel_script._text_box_buttons_panel
	
	local button_index = self._panel_script:get_focus_button_id()
	local text = button_panel:child( button_index ):child( "button_text" )
	button_text = add_text( self._data.button_list[ tonumber(button_index) ], button_text )
	
	text:set_text( utf8.to_upper( button_text ) )
	local _,_,w,h = text:text_rect()
	text:set_size( w, h )
	text:set_right( button_panel:w() )
end

function SystemMenuManager.Dialog:button_pressed( button_index )
	local button_list = self._data.button_list
	
	local button
	-- Callback on button data:
	if( button_list ) then
		button = button_list[ button_index ]
	
		if( button and button.callback_func ) then
			button.callback_func( button_index, button )
		end
	end

	-- Callback on dialog data:
	local callback_func = self._data.callback_func
	if( callback_func ) then
		callback_func( button_index, self._data )
	end
	
	if button and button.switch_back then -- Change text	
		local button_panel = self._panel_script._text_box_buttons_panel
		local text = button_panel:child( tostring(button_index) ):child( "button_text" )
		
		local button_text = add_text( button )
		
		text:set_text( utf8.to_upper( button_text ) )
		local _,_,w,h = text:text_rect()
		text:set_size( w, h )
		text:set_right( button_panel:w() )
	else
		self:fade_out_close()
	end
end

function SystemMenuManager.GenericDialog:mouse_pressed( o, button, x, y )
	if button == Idstring( "0" ) or button == Idstring( "1" ) then
		local x, y = managers.mouse_pointer:convert_1280_mouse_pos( x, y )
		if self._panel_script:check_grab_scroll_bar( x, y ) then
			return
		end
		for i,panel in ipairs( self._panel_script._text_box_buttons_panel:children() ) do
			if panel.child and panel:inside( x, y ) then
				if button == Idstring( "0" ) and self._data.button_list[i].combobox then -- open combobox
					self._panel_script:set_fade( 0.2 )
					self._data.button_list[i].combobox()
					self:set_input_enabled( false )
					Combobox.menu_panel = self
					return
				end
				
				if button == Idstring( "0" ) then
					self:button_pressed_callback()
				end
				return
			end
		end
	elseif button == Idstring( "mouse wheel down" ) then
		return self._panel_script:mouse_wheel_down( x, y )
	elseif button == Idstring( "mouse wheel up" ) then
		return self._panel_script:mouse_wheel_up( x, y )
	end
end

-- Menu

SimpleMenuV3 = SimpleMenuV3 or class()

function SimpleMenuV3:init( title, text, data, dont_show )
	self.shown = false
	self.dialog_data = {}
	self.dialog_data.id = tostring(math.random(0,0xFFFFFFFF))
	self.dialog_data.title = title or ""
	self.dialog_data.text = text or ""
	
	self.dialog_data.button_list = { }
	
	for _, option in ipairs( data ) do
		if not ( option.host_only and is_client() ) then
			option.callback_func = callback( self, self, "do_callback", { callback = option.callback, switch_back = option.switch_back, args = { unpack( type( option.data ) == 'table' and option.data or { option.data } ) } } )
		end
		--Temporary hacks again {
		option.cancel_button = option.cancel_button or option.is_cancel_button
		option.switch_back = type(option.switch_back) ~= 'function' and option.switch_back or nil
		-- }
		table.insert( self.dialog_data.button_list, option )
	end
	
	if not dont_show then
		self:show()
	end
end

function SimpleMenuV3:show()
	if self.shown then
		return
	end
	if Combobox and Combobox.__active then
		Combobox.__active:close() --Close active combobox
	end
	
	if SimpleMenuV3._current_menu then
		SimpleMenuV3._current_menu:hide() --Close active menu
	end
	managers.system_menu:show( self.dialog_data )
	self.shown = true
	SimpleMenuV3._current_menu = self --Now I'm active menu
end

function SimpleMenuV3:hide()
	if not self.shown then
		return
	end
	for i,btn in pairs(self.dialog_data.button_list) do
		--Emulate close_button press
		if btn.cancel_button and btn.callback_func then
			btn.callback_func(i, btn)
		end
	end
	managers.system_menu:close( self.dialog_data.id )
	self.shown = false
	if self == SimpleMenuV3._current_menu then --If I was active menu, remove myself from active menu
		SimpleMenuV3._current_menu = nil
	end
end

function SimpleMenuV3:do_callback( data )
	if data.callback then
		local err, res = pcall(data.callback, unpack( data.args ) )
		if not err then
			m_log_error('SimpleMenuV3:do_callback()', res)
		end
	end
	if data.switch_back and type(data.switch_back) == 'function' then
		safecall(data.switch_back)
	end
end