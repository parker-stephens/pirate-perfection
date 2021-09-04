
BLT:Require("req/ui/BLTUIControls")
BLT:Require("req/ui/BLTModItem")
BLT:Require("req/ui/BLTViewModGui")

BLTModsGui = BLTModsGui or blt_class( MenuGuiComponentGeneric )
BLTModsGui.last_y_position = 0
BLTModsGui.show_libraries = false
BLTModsGui.show_mod_icons = true

local padding = 10

local massive_font = tweak_data.menu.pd2_massive_font
local large_font = tweak_data.menu.pd2_large_font
local medium_font = tweak_data.menu.pd2_medium_font
local small_font = tweak_data.menu.pd2_small_font

local massive_font_size = tweak_data.menu.pd2_massive_font_size
local large_font_size = tweak_data.menu.pd2_large_font_size
local medium_font_size = tweak_data.menu.pd2_medium_font_size
local small_font_size = tweak_data.menu.pd2_small_font_size

local function make_fine_text( text )
	local x,y,w,h = text:text_rect()
	text:set_size( w, h )
	text:set_position( math.round( text:x() ), math.round( text:y() ) )
end

local function make_fine_text_aligning(text)
	-- Make fine text, but use the text rect X and Y in set_position
	local x,y,w,h = text:text_rect()
	text:set_size(w, h)
	text:set_position(math.round(x), math.round(y))
end

function BLTModsGui:init( ws, fullscreen_ws, node )

	self._ws = ws
	self._fullscreen_ws = fullscreen_ws
	self._fullscreen_panel = self._fullscreen_ws:panel():panel({})
	self._panel = self._ws:panel():panel({})
	self._init_layer = self._ws:panel():layer()

	self._data = node:parameters().menu_component_data or {}
	self._buttons = {}
	self._custom_buttons = {}

	self:_setup()

end

function BLTModsGui:close()
	BLTModsGui.last_y_position = self._scroll:canvas():y() * -1
	self._ws:panel():remove( self._panel )
	self._fullscreen_ws:panel():remove( self._fullscreen_panel )
end

