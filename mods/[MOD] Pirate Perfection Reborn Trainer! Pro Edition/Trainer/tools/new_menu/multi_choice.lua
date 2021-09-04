--Menu component. Shows extra menu with variants
--Author: Simplity

local pairs = pairs

local Input = Input
local mouse = Input:mouse()
local keyboard = Input:keyboard()
local mouse_pressed = mouse.pressed
local keyboard_pressed = keyboard.pressed
local Idstring = Idstring
local left_click = Idstring("0")
local left_arrow_btn = Idstring("left")
local right_arrow_btn = Idstring("right")

local callback = callback
local managers = managers
local M_mouse_pointer = managers.mouse_pointer
local gui_mouse = M_mouse_pointer._mouse
local pd2_medium_font = tweak_data.menu.pd2_medium_font

local ppr_config = ppr_config
local RunNewLoop = RunNewLoop

local MultiChoice = class()

local function index_from_value(self, val)
	for i, data in pairs( self.data ) do
		if data.value == val then
			return i
		end
	end
end

function MultiChoice:init( panel, button )
	self.panel = panel
	self.button = button
	self.data = button.multi_choice_data
	self.name = button.name
	self.callback = button.multi_callback
	local val = button.value
	if (not val) then
		--Or get value from function. This way comfortable for dynamic values
		local func = button.value_func
		if (func) then
			val = func()
		end
	end
	self.index = (--[[ ppr_config[ self.name ] and self:index_from_value() or]] val and index_from_value( self, val ) or button.index ) or 1
	
	self:create_gui()
	self.id = RunNewLoop( callback( self, self, "update" ) )
end

function MultiChoice:create_gui()
	local panel = self.panel
	
	local multi_choice = panel:panel( { name = "multi_choice", w = panel:w(), h = panel:h() } )
	
	local text_panel = multi_choice:text( { name = "text", layer = 1, wrap = "true", word_wrap = "true", visible = true,
										font = pd2_medium_font, font_size = 20, color = Color.Pro,
										align="left", halign="left", vertical="center", valign="center", blend_mode = "add" } )
	self.text_panel = text_panel
	
	local arrow_left = multi_choice:bitmap( { texture = "guis/textures/menu_arrows", texture_rect = {0,0,24,24}, color = Color.Pro, layer = 2 } )
	local arrow_right = multi_choice:bitmap( { texture = "guis/textures/menu_arrows", texture_rect = {0,0,24,24}, rotation = 180, color = Color.Pro, layer = 2 } )
	
	self.arrow_left = arrow_left
	self.arrow_right = arrow_right
	
	arrow_right:set_right( panel:w() )
	arrow_left:set_x( arrow_right:x() - 180 )
	
	self:set_text_index()
	
	text_panel:set_center_x( (( arrow_right:x() + arrow_left:x() ) / 2) + 10 )
end

function MultiChoice:set_text_index( index )
	index = index or self.index
	local text = self.data[ index ].text
	
	self:safe_set_text( text )
end

function MultiChoice:update()
	local arrow_left, arrow_right = self.arrow_left, self.arrow_right
	local x, y = gui_mouse:x(), gui_mouse:y()
	local left_moved = keyboard_pressed( keyboard, left_arrow_btn )
	local right_moved
	if ( not left_moved ) then
		right_moved = keyboard_pressed( keyboard, right_arrow_btn )
	end
	local clicked = mouse_pressed( mouse, left_click )
	local inside_panel = self.panel:inside(x,y)
	
	if arrow_left:inside( x, y ) then
		arrow_left:set_color( Color.Pro)
		if (clicked or left_moved) then
			self:previous_option()
		end
	else
		if (inside_panel and left_moved) then
			self:previous_option( x, y )
		end
		arrow_left:set_color( Color.Pro)
	end
	
	
	if arrow_right:inside( x, y ) then
		arrow_right:set_color( Color.Pro)
		if (clicked or right_moved) then
			self:next_option()
		end
	else
		if (inside_panel and right_moved) then
			self:next_option()
		end
		arrow_right:set_color( Color.Pro)
	end
end

function MultiChoice:previous_option()
	local data = self.data
	local new_index = self.index - 1	
	local index = ( new_index < 1 ) and #data or new_index
	
	self:change_option( index )
end

function MultiChoice:next_option()
	local data = self.data
	local new_index = self.index + 1
	local index = data[ new_index ] and new_index or 1
	
	self:change_option( index )
end

function MultiChoice:change_option( index )
	local data = self.data[ index ]
	
	self.index = index
	--ppr_config[ self.name ] = data.value
	local clbk = self.callback
	if (clbk) then
		clbk( self.name, data.value )
	end
	
	
	self:safe_set_text( data.text )
end

function MultiChoice:safe_set_text( text )
	local text_panel = self.text_panel
	
	text_panel:set_text( text or "" )
	local _,_,w,h = text_panel:text_rect() 
	text_panel:set_size( w, h )
	text_panel:set_center_x( (( self.arrow_right:x() + self.arrow_left:x() ) / 2) + 10 )
end

function MultiChoice:close()
	StopLoopIdent( self.id )
end

local G = getfenv(0)
G.MultiChoice = MultiChoice