--[[
	BLTCustomComponent

	This is a GUI component customized for common uses in BLT.
]]

BLTCustomComponent = BLTCustomComponent or blt_class(MenuGuiComponentGeneric)

local padding = 10
local large_font_size = tweak_data.menu.pd2_large_font_size
local large_font = tweak_data.menu.pd2_large_font

function BLTCustomComponent:init(ws, fullscreen_ws, node)
	self._ws = ws
	self._fullscreen_ws = fullscreen_ws
	self._fullscreen_panel = self._fullscreen_ws:panel():panel({})
	self._panel = self._ws:panel():panel({})
	self._init_layer = self._ws:panel():layer()
	self._data = node:parameters().menu_component_data or {}
	self:_setup()
end

function BLTCustomComponent:_setup()
	self._buttons = {}
	self._visible_buttons = {}

	if not self.no_back_button then
		self:_add_back_button()
	end

	self:setup()

	if self._scroll then
		self._scroll:update_canvas_size()
	end
	if self.last_y_position then
		self._scroll:scroll_to(self.last_y_position)
	end
	self:check_items()
end

--[[
	This should be overridden by subclasses, and is called during initialization
]]
function BLTCustomComponent:setup() end

--[[
	Trim the container so it perfectly fits the text?
]]
function BLTCustomComponent:make_fine_text(text)
	local x,y,w,h = text:text_rect()
	text:set_shape(math.round(text:x()), math.round(text:y()), w,h)
end

--[[
	Set this component up as a list (eg, the download manager)
]]
function BLTCustomComponent:make_into_listview(name, title, add_frame)
	self:make_background()
	self:make_title(title, add_frame and -12 or nil)

	local scroll_panel = self._panel:panel({
		name = name.."_scroll_panel",
		h = self._panel:h() - large_font_size * 2 - padding * 2,
		y = large_font_size,
	})

	if add_frame then
		BoxGuiObject:new(scroll_panel:panel({layer=100}), {sides = {1, 1, 1, 1}})
		BoxGuiObject:new(scroll_panel:panel({layer=100}), {sides = {1, 1, 2, 2}})
	end

	self._scroll = ScrollablePanel:new(scroll_panel, name, {})
end

--[[
	Set up this component's background panel
]]
function BLTCustomComponent:make_background(panel)
	panel = panel or self._fullscreen_panel
	self._background = panel:rect({
		name = "background",
		color = Color.black,
		alpha = 0.4,
		layer = -1
	})
	return self._background
end

--[[
	Create this component's title text
]]
function BLTCustomComponent:make_title(title, offset)
	local title = self._panel:text({
		name = "title",
		x = padding,
		y = padding + (offset or 0),
		font_size = large_font_size,
		font = large_font,
		layer = 10,
		blend_mode = "add",
		color = tweak_data.screen_colors.title,
		text = title,
		vertical = "top",
	})
	self:make_fine_text(title)
	return title
end

--[[
	Create a back button the same as those added by the old
	copied-and-pasted component code.

	Don't call this directly - rather, set it to override
	the vanilla _add_back_button:

	MyComponent._add_back_button = MyComponent._add_custom_back_button
]]
function BLTCustomComponent:_add_custom_back_button()
	local back_button = self._panel:text({
		name = "back_button",
		text = managers.localization:text("menu_back"),
		align = "right",
		vertical = "bottom",
		font_size = tweak_data.menu.pd2_large_font_size,
		font = tweak_data.menu.pd2_large_font,
		color = tweak_data.screen_colors.button_stage_3,
		layer = 40,
		blend_mode = "add"
	})
	self:make_fine_text( back_button )
	back_button:set_right( self._panel:w() - 10 )
	back_button:set_bottom( self._panel:h() - 10 )
	back_button:set_visible( managers.menu:is_pc_controller() )
	self._back_button = back_button

	local bg_back = self._fullscreen_panel:text({
		name = "back_button",
		text = utf8.to_upper( managers.localization:text("menu_back") ),
		h = 90,
		align = "right",
		vertical = "bottom",
		blend_mode = "add",
		font_size = tweak_data.menu.pd2_massive_font_size,
		font = tweak_data.menu.pd2_massive_font,
		color = tweak_data.screen_colors.button_stage_3,
		alpha = 0.4,
		layer = 1
	})
	local x, y = managers.gui_data:safe_to_full_16_9( back_button:world_right(), back_button:world_center_y() )
	bg_back:set_world_right( x )
	bg_back:set_world_center_y( y )
	bg_back:move( 13, -9 )
