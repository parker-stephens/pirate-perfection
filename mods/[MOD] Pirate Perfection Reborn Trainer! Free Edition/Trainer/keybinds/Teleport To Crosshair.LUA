-- TELEPORT/PENETRATE SCRIPT

if inGame() and isPlaying() and not inChat() and not InOverlay() then

	local player_unit = managers.player:player_unit()
	local rot0 = Rotation(0,0,0)
	local get_ray = get_ray
	local ppr_config = ppr_config
	local M_player = managers.player
	local warp_to = M_player.warp_to
	local ray = get_ray(ppr_config.TeleportPenetrate)
	
	if ray then
		managers.player:warp_to(ray.hit_position, rot0, 1)
		--managers.player:warp_to(ray.hit_position, player_unit:position(), 1, rot0)
		show_mid_text("Teleport","Penetrative",0.25)
		beep()
	end
end


--[[
function PlayerMovement:warp_to(pos, rot, velocity)
	self._unit:warp_to(rot, pos)
	if velocity then
		self:push(velocity)
	end
	local camera_base = self:current_state()._camera_unit:base()
	camera_base._camera_properties.spin = rot:yaw() + 90
	camera_base._camera_properties.pitch = rot:pitch()
end
]]