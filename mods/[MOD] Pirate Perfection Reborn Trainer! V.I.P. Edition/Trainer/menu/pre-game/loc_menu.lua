--Purpose: allows user to update and download new translations
--Author: ThisJazzman

local ppr_require = ppr_require
ppr_require("Trainer/tools/new_menu/menu")

local Menu = Menu
local open_menu = Menu.open
local L = Localization
local Lchange_language = L.change_language
local tr = L.translate
local grab_list = L.grab_list
local download_translation = L.download_translation
local tr_text = L.text
local _err = m_log_error
local m_log_vs = m_log_vs
local tab_insert = table.insert
local rlist_files = rlist_files

local pairs = pairs
local function log( ... )
	m_log_vs("{loc_menu.lua}", ...)
end

local REQUESTED = false
local NEED_SHOWUP = false

local menu_data = false

local function on_update_language( id, ldata )
	if ( id ) then
		open_menu(Menu, {
			title = tr.loc_menu_success,
			description = tr.loc_menu_succ_desc,
			button_list = {
				{ text = tr.except_yes, callback = function()
						Lchange_language( L, id, true )
					end
				},
			}
		})
	else
		open_menu(Menu, { title = tr.loc_menu_fail,
				description = tr.loc_menu_fail,
				button_list = {}
			})
	end
end

local function update_language( id )
	download_translation( L, id, on_update_language )
end
--[[TO DO: Add abillity to just change language in Trainer
local function what_to_do( id )
	local data = {
		
	}
	open_menu(Menu, { title = tr.loc_menu_todo,
			description = tr.loc_menu_todo_desc,
			button_list = data
		})
	
end
]]
local function open_up_data( net_data )
	REQUESTED = false
	if ( NEED_SHOWUP ) then
		if ( menu_data ) then
			open_menu(Menu, menu_data)
			return
		elseif ( net_data ) then
			local data = {}
			for id, ldata in pairs( net_data ) do
				tab_insert(data, { text = ldata.l.." ("..ldata.l2..") v"..ldata.v, callback = update_language, data = id })
			end
			local my_language = net_data[L.lan]
			my_language = my_language and my_language.l2 or L.lan
			menu_data = { title = tr.loc_menu_title,
				description = tr_text(L, 'loc_menu_desc', my_language, tr.lan_version),
				button_list = data }
			open_menu(Menu, menu_data)
		else
			_err("{loc_menu.lua}", "failed to retrieve net_data")
		end
	end
end

local dl_menu_data = { title = tr.menu_wait, description = tr.loc_menu_wait_desc, button_list = {} }
local function dl_main()
	NEED_SHOWUP = true
	if ( not REQUESTED ) then --Don't repeat download request if it is put in here already!
		if ( menu_data ) then --Got menu data already, just open it
			return open_up_data()
		else
			local have_package = L.__net_data
			if ( have_package ) then --Languages list have been loaded, make menu data from that
				return open_up_data( have_package )
			else --Grab list
				grab_list(L, open_up_data)
				REQUESTED = true
			end
		end
	end
	local M = open_menu(Menu, dl_menu_data)
	M.close_clbks.on_loc_close = function() NEED_SHOWUP = false end --So when user will decide to close this dialog, available localizations dialog will not open
end

local lan_menu_blist = nil
local lan_menu_data = { title = tr.loc_menu, button_list = false }

local function change_loc( lang )
	Lchange_language( L, lang, true )
end

local browse_locs
browse_locs = function()
	if not lan_menu_blist then
		lan_menu_blist = {}
		tab_insert(lan_menu_blist, { text = tr.loc_menu_update_locals, callback = function()
					lan_menu_blist = nil
					browse_locs()
				end })
		
		local list = rlist_files("Trainer/translations/", "txt")
		if list then
			log("List:")
			for _,name in pairs(list) do
				log(name)
				tab_insert(lan_menu_blist, { text = name, callback = change_loc, data = name })
			end
		else
			_err("in {loc_menu.lua}", "No languages found!!!")
			tab_insert(lan_menu_blist, { text = tr.loc_menu_no_locals, callback = function()end})
		end
		lan_menu_data.button_list = lan_menu_blist
	end
	open_menu(Menu, lan_menu_data)
end

local main_menu_data = { title = tr.loc_menu, description = '', button_list = {
		{ text = tr.loc_menu_choose_local, callback = browse_locs, menu = true },
		{ text = tr.loc_menu_choose_remote, callback = dl_main, menu = true },
	}
}
local function main()
	--TO DO:
	--Menu got split:
	--	Menu, where user can go through available translations
	--	Menu, where user can download translation
	--ETA: Mostly done, testing for bugs
	open_menu(Menu, main_menu_data)
end
return main