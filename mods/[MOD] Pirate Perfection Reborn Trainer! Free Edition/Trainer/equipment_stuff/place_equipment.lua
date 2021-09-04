--Author: ThisJazzman & Simplity

if (not GameSetup) then
	return
end

local ppr_require = ppr_require
ppr_require('Trainer/tools/new_menu/menu')

--local strict = assert

local managers = managers
local M_localization = managers.localization
local locale_text = M_localization.text
local locale_exists = M_localization.exists

local tr = Localization.translate
local ppr_config = ppr_config
local bound_key = ppr_config.equipment_place_key or '4' --Key, to what placement of equipment will be bound

local tweak_data = tweak_data
local T_equipments = tweak_data.equipments
local tab_insert = table.insert
local G = getfenv(0)

local alive = alive

local GetPlayerUnit = GetPlayerUnit

local is_client = is_client
local pairs = pairs
local KeyInput = KeyInput
local edit_key = KeyInput and KeyInput.edit_key
local plugins = plugins
local plug_g_loaded = plugins.g_loaded
local plug_require = plugins.ppr_require

local open_menu
do
	local Menu = Menu
	local open = Menu.open
	open_menu = function( ... ) return open(Menu, ...) end
end

local place_equipment = function( use_function_name )
	local ply = GetPlayerUnit()
	if ( alive(ply) ) then
		local equipment = ply:equipment()
		equipment[ use_function_name ]( equipment )
	end
end

local switch_equipment = function( use_function_name )
	if ( edit_key ) then
		edit_key(KeyInput, bound_key, { callback = function() place_equipment( use_function_name ) end })
	end
end

local main = function()
	if ( alive( GetPlayerUnit() ) ) then
		if not plug_g_loaded( plugins, "long_placement") then
			plug_require( plugins, 'Trainer/equipment_stuff/long_placement', true)
		end
		
		local data = {}
			--{ text = 'Far Placements', plugin = 'long_placement', switch_back = true },
			--{},
		--}
		
		local locale_text = locale_text
		local locale_exists = locale_exists

		for id, eq_data in pairs( T_equipments ) do
			local text_id = eq_data.text_id
			if text_id and locale_exists(M_localization, text_id) then
				tab_insert( data,
					{
						text = locale_text(M_localization, text_id),
						callback = place_equipment,
						alt_callback = switch_equipment,
						data = { eq_data.use_function_name }
					})
			end
		end
		
		open_menu({ title = tr.equip_menu_title, description = tr.equip_warning .. "\n" .. tr.equip_desc .. " '" .. bound_key .."'", button_list = data })
	end
end

return main