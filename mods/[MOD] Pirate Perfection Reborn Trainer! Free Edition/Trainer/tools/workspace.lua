--Purpose: Base for HUD extensions

ExGUIObject = ExGUIObject or class()

--In release it maybe commented
--ExGUIObject.__all_objects = ExGUIObject.__all_objects or {}

function ExGUIObject:init( ws )
	self.ws = ws
	self.panel = ws:panel():panel( { name = 'main' } )
	--table.insert(ExGUIObject.__all_objects, self)
	self.clbk_id = managers.viewport:add_resolution_changed_func( pro_callback( self, 'update_object', {self} ) )
end

--Called when resolution changed, override this in created object
function ExGUIObject.update_object()
end

function ExGUIObject:text( id, text, x, y, size, color, font, layer )
	local mod = self.panel:text( { name=id or " ", text=text or " ", --[[align="center", vertical="bottom",]] font_size= size or tweak_data.menu.pd2_small_font_size, font=font or tweak_data.menu.pd2_small_font, color=color or Color(1,1,1), layer=layer or 5, blend_mode="add", x = x or 0, y = y or 0 } )
	do
		local x,y,w,h = mod:text_rect()
		mod:set_size( w, h )
	end
	return mod
end

function ExGUIObject:destroy()
	self.ws:gui():destroy_workspace( self.ws )
	if self.mouse then
		self.mouse:destroy()
	end
end
-----------------------------------Mouse extension---------------------------------------------
local MouseEXT = class()

function MouseEXT:init()
	self.m = Input:mouse()
end

function MouseEXT:coords()
	local mouse = managers.mouse_pointer._mouse
	return mouse:x(), mouse:y()
end

function MouseEXT:clicked( btn )
	return self.m:pressed( btn:id() )
end

function MouseEXT:inside( obj )
	local x,y = self:coords()
	local w,h = obj:w(), obj:h()
	local x2,y2 = obj:x(), obj:y()
	return (x>=x2 and x <= x2+w) and (y>=y2 and y<=y2+h)
end

function MouseEXT:clicked_inside( btn, obj )
	return self:clicked( btn ) and self:inside( obj )
end

function MouseEXT.destroy()
end
-------------------------------------------------------------------------------------------------

function ExGUIObject:setup_mouse()
	self.mouse = MouseEXT:new()
end