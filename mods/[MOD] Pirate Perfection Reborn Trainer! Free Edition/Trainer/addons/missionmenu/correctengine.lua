--Purpose: opens menu where you can find correct engine and decide what to do
--Author: baldwin

local Network = Network

local m_log_v = m_log_v
local show_mid_text = show_mid_text or function()end

local alive = alive
local tostring = tostring
local pairs = pairs
local Vector3 = Vector3
local managers = managers
local M_player = managers.player
local M_mission = managers.mission
local M_interaction = managers.interaction
local M_network = managers.network

local vec0 = Vector3(0,0,0)
local vec1 = Vector3(0,0,100)

ppr_require 'Trainer/tools/new_menu/menu'

local tr = Localization.translate

local function interactbytweak_ex( key, tweak, alt )
	if not key or not tweak then
		return
	end
	local player = M_player:local_player()
	if not alive( player ) then
		return
	end
	for _,unit in pairs(M_interaction._interactive_units) do
		local interaction = unit.interaction
		interaction = interaction and interaction( unit )
		local carry_data = unit.carry_data
		carry_data = carry_data and carry_data( unit )
		if interaction then
			local tweak_d = interaction.tweak_data
			if key == 0 and tweak_d == tweak and carry_data and carry_data:carry_id() == alt then
				interaction:interact( player )
				return true
			elseif tweak_d == tweak and unit:name():key() == key then
				interaction:interact( player )
				return true
			end
		end
	end
end

local function find_engine()
	local script = M_mission:script("default")
	local fusion_engine = script._elements[103718]._values.on_executed[1].id
	local table_t = { 
		["103717"] = "engine_12", ["103716"] = "engine_11", ["103715"] = "engine_10", ["103714"] = "engine_09", ["103711"] = "engine_08", ["103709"] = "engine_07", ["103708"] = "engine_06", ["103707"] = "engine_05", ["103706"] = "engine_04", ["103705"] = "engine_03", ["103704"] = "engine_02", ["103703"] = "engine_01" 
	}
	local table_k = {
		engine_01 = 'f0e7a7f29fc87c44', engine_02 = 'db218f98a571c0b1', engine_03 = 'c717770fadc88e04', engine_04 = '5fb0a3191c4b8202', engine_05 = '0b2ecebcf49765b9', engine_06 = 'b531a6b7026ad84f', engine_07 = 'e191b6d86e655e23', engine_08 = '5aabe6e626f00bd4', engine_09 = '5afbe85d94046cbe', engine_10 = '9f316997306803b9', engine_11 = 'b2560b63edcda138', engine_12 = 'ee644ab092313077', --v=xE23YXNGkKE,
	}
	local ret = table_t[tostring(fusion_engine)]
	if ret then
		return ret, table_k[ret]
	end
	return ""
end

local function SpawnBag(id)
	local player = M_player:local_player()
	if not alive(player) then
		return
	end
	local pos = player:position() + vec1
	local rot = player:rotation()
	
	if Network:is_client() then --Are you sure you want to spawn that as client ?
		M_network:session():send_to_host( "server_drop_carry", id, 1, false, false, 1, pos, rot, vec0, 100, nil)
	else
		M_player:server_drop_carry(id, 1, false, false, 1, pos, rot, vec0, 100, nil)
	end
end

local is_server = Network:is_server()
local menu_c = {
	{ text = tr.cengine_menu_print, callback = function()
		local e = find_engine()
		if is_server and e ~= "" then 
			m_log_v("Correct engine is "..e.."\n")
		end
	end },
	{ text = tr.cengine_menu_hud, callback = function()
		local e = find_engine()
		if is_server and e ~= "" then 
			show_mid_text(e, "Correct engine", 3) 
		end
	end },
	{ text = tr.cengine_menu_spawn, callback = function()
		local e = find_engine()
		if is_server and e ~= "" then 
			SpawnBag(find_engine())
			return
		end
	end },
	{ text = tr.cengine_menu_pickup, callback = function() 
		local e,k = find_engine()
		if e == "" then
			return
		end
		local found = interactbytweak_ex(k, "gen_pku_fusion_reactor")
		if not found then
			interactbytweak_ex(0, "carry_drop", e)
		end
	end },
}

Menu:open( { title = tr.cengine_menu_desc, button_list = menu_c } )