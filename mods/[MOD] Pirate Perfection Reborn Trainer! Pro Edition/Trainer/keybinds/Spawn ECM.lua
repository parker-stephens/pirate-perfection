-- SPAWN ECM ON XHAIR
if inGame() and isPlaying() and not inChat() then
	local from = managers.player:player_unit():movement():m_head_pos()
	local to = from + managers.player:player_unit():movement():m_head_rot():y() * 200
	local ray = managers.player:player_unit():raycast("ray", from, to, "slot_mask", managers.slot:get_mask("trip_mine_placeables"), "ignore_unit", {})
	if ray then
		local pos = ray.position
		local unit2 = managers.player:player_unit()
		local duration_multiplier = managers.player:upgrade_value( "ecm_jammer", "duration_multiplier", 1 ) * managers.player:upgrade_value( "ecm_jammer", "duration_multiplier_2", 1 )
		if Network:is_client() then
			managers.chat:send_message( 1, managers.network.account:username(), "squak")
			--managers.network:session():send_to_host( "request_place_ecm_jammer", pos, ray.normal, duration_multiplier )
			--PlayerEquipment.ecm_jammer_placement_requested = true
		else
			local rot = Rotation(ray.normal, math.UP)
			local unit = ECMJammerBase.spawn( pos, rot, duration_multiplier, unit2 )
			unit:base():set_active( true )
		end
	end
else
end