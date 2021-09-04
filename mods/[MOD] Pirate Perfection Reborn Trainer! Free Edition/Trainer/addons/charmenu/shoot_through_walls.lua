--Purpose: allows you to shoot through walls
--Author: Simplity

plugins:new_plugin('shoot_through_walls')

local query_execution_testfunc = query_execution_testfunc
local m_log_vs = m_log_vs

local managers = managers
local M_player = managers.player
local M_slot = managers.slot

local alive = alive
local pairs = pairs

VERSION = '1.0'

CATEGORY = 'character'

local main, unload

main = function()
	local player = M_player:player_unit()
	if not alive(player) then
		m_log_vs('(shoot_through_walls.lua) Warning! Player is currently dead, delaying callback till player will be alive again.')
		query_execution_testfunc(function() return alive( M_player:player_unit() ) end, { f = main })
		return
	end
	local get_mask = M_slot.get_mask
	for _,selection in pairs(player:inventory()._available_selections) do
		local b = selection.unit:base()
		b.old_mask = b._bullet_slotmask
		b._bullet_slotmask = World:make_slot_mask(7, 11, 12, 14, 16, 17, 18, 21, 22, 25, 26, 33, 34, 35)
	end
end

unload = function()
	local player = M_player:player_unit()
	if not alive(player) then
		return
	end
	for _,selection in pairs(player:inventory()._available_selections) do
		local b = selection.unit:base()
		if b.old_mask then
			b._bullet_slotmask = b.old_mask
			b.old_mask = nil
		end
	end
end

MAIN = main
UNLOAD = unload

FINALIZE()