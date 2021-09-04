--Menu component. Represents tickbox.
--Author: Simplity

local type = type

local togg_vars = togg_vars
local plugins = plugins
local required_plugins = plugins.required
local loaded = plugins.g_loaded

local Tickbox = class()

function Tickbox:init( panel, button, plugin_path )
	self.panel = panel
	self.button = button
	self.plugin_path = plugin_path
	
	self:create_gui()
end

function Tickbox:create_gui()
	local panel = self.panel
	
	self.tickbox = panel:bitmap( { name = "tickbox", texture = "guis/textures/menu_tickbox", layer = 2, texture_rect = { 0,0,24,24 }, w = 24, h = 24, color = Color.Free} )
	self.tickbox:set_right( panel:w() )
	
	self:toggle()
end

function Tickbox:toggle()
	local state = self:get_state()
	local tickbox = self.tickbox

	if state then
		tickbox:set_image( "guis/textures/menu_tickbox", 24, 0, 24, 24 )
	else
		tickbox:set_image( "guis/textures/menu_tickbox", 0, 0, 24, 24 )
	end
end

function Tickbox:get_state()
	local button = self.button
	
	local obj_toggle = button.toggle
	local toggle = type( obj_toggle )
	local plug = button.plugin
	if ( plug ) then
		local path = self.plugin_path
		if ( path ) then
			local real_name = required_plugins[path..plug]
			if ( real_name ) then
				return loaded( plugins, real_name )
			end
		end
	end
	if toggle ~= 'nil' then
		if toggle == "string" then
			return togg_vars[ obj_toggle ]
		elseif toggle == "function" then
			return obj_toggle()
		end
	end
	return false
end

local G = getfenv(0)
G.Tickbox = Tickbox