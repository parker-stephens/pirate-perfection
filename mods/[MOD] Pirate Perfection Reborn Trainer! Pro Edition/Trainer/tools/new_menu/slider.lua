--Menu component. Represents progress bar, that can be changed by user
--Author: Simplity

local mouse = Input:mouse()
local mouse_down = mouse.down
local Idstring = Idstring
local left_click = Idstring('0')
local right_click = Idstring('1')
local ceil = math.ceil

local managers = managers
local M_mouse_pointer = managers.mouse_pointer

local game_config = game_config
local togg_vars = togg_vars
local RunNewLoop = RunNewLoop
local callback = callback
local tweak_data = tweak_data
local button_stage_2 = tweak_data.screen_colors.button_stage_2
local pd2_small_font = tweak_data.menu.pd2_small_font
local plugins = plugins

local Slider = class()

function Slider:init( panel, button )
	local data = button.slider_data
	
	self.panel = panel
	self.button = button
	self.name = data.name
	self.max = data.max -- maximum value
	local name = self.name
	self.value = togg_vars[ name ] or data.value or 0 -- current value
	togg_vars[ name ] = self.value
	
	self:create_gui()
	self.id = RunNewLoop( callback( self, self, "update" ) )
end

function Slider:create_gui()
	local panel = self.panel
	
	local slider = panel:panel( { name = "slider", w = panel:w(), h = panel:h() } )
	self.slider = slider
	
	self.slider_bg = slider:rect( { name = "slider_bg", w = 0, h = slider:h(), color = Color.Pro:with_alpha( 0.6 ), layer = 1 } )
	
	self.slider_text = slider:text( { name = "slider_text", layer = 2, wrap = "true", word_wrap = "true", visible = true,
						  font = pd2_small_font, font_size = 15, color = Color.Pro,
						  align="left", halign="left", vertical="center", valign="center", blend_mode = "add" } )
	
	self:set_default_value()
	
	self.slider_text:set_left( slider:w() - 40 )
	self.slider_text:set_y( 5 )
end

function Slider:set_default_value()
	local where = ( self.value * 100 / self.max ) / 100
	self.slider_bg:set_w( self.slider:w() * where )
	self:safe_set_text( self.value )
end

function Slider:update()
	local M = M_mouse_pointer._mouse
	local x, y = M:x(), M:y()
	
	if self.slider:inside( x, y ) and ( ( not self.button.plugin and mouse_down( mouse, left_click ) ) or mouse_down( mouse, right_click ) ) then
		self:on_slider( x )
	end
end

function Slider:on_slider( x )
	local slider = self.slider
	local slider_bg = self.slider_bg
	
	local where = ( x - slider:world_left() ) / ( slider:world_right() - slider:world_left() )
	
	slider_bg:set_w( slider:w() * where )
	
	self.value = ceil( self.max * where )
	self:safe_set_text( self.value )
	
	self:do_callback()
end

function Slider:do_callback()	
	if self.button.plugin then
		self:callback_plugin()
	else
		self:callback_button()
	end
end

function Slider:callback_plugin()
	local callback_func = self.button.slider_callback
	
	if callback_func then
		callback_func( self.value )
	end
	
	togg_vars[ self.name ] = self.value -- save current value
	
	if game_config then
		game_config[ self.name ] = self.value
	end
end

function Slider:callback_button()
	togg_vars[ self.name ] = self.value
	
	if game_config then
		game_config[ self.name ] = self.value
	end
end

function Slider:safe_set_text( text )
	local slider_text = self.slider_text
	
	slider_text:set_text( text )
	local _,_,w,h = slider_text:text_rect() 
	slider_text:set_size( w, h )
end

function Slider:close()
	StopLoopIdent( self.id )
end

local G = getfenv(0)
G.Slider = Slider