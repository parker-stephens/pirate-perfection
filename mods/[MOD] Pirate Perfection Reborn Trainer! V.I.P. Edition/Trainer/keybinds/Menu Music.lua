local insert = table.insert
local track_list = tweak_data.music.track_list
local localization = managers.localization
local tr = Localization.translate
local music_manager = Global.music_manager
local music_source = music_manager.source
local KB = KeyInput
local edit_key = KB.edit_key

local ppr_require = ppr_require
ppr_require 'Trainer/tools/new_menu/menu'

local Menu = Menu
local Menu_open = Menu.open

local cur_track_id = 1

local stop_music = function()
	music_source:stop()
end

local play_track = function( track, id )
	stop_music()
	music_source:post_event("music_heist_control")
	music_manager._current_track = track
	music_source:set_switch("music_randomizer", track)
	
	cur_track_id = id
end

local switch_track_next = function()
	local new_id = cur_track_id + 1
	if new_id > #track_list then
		new_id = 1
	end
	
	local next_track = track_list[new_id].track
	
	play_track( next_track, new_id )
end

local switch_track_prev = function()
	local new_id = cur_track_id - 1
	if new_id < 1 then
		new_id = #track_list
	end
	
	local prev_track = track_list[new_id].track
	
	play_track( prev_track, new_id )
end

local main_menu = function()
	edit_key(KB, ',', { callback = switch_track_prev })
	edit_key(KB, '.', { callback = switch_track_next })

	local data = {
		{ text = tr.music_menu_stop, callback = stop_music },
		{},
	}

	for id, track_data in pairs( track_list ) do
		insert( data, { text = localization:text("menu_jukebox_" .. track_data.track), callback = play_track, data = { track_data.track, id } } )
	end

	Menu_open(Menu, { title = tr.music_menu_title, button_list = data } )
end

return main_menu