function BLTModsGui:_setup()

	-- Background
	self._background = self._fullscreen_panel:rect({
		color = Color.black,
		alpha = 0.4,
		layer = -1
	})

	-- Back button
	local back_button = self._panel:text({
		name = "back",
		text = managers.localization:text("menu_back"),
		align = "right",
		vertical = "bottom",
		font_size = tweak_data.menu.pd2_large_font_size,
		font = tweak_data.menu.pd2_large_font,
		color = tweak_data.screen_colors.button_stage_3,
		layer = 40,
		blend_mode = "add"
	})
	make_fine_text( back_button )
	back_button:set_right( self._panel:w() - 10 )
	back_button:set_bottom( self._panel:h() - 10 )
	back_button:set_visible( managers.menu:is_pc_controller() )
	self._back_button = back_button
	self._custom_buttons[back_button] = {
		clbk = function()
			managers.menu:back()
			return true
		end
	}

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
	local x, y = managers.gui_data:safe_to_full_16_9( self._panel:child("back"):world_right(), self._panel:child("back"):world_center_y() )
	bg_back:set_world_right( x )
	bg_back:set_world_center_y( y )
	bg_back:move( 13, -9 )

	-- Title
	local title = self._panel:text({
		name = "title",
		x = padding,
		y = padding,
		font_size = large_font_size,
		font = large_font,
		h = large_font_size,
		layer = 10,
		blend_mode = "add",
		color = tweak_data.screen_colors.title,
		text = "Installed Mods",
		align = "left",
		vertical = "top",
	})

	-- Toggle libraries visible button
	local padding = 10
	local params = {
		x = padding,
		y = padding,
		width = self._panel:w() - padding*2,
		height = large_font_size,

		color = tweak_data.screen_colors.button_stage_3,

		font = tweak_data.menu.pd2_small_font,
		font_size = tweak_data.menu.pd2_small_font_size,
		vertical = "bottom",
		align = "right",
	}

	local function customize(changes)
		return table.map_append(table.map_copy(params), changes)
	end

	-- Count the number of libraries installed
	local libs_count = 0
	for i, mod in ipairs( BLT.Mods:Mods() ) do
		if mod:IsLibrary() then
			libs_count = libs_count + 1
		end
	end

	-- Add the libraries label
	local libraries_text = self._panel:text(customize({
		text = managers.localization:to_upper_text("blt_libraries", {count=libs_count}),
		color = tweak_data.screen_colors.text,
	}))

	-- Shift the show and hide buttons to the left of the libraries label
	make_fine_text_aligning(libraries_text)
	params.width = libraries_text:x() - params.x - 4 -- 4px padding

	self._libraries_show_button = self._panel:text(customize({
		text = managers.localization:to_upper_text("menu_button_show"),
	}))

	self._libraries_hide_button = self._panel:text(customize({
		text = managers.localization:to_upper_text("menu_button_hide"),
	}))

	make_fine_text_aligning(self._libraries_show_button)
	make_fine_text_aligning(self._libraries_hide_button)

	self._custom_buttons[self._libraries_show_button] = {
		clbk = function()
			BLTModsGui.show_libraries = true
			self:update_visible_mods()
			return true
		end,
	}
	self._custom_buttons[self._libraries_hide_button] = {
		clbk = function()
			BLTModsGui.show_libraries = false
			self:update_visible_mods()
			return true
		end,
	}

	-- Set up the toggle icons button
	params.width = self._panel:w() - padding*2
	params.height = params.height - small_font_size

	local icons_text = self._panel:text(customize({
		text = managers.localization:to_upper_text("blt_mod_icons"),
		color = tweak_data.screen_colors.text,
	}))

	-- Shift the show and hide buttons to the left of the label
	make_fine_text_aligning(icons_text)
	params.width = icons_text:x() - params.x - 4 -- 4px padding

	self._mod_icons_show_button = self._panel:text(customize({
		text = managers.localization:to_upper_text("menu_button_show"),
	}))

	self._mod_icons_hide_button = self._panel:text(customize({
		text = managers.localization:to_upper_text("menu_button_hide"),
	}))

	make_fine_text_aligning(self._mod_icons_show_button)
	make_fine_text_aligning(self._mod_icons_hide_button)

	self._custom_buttons[self._mod_icons_show_button] = {
		clbk = function()
			BLTModsGui.show_mod_icons = true
			self:update_visible_mods()
			return true
		end,
	}
	self._custom_buttons[self._mod_icons_hide_button] = {
		clbk = function()
			BLTModsGui.show_mod_icons = false
			self:update_visible_mods()
			return true
		end,
	}

	-- Mods scroller
	local scroll_panel = self._panel:panel({
		h = self._panel:h() - large_font_size * 2 - padding * 2,
		y = large_font_size,
	})
	self._scroll = ScrollablePanel:new( scroll_panel, "mods_scroll", {} )

	self:update_visible_mods(BLTModsGui.last_y_position)

end

function BLTModsGui:update_visible_mods(scroll_position)
	-- Update the show libraries and mod icons button
	self._libraries_show_button:set_visible(not BLTModsGui.show_libraries)
	self._libraries_hide_button:set_visible(BLTModsGui.show_libraries)

	self._mod_icons_show_button:set_visible(not BLTModsGui.show_mod_icons)
	self._mod_icons_hide_button:set_visible(BLTModsGui.show_mod_icons)

	-- Save the position of the scroll panel
	BLTModsGui.last_y_position = scroll_position or self._scroll:canvas():y() * -1

	-- Clear the scroll panel
	self._scroll:canvas():clear()
	self._scroll:update_canvas_size() -- Ensure the canvas always starts at it's maximum size
	self._buttons = {}

	-- Create download manager button
	local title_text = managers.localization:text("blt_download_manager")
	local downloads_count = table.size( BLT.Downloads:pending_downloads() )
	if downloads_count > 0 then
		title_text = title_text .. " (" .. managers.experience:cash_string(downloads_count, "") .. ")"
	end

	local icon, rect = tweak_data.hud_icons:get_icon_data( "csb_pagers" )
	local button = BLTUIButton:new( self._scroll:canvas(), {
		x = 0,
		y = 0,
		w = (self._scroll:canvas():w() - (BLTModItem.layout.x + 1) * padding) / BLTModItem.layout.x,
		h = 256 + (BLTModsGui.show_mod_icons and 0 or padding),
		title = title_text,
		text = managers.localization:text("blt_download_manager_help"),
		image = icon,
		image_size = 108,
		texture_rect = rect,
		callback = callback( self, self, "clbk_open_download_manager" )
	} )
	table.insert( self._buttons, button )

	-- Create mod boxes
	for _, mod in ipairs( BLT.Mods:Mods() ) do
		if BLTModsGui.show_libraries or not mod:IsLibrary() then
			local i = #self._buttons + 1

			-- Wrap mods around the download button, if mod icons are disabled
			if i >= 5 and not BLTModsGui.show_mod_icons then
				i = i + 1
			end

			local item = BLTModItem:new( self._scroll:canvas(), i, mod, BLTModsGui.show_mod_icons )
			table.insert( self._buttons, item )
		end
	end

	-- Update scroll size
	self._scroll:update_canvas_size()

	self._scroll:scroll_to(BLTModsGui.last_y_position)

