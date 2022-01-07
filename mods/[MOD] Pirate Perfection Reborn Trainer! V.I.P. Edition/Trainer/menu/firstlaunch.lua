--Purpose: First launch greeting message.

local ppr_require = ppr_require
local backuper = backuper
local io_open = ppr_io.open
local tr = Localization.translate

local main = function()
	ppr_require 'Trainer/tools/new_menu/menu'

	if io_open('Trainer/configs/checks/First Launch.Check','rb') then
		return
	end

	local data = {
		--{ text = tr.btn_close, is_cancel_button = true }
	}

	Menu:open({ title = tr.welcome_title, description = tr.welcome_message, button_list = data, w_mul = 2.5, h_mul = 3.2 })

	--Menu:show()

	io_open('Trainer/configs/checks/First Launch.Check','w'):close()
end

backuper:add_clbk('MenuMainState.at_enter', main, 'first_time', 2)