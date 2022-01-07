--Purpose: Tools for various
--Author: baldwin

ppr_require 'Trainer/tools/new_menu/menu'

local ppr_dofile = ppr_dofile
local managers = managers
local M_network = managers.network
local s = M_network:session()

local tr = Localization.translate

local Menu = Menu
local Menu_open = Menu.open

local main_menu

local force_start = function()
	M_network:session():spawn_players(true)
end

local force_ready = function(ready)
	local readyNum = ready and 1 or 0
	if not s then
		return
	end
	for _, peer in pairs(s._peers) do
		local peer_id = peer:id()
		s:on_set_member_ready(peer_id, ready, ready, false)
		s:send_to_peers( "set_member_ready", peer_id, readyNum, readyNum, "" )
	end
end

local path = "Trainer/addons/tools/"

main_menu = function()
	local contents = {
		{ text = tr.unlock_all_preplaning, callback = ppr_dofile, data = path .. 'allpreplaning'},
		{ text = tr.unlock_all_assets, callback = ppr_dofile, data = path .. 'all_assets'},
		{},
		{ text = tr.force_game_start, callback = force_start, host_only = true },
		{},
		{ text = tr.force_ready, callback = force_ready, data = true },
		{ text = tr.force_unready, callback = force_ready, data = false },
		{},
		{ text = tr.want_that_title, callback = ppr_dofile, data = path .. 'item_stealing_menu' },
		{ text = tr.sequencer_menu, callback = ppr_dofile, data = path .. 'sequence_menu', host_only = false },
		{},
		{ text = tr.spoof_detection_lvl, plugin = 'spoof_detection_lvl' },
	}
	
	Menu_open( Menu, { title = tr['tools_menu'], button_list = contents, plugin_path = path } )
end

return main_menu