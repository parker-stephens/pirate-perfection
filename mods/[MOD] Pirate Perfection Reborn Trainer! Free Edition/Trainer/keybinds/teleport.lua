--Purpose: Teleport to the position of your crosshair.
--You can penetrate through walls If you'll enable it in the config.

if (not GameSetup) then
	return
end

local get_ray = get_ray
local ppr_config = ppr_config
local M_player = managers.player
local warp_to = M_player.warp_to

local function TELEPORT()
	local ray = get_ray(ppr_config.TeleportPenetrate)
	if ray then
		warp_to(M_player, ray.hit_position, M_player:player_unit():camera():rotation())
	end
end

return TELEPORT