local ppr_require = ppr_require
local togg_vars = togg_vars
local in_table = in_table
local in_chat = in_chat
local open_file = ppr_io.open
local ray_pos = ray_pos
local get_ray = get_ray
local ppr_config = ppr_config
local show_hint = show_hint
local tostring = tostring
local Idstring = Idstring
local pairs = pairs
local loadstring = loadstring

ppr_require('Trainer/tools/new_menu/menu')

local delete_key = ppr_config.LegoDeleteKey or 'h'
--local id_delete = Idstring( delete_key )
local spawn_key = ppr_config.LegoSpawnKey or '6'
--local id_spawn = Idstring( spawn_key )
local switch_prev_key = ppr_config.LegoPrevKey or '7'
--local id_prev_key = Idstring(switch_prev_key)
local switch_next_key = ppr_config.LegoNextKey or '8'
--local id_next_key = Idstring(switch_next_key)

local io_popen = ppr_io.io_popen
local str_split = string.split
local find = string.find
local insert = table.insert
local gsub = string.gsub
local tr = Localization.translate
local Menu = Menu
local Menu_open = Menu.open
local World = World
local W_spawn_unit = World.spawn_unit
local W_delete_unit = World.delete_unit
local unit_on_map = unit_on_map

local main_menu, spawn_props_menu, delete_lego, place_lego, load_lego_file, lego_choose_file_menu, lego_create_menu, switch_unit_next, switch_unit_prev

local Lego_temp = {}
--[[
local kb = Input:keyboard()
local kb_pressed = kb.pressed
local function update()
	if kb_pressed( kb, id_delete ) then
		delete_lego()
	elseif kb_pressed( kb, id_spawn ) then
		place_lego(togg_vars.lego_unit_name)
	end
end
RunNewLoopIdent( 'update_lego', update )
]]
local switch_unit = function( unit_name, idx )
	togg_vars.lego_unit_name = unit_name
	togg_vars.lego_unit_idx = idx
end

local create_file = function( file_name )
	local file = open_file("Trainer/addons/lego/".. file_name ..".lua", 'w')
	file:close()
	
	main_menu()
end

local load_lego = function()
	local lego_array = load_lego_file()
	if (lego_array) then
		Lego_temp = {}
		for _, line in pairs( lego_array ) do
			W_spawn_unit( World, Idstring( line[1] ), line[2], line[3] )
			
			insert( Lego_temp, { line[1], tostring(line[2]), tostring(line[3]) } )
		end
		return true
	end
end

place_lego = function( unit_name )
	if ( unit_name ) then
		local pos, rot = ray_pos()
		if ( pos ) then
			local unit = W_spawn_unit( World, Idstring(unit_name), pos, rot )
			insert( Lego_temp, { unit_name, tostring(pos), tostring(rot) } )
		end
		return
	end
end

delete_lego = function()
	local ray = get_ray()
	
	if ray and ray.unit and ray.unit:network_sync() == "spawn" then
		local unit = ray.unit
		local pos = tostring( unit:position() )
		
		W_delete_unit( World, unit )
	
		for i, line in pairs( Lego_temp ) do
			if line[2] == pos then
				Lego_temp[i] = nil
				break
			end
		end
	end	
end

local lego_save = function()
	local file_name = ppr_config.LegoFile
	local file = open_file("Trainer/addons/lego/".. file_name ..".lua", 'w')
	
	for _, line in pairs( Lego_temp ) do
		file:write("{'" .. line[1] .. "'," .. line[2] .. "," .. line[3] .. "},\n")
	end
	
	file:close()
end

load_lego_file = function()
	local file_name = ppr_config.LegoFile
	local file = open_file("Trainer/addons/lego/".. file_name ..".lua", 'r')
	local l, err
	if file then
		local all = file:read('*all')
		file:close()
		local text = "return {" .. all .. "}"
		l, err = loadstring( text )
	end
	if not file or err then
		m_log_error('load_lego_file()', err)
		return false
	end
	return l()
end

local get_file_list = function()
	local list = io_popen("@echo OFF & cd Trainer/addons/lego & for /r %f in (*.lua) do echo %~nf"):read("*all")
	if ( list ~= "" ) then
		list = str_split(list, '\n')
		return list
	end
end

local add_favorite = function( unit_name )
	local file = open_file("Trainer/configs/favorites/props.txt", 'a')
	file:write( unit_name .. "\n" )
	file:close()
end

local delete_favorite = function( unit_name )
	local file_name = "Trainer/configs/favorites/props.txt"
		
	local text = ""
	for line in ppr_io.lines( file_name ) do
		if line ~= unit_name then
			text = text .. line .. "\n"
		end
	end
	
	local file = open_file( file_name, 'w' )
	file:write( text )
	file:close()
end

-- Menu

local fav_unit_menu = function( unit_name )
	local data = { 
		{ text = tr['bind_to_key'], callback = switch_unit, data = unit_name },
		{ text = tr['delete'], callback = delete_favorite, data = unit_name },
	}
	
	Menu_open( Menu, { title = tr['spawn_props_menu'], button_list = data, back = favorite_menu } )
end

