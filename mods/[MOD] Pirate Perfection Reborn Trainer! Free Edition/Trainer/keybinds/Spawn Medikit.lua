if inGame() and isPlaying() and not inChat() then
	-- SPAWN MEDIKIT ON SELF
	local from = managers.player:player_unit():movement():m_head_pos()
	local to = from + managers.player:player_unit():movement():m_head_rot():y() * 200
	local ray = managers.player:player_unit():raycast("ray", from, to, "slot_mask", managers.slot:get_mask("trip_mine_placeables"), "ignore_unit", {})
	if ray then
		local pos = ray.position
		local rot = managers.player:player_unit():movement():m_head_rot()
		local rot = Rotation( rot:yaw(), 0, 0 )
	local amount_upgrade_lvl = managers.player:upgrade_level( "doctor_bag", "amount_increase" )
	if Network:is_client() then
			managers.chat:send_message( 1, managers.network.account:username(), "aaaaar")
	else
		local unit = DoctorBagBase.spawn( pos, rot, amount_upgrade_lvl )
	end
	end
else
end
return tostring(GroupAIStateBase:police_hostage_count())