--Author: JazzyDude
--Purpose: loads plugins from user folder and then creates menu with available options. Also it can open wrapped into plugin menu aswell.

local assert = assert
local ppr_require = ppr_require
ppr_require('Trainer/tools/new_menu/menu')

local PATH = 'Trainer/plugins/'

local pairs = pairs

local table = table
local tab_insert = table.insert

local plugins = plugins
local pre_require = plugins.pre_require

local Menu = Menu
local open_menu = Menu.open
local str_split = string.split
local io_popen = ppr_io.io_popen

local function scan_for_plugins()
	local list = io_popen("@echo OFF & cd Trainer/plugins & for /r %f in (*.lua) do echo %~nf"):read("*all")
	if ( list ~= "" ) then
		list = str_split(list, '\n')
		return list
	end
end

--Are we precached list already ?
local scanned_list = gScannedList
if ( not scanned_list ) then
	scanned_list = scan_for_plugins()
	gScannedList = scanned_list
end

local data = { { text = "Clear plugin cache", callback = function() gScannedList = nil end } }
plugin_menu = function()
	if ( scanned_list ) then
		local to_clean = {}
		local plist = plugins.plugins
		for _,key in pairs(scanned_list) do
			local real_name = pre_require( plugins, PATH..key )
			if ( real_name ) then
				local plug = plist[real_name]
				if ( plug.menu_data ) then
					tab_insert(data, { text = plug.full_name or plug.name, menu = true, callback = function() plug:open_menu() end })
				else
					tab_insert(data, { text = plug.full_name or plug.name, plugin = key, switch_back = true })
				end
			else
				to_clean[key] = true
			end
		end
		--Process to clean list
		for key in pairs(to_clean) do
			scanned_list[key] = nil
		end
	else
		data[1] =  { text = "No plugins found!", callback = function()end }
	end

	open_menu(Menu, { title = 'User plugins', button_list = data, plugin_path = PATH })
end

return plugin_menu