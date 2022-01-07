--Menu component. Represents field, where you can enter your text
--Author: Simplity

--TO DO:
--Add event callbacks:
--On clicked
--On released
--On text
---------
--Improve design

local kb = Input:keyboard()
local mb = Input:mouse()
local kb_pressed = kb.pressed
local kb_down = kb.down
local mb_pressed = mb.pressed

local os_clock = os.clock

local pcall = pcall
local safecall = safecall

local Idstring = Idstring

local left_clk = Idstring("0")
local bkspace = Idstring("backspace")
local enter = Idstring("enter")
local left = Idstring( "left" )
local right = Idstring( "right" )

local managers = managers
local M_mouse_pointer = managers.mouse_pointer

local RunNewLoop = RunNewLoop
local callback = callback

local ulen = utf8.len

local m_log_error = m_log_error
local StopLoopIdent = StopLoopIdent

local TextInput = class()

function TextInput:init( panel, button, ws )
	self.panel = panel
	self.button = button
	
	ws:connect_keyboard( kb )
	
	self:create_gui()
	
	self.id = RunNewLoop( callback( self, self, "update" ) )
end

local T_menu = tweak_data.menu
local pd2_small_font = T_menu.pd2_small_font
local pd2_small_font_size = T_menu.pd2_small_font_size
function TextInput:create_gui()
	local panel = self.panel
	local button_text = panel:child("text") 
	
	local input_panel = panel:panel( { name = "input_panel", x = button_text:w() + 10, h = panel:h(), w = panel:w() - button_text:w() - 10, layer = 1 } )
	input_panel:rect( { name = "focus_indicator", visible = true, color = Color.black:with_alpha(0.1), layer = 4 } )

	local text_input = input_panel:text( { name = "input_text", text = "", font = pd2_small_font, font_size = pd2_small_font_size, x = 0, y = 0,
										align="left", halign="left", vertical="center", hvertical="center", blend_mode="normal",
										color = Color.VIP, layer = 5, wrap = true, word_wrap = false } )
										
	local caret = input_panel:rect( { name="caret", layer = 2, x = 0, y = 2, w = 0.8, h = panel:h() - 5, color = Color.VIP } )
	input_panel:rect( { name="input_bg", color=Color.black:with_alpha(0.5), layer = -1, valign = "grow", h = input_panel:h() } )
	
	self.input_panel = input_panel
	
	if self.button.value then
		self:enter_text( nil, self.button.value )
	end
end

function TextInput:enter_text( o, s )
	local text = self.input_panel:child("input_text")
	
	text:replace_text(s)
	
	local lbs = text:line_breaks()
	
	if #lbs > 1 then
		local s = lbs[2]
		local e = ulen( text:text() )
	
		text:set_selection( s, e )
		text:replace_text( "" )
	end
	self:on_text()
	self:update_caret()
end

function TextInput:update()
	local enabled = self.input_enabled
	local M = M_mouse_pointer._mouse
	local x, y = M:x(), M:y()
	local is_inside = self.input_panel:inside( x, y )
	
	if ( not enabled and is_inside ) then
		if mb_pressed(mb, left_clk ) then
			self:activate_input()
		end
	elseif ( not is_inside and enabled and mb_pressed(mb, left_clk ) ) then
		self:disable_input()
	elseif ( enabled ) then
		self:update_buttons()
	end
end

local function holding_key(keys_t, key)
	local pressed = kb_pressed( kb, key )
	local is_down = kb_down( kb, key )
	local clocks = os_clock()
	local t = is_down and (keys_t[key] or clocks) or false
	if (t and (clocks - t) > 0.75) then
		pressed = true
		t = t + 0.04 --Move it smooth, not so fast
	end
	keys_t[key] = t
	return pressed
end

function TextInput:update_buttons()
	local hold_key_tab = self.holding_keys
	if ( not hold_key_tab ) then
		hold_key_tab = {}
		self.holding_keys = hold_key_tab
	end
	if holding_key(hold_key_tab, bkspace) then
		self:remove_text()
	--If input activated, then let's trace left and right presses
	elseif holding_key(hold_key_tab, left) then
		local text = self.input_panel:child( "input_text" )
		local s, e = text:selection()
		
		if e>s then 
			text:set_selection(s,s)
		elseif s>0 then
			text:set_selection(s-1,s-1)
		end
		self:update_caret()
	elseif holding_key(hold_key_tab, right) then
		local text = self.input_panel:child( "input_text" )
		local s, e = text:selection()
		
		if e>s then
			text:set_selection(e,e)
		elseif s<ulen(text:text()) then
			text:set_selection(s+1,s+1)
		end
		self:update_caret()
	elseif kb_pressed(kb, enter ) then
		self:do_callback()
		self:disable_input()
	end
end

function TextInput:update_caret()
	local text = self.input_panel:child( "input_text" )
	local caret = self.input_panel:child( "caret" )
	
	local s, e = text:selection()
	local x, y, w, h = text:selection_rect()
	
	if s == 0 and e == 0 then
		x = text:world_x()
		y = text:world_y()
		h = text:h()
	end

	caret:set_world_shape( x, y, w, h )
end

function TextInput:activate_input()
	if self.input_enabled then
		return
	end
	self.input_panel:enter_text( callback( self, self, "enter_text" ) )
	self.input_enabled = true
	TextInput.active = self
	
	local caret = self.input_panel:child("caret")
	caret:animate( self.blink )
	caret:set_visible( true )
end

function TextInput:disable_input()
	if not self.input_enabled then
		return
	end
	self.input_panel:enter_text( nil )
	self.input_enabled = false
	self.button.value = ( self.input_panel:child("input_text") ):text()
	if TextInput.active == self then
		TextInput.active = nil
	end
	
	local caret = self.input_panel:child("caret")
	caret:stop()
	caret:set_visible( false )
end

function TextInput:remove_text()
	local text = self.input_panel:child("input_text")
	
	local s, e = text:selection()

	if s == e and s > 0 then
		text:set_selection( s - 1, e )
	end
	
	text:replace_text("")
	self:on_text()
	self:update_caret()
end

local wait = wait
function TextInput.blink( o )
	while true do
		o:set_color( Color.VIP )
		wait(0.3)
		o:set_color( Color.VIP )
		wait(0.3)
	end
end

function TextInput:on_text()
	local on_text_clbk = self.button.on_text_clbk
	if ( on_text_clbk ) then
		local text = self.input_panel:child("input_text")
		safecall( on_text_clbk, text:text() )
	end
end

function TextInput:do_callback()
	local text = self.input_panel:child("input_text")
	
	local clbk_input = self.button.callback_input
	if clbk_input then
		local s, e = pcall( clbk_input, text:text() )
		if not s then
			m_log_error('TextInput:do_callback()', e)
		end
	end
end

function TextInput:close()
	self:disable_input()
	StopLoopIdent( self.id )
end

local G = getfenv(0)
G.TextInput = TextInput