--Author: ThisJazzman (revived old underground script, which orignally was written by ****)

plugins:new_plugin('noone_shall_down')

VERSION = '1.1'

DESCRIPTION = 'Will automatically revive player if he downs'

--Preloading globals and tables into locals (upvalues)
local alive = alive
local pairs = pairs

local managers = managers
local M_network = managers.network
local get_player_unit = GetPlayerUnit
local revive_by_interaction = ReviveInteractionExt.interact

local add_clbk
local rem_clbk
local ply --Here will be player

do
	local backuper = backuper
	local __add_clbk = backuper.add_clbk
	add_clbk = function( ... )
		return __add_clbk(backuper, ...)
	end
	local remove_clbk = backuper.remove_clbk
	rem_clbk = function( ... )
		return remove_clbk(backuper, ...)
	end
end
--

--If player was dead, restore him into locals
local catch_player = function()
	if not alive(ply) then
		ply = get_player_unit()
	end
	return ply
end

local do_revive = function( ext )
	if catch_player() then
		revive_by_interaction( ext, ply )
	end
end

function MAIN()
	add_clbk('ReviveInteractionExt.set_active',
		function( r, self, active )
			if active then
				do_revive( self )
			end
		end,
		'on_downed', 2
	)
	catch_player()
end

function UNLOAD()
	rem_clbk('ReviveInteractionExt.set_active', 'on_downed', 2)
end

FINALIZE()