local favorite_menu = function()
	local data = {}
	
	for line in ppr_io.lines("Trainer/configs/favorites/props.txt") do
		local _,_,_,prop_name = find(line, "(.+)/(.+)$")
		
		if unit_on_map( line ) then
			insert( data, { text = gsub(prop_name, "_", " "), callback = place_lego, alt_callback = function() fav_unit_menu( line ) end, data = line } )
		end
	end
	
	Menu_open( Menu, { title = tr['favorite_menu'], button_list = data, back = main_menu } )
end

lego_create_menu = function()
	local data = {
		{ text = tr['config_type'] ..":", type = "input", callback_input = create_file, switch_back = true },
	}
	
	Menu_open( Menu, { title = tr['lego_create'], button_list = data, back = main_menu } )
end

local unit_menu = function( unit_name, i )
	local data = { 
		{ text = tr['bind_to_key'], callback = switch_unit, data = { unit_name, i } },
		{ text = tr['add_favorite'], callback = add_favorite, data = unit_name },
	}
	
	Menu_open( Menu, { title = tr['spawn_props_menu'], button_list = data, back = spawn_props_menu } )
end

--Preloading props into table, so you won't have to do it every time you open menu
local prop_data = {}
do
	local PackageManager = PackageManager
	local all_loaded_unit_data = PackageManager.all_loaded_unit_data
	local get_unit_data = PackageManager.unit_data
	for _,unit_data in pairs( all_loaded_unit_data(PackageManager) )  do
		local unit_ids = unit_data:name()
		local unit_package_data = get_unit_data( PackageManager, unit_ids )
		local i = 0
		for spawn_node in unit_package_data:model_script_data():children() do
			local str_spawn_node = tostring( spawn_node )
			if find(str_spawn_node, "<sequence_manager file=") and not find(str_spawn_node, "characters") and unit_package_data:network_sync() == "spawn" then
				local _,_,spawn_unit_name = find(str_spawn_node, "<sequence_manager file=\"(.+)\"")
				local _,_,_,prop_name = find(spawn_unit_name,"(.+)/(.+)$")
				
				if Idstring( spawn_unit_name ) == unit_ids then
					i = i + 1
					insert(prop_data, { text = gsub(prop_name, "_", " "), callback = place_lego, alt_callback = function() unit_menu( spawn_unit_name, i ) end, data = { spawn_unit_name, i }, switch_back = true })
					break
				end
			end
		end
	end
end
local prop_menu_data = { title = tr['spawn_props_menu'], description = tr.equip_desc .. " '" .. spawn_key .."'", button_list = prop_data, back = main_menu }
local prop_data_size = #prop_data
spawn_props_menu = function()
	Menu_open( Menu, prop_menu_data )
end

switch_unit_next = function()
	local IDX = togg_vars.lego_unit_idx
	if ( IDX and IDX < prop_data_size ) then
		IDX = IDX + 1
		togg_vars.lego_unit_idx = IDX
		local tab = prop_data[IDX]
		togg_vars.lego_unit_name = tab.data[1]
		show_hint(tab.text)
	end
end

switch_unit_prev = function()
	local IDX = togg_vars.lego_unit_idx
	if ( IDX and IDX > 1 ) then
		IDX = IDX - 1
		togg_vars.lego_unit_idx = IDX
		local tab = prop_data[IDX]
		togg_vars.lego_unit_name = tab.data[1]
		show_hint(tab.text)
	end
end

do
	local KB = KeyInput
	local edit_key = KB.edit_key
	edit_key(KB, delete_key, { callback = delete_lego })
	edit_key(KB, spawn_key, { callback = function() place_lego(togg_vars.lego_unit_name) end })
	edit_key(KB, switch_prev_key, { callback = switch_unit_prev })
	edit_key(KB, switch_next_key, { callback = switch_unit_next })
end

lego_choose_file_menu = function()
	local data = {}
	local file_list = get_file_list()
	
	for _,name in pairs( file_list ) do
		insert( data, { text = name, callback = function() ppr_config.LegoFile = name end } )
	end
	
	Menu_open( Menu, { title = tr['lego_choose_file'], button_list = data, back = main_menu } )
end
local main_menu_data = { 
	{ text = tr['lego_choose_file'], callback = lego_choose_file_menu, menu = true  }, 
	{ text = tr['lego_create'], callback = lego_create_menu }, 
	{ text = tr['lego_load_file'], callback = load_lego }, 
	{ text = tr['save'], callback = lego_save }, 
	{},
	{ text = tr['favorite_menu'], callback = favorite_menu, menu = true  }, 
	{ text = tr['spawn_props_menu'], callback = spawn_props_menu, menu = true  }, 
}

main_menu = function()
	if ( not in_chat() ) then
		Menu_open( Menu,
			{ title = tr['lego_menu'],
				description = "Your current file - '".. ppr_config.LegoFile ..
				"'\nDelete props button - '" .. delete_key ..
				"'\nSpawn prop key - '" .. spawn_key ..
				"'\nSwitch prop to spawn - '" .. switch_prev_key .. "'/'" .. switch_next_key .. "'",
				button_list = main_menu_data
			}
		)
	end
end

return main_menu, load_lego