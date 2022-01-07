--Purpose: configuration menu
--Authors: Simplity - idea, lua stub and logic. JazzyDude - finishing and fixing

--TO DO:
--Improve text_input.lua
--Better "OnTextEntered" event handling
--Move more scripts into plugins

local ppr_require = ppr_require
ppr_require 'Trainer/tools/new_menu/menu'

local Menu = Menu
local Menu_open = Menu.open
local tr = Localization.translate
local io_open = ppr_io.open
local str_split = string.split
local rlist_files=rlist_files
local insert = table.insert
local show_hint = show_hint
local ppr_dofile = ppr_dofile
local pairs = pairs
local gm = getmetatable
local plugins = plugins
local ppr_config = ppr_config
local os_remove = os.remove
local os_rename = os.rename

local main_menu, create_config_menu, load_config_menu, are_you_sure, delete_config_menu, rename_config_menu, rename_config_input, reload_ppr_config, save_settings_create_config, _save_settings_create_config

local create_config = function( name, clbk )
	local path = "Trainer/configs/"..name..".lua"
	fh = io_open(path, "r")
	if ( fh ) then
		fh:close()
		return are_you_sure( path, name, clbk )
	end
	--Write stub
	fh = io_open(path, "w")
	fh:write("return function(cfg) return\n")
	fh:close()
	main_menu()
	return path
end

local load_config = function( name )
	plugins:unload_except_by_cat("no_reload", true) --normalizer
	ppr_config.DefaultConfig = name
	ppr_dofile('Trainer/Setup/auto_config')
	
	show_hint("Config loaded")
end

local delete_config = function( name )
	os_remove("Trainer/configs/"..name..".lua")
	
	if ppr_config.DefaultConfig == name then
		ppr_config.DefaultConfig = "default_config"
		ppr_config()
	end
end

local rename_config = function( name, new_name )
	local old_loc = "Trainer/configs/"..name..".lua"
	local new_loc = "Trainer/configs/"..new_name..".lua"
	os_rename(old_loc, new_loc)
	
	if ppr_config.DefaultConfig == name then
		ppr_config.DefaultConfig = new_name
		game_config.auto_config = new_loc
	end
	
	main_menu()
end

local save_settings = function()	
	game_config() -- reload config
end

local get_configs_list = function()
	return rlist_files( "Trainer/configs", "lua" )
	--local list = io_popen("@echo OFF & cd Trainer/configs & for /r %f in (*.lua) do echo %~nf"):read("*all")
	--if ( list ~= "" ) then
	--	list = str_split(list, '\n')
	--	return list
	--end
end

-- Menu

are_you_sure = function(p, name, clbk)
	local data = {
		{ text = tr.except_yes, callback = function()
				os_remove(p)
				if (clbk) then
					clbk( name )
				else
					create_config(name)
				end
			end },
		{ text = tr.except_no, callback = main_menu }
	}
	Menu_open( Menu, { title = tr.except_title_warn, description = tr.config_are_you_sure, button_list = data })
end

do
	local data = {
		{ text = tr['config_type'] ..":", type = "input", callback_input = create_config, switch_back = true },
	}
	create_config_menu = function()
		Menu_open( Menu, { title = tr['config_create'], button_list = data, back = main_menu } )
	end
end

load_config_menu = function()
	local data = {}
	
	local configs_list = get_configs_list()
	for _, name in pairs( configs_list ) do
		if name ~= "blank" then
			insert( data, { text = tr['load'] .. " - '".. name .."'", callback = load_config, data = name } )
		end
	end
	
	Menu_open( Menu, { title = tr['config_load'], button_list = data, back = main_menu } )
end

rename_config_input = function( name )
	local data = {
		{ text = tr['config_type'] ..":", type = "input", callback_input = function( new_name ) rename_config( name, new_name ) end, switch_back = true },
	}
	
	Menu_open( Menu, { title = tr['config_rename'], button_list = data, back = rename_config_menu } )
end

rename_config_menu = function()
	local data = {}
	
	local configs_list = get_configs_list()
	if ( configs_list ) then
		for _, name in pairs( configs_list ) do
			if name ~= "default_config" and name ~= "blank"  then
				insert( data, { text = tr['rename'] .. " - '".. name .."'", callback = rename_config_input, data = name, menu = true } )
			end
		end
	end
	
	if #data == 0 then
		insert( data, { text = tr['config_empty'] } )
	end
	
	Menu_open( Menu, { title = tr['config_rename'], button_list = data, back = main_menu } )
end

delete_config_menu = function()
	local data = {}
	
	local configs_list = get_configs_list()
	for _, name in pairs( configs_list ) do
		if name ~= "default_config" and name ~= "blank" then
			insert( data, { text = tr['delete'] .. " - '".. name .."'", callback = delete_config, data = name } )
		end
	end
	
	if #data == 0 then
		insert( data, { text = tr['config_empty'] } )
	end
	
	Menu_open( Menu, { title = tr['config_delete'], button_list = data, back = main_menu } )
end

_save_settings_create_config = function( name )
	local mepath = create_config( name, _save_settings_create_config )
	if (mepath) then
		local C = game_config
		C.auto_config = mepath
		C() --Apply new changes
		ppr_config.DefaultConfig = name
		--load_config( name )
	end
end

do
	local data = {
		{ text = tr['config_type'] ..":", type = "input", callback_input = _save_settings_create_config, switch_back = true },
	}
	save_settings_create_config = function()
		Menu_open( Menu, { title = tr['config_create'], button_list = data, back = main_menu } )
	end
end

reload_ppr_config = function()
	ppr_config()
end

local main_menu_data = {
	--TO DO: Improve menu class or create link between these 2, so user can press return and return to this menu.
	{ text = tr['wp_title'], callback = ppr_require("Trainer/menu/waypoints_settings"), menu = true },
	{},
	{ text = tr['loc_menu'], callback = ppr_require("Trainer/menu/pre-game/loc_menu"), menu = true },
	{},
	{ text = tr['config_create'], callback = create_config_menu, menu = true },
	{ text = tr['config_rename'], callback = rename_config_menu, menu = true },
	{ text = tr['config_delete'], callback = delete_config_menu, menu = true },
	{ text = tr['config_load'], callback = load_config_menu, menu = true },
	{},
	{ text = tr['config_save_into_new'], callback = save_settings_create_config, menu = true },
	{ text = tr['config_save_all'], callback = save_settings },
	{ text = tr['config_save_default'], callback = reload_ppr_config },
}

main_menu = function()
	Menu_open( Menu, { title = tr['config_menu'], description = tr['config_current']..': '..ppr_config.DefaultConfig, button_list = main_menu_data } )
end

return main_menu
