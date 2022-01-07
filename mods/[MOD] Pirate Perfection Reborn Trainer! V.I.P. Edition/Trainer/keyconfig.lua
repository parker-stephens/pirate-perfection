--[[	Possible HotKeys :
			Keyboard: a-z (lowered!), 0-9, left shift, right shift, left ctrl, right ctrl, space, f1-14, num 0-9, num +, num -,  num . , num *, num enter, num lock, num /, insert, delete, home, end, page up, page down
			Mouse: left_button, right_button, middle_button, x_button_1, x_button_2, x_button_3, x_button_4, x_button_5, wheel_up, wheel_down

		Possible table keys:
			ig_chat	= true/false												-- If true, this will execute script and/or callback when you're typing something into chat, text input.
			no_stuck	= true/false												-- If true, key will no longer repeat itself by holding key down long enough.
			
			script = 'path_to_script'											-- Path to the script, that will be executed after key pressed.
			handled_callback = 'path_to_script'								-- Path to the script, that ppr_dofile will return callback function, that will be executed when binded key pressed.
			callback = function() .. methods .. end/direct_function	-- Function, that will be executed after key pressed.

		*handled_callback note:
			This way is recommended as it eliminates repeated and unnecessary script interpretation.
			Though it have cons if you're developing some script, as it won't be reloaded anymore, unless you intepretate this script again.

		Configuration entry examples:
			If you want to execute script file on keypress
				['x'] = { script = 'Trainer/addons/autocooker.lua' },

			If you want to execute script, ignoring check if you're in chat and also never repeat script, if key holden.
				['y'] = { script = 'Trainer/keybinded/xray.lua, ig_chat = false, no_stuck = true },

			If you want to execute function on keypress  (NOT WORKING)
				['z'] = { callback = function() managers.player:player_unit():base():replenish() end },

Comma after every entry is required, except if it is last entry in the table, where it isn't necessary.
]]

--Return format: Keyconfig's table, version of config
return{	['f1']				= { handled_callback	= 'Trainer/menu/help.lua',									ig_chat = false, no_stuck = true		},	-- Function Works Both Main-Menu & In-Game
			['f2']				= { handled_callback	= 'Trainer/menu/config_menu.lua',						ig_chat = false, no_stuck = true		},	-- Function Works Both Main-Menu & In-Game
			['f3']				= { handled_callback	= 'Trainer/menu/main_menu-charmenu.lua',				ig_chat = false, no_stuck = true		},	-- Function Works Both Main-Menu & In-Game
			['f4']				= { handled_callback	= 'Trainer/menu/jobmenu-stealthmenu.lua',				ig_chat = false, no_stuck = true		},	-- Function Works Both Main-Menu & In-Game
			['f5']				= { handled_callback	= 'Trainer/menu/spoof_name-troll_menu.lua',			ig_chat = false, no_stuck = true		},	-- Function Works Both Main-Menu & In-Game
		--	['+']					= { handled_callback	= 'Trainer/menu/custom_plugins.lua',					ig_chat = false, no_stuck = true		},	-- Function Works Both Main-Menu & In-Game (Not Fully implemented)
			['page up']			= { handled_callback	= 'Trainer/menu/ingame/tools.lua',						ig_chat = false, no_stuck = true		},	-- Function Works Both Main-Menu & In-Game
			['page down']		= { handled_callback	= 'Trainer/keybinded/music_menu.lua',					ig_chat = false, no_stuck = true		},	-- Function Works Both Main-Menu & In-Game
			['home']				= { handled_callback	= 'Trainer/addons/normalizer.lua',						ig_chat = false, no_stuck = true		},	-- Function Works Both Main-Menu & In-Game
			['delete']			= { script				= 'Trainer/user_script.lua',								ig_chat = false, no_stuck = false	},	-- Debends on the Script
			['f6']				= { handled_callback	= 'Trainer/menu/ingame/interactions.lua',				ig_chat = false, no_stuck = true		},	-- Function Works Only In-Game
			['f7']				= { handled_callback	= 'Trainer/menu/ingame/inventory_menu.lua',			ig_chat = false, no_stuck = true		},	-- Function Works Only In-Game
			['f8']				= { handled_callback	= 'Trainer/menu/ingame/equipment_menu.lua',			ig_chat = false, no_stuck = true		},	-- Function Works Only In-Game
		--	['f9']				= { handled_callback	= '',																ig_chat = false, no_stuck = true		},	-- Reserved for Game Debug-Menu
			['f10']				= { handled_callback	= 'Trainer/menu/ingame/missionmenu.lua',				ig_chat = false, no_stuck = true		},	-- Function Works Only In-Game
			['f11']				= { handled_callback	= 'Trainer/menu/ingame/mod_menu.lua',					ig_chat = false, no_stuck = true		},	-- Function Works Only In-Game
			['f12']				= { handled_callback	= 'Trainer/menu/ingame/spawn_menu.lua',				ig_chat = false, no_stuck = true		},	-- Function Works Only In-Game
			['insert']			= { script				= 'Trainer/addons/carrystacker.lua',					ig_chat = false, no_stuck = false	},	-- Function Works Only In-Game
			['end']				= { handled_callback	= 'Trainer/keybinded/instant_win.lua',					ig_chat = false, no_stuck = true		},	-- Function Works Only In-Game
			['x']					= { handled_callback	= 'Trainer/keybinded/xray.lua',							ig_chat = false, no_stuck = false	},	-- Function Works Only In-Game
			['z']					= { handled_callback	= 'Trainer/keybinded/replenish.lua',					ig_chat = false, no_stuck = false	},	-- Function Works Only In-Game
			['5']					= { handled_callback	= 'Trainer/equipment_stuff/place_equipment.lua',	ig_chat = false, no_stuck = false	},	-- Function Works Only In-Game
			['x_button_1']		= { handled_callback	= 'Trainer/keybinded/slowmotion.lua',					ig_chat = false, no_stuck = false	},	-- Function Works Only In-Game
			['middle_button']	= { handled_callback	= 'Trainer/keybinded/teleport.lua',						ig_chat = false, no_stuck = false	},	-- Function Works Only In-Game
		--	['c']					= { handled_callback	= 'Trainer/addons/spawngagepackage.lua',				ig_chat = false, no_stuck = false	},	-- Function Works Only In-Game **Crash on Green Bridge**
		}