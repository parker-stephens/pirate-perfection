--  Authors:  Configuration method by baldwin and ThisJazzman, menu by Davy Jones
--  Purpose:  Change base options in the game
local insert = table.insert
local pairs = pairs
local round = math.round
local len = string.len
local size = table.size
local sub = string.sub
local type = type
local unpack = unpack

local managers = managers
local M_experience = managers.experience
local M_localization = managers.localization

local T_economy = tweak_data.economy

local ApplyConfigExtension = ApplyConfigExtension
local rlist_files = rlist_files

local tr = Localization.translate

local Menu = Menu
local Menu_open = Menu.open

local togg_vars = togg_vars
local ppr_config = ppr_config

local main_menu

local back_num = 0
local back_track = {}
local is_legacy

local prefix = "base_"

local options = {
	{name = "HUD_Announce_Sub", desc = true, sub = {
		{name = "HUD"},
		{},
		{name = "HUD_VersionText"},
		{name = "HUD_MovingText"},
		{},
		{name = "announcements"},
		{name = "announcements_interval", type = "slider", max = 720},
		{},
		{name = "check_for_updates"},
		{},
		{name = "RSSFeed"},
	}},
	{name = "General_Sub", desc = true, sub = {
		{name = "Language", menu = function() return rlist_files("Trainer/translations/", "txt") or {} end},
		{},
		{name = "Crosshair"},
		{name = "NoStatsSynced"},
		{name = "AllPerks"},
		{name = "Extend_Inventory_Slots"},
		{},
		{name = "FreeBlackMarket"},
		{name = "FreeAssets"},
		{name = "FreePreplanning"},
		{name = "FreeCrimeSpree"},		
		{},
		{name = "StraightToMainMenu"},
		{name = "NoDropinPause"},
		{name = "HostMatters", host = true},
		{name = "DisableAutoKick", host = true},
		{},
		{name = "ReduceDetectionLevel"},
		{name = "NameSpoof", type = "input"},
	}},
	{name = "Unlocker_Sub", desc = true, sub = {
		{name = "DLCUnlocker"},
		{name = "unlocked_hoxton"},
		{name = "unlocked_arbiter"},
		{name = "unlocked_aldstone_items"},
		{name = "CrewUnlocker"},
		{name = "AllWeaponSkins"},
		{name = "NoSkinMods"},
		{name = "AllArmorSkins"},
	}},
	{name = "Anticheat_Sub", desc = true, sub = {
		{name = "Hide_All_Mods"},
        {name = "Hide_Pirate_Perfection"},
		{name = "non_modded_lobby"},
		{},
		{name = "DisableAnticheat"},
		{},
		{name = "PreventEquipDetecting", host = true},
		{},
		{name = "ControlCheats", desc = true, menu = {
			base_ControlCheats_false = false,
			base_ControlCheats_1 = 1,
			base_ControlCheats_2 = 2,
		}},
	}},
	{name = "Equipment_Sub", desc = true, sub = {
		{name = "far_placements"},
		{},
		{name = "equipment_place_key", type = "input"},
	}},
	{name = "Misc_Sub", desc = true, sub = {
		{name = "Lasercolor", lasercolor = true, disable = true},
		{},
		{name = "SecureAll"},
		{name = "NoCivilianPenality"},
		{},
		{name = "NoInvisibleWalls", host = true},
		{name = "RestartProMissions", host = true},
		{name = "RestartJobs", host = true},
		{name = "NoEscapeTimer", host = true},
		{},
		{name = "DontFreezeRagdolls"},
		{name = "DontDisposeRagdolls"},
	}},
	{name = "flying_sub", desc = true, sub = {
		{name = "FreeFlightTeleport"},
		{},
		{name = "NoClipSpeed", type = "slider", max = 50},
		{},
		{name = "TeleportPenetrate"},
	}},
	{name = "KillAll_sub", desc = true, sub = {
		{name = "KillAllIgnoreTied"},
		{},
		{name = "KillAllIgnoreCivilians"},
		{},
		{name = "KillAllIgnoreEnemies"},
		{},
		{name = "KillAllTouchCameras"},
	}},
	{name = "character_sub", desc = true, sub = {
		{},
		{name = "JumpHeightMultiplier", type = "slider", max = 100},
		{},
		{},
		{},
		{name = "RunSpeed", type = "slider", max = 500},
		{},
	}},
	{name = "job_sub", desc = true, sub = {
		{name = "jobmenu_def_difficulty", menu = {
			"Easy", --"easy",
			"Normal", --"normal",
			"Hard", --"hard",
			"Very Hard", --"overkill",
			"Overkill", --"overkill_145",
			"Mayhem", --"easy_wish",
			"Deathwish", --"overkill_290",
			"One Down", --"sm_wish",
		}},
		{},
		{name = "jobmenu_singleplayer"},
		{},
		{name = "EnableJobFix"},
	}},
	{name = "Spawn_sub", desc = true, sub = {
		{name = "SpawnUnitsAmount", type = "slider", max = 100},
		{},
		{name = "SpawnPos", menu = {
			base_SpawnPos_ray = "ray",
			base_SpawnPos_spawn_point = "spawn_point",
			base_SpawnPos_random_spawn_point = "random_spawn_point",
		}},
		{},
		{name = "SpawnUnitKey", type = "input"},
	}},
	{name = "inventory_sub", desc = true, sub = {
		{name = "rain_bags_amount", type = "slider", max = 1000},
		{name = "SpawnBagsAmount", type = "slider", max = 100},
		{name = "SpawnBagKey", type = "input"},
		{name = "TrollAmountBags", type = "slider", max = 100},
	}},
	{name = "slow_sub", desc = true, sub = {
		{name = "SmSpeed", type = "slider", max = 100},
		{name = "SmSlowPlayer"},
		{},
		{name = "slowmo_protect"},
		{name = "slowmo_reverse"},
	}},
	{name = "xray_sub", desc = true, sub = {
		{name = "xray_Cams"},
		{name = "xray_CamsCol", color_xray = true},
		{},
		{name = "xray_Civ"},
		{name = "xray_CivCol", color_xray = true},
		{name = "xray_CivKeyCol", color_xray = true},
		{},
		{name = "xray_Cops"},
		{name = "xray_CopsCol", color_xray = true},
		{name = "xray_CopsKeyCol", color_xray = true},
		{name = "xray_SpecialCol", color_xray = true},
		{name = "xray_SniperCol", color_xray = true},
		{name = "xray_Friendly", color_xray = true},
		{},
		{name = "xray_Items"},
	}},
	{name = "aimbot_sub", desc = true, sub = {
		{name = "AimMode", menu = {
			base_AimMode_1 = 1,
			base_AimMode_2 = 2,
			base_AimMode_3 = 3,
		}},
		{name = "RightClick"},
		{name = "AimbotInfAmmo"},
		{name = "ShootThroughWalls"},
		{name = "MaxAimDist", type = "slider", max = 10000},
		{name = "AimbotDamageMul", type = "slider", max = 100},
	}},
	{name = "Lego_sub", desc = true, sub = {
		{name = "LegoFile", type = "input"},
		{name = "LegoDeleteKey", type = "input"},
		{name = "LegoSpawnKey", type = "input"},
		{name = "LegoPrevKey", type = "input"},
		{name = "LegoNextKey", type = "input"},
	}},
	{name = "SpoofCards_sub", desc = true, sub = function()
		local data = {{name = "SpoofCards"}, {}}
		for typ_n, typ in pairs({safes = T_economy.safes, drills = T_economy.drills}) do
			for id, item in pairs(typ) do
				if item.name_id then
					insert(data, {name = typ_n..id, disp = M_localization:text(item.name_id)})
				end
			end
		end
		return data
	end},
	{name = "Debug_Sub", desc = true, sub = {
		{name = "DebugConsole"},
		{},
		{name = "DebugDramaDraw"},
		{name = "DebugStateDraw"},
		{name = "DebugNavDraw"},
		{},
		{name = "DebugAdditionalEsp"},
		{name = "DebugMissionElements"},
		{name = "DebugElementsAdditional"},
		{},
		{name = "EnableDebug"},
		{},
		{name = "LegacyMenu", forceout = false},
	}},
	{name = "Fixes_Tweaks_Sub", desc = true, sub = {
		{name = "Fixes_Sub", desc = true, sub = {
			{name = "CheckGhostBonus"},
			{name = "CheckLobbyHandler"},
			{name = "CheckMeleeAttack"},
			{name = "CheckMissionDoorDevicePlaced"},
			{name = "CrashFixer"},
			{name = "LoopFireSounds"},
			{name = "SentryIgnoresShields"},
		}},
		{name = "Tweaks_Sub", desc = true, sub = {
			{name = "armor_tweaks_Sub", desc = true, sub = {
				{name = "armor_tweaks"},
			},},
			{name = "vehicle_tweaks_Sub", desc = true, sub = {
				{name = "vehicle_tweaks"},
			},},
			{name = "weapon_tweaks_Sub", desc = true, sub = {
				{name = "melee_weapons_tweaks_Sub", desc = true, sub = {
				{name = "iceaxe_tweaks"},
			},},
			{name = "primary_weapons_tweaks_Sub", desc = true, sub = {
				{name = "CAR4_tweaks"},
				{name = "M79_tweaks"},
			},},
			{name = "secondary_weapons_tweaks_Sub", desc = true, sub = {
				{name = "Bernetti9mm_tweaks"},
				{name = "ChinaPuff_tweaks"},
				{name = "Glock18c_tweaks"},
			},},
			{name = "throwable_weapons_tweaks_Sub", desc = true, sub = {
				{name = "Ace_tweaks"},
				{name = "Frag_Grenade_tweaks"},
			},},
			{name = "general_weapons_tweaks_Sub", desc = true, sub = {
				{name = "Bipod_Freelook"},
				{name = "Bipod_Standing"},
				{name = "Bullet_Penetration"},
				{name = "Drum_Magazine_Mod"},
				{name = "Gadget_Always_On"},
				{name = "Improved_Tripmine"},
				{name = "Increased_Pickup_Ammo"},
				{name = "LMG_Scopes"},
				{name = "projectiles_Tweaks"},
				{name = "Rocket_Jump"},
				{name = "Sentry_Gun_Tweaks"},
				{name = "Shotgun_Physics"},
				{name = "Weapon_Parts_Tweaks"},
				{name = "Weapon_Tweaks"},
			},},
	},}, },}, },},
	{name = "custom_safehouse_Sub", desc = true, sub = {
		{name = "SafeHouseDoors"},
		{name = "SafeHouseInvest"},
		{name = "SafeHouseInvestAmt", type = "multi_choice", choices = function()
			local data = {}
			for i = 1, 7 do
				insert(data, {text = M_experience:cash_string(100 * (10^i)), value = i})
			end
			return data
		end},
		{name = "SafeHouseLego"},
	}},
}

