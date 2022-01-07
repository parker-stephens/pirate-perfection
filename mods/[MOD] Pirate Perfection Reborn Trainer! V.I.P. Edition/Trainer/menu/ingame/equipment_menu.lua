--Purpose: several equipments operations (Like invulnerable sentry or infinite medic bags)
--Author: baldwin

if (not GameSetup) then
	return
end

local ppr_require = ppr_require
ppr_require 'Trainer/tools/new_menu/menu'

local main_menu, sentry_ammo_box

local path = "Trainer/addons/equipment_menu/"

local tr = Localization.translate --Shortened Localization.translate

local togg_vars = togg_vars
local Menu = Menu
local Menu_open = Menu.open

local change_sentry_ammo = function( ammo_type )
	togg_vars.sentry_ammo = ammo_type
end

-- Menu

sentry_ammo_box = function()
	local data = {
		{ text = tr.equip_sentry_ammo_toggle, plugin = 'sentry_nades', switch_back = true },
		{},
		{ text = tr.equip_sentry_grenade, callback = change_sentry_ammo, data = 1 },
		{ text = tr.equip_sentry_molotov, callback = change_sentry_ammo, data = 4 },
		{ text = tr.equip_sentry_rocket, callback = change_sentry_ammo, data = 3 },
	}
	
	Menu_open( Menu, { title = tr.equip_sentry_ammo, button_list = data, plugin_path = path, back = main_menu } )
end

main_menu = function()
	local data = {
		{ text = tr.equip_inf_equipments, plugin = 'inf_equipments', switch_back = true },
		{ text = tr.equip_instant_deployments, plugin = 'instant_deployments', switch_back = true },
		{ text = tr.equip_infinite_bags, plugin = 'non_consumable_equipments', host_only = true, switch_back = true },
		{},
		{ text = tr.equip_drill_service, plugin = 'drill_auto_service', switch_back = true },
		{ text = tr.equip_drill_instant, plugin = 'instantdrills', host_only = false, switch_back = true },
		{},
		{ text = tr.equip_sentry_inv, plugin = 'invulnerable_sentry', host_only = true, switch_back = true },
		{ text = tr.equip_sentry_infammo, plugin = 'sentry_infinite_ammo', host_only = true, switch_back = true },
		{ text = tr.equip_sentry_ammo, callback = sentry_ammo_box, host_only = true, box = true },
	}
	
	Menu_open( Menu, { title = tr.equip_menu_title, button_list = data, plugin_path = path } )
end

return main_menu