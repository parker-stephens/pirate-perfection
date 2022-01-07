-- God mode
-- Author: adapted by baldwin, original: ???

plugins:new_plugin('god_mode')

local alive = alive
local managers = managers
local M_player = managers.player

VERSION = '1.0'

CATEGORY = 'character'

local function verify_ply_alive()
	local ply = M_player:player_unit()
	return alive(ply) and ply
end

local function set_god_mode( bool )
	local player = verify_ply_alive()
	if not player then
		return
	end
	player:character_damage():set_god_mode( bool ) --Godmode being stored in global variable aswell.
end

function MAIN()
	query_execution_testfunc(verify_ply_alive, { f = set_god_mode, a = { true } } )
end

function UNLOAD()
	query_execution_testfunc(verify_ply_alive, { f = set_god_mode, a = { false } } )
end

FINALIZE()