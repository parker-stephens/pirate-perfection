-- Spoof your name
-- Author: ???

local ppr_require = ppr_require
ppr_require 'Trainer/tools/new_menu/menu'

local pairs = pairs
local ipairs = ipairs
local io_open = ppr_io.open
local tab_insert = table.insert
local change_name,spoof_menu,open_name_menu,table_names
local data_names
local tr = Localization.translate
local togg_vars = togg_vars
local Menu = Menu
local Menu_open = Menu.open
local spoof_menu

-- Function
change_name = function(name)
	Global.spoofed_name = name
	ppr_require 'Trainer/addons/namespoof'
	ppr_config.NameSpoof = name
end

-- Menu
open_name_menu = function(id, translation)
	Menu_open(Menu, { title = tr['spoof_menu'], button_list = data_names[id] } )
end

spoof_menu = function()
	data_names = { [1] = {}, [2] = {}, [3] = {}, [4] = {}, [5] = {}, }
	local data = { 
		{ text = Localization.translate['spoof_standard_names'], callback = function() open_name_menu(1, "spoof_standard_names") end },
		{ text = Localization.translate['spoof_pirates_names'], callback = function() open_name_menu(2, "spoof_pirates_names") end },
		{ text = Localization.translate['spoof_donors_names'], callback = function() open_name_menu(3, "spoof_donors_names") end },
		{ text = Localization.translate['spoof_patrons_names'], callback = function() open_name_menu(4, "spoof_patrons_names") end },
		{ text = Localization.translate['spoof_developer_names'], callback = function() open_name_menu(5, "spoof_developer_names") end },
	}
	
	for line in ppr_io.lines("Trainer/other/names.txt") do 
		table_names = (line == "--Standard") and 1 or (line == "--Pirates") and 2 or (line == "--Donors") and 3 or (line == "--Patrons") and 4 or (line == "--Developer") and 5 or table_names

		if not string.find(line, "^(%-%-)") then
			table.insert(data_names[table_names], { text = line, callback = change_name, data = line })
		end
	end
	table.insert(data_names[1], 1, { text = "Anti-kicky", callback = change_name, data = "" })
	
	Menu_open(Menu,  { title = tr['spoof_menu'], button_list = data } )
end

return spoof_menu