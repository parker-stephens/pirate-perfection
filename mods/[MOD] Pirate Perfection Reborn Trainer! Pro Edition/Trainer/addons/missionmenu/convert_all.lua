--Purpose: converts all enemies
--Author: baldwin

local managers = managers

local plugins = plugins
local g_loaded = plugins.g_loaded
local prequire = plugins.ppr_require
local punload = plugins.unload
local pairs = pairs
local AI_State = managers.groupai:state()
local convert_hostage_to_criminal = AI_State.convert_hostage_to_criminal
local all_enemies = managers.enemy:all_enemies()
local safecall = safecall

return function()
	local have_to_load = not g_loaded(plugins, "inf_converts")
	if have_to_load then
		prequire( plugins, 'Trainer/addons/stealthmenu/inf_converts', true )
	end
	for _,ud in pairs( all_enemies ) do
		local unit = ud.unit
		if not unit:brain()._logic_data.is_converted then
			--Sometimes it fails to convert single unit
			safecall( convert_hostage_to_criminal, AI_State, unit )
		end
	end
	if have_to_load then
		punload(plugins,"inf_converts")
	end
end