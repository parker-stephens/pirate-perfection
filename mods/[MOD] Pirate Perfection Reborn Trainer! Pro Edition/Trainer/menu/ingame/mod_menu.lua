if ( not GameSetup ) then
	return
end

local ppr_require = ppr_require
ppr_require 'Trainer/tools/new_menu/menu'

local main_menu

local path = "Trainer/addons/mod_menu/"

local tr = Localization.translate

local function sw(t) --Shortened switch text check
	return t and tr['btn_off'] or tr['btn_on']
end

local Menu = Menu
local Menu_open = Menu.open

-- Menu

main_menu = function()
	local data = {
		{ text = tr['mod_noclip'], plugin = "noclip" },
		{ text = tr['mod_driver'], plugin = "driver", host_only = true },
		{ text = tr['mod_helicopter'], plugin = "helicopter", host_only = true },
		{ text = tr['mod_aimbot'], plugin = "aimbot" },
		{ text = tr['mod_lego'], callback = ppr_require("Trainer/menu/ingame/lego_menu"), host_only = true },
		{ text = tr['mod_pvp'], callback = function() ppr_require("Trainer/pvp/pvp.lua")() end },
		{ text = tr['mod_wavehouse'], plugin = "wavehouse", host_only = true },
		{ text = tr['mod_TerminatorHUD'], plugin = "TerminatorHUD" },		
	}
	
	Menu_open( Menu, { title = tr['mod_menu'], button_list = data, plugin_path = path } )
end

return main_menu