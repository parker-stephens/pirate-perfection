return {
-- From character menu
	god_mode = false,							-- Enables godmode, making you invulnerable from damage, kicks and tases.
	buddha_mode = false,						-- Enables Buddha Mode, you can lose health points until you reach 1hp and then its freezes that value.
	less_damage = false,						-- Player receive 50% less damage
	high_jump = false,						-- Greatly increases height of jump (see JumpHeightMultiplier)
	kill_in_one_hit = false,				-- Instantly kill enemies using weapons
	increase_standard_speed = false,		-- Increases your walking speed
	increase_speed = false,					-- Increases your sprinting speed (see RunSpeed)
	long_melee_range = false,				-- Greatly increases melee range
	instant_melee = false,					-- Superiourly decreases melee charge time
	no_delay_melee = false,					-- Remove delays between melee attacks
	no_hit = false,							-- Removes hit disorientation
	shoot_through_walls = false,			-- Shoot through walls and civilians (only enemies being hit)
	no_headbob = false,						-- Removes camera shake, when you sprinting
	max_accurate = false,					-- 100% weapon accuracy
	inf_ammo_reload = false,				-- Infinite ammo (Weapon reloading left)
	infinite_ammo = false,					-- Infinite ammo (and no reloading, don't enable both infinite_ammo and inf_ammo_reload to avoid conflicts)
	extreme_firerate = false,				-- Absolutely removes delay between shots, shoot like a crazy
	explosive_bullets = false,				-- Changes ammunition type in all weapons to explosive bullets
	NoCivilianPenality = false,			-- No penalities for killing civilians
	no_fall_damage = false,					-- You no longer receive damage from falling
	no_recoil = false,						-- Removes weapon's recoil
	infinite_stamina = false,				-- Infinite Stamina
	no_bag_cooldown = false,				-- Removes temporary interaction block, after you throw your bag.
	increase_melee_dmg = false,			-- Greatly multiplies melee damage.
	no_flash_bangs = false,					-- Flashbangs no longer blind you.
	hacked_maskoff = false,					-- Enable sprinting, shooting and interacting while your mask off
	nodelaytalk = false,						-- Speak with no delays, annoy players!
	grenade_weapon = false,					-- Weapon fires grenades.

-- From stealth menu
	inf_pager_answers = false,				-- Answer infinite amount of pagers (Host only)
	inf_cable_activated = false,			-- Cable ties no longer being consumed
	cops_dont_shoot = false,				-- Cops no longer shoot you
	prevent_panic_buttons = false,		-- Disables panic buttons
	inf_battery_activated = false,		-- Jammers never stop working
	disable_cams = false,					-- Disables cameras in stealth
	disable_pagers = false,					-- Disables pagers on all kills
	steal_pagers_on_melee = false,		-- Steals pagers on melee kill
	inf_converts = false,					-- Convert unlimited amount of cops
	inf_follow_hostages = false,			-- Follow as many hostages as you can
	dont_call_police = false,				-- Civilians no longer call police
	inf_body_bags = false,					-- You have infinite amount of body bags
	ReduceDetectionLevel = false,			-- Reduce Detection Level (Pro & V.I.P. Only)
	change_fov = false,						-- Use mousewheel to change FOV
	lobotomize_ai = false,					-- Lobotomize enemy AI
	invisible_player = false,				-- Make players invisible for AI

-- From interaction menu
	instant_interaction = false,			-- Superiorly dercreases interaction time
	fast_interaction = false,				-- Greatly decreases interaction time (won't be activated, if instant_interaction enabled)
	instant_intimidation = false,			-- Instantly intimidate enemies
	ignore_walls = false,					-- Interact through walls like you did in PAYDAY: The Heist
	infinite_distance = false,				-- Interact with anything at any distance
	interact_and_look = false,				-- You can look anywhere you want, while interacting with something
	interact_with_all = false,				-- Interact with anything, don't requires equipments and/or skills
	instant_lootpile = false,				-- Toggle Instant Lootpile
	reboard = false,							-- Toggle reboarding (V.I.P. Only)
	interact_team = false,					-- Instant interaction for Team (V.I.P. Only)
	noone_shall_down = false,				-- Noone shall down

-- From inventory Modifier menu
	bag_throw_force = false,				-- Increases bag throw distance
	bag_throw_power = 2,						-- Bag throw distance multiplier
	bag_no_penalty = false,					-- Removes movement penalty, when you carry heavy bags.
	explosive_bags = false,					-- Makes all bags explosive.

-- From inventory weapons menu
	always_dismember = false,				-- Always run gore actions for everything
	
-- From equipment menu
	inf_equipments = false,					-- Equipment no longer being consumed on use
	instant_deployments = false,			-- Instantly deploy things
	non_consumable_equipments = false,	-- Ammo bags, medic bags, bodybag cases and grenade crates no longer being consumed on pickup
	drill_auto_service = false,			-- Automatically restores drill once it gets jammed.
	instantdrills = false,					-- Drills instantly finish their work (Host only)
	invulnerable_sentry = false,			-- Sentry receives unlimited health
	sentry_infinite_ammo = false,			-- Sentry's ammo no longer being consumed

-- From mission menu
	waypoints = false,						-- Toggle objects waypoints
	debug_hud = false,						-- Toggle Debug HUD
	trigger_recorder = false,				-- Toggle Trigger Recorder
	intimidator = false,						-- instant intimidator
	shutdown_dialogs = false,				-- Shutdown all dialogs
	reduce_ai_health = false,				-- Reduce AI health
	increase_ai_amount = false,			-- Increase amount of enemys
	pointless_medics = false,				-- Pointless Medics
	Auto_counter_Cloakers = false,		-- Auto counter Cloaker Attacks
},1