local function get_value(id)
	local pre_id = prefix..id
	return (togg_vars[pre_id] ~= nil and togg_vars[pre_id]) or (togg_vars[pre_id] == nil and ppr_config[id])
end

local function config_edit(id, val, back)
	val = val == nil and not get_value(id) or val ~= nil and (val ~= "" and val or false)
	togg_vars[prefix..id] = val
	if back then
		main_menu()
	end
end

local create_item, create_sub, create_menu, create_lasercolor, create_color_xray

create_item = function(opt)
	local name = opt.name
	if not name then
		return {}
	end
	local pre_name = prefix..name
	if togg_vars[pre_name] == nil and not opt.sub and not opt.lasercolor and not opt.color_xray then
		togg_vars[pre_name] = ppr_config[name]
	end
	local opt_val = not opt.sub and not opt.lasercolor and not opt.color_xray and get_value(name)
	local is_lasercolor = opt.lasercolor
	local is_color_xray = opt.color_xray
	local is_slider = opt.type == "slider"
	local is_input = opt.type == "input"
	local is_multi = opt.type == "multi_choice"
	local is_menu = opt.menu
	local is_sub = opt.sub
	local is_toggle = not is_sub and not is_menu and not is_lasercolor and not is_color_xray and not opt.type
	return {
		text = (opt.disp or is_legacy and not (is_sub or opt.notlegacy) and name or tr[pre_name])..(is_input and "  ( "..(opt_val or tr.base_none).." ) :" or "")..(opt.host and " "..tr.host_only or ""),
		type = (is_toggle and "toggle") or opt.type or nil,
		name = is_multi and name or nil,
		toggle = (is_toggle and pre_name) or nil,
		slider_data = is_slider and {name = pre_name, value = opt_val, max = opt.max} or nil,
		callback = (is_toggle and config_edit) or (is_sub and create_sub) or (is_menu and create_menu) or (is_lasercolor and create_lasercolor) or (is_color_xray and create_color_xray) or nil,
		callback_input = (is_input and function(val) config_edit(name, val) end) or nil,
		multi_callback = is_multi and config_edit or nil,
		data = (is_toggle and name) or (is_sub and {pre_name, opt}) or (is_menu and {name, opt}) or (is_lasercolor and {name, opt.disable}) or (is_color_xray and {name, opt.disable}) or nil,
		multi_choice_data = is_multi and opt.choices() or nil,
		value = is_multi and opt_val or nil,
		switch_back = not opt.forceout and (is_toggle or is_slider or is_input or is_multi) or nil,
		menu = is_sub or is_menu or is_lasercolor or is_color_xray or nil,
	}
