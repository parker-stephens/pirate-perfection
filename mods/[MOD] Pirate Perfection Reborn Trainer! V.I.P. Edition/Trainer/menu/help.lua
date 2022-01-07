local ppr_require = ppr_require
local setmetatable = setmetatable

ppr_require 'Trainer/tools/new_menu/menu'

local KeyInput = KeyInput
local tr = Localization.translate
local open_menu
do
	local Menu = Menu
	local open = Menu.open
	open_menu = function( ... )
		return open(Menu, ...)
	end
end
local Steam = Steam
local overlay_activate = Steam.overlay_activate

local main,credits,keybinds,cheatertag

main = function()
	local fn = KeyInput.filenames
	setmetatable(fn, {__index = function() return tr['help_nokey'] end})
	local border0 = ""
	local border1 = "«¡--------- These Keybinds Work Both Main-Menu & In-Game ---------¡»"
	local border2 = "«|--------------- These Keybinds Work Only In-Game ---------------|»"
	local border3 = "«!----------------------------------------------------------------!»"
	local spacer = "  =  "
	open_menu(
		{
			title = tr.help_title,
			description =	tr['help_desc'].."\n"..
							--tr['help_bound']..":\n"..
							--fn['help']..spacer..tr['help_title_t'].."\n"..
							--fn['config_menu']..spacer..tr['config_menu'].."\n"..
							--fn['main_menu-charmenu']..spacer..tr['main_menu_title'].." / "..tr['char_menu'].."\n"..
							--fn['jobmenu-stealthmenu']..spacer..tr['job_menu_title'].." / "..tr['stealth_menu'].."\n"..
							--fn['spoof_name-troll_menu']..spacer..tr['spoof_menu'].." / "..tr['troll_menu'].."\n"..
							--fn['tools']..spacer..tr['tools_menu'].."\n"..
							--fn['music_menu']..spacer..tr['music_menu_title'].."\n"..
							--fn['normalizer']..spacer..tr['Normalizer'].."\n"..
							--fn['interactions']..spacer..tr['intm_title'].."\n"..
							--fn['missionmenu']..spacer..tr['mission_menu_title'].."\n"..
							--fn['inventory_menu']..spacer..tr['inventory_menu'].."\n"..
							--fn['equipment_menu']..spacer..tr['equip_menu_title'].."\n"..
							--fn['weaponlistmenu']..spacer..tr['weapon_menu_title'].."\n"..
							--fn['mod_menu']..spacer..tr['mod_menu'].."\n"..
							--fn['spawn_menu']..spacer..tr['spawn_menu'].."\n"..
							--fn['carrystacker']..spacer..tr['help_carrystacker'].."\n"..
							--fn['instant_win']..spacer..tr['help_instant_win'].."\n"..
							--fn['xray']..spacer..tr['base_xray_sub'].."\n"..
							--fn['replenish']..spacer..tr['help_replenish'].."\n"..
							--fn['place_equipment']..spacer..tr['base_far_placements'].."\n"..
							--fn['teleport']..spacer..tr['help_teleport'].."\n"..
							--fn['slowmotion']..spacer..tr['base_slow_sub'].."\n"..
							--fn['user_script']..spacer..tr['help_user_script'].."\n"..
							border0,
			button_list =	{	{ text = tr.help_keybinds, callback = keybinds },
								{ text = tr.help_cheatertag, callback = cheatertag },
								{ text = tr.help_credits, callback = credits },
								{ text = tr.help_site, callback = overlay_activate, data = { Steam, "url",'https://pirateperfection.com' }},
							},
			w_mul = 2.3,
			h_mul = 3.4
		}
	)
end
keybinds = function()
	local data =	{	{ text = tr.back, callback = main },
						{ text = tr.prev_page, callback = credits },
						{ text = tr.next_page, callback = cheatertag },
						--{ text = tr.btn_close }
					}
	open_menu({ title = tr.help_keybinds, description = tr.help_keybinds_desc, button_list = data, w_mul = 2, h_mul = 2 })
end

cheatertag = function()
	local data =	{	{ text = tr.back, callback = main },
						{ text = tr.prev_page, callback = keybinds },
						{ text = tr.next_page, callback = credits },
						--{ text = tr.btn_close }
					}
	open_menu({ title = tr.help_cheatertag, description = tr.help_cheatertag_desc, button_list = data, w_mul = 2, h_mul = 2 })
end

credits = function()
	local data =	{	{ text = tr.back, callback = main },
						{ text = tr.prev_page, callback = cheatertag },
						{ text = tr.next_page, callback = keybinds }, 
						--{ text = tr.btn_close }
					}
	open_menu({ title = tr.help_credits, description = tr.help_credits_desc, button_list = data, w_mul = 2, h_mul = 2 })
end

return main