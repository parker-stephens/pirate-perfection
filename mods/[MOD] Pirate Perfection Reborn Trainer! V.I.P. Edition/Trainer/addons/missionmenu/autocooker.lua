--  Authors:  Originally by baldwin, re-write by Davy Jones
--  Purpose:  Cooks meth on Rats and Cook-Off for you... infinitely.

local plugins = plugins
plugins:new_plugin('autocooker')

local alive = alive
local pairs = pairs
local random = math.random
local type = type
local Vector3 = Vector3

local Global = Global
local G_game_settings = Global.game_settings

local managers = managers
local M_interaction = managers.interaction
local M_player = managers.player

local backuper = backuper
local add_clbk = backuper.add_clbk
local remove_clbk = backuper.remove_clbk

local executewithdelay = executewithdelay

local GetNetSession = GetNetSession
local is_client = is_client

FULL_NAME = "Meth Auto-Cooker"

VERSION = "2.0"

DESCRIPTION = "Cooks and bags up meth for you.  Originally by baldwin, re-written by Davy Jones."

local _interactive_units = M_interaction._interactive_units
local _players = M_player._players
local clear_carry = M_player.clear_carry
local level_id = G_game_settings.level_id
local server_drop_carry = M_player.server_drop_carry

local UP = Vector3(0, 0, 1)

local needed_chem = {'methlab_bubbling', 'methlab_caustic_cooler', 'methlab_gas_to_salt'}

local spawn_meth_pos


local function true_func()
	return true
end

local function cook_meth(chemical)
	local player = _players[1]
	if alive(player) then
		local interaction
		if type(chemical) == 'string' then
			for _, unit in pairs(_interactive_units) do
				interaction = unit:interaction()
				if interaction.tweak_data == chemical then
					break
				end
			end
		end
		interaction.can_interact = true_func
		interaction:interact(player)
	end
end

function MAIN()
	add_clbk(backuper, 'DialogManager.queue_dialog', function(o, self, id)
		if id == 'pln_rt1_20' then
			cook_meth(needed_chem[1])
		elseif id == 'pln_rt1_22' then
			cook_meth(needed_chem[2])
		elseif id == 'pln_rt1_24' then
			cook_meth(needed_chem[3])
		end
	end, 'chemical_hook', 1)
	add_clbk(backuper, 'ObjectInteractionManager.add_unit', function(o, self, unit)
		executewithdelay(function()
			local interaction = alive(unit) and unit:interaction()
			if interaction and interaction.tweak_data == 'taking_meth' then
				if not spawn_meth_pos then
					local pos = interaction:interact_position()
					spawn_meth_pos = Vector3(pos.x + (level_id == 'alex_1' and -50 or 0), pos.y, pos.z + 10)
				end
				interaction:interact(_players[1])
				if is_client() then
					GetNetSession():send_to_host('server_drop_carry', 'meth', 1, false, false, 1, spawn_meth_pos, Vector3(random(-180, 180), random(-180, 180), 0), UP, 100, nil)
				else
					server_drop_carry(M_player, 'meth', 1, false, false, 1, spawn_meth_pos, Vector3(random(-180, 180), random(-180, 180), 0), UP, 100, nil)
				end
				clear_carry(M_player)
			end
		end, 0.4)
	end, 'bag_meth_hook', 2)
end

function UNLOAD()
	remove_clbk(backuper, 'DialogManager.queue_dialog', 'chemical_hook', 1)
	remove_clbk(backuper, 'ObjectInteractionManager.add_unit', 'bag_meth_hook', 2)
end

FINALIZE()