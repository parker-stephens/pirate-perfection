--Menu component. Represents button with text in the middle
--Author: Simplity

local SaveButton = class()

local togg_vars = togg_vars

function SaveButton:init( panel, button )
	self.button = button
	
	local text = panel:child( "text" )
	text:set_x( ( panel:w() / 2 ) - 10 )
	panel:set_y( panel:y() + 3 )
end

function SaveButton:save()
	local button = self.button
	local callback = button.callback
	local name = button.name
	local value = togg_vars[ name ]
	
	if callback and value then
		callback( value )
	end
end

local G = getfenv(0)
G.SaveButton = SaveButton