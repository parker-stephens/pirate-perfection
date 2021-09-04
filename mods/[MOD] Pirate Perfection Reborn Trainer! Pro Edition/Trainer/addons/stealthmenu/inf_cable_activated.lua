-- Infinite cable-ties
-- Author: Simplity

ppr_require("Trainer/addons/ply_equip_fix")
local backuper = backuper
local M_player = managers.player
local add_special = M_player.add_special
local cable_tie_special = { name = "cable_tie", amount = 1 }
local set_infinite_special = M_player.set_infinite_special

plugins:new_plugin('inf_cable_activated')

VERSION = '1.0'

function MAIN()
	set_infinite_special("cable_tie", true)
	add_special(M_player, cable_tie_special) --Add 1 more cable in case, if player don't have cable ties yet
end

function UNLOAD()
	set_infinite_special("cable_tie", nil)
end

FINALIZE()