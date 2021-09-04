function inGame() 
  if not game_state_machine then return false end 
	return string.find(game_state_machine:current_state_name(), "game") 
end 
if inGame() and isPlaying() and not inChat() then
	-- SPAWN TRIPMINE ON SELF
	local from = managers.player:player_unit():movement():m_head_pos()
	local to = from + managers.player:player_unit():movement():m_head_rot():y() * 200
	local ray = managers.player:player_unit():raycast("ray", from, to, "slot_mask", managers.slot:get_mask("trip_mine_placeables"), "ignore_unit", {})
	if ray then
		local pos = ray.position
		local unit2 = managers.player:player_unit()
		local sensor_upgrade = managers.player:has_category_upgrade( "trip_mine", "sensor_toggle" )
		if Network:is_client() then
			managers.chat:send_message( 1, managers.network.account:username(), "mutiny")
			--managers.network:session():send_to_host( "attach_device", pos, ray.normal, sensor_upgrade )
		else
			local rot = Rotation( ray.normal, math.UP )
			local unit = TripMineBase.spawn( pos, rot, sensor_upgrade )
			unit:base():set_active( true, unit2 )
		end
	end
else
end


