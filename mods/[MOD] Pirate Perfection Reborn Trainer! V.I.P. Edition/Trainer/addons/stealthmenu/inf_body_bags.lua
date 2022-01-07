-- Infinite body bags
-- Author: Simplity

local backuper = backuper
local backup = backuper.backup
local restore = backuper.restore
local PlayerManager = PlayerManager
local managers = managers
local M_player = managers.player
local _set_body_bags_amount = M_player._set_body_bags_amount
plugins:new_plugin('inf_body_bags')

VERSION = '1.0'

function MAIN()
	backup(backuper, 'PlayerManager.on_used_body_bag')
	function PlayerManager.on_used_body_bag()end
	_set_body_bags_amount(M_player, 17) --Just in case, if player have no body bags at the start.
end

function UNLOAD()
	restore(backuper, 'PlayerManager.on_used_body_bag')
end

FINALIZE()