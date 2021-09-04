-- Pirate Perfection Reborn Trainer! Free Edition Main Configuration File.
-- To turn options ON write true after '=' , to turn options OFF write false.
-- Config frequently being updated through versions, don't forget to update it.

return {
-- Pirate Perfection Reborn Trainer related Options
 -- Keybinds
	DisableBindings = false,						-- Set to true in order to disable all binds (maybe usefull when you want to use only DLCUnlocker and some stealth cheats, like no recoil)
	keyconfig = 'Trainer/keyconfig.lua',		-- Key bindings configuration filename. Use "keyconfig" (or false) to load the default keyconfig.lua. Or Set up your own Key configuration and switch to it.

 -- Updates & Annoucements
	check_for_updates = true,						-- This will check for new versions of Pirate Perfection and notify you, when it is available.
	announcements = true,							-- This will display announcements from Pirate Perfection about community events (including giveaways or group chat events)
	announcements_interval = 60,					-- Delay between game checks for new announcements in minutes

 -- HUD Texts
	HUD = true,											-- Set to false in order to disable ALL Pirate Perfection hud elements
	HUD_VersionText = true,							-- Displays current version of PPR in main menu
	HUD_MovingText = true,							-- Displays moving text in main menu and in game.
	RSSFeed = true,									-- Displays PiratePerfection.com RSS Feed in Main-Menu

 -- Logging Option
	LogErrorsToFile = true,							-- This will not only display PPR related errors into console, but will write them into errlog.log

 -- Secert
	no_liberty_hook = false,						-- It's a Secret that only retired developers know about.

-- General Options
 -- Language & Config Options
	Language = 'english',							-- Current language. Available languages: English, German, Portuguese, Turkish, Russian, Italian, Spanish, Schinese, Tchinese. Set to false to automatically choose language.
	check_language_updates = true,				-- Set to false to automatically check and announce you, when any update for your language available
	DefaultConfig = 'default_config',			-- Default config file, that is loaded automatically.

 -- Misc
	NoStatsSynced = true,							-- Prevents statistics being published to Steam. Disable this, if you're having problems with unlocking certain achievement, just make sure to set your profile from Public to other visibillity.
	AllPerks = false,									-- Gives you bonuses from all perks. Currently works odd and may cause crash, when you change armors.
	Extend_Inventory_Slots = false,				-- Extend Inventory Slots

 -- Unlocker Options
	DLCUnlocker = false,								-- Unlocks all dlcs in game. Use with caution, OVERKILL implemented check, if you wearing DLC item or creating DLC heist from DLC you don't own.
	AllWeaponSkins = false,							-- Gives you all Weapon skins
	NoSkinMods = false,								-- Prevents skins from automatically adding their own modifications.
	AllArmorSkins = false,							-- Gives you all Armor skins
	unlocked_hoxton = false,						-- Unlocks old hoxton without need to complete heist and being in official payday 2 group.
	unlocked_arbiter = false,						-- Unlocks the Arbiter Grenade Launcher without collecting the Gage spec ops cases.
	unlocked_aldstone_items = false,				-- Unlocks all Aldstone Items.
	CrewUnlocker = false,							-- Unlocks all Crew Abilities and Boosts.

 -- Lobby Options
	StraightToMainMenu = false,					-- 
	DisableAutoKick = true,							-- Turns off cheater auto kick option by default
	NoDropinPause = false,							-- Disables drop-in pause, works both on client and host side.
	HostMatters = true,								-- Host forces plan he choosed in preplanning ignoring other players votes.
	FreeBlackMarket = false,						-- Purchase everything at no cost.
	FreeAssets = false,								-- Purchase assets at no cost.
	FreePreplanning = false,						-- Free preplanning elements + no favors consumed for purchasing them.
	FreeCrimeSpree = false,							-- Free Crime Spree start, continue, and randomization costs.

 -- Spoof Options	
	NameSpoof = "A fellow Scrub Pirate",		-- Your new name in game, set to false in order to use your steam name. Don't forget to write your name in "Quotation Marks" (V.I.P. only Function)
	ReduceDetectionLevel = false,					-- Reduce Detection Level (Pro & V.I.P. only Function)

 -- Exceptions Options
	ExceptionsEnabled = true,						-- Allows users to bypass some limit by warning (only equipment control stuff affected currently)
	ExceptionsCrashDetect = false,				-- Tries to detect whenever application was crashed or not. (Requires ExceptionsEnabled = true)
															-- Was planned to make process of locating latestcrash easier for cabin boys and it was success, but cabin boys experienced really weird problems with that.

 -- Anticheat related Options
	DisableAnticheat = true,						-- Disables some anticheat checks, also it turns off DLC ownership checks.
	PreventEquipDetecting = false,				-- Experimental way to prevent extra grenades and equipments from tagging you as cheater. (V.I.P. Only)
	Hide_All_Mods = false,							-- Prevents other Users from seeing all of your mods.
	Hide_Pirate_Perfection = false,				-- Hides Pirate Perfection from others.
	non_modded_lobby = false,						-- Sets your Lobby to not Modded. (Pro & V.I.P. Only Function)

 -- Equipment placement Options
	far_placements = true,							-- Allows you to place equipments at any distance, ahywhere (Will cause visual glitch, where dummy equipment will not appear, when you place something)
	equipment_place_key = '4',						-- Key, to that will be binded placement of equipments from menu

 -- Main Options
	NoCivilianPenality = true,						-- No penalities for killing civilians
	NoInvisibleWalls = false,						-- Removes invisible walls (Host only)
	RestartProMissions = true,						-- Allow restart pro missions
	RestartJobs = true,								-- Returns "Restart" button, when you're hosting game
	NoEscapeTimer = false,							-- No escape timer (Host only)
	ControlCheats = 1,								-- ( false - always off, 1 - Turns on control, when you're client on someone's server, 2 - Always on).
															-- This option will limit placement of your equipments and grenade throws in order to prevent randomly being marked as cheater.
															-- Aswell it will prevent you from randomly changing your current weapon.
	Crosshair = true,									-- Enable crosshair on all weapons											
	LaserColorR = 125,								-- Change your weapon's laser color.
	LaserColorG = 75,									-- Color format as Red, Green, Blue example: 0, 128, 0 will be dark green.
	LaserColorB = 205,								-- Set to false to disable this feature.
	DontFreezeRagdolls = false,					-- Never freezes corpses. May cause performance issues!
	DontDisposeRagdolls = false,					-- Corpses never disappear. May cause performance issues!
	SecureAll = false,								-- Secure any bag on any map.

 -- Script Options
	FreeFlightTeleport = false,					-- Turning off freeflight will drop you at the position where freeflight camera was
	NoClipSpeed = 1,									-- Change how fast you move in NoClip Mod default value (1).

 -- Kill all script Options
	KillAllIgnoreTied = true,						-- Kill all script will ignore hostaged units.
	KillAllIgnoreCivilians = true,				-- Kill all script will ignore civilians
	KillAllIgnoreEnemies = false,					-- Kill all script will ignore enemies.
	KillAllTouchCameras = true,					-- Kill all scripts will kill all cameras aswell.

 -- Character menu Options
	JumpHeightMultiplier = 5,						-- Multiplier for player's jump height. Set to false for default value (5).
	RunSpeed = 115,									-- Maximum run speed. Set to false for default value (115).

 -- Job menu Options
	jobmenu_def_difficulty = 'overkill_145',	-- Default difficulty choosed, when you host game from menu. Available difficulties ("easy","normal","hard","overkill","overkill_145","easy_wish","overkil_290","sm_wish")
	jobmenu_singleplayer = false,					-- Job menu will host singleplayer games by default (Can be toggled on/off in jobmenu manually)

 -- Game Fix Options
	DisableBulletFix = false,						-- Disables fix on delayed bullet effect play.
	DisableInvFix = false,							-- Disables fix on ctd, when other player changes weapon.
	EnableJobFix = true,								-- Replaces job_class values to 10, so other players will see lobbies with jobs these game thinks "too hard for them". You also can see these jobs now when search.

 -- Spawn menu Options
	SpawnUnitsAmount = 1,							-- Amount of units being spawned, when you select some unit to spawn
	SpawnPos = 'ray',									-- Spawn position ( "ray", "spawn_point", "random_spawn_point" )
	SpawnCivsAnim = 'cm_sp_stand_idle',			-- Default animation set for civilians, when you spawn them
	SpawnEnemyAnim = 'idle',						-- Default animation set for enemies, when you spawn them
	SpawnUnitKey = "7",								-- Spawn unit button

 -- Inventory menu Options
	rain_bags_amount = 100,							-- Default amount of rained bags
	SpawnBagsAmount = 1,								-- Default amount of spawned bags on single select.
	SpawnBagKey = "8",								-- Spawn bag button

 -- Slowmotion Options
	SmSpeed = 20,										-- Slow motion speed
	SmSlowPlayer = true,								-- Affects slow motion on player
	slowmo_protect = true,							-- Prevents client from being slowed by forced code
	slowmo_reverse = true,							-- Sends the effect back to the sender

 -- xray Options										-- Color format as Red, Green, Blue example: 0, 128, 0 will be dark green.
	xray_Cams = true,									-- xray will highlight cameras
	xray_CamsColR = 255,								-- Camera's highlight color (Orange)
	xray_CamsColG = 50,
	xray_CamsColB = 0,

	xray_Civ = true,									-- xray will highlight civilians
	xray_CivColR = 0,									-- Civilian's highlight color (Blue)
	xray_CivColG = 0,
	xray_CivColB = 255,

	xray_CivKeyColR = 255,							-- Civilian with keycard's highlight color
	xray_CivKeyColG = 255,
	xray_CivKeyColB = 0,

	xray_Cops = true,									-- xray will highlight enemies
	xray_CopsColR = 255,								-- Cop's highlight color
	xray_CopsColG = 0,
	xray_CopsColB = 0,

	xray_CopsKeyColR = 255,							-- Cop with keycard's highlight color
	xray_CopsKeyColG = 100,
	xray_CopsKeyColB = 0,

	xray_SpecialColR = 150,							-- Special's highlight color
	xray_SpecialColG = 50,
	xray_SpecialColB = 205,

	xray_SniperColR = 0,								-- Sniper's highlight color (Green)
	xray_SniperColG = 125,
	xray_SniperColB = 0,

	xray_FriendlyR = 50,								-- Converted enemies color
	xray_FriendlyG = 205,
	xray_FriendlyB = 255,

	xray_Items = true,								-- Highlight some important to objective items (Highlights Framing Frame 3 objects and key cards).

 -- Teleporter Option
	TeleportPenetrate = true,						-- Set to true if you want to penetrate through walls and props, when teleporting.

 -- Troll menu Options
--	TrollAmountBags = 5,								-- Amount of bags spawned on victims.(Pro & V.I.P. Only)

 -- AimBot Options
	ShootThroughWalls = false,						-- Allow AimBot shoot through walls.
	MaxAimDist = 8000,								-- AimBot max. detection range.
	AimbotInfAmmo = false,							-- Enable infinite ammo for AimBot.
	AimbotDamageMul = 2,								-- Damage multiplier, set to false to use default weapon damage.
	AimMode = 2,										-- AimBot mode (1 - Only auto shoot, 2 - Only aim, 3 - Auto aim and shoot).
	RightClick = true,								-- Only let the AimBot work if the right mouse button is held.

 -- Lego Options
	LegoFile = 'default',							-- Default lego file.
	LegoDeleteKey = 'h',								-- Delete props button.
	LegoSpawnKey = '6',								-- Spawn props button.
	LegoPrevKey = '7',								-- Quick-switch to previous prop from the list.
	LegoNextKey = '8',								-- Quick-switch to next prop from the list.

 -- Loot Card Spoofer Option
	SpoofCards = false,								-- Fake your multiplayer loot drops to always drop a random safe or drill.

 -- Debug HUD Options
	DebugDramaDraw = false,							-- Enable drama HUD.
	DebugStateDraw = false,							-- Enable displaying state on unit.
	DebugConsole = false,							-- Enable debug console.
	DebugNavDraw = false,							-- Enable displaying debug navigation fields.
	DebugAdditionalEsp = false,					-- Enable additional esp on units.
	DebugMissionElements = false,					-- Enable drawing mission elements.
	DebugElementsAdditional	= false,				-- Enable drawing additional mission elements.
	EnableDebug = false,								-- Enables debug menu, this also enables freeflight.
	LegacyMenu = false,								-- Use config file names in PPR Setup menu.

-- Fixes - Doing Overkills Job
	CrashFixer = false,								--
	LoopFireSounds = false,							--
	SentryIgnoresShields = false,					--
	CheckGhostBonus = false,						-- Check if accumulated_ghost_bonus is not nil.
	CheckLobbyHandler = false,						--
	CheckMeleeAttack = false,						--
	CheckMissionDoorDevicePlaced = false,		--

-- Tweaks - For Advanced Users only!			-- Toggle here the Tweaks you want to enable.
	armor_tweaks = false,							-- Edit the Values in the .lua files for fine tunning.
	vehicle_tweaks = false,							-- Navigate to Trainer/addons/tweaks for this.
	iceaxe_tweaks = false,							--
	CAR4_tweaks = false,								--
	M79_tweaks = false,								--
	Bernetti9mm_tweaks = false,					--
	ChinaPuff_tweaks = false,						--
	Glock18c_tweaks = false,						--
	Ace_tweaks = false,								--
    Frag_Grenade_tweaks = false,					--
	Bipod_Freelook = false,							--
	Bipod_Standing = false,							--
	Bullet_Penetration = false,					--
	Drum_Magazine_Mod = false,						--
	Gadget_Always_On = false,						--
	Improved_Tripmine = false,						--
	Increased_Pickup_Ammo = false,				--
	LMG_Scopes = false,								--
	projectiles_Tweaks = false,					--
	Rocket_Jump = false,								--
	Sentry_Gun_Tweaks = false,						--
	Shotgun_Physics = false,						--
	Weapon_Parts_Tweaks = false,					--
	Weapon_Tweaks = false,							--

 -- Custom Safehouse
	SafeHouseDoors = true,							-- Makes doors actually doors in the Safe House.
	SafeHouseInvest = false,						-- Put your offshore money on the line to increase or decrease your funds.
	SafeHouseInvestAmt = 500,						-- Amount of money to give to put on Safe House Investment.
	SafeHouseLego = false,							-- Automatically loads a file named 'custom_safehouse' upon entering the Safe House.

-- Enables Sub Menus for PPR Setup Menu		-- No need to Change something, this is just to prevent some errors getting logged in the console to reduce the lag caused by this.
	announce_sub = nil,								-- 
	HUD_sub = nil,										-- 
	general_sub = nil,								-- 
	anticheat_sub = nil,								-- 
	equipment_sub = nil,								--
	misc_sub = nil,									--
	flying_sub = nil,									--
	KillAll_sub = nil,								--
	character_sub = nil,								--
	job_sub = nil,										--
	Spawn_sub = nil,									--
	inventory_sub = nil,								--
	slow_sub = nil,									--
	xray_sub = nil,									--
	aimbot_sub = nil,									--
	Lego_sub = nil,									--
	SpoofCards_sub = nil,							--
	Lasercolor = nil,									--
	xray_CamsCol = nil,								--
	xray_CivCol = nil,								--
	xray_CopsCol = nil,								--
	xray_SpecialCol = nil,							--
	xray_SniperCol = nil,							--
	xray_Friendly = nil,								--
}