end

local function save_config()
	local pre_len = len(prefix)
	for id, val in pairs(togg_vars) do
		local check = sub(id, 1, pre_len)
		if check == prefix then
			id = sub(id, pre_len + 1)
			ppr_config[id] = val
		end
	end
	ppr_config()
	Menu_open(Menu, {title = tr[prefix.."menu"], description = tr.base_menu_restart, button_list = {}})
end

local save_button = {text = tr.save, type = "save_button", callback = save_config, name = prefix.."menu_save"}

create_sub = function(pre_id, menu)
	local opts = menu.sub
	if type(opts) == "function" then
		opts = opts()
	end
	local data = {}
	local i = 0
	local opts_size = size(opts)
	for _, opt in pairs(opts) do
		insert(data, create_item(opt))
		i = i + 1
		if i % 20 == 0 or i == opts_size then
			insert(data, {})
			insert(data, save_button)
		end
	end

	Menu_open(Menu, {title = tr[pre_id]..(menu.host and "    "..tr.host_only or ""), description = menu.desc and tr[pre_id.."_desc"] or nil, button_list = data, back = main_menu})
end

create_menu = function(id, menu)
	local opts = menu.menu
	if type(opts) == "function" then
		opts = opts()
	end
	local same_name = opts[1] and true
	local cur_val = get_value(id)
	local data = {}
	for ind, val in pairs(opts) do
		if cur_val == val then
			insert(data, 1, {})
			insert(data, 1, {text = tr.base_selected..":  "..(same_name and val or tr[ind]), switch_back = true})
		end
		insert(data, {text = same_name and val or tr[ind], callback = config_edit, data = {id, val, true}})
	end

	local pre_id = prefix..id
	Menu_open(Menu, {title = (is_legacy and not (menu.sub or menu.notlegacy) and id or tr[pre_id])..(menu.host and "    "..tr.host_only or ""), description = tr[pre_id.."_desc"], button_list = data, back = main_menu})
