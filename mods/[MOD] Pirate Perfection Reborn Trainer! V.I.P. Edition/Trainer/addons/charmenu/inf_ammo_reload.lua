-- Infinite ammo with reload
-- Author: baddog-11

plugins:new_plugin('inf_ammo_reload')

local managers = managers
local M_player = managers.player

VERSION = '1.0'

CATEGORY = 'character'

function MAIN()
	local on_reload = backuper:backup('RaycastWeaponBase.on_reload')
	function RaycastWeaponBase:on_reload(...)
		if M_player:player_unit() == self._setup.user_unit then
			self.set_ammo(self, 1.0)
		else
			on_reload(self, ...)
		end
	end
end

function UNLOAD()
	backuper:restore('RaycastWeaponBase.on_reload')
end

FINALIZE()