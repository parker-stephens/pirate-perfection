
Hooks:Register( "BLTOnBuildOptions" )

-- Create the menu node for BLT mods
local function add_blt_mods_node( menu )

	local new_node = {
		_meta = "node",
		name = "blt_mods",
		back_callback = "perform_blt_save close_blt_mods",
		menu_components = "blt_mods",
		scene_state = "crew_management",
		[1] = {
			["_meta"] = "default_item",
			["name"] = "back"
		}
	}
	table.insert( menu, new_node )

	return new_node

end

-- Create the menu node for BLT mod options
local function add_blt_options_node( menu )

	local new_node = {
		_meta = "node",
		name = "blt_options",
		modifier = "BLTModOptionsInitiator",
		refresh = "BLTModOptionsInitiator",
		back_callback = "perform_blt_save",
		modifier = "BLTOptionsMenuCreator",
		[1] = {
			_meta = "legend",
			name = "menu_legend_select"
		},
		[2] = {
			_meta = "legend",
			name = "menu_legend_back"
		},
		[3] = {
			_meta = "default_item",
			name = "back"
		},
		[4] = {
			_meta = "item",
			name = "back",
			text_id = "menu_back",
			back = true,
			previous_node = true,
			visible_callback = "is_pc_controller"
		}
	}
	table.insert( menu, new_node )

	return new_node

end

-- Create the menu node for BLT mod keybinds
local function add_blt_keybinds_node( menu )

	local new_node = {
		_meta = "node",
		name = "blt_keybinds",
		back_callback = "perform_blt_save",
		modifier = "BLTKeybindMenuInitiator",
		refresh = "BLTKeybindMenuInitiator",
		[1] = {
			_meta = "legend",
			name = "menu_legend_select"
		},
		[2] = {
			_meta = "legend",
			name = "menu_legend_back"
		},
		[3] = {
			_meta = "default_item",
			name = "back"
		},
		[4] = {
			_meta = "item",
			name = "back",
			text_id = "menu_back",
			back = true,
			previous_node = true,
			visible_callback = "is_pc_controller"
		}
	}
	table.insert( menu, new_node )

	return new_node

end

-- Create the menu node for the download manager
local function add_blt_downloads_node( menu )

	local new_node = {
		_meta = "node",
		name = "blt_download_manager",
		menu_components = "blt_download_manager",
		back_callback = "close_blt_download_manager",
		scene_state = "crew_management",
		[1] = {
			_meta = "default_item",
			name = "back"
		}
	}
	table.insert( menu, new_node )

	return new_node

end

local function inject_menu_options( menu, node_name, injection_point, items )

	for _, node in ipairs( menu ) do
		if node.name == node_name then
			for i, item in ipairs( node ) do
				if item.name == injection_point then

					for k = #items, 1, -1 do
						table.insert( node, i + 1, items[k] )
					end

				end
			end
		end
	end

end

-- Add the menu nodes for various menus
Hooks:Add("CoreMenuData.LoadDataMenu", "BLT.CoreMenuData.LoadDataMenu", function( menu_id, menu )

	-- Create menu items
	local menu_item_divider = {
		_meta = "item",
		name = "blt_divider",
		type = "MenuItemDivider",
		no_text = true,
		size = 8,
	}

	local menu_item_options = {
		_meta = "item",
		name = "blt_options",
		text_id = "blt_options_menu_lua_mod_options",
		help_id = "blt_options_menu_lua_mod_options_desc",
		next_node = "blt_options",
	}

	local menu_item_mods = {
		_meta = "item",
		name = "blt_mods_new",
		text_id = "blt_options_menu_blt_mods",
		help_id = "blt_options_menu_blt_mods_desc",
		next_node = "blt_mods",
	}

	local menu_item_keybinds = {
		_meta = "item",
		name = "blt_keybinds",
		text_id = "blt_options_menu_keybinds",
		help_id = "blt_options_menu_keybinds_desc",
		visible_callback = "blt_show_keybinds_item",
		next_node = "blt_keybinds",
	}

	-- Inject menu nodes and items
	if menu_id == "start_menu" then

		add_blt_mods_node( menu )
		local options_node = add_blt_options_node( menu )
		Hooks:Call( "BLTOnBuildOptions", options_node ) -- All mods to hook into the options menu to add items
		add_blt_keybinds_node( menu )
		add_blt_downloads_node( menu )
		inject_menu_options( menu, "options", "quickplay_settings", {
			menu_item_divider,
			menu_item_mods,
			menu_item_options,
			menu_item_keybinds
		} )

	elseif menu_id == "pause_menu" then

		local options_node = add_blt_options_node( menu )
		Hooks:Call( "BLTOnBuildOptions", options_node ) -- All mods to hook into the options menu to add items
		add_blt_keybinds_node( menu )
		inject_menu_options( menu, "options", "ban_list", {
			menu_item_divider,
			menu_item_options,
			menu_item_keybinds
		} )

	end

end)

--------------------------------------------------------------------------------

BLTOptionsMenuCreator = BLTOptionsMenuCreator or class()
function BLTOptionsMenuCreator:modify_node( node )
	local old_items = node:items()

	local blt_languages
	for k, item in pairs(old_items) do
		if item:parameters().name == 'blt_localization_choose' then
			blt_languages = table.remove( old_items, k )
			break
		end
	end

	node:clean_items()

	if blt_languages then
		node:add_item(blt_languages)
	end

	table.sort(old_items, function(a, b)
		local text_a = managers.localization:text( a:parameters().text_id )
		local text_b = managers.localization:text( b:parameters().text_id )
		return text_a < text_b
	end)

	for _, item in pairs(old_items) do
		node:add_item(item)
	end

	return node
end