end

local c_tab = {"R", "G", "B"}

local function disable_lasercolor(id)
	for _, c in pairs(c_tab) do
		togg_vars[id..c] = false
	end
end

local b_lc = "base_lasercolor_"

create_lasercolor = function(id, disable)
	local data = {}
	for _, c in pairs(c_tab) do
		local id_c = id..c
		insert(data, {text = tr[b_lc..c], type = "slider", slider_data = {name = prefix..id_c, value = get_value(id_c) or 1, max = 255}, switch_back = true})
	end
	local pre_id = prefix..id
	if disable then
		insert(data, {text = tr.base_disable, callback = disable_lasercolor, data = pre_id, switch_back = main_menu})
	end
	insert(data, save_button)
	Menu_open(Menu, {title = tr[pre_id], description = tr[pre_id.."_desc"].."\n"..tr.base_lasercolor_ins, button_list = data, back = main_menu})
end

local function disable_color_xray(id)
	for _, c in pairs(c_tab) do
		togg_vars[id..c] = false
	end
end

local b_xc = "base_xraycolor_"

create_color_xray = function(id, disable)
	local data = {}
	for _, c in pairs(c_tab) do
		local id_c = id..c
		insert(data, {text = tr[b_xc..c], type = "slider", slider_data = {name = prefix..id_c, value = get_value(id_c) or 1, max = 255}, switch_back = true})
	end
	local pre_id = prefix..id
	if disable then
		insert(data, {text = tr.base_disable, callback = disable_color_xray, data = pre_id, switch_back = main_menu})
	end
	insert(data, save_button)
	Menu_open(Menu, {title = tr[pre_id], description = tr[pre_id.."_desc"].."\n"..tr.base_color_xray_ins, button_list = data, back = main_menu})
end

is_legacy = get_value("LegacyMenu")
togg_vars[prefix.."menu_save"] = true
local base_name = prefix.."menu"
main_menu = function() create_sub(base_name, {name = base_name, sub = options}) end
main_menu()