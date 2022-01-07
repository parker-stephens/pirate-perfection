--Purpose: auto intimidator for enemies and civilians
--Author: baldwin

plugins:new_plugin('intimidator')

VERSION = '1.0'

local managers = managers
local GetPly = GetPlayerUnit
local M_enemy = managers.enemy
local HUGE = math.huge
local alive = alive
local pairs = pairs

local RunNewLoopIdent = RunNewLoopIdent
local StopLoopIdent = StopLoopIdent

function MAIN()
	local function __clbk()
		local ply = GetPly()
		if not alive(ply) then
			return
		end
		for _,ud in pairs( M_enemy:all_civilians() ) do
			ud.unit:brain():on_intimidated(HUGE,ply)
		end
		for _,ud in pairs( M_enemy:all_enemies() ) do
			ud.unit:brain():on_intimidated(HUGE,ply)
		end
	end
	RunNewLoopIdent('intimidator', __clbk)
end

function UNLOAD()
	StopLoopIdent('initmidator')
end

FINALIZE()