end

function BLTModsGui:inspecting_mod()
	return self._inspecting
end

function BLTModsGui:clbk_open_download_manager()
	managers.menu:open_node( "blt_download_manager" )
end

--------------------------------------------------------------------------------

function BLTModsGui:mouse_moved( button, x, y )

	if managers.menu_scene and managers.menu_scene:input_focus() then
		return false
	end

	local used, pointer

	for button, data in pairs(self._custom_buttons) do
		if alive(button) and button:visible() then
			if button:inside(x, y) then
				local colour = data.selected_colour or tweak_data.screen_colors.button_stage_2
				if button:color() ~= colour then
					button:set_color(colour)
					managers.menu_component:post_event("highlight")
				end
				used, pointer = true, "link"
				break
			else
				button:set_color(data.deselected_colour or tweak_data.screen_colors.button_stage_3)
			end
		end
	end

	local inside_scroll = alive(self._scroll) and self._scroll:panel():inside( x, y )
	for _, item in ipairs( self._buttons ) do
		if not used and item:inside( x, y ) and inside_scroll then
			item:set_highlight( true )
			used, pointer = true, "link"
		else
			item:set_highlight( false )
		end
	end

	if alive(self._scroll) and not used then
		used, pointer = self._scroll:mouse_moved( button, x, y )
	end

	return used, pointer

end

function BLTModsGui:mouse_clicked( o, button, x, y )

	if managers.menu_scene and managers.menu_scene:input_focus() then
		return false
	end

	if alive(self._scroll) then
		return self._scroll:mouse_clicked( o, button, x, y )
	end

end

function BLTModsGui:mouse_pressed( button, x, y )

	if managers.menu_scene and managers.menu_scene:input_focus() then
		return false
	end

	local result
	if alive(self._scroll) then
		result = self._scroll:mouse_pressed( button, x, y )
	end

	if button == Idstring( "0" ) then

		for button, data in pairs(self._custom_buttons) do
			if alive(button) and button:visible() and button:inside(x, y) then
				return data.clbk()
			end
		end

		if alive(self._scroll) and self._scroll:panel():inside( x, y ) then

			for _, item in ipairs( self._buttons ) do
				if item:inside( x, y ) then

					if item.mod then
						self._inspecting = item:mod()
						managers.menu:open_node( "view_blt_mod" )
						managers.menu_component:post_event( "menu_enter" )
					elseif item.parameters then
						local clbk = item:parameters().callback
						if clbk then
							clbk()
						end
					end

					return true
				end
			end

		end

	end

	return result

end

function BLTModsGui:mouse_released( button, x, y )

	if managers.menu_scene and managers.menu_scene:input_focus() then
		return false
	end

	if alive(self._scroll) then
		return self._scroll:mouse_released( button, x, y )
	end

end

function BLTModsGui:mouse_wheel_up( x, y )
	if alive(self._scroll) then
		self._scroll:scroll( x, y, 1 )
	end
end

function BLTModsGui:mouse_wheel_down( x, y )
	if alive(self._scroll) then
		self._scroll:scroll( x, y, -1 )
	end
end

-- Load and save settings from savefile
local function load_data(cache)
	local data = cache.mods_gui
	if data then
		BLTModsGui.show_libraries = data.show_libraries
		BLTModsGui.show_mod_icons = data.show_mod_icons
		log("Loading mod settings : " .. tostring(cache.show_libraries))
	end
end
Hooks:Add("BLTOnLoadData", "BLTOnLoadData.BLTModsGui", load_data)

-- If the data has already been loaded, use it now
if BLT.Mods._saved_data then
	load_data(BLT.Mods._saved_data)
end

Hooks:Add("BLTOnSaveData", "BLTOnSaveData.BLTModsGui", function(cache)
	cache.mods_gui = {
		show_libraries = BLTModsGui.show_libraries,
		show_mod_icons = BLTModsGui.show_mod_icons,
	}
end)

--------------------------------------------------------------------------------
-- Patch MenuComponentManager to create the BLT Mods component

MenuHelper:AddComponent("blt_mods", BLTModsGui)
