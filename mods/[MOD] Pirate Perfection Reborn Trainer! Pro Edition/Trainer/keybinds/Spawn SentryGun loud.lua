if inGame() and isPlaying() and not inChat() then
	-- SPAWN SENTRY ON SELF
	spsentry = spsentrys or function()
		local ammo_multiplier = managers.player:upgrade_value( "sentry_gun", "extra_ammo_multiplier", 1 )
		--ammo_multiplier = 80000 * managers.player:upgrade_value( "sentry_gun", "extra_ammo_multiplier", 1 ) --infinite ammo
		local armor_multiplier = managers.player:upgrade_value( "sentry_gun", "armor_multiplier", 1 )
		--armor_multiplier = 80000 * managers.player:upgrade_value( "sentry_gun", "armor_multiplier", 1 ) --infinite health
		local damage_multiplier = managers.player:upgrade_value( "sentry_gun", "damage_multiplier", 1 )
		local unit = managers.player:player_unit()
		local from = managers.player:player_unit():movement():m_head_pos()
		local to = from + managers.player:player_unit():movement():m_head_rot():y() * 200
		local ray = managers.player:player_unit():raycast("ray", from, to, "slot_mask", managers.slot:get_mask("trip_mine_placeables"), "ignore_unit", {})
		if ray then
			local pos = ray.position
			local rot = managers.player:player_unit():movement():m_head_rot()
			local rot = Rotation( rot:yaw(), 0, 0 )
			local selected_index = nil
			if Network:is_client() then
				managers.chat:send_message( 1, managers.network.account:username(), "pirateperfection.com")
				--managers.network:session():send_to_host( "place_sentry_gun", pos, rot, ammo_multiplier, armor_multiplier, damage_multiplier, selected_index, unit )
				--PlayerEquipment.sentrygun_placement_requested = true
			else
				local shield = managers.player:has_category_upgrade( "sentry_gun", "shield" )
				local sentry_gun_unit = SentryGunBase.spawn( unit, pos, rot, ammo_multiplier, armor_multiplier, damage_multiplier )
				if sentry_gun_unit then
					managers.network:session():send_to_peers_synched( "from_server_sentry_gun_place_result", managers.network:session():local_peer():id(), selected_index, sentry_gun_unit, sentry_gun_unit:movement()._rot_speed_mul, sentry_gun_unit:weapon()._setup.spread_mul, shield )
				else
				end
			end
		end
	end
else
end
spsentry()