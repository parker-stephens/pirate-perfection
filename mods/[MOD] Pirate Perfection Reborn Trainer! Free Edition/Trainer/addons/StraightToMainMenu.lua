------------
-- Purpose: Hooks MenuTitlescreenState:get_start_pressed_controller_index() to trigger the game to proceed straight to the main
--          menu with keyboard input instead of waiting on the attract screen, and also hooks
--          MenuTitlescreenState:_load_savegames_done() to suppress the menu entry sound that is played when the main menu is
--          entered (but only for automatic entries)
------------
local silenced = true
local get_start_pressed_controller_index_actual = MenuTitlescreenState.get_start_pressed_controller_index
function MenuTitlescreenState:get_start_pressed_controller_index(...)
	local num_connected = 0
	local keyboard_index = nil
	for index, controller in ipairs(self._controller_list) do
		if controller._was_connected then
			num_connected = num_connected + 1
		end
		if controller._default_controller_id == "keyboard" then
			keyboard_index = index
		end
	end
	if num_connected == 1 and keyboard_index ~= nil then
		silenced = true
		return keyboard_index
	else
		return get_start_pressed_controller_index_actual(self, ...)
	end
end
local _load_savegames_done_actual = MenuTitlescreenState._load_savegames_done
function MenuTitlescreenState:_load_savegames_done(...)
	if silenced then
		-- Shush. Don't play that sound if this is an automatic entry
		self:gsm():change_state_by_name("menu_main")
	else
		_load_savegames_done_actual(self, ...)
	end
end