end

--[[
	Populate this component's '_visible_buttons' table.

	This is useful if you're trying to handle something like input
	events, which should only go to visible buttons.
]]
function BLTCustomComponent:check_items()
	self._visible_buttons = {}

	for _, button in pairs(self._buttons) do
		if not button.try_to_render or button:try_to_render() then
			table.insert(self._visible_buttons, button)
		end
	end
end

--[[
	Handle mouse pressed events
]]
function BLTCustomComponent:mouse_pressed(button, x, y)
	if managers.menu_scene and managers.menu_scene:input_focus() then
		return false
	end

	local result
	if alive(self._scroll) then
		result = self._scroll:mouse_pressed(button, x, y)
		if result then
			self:check_items()
			return true
		end
	end

	if button == Idstring("0") then
		local item = self._current_button
		if item then
			if item.mouse_pressed then
				item:mouse_pressed(button, x, y)
			elseif item:inside(x, y) then
				if self.on_item_pressed then
					self:on_item_pressed(item)
				end
				if item.parameters then
					local clbk = item:parameters().callback
					if clbk then
						clbk()
					end
				end
				return true
			end
		end
	end

	return result
end

--[[
	Handle mouse released events
]]
function BLTCustomComponent:mouse_released(o, x, y)
	if alive(self._scroll) then
		self._scroll:mouse_released(o, x, y)
	end
	self._used, self._pointer = nil, nil --not grabbing anything anymore.
end

--[[
	Close the component.

	TODO does this also discard the resources used by this component?
]]
function BLTCustomComponent:close()
	if self.on_close then
		self:on_close()
	end
	self._ws:panel():remove(self._panel)
	self._fullscreen_ws:panel():remove(self._fullscreen_panel)
end

--[[
	Handle mouse wheel up events
]]
function BLTCustomComponent:mouse_wheel_up(x, y)
	if alive(self._scroll) then
		self._scroll:scroll(x, y, 1)
		self:check_items()
	end
end

--[[
	Handle mouse wheel down events
]]
function BLTCustomComponent:mouse_wheel_down(x, y)
	if alive(self._scroll) then
		self._scroll:scroll(x, y, -1)
		self:check_items()
	end
end

--[[
	Handle the raw mouse moved events

	This checks if an update is necessary (I think this is called every frame) and
	if so, calls mouse_move
]]
function BLTCustomComponent:mouse_moved(o, x, y) --Don't run like an update function.
	if y == nil then --for some reason o is non existent at some cases.
		y = x
		x = o
	end

	local u,p = self._used, self._pointer -- if mouse didn't move, don't change pointer.
	if self._prev_x and self._prev_y then
		if self._prev_x ~= x or self._prev_y ~= y then
			u,p = self:mouse_move(o, x, y)
		end
	end

	self._used, self._pointer = u, p
	self._prev_x = x
	self._prev_y = y
	return u,p
end

--[[
	Handle the mouse actually being moved.

	This function is called from mouse_moved, not from within Diesel
]]
function BLTCustomComponent:mouse_move(o, x, y)
	local used, pointer = self:update_back_button_hover(o, x, y)
	self._current_button = nil

	if alive(self._scroll) and not used then
		used, pointer = self._scroll:mouse_moved(o, x, y)
		if pointer then
			self:check_items()
			return used, pointer --focusing on scroll no need to continue.
		end
	end

	local inside_scroll = not alive(self._scroll) or self._scroll:panel():inside(x, y)
	for _, item in pairs(self._visible_buttons) do
		if item.mouse_moved then
			item:mouse_moved(o, x, y)
		end
		if inside_scroll and (not used and item:inside(x, y)) then
			item:set_highlight(true)
			used, pointer = true, "link"
			self._current_button = item
		else
			item:set_highlight(false)
		end
	end

	return used, pointer
end
