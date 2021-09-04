-- PLACE LEGO PIECE SCRIPT
-- function inGame() 
  -- if not game_state_machine then return false end 
  -- return string.find(game_state_machine:current_state_name(), "game") 
-- end 
-- function show_mid_text( msg, msg_title, show_secs ) 
    -- if managers and managers.hud then 
    -- managers.hud:present_mid_text( { text = msg, title = msg_title, time = show_secs } ) 
    -- end 
-- end 
if inGame() and isPlaying() and isHost() and not inChat() then
	local camera = managers.player:player_unit():movement()._current_state._ext_camera
	local mvec_to = Vector3()
	local from_pos = camera:position()
	mvector3.set( mvec_to, camera:forward() )
	mvector3.multiply( mvec_to, 20000 )
	mvector3.add( mvec_to, from_pos )
	local col_ray = World:raycast( "ray", from_pos, mvec_to, "slot_mask", managers.slot:get_mask( "bullet_impact_targets" ) )
	if col_ray then
		GrenadeCrateBase.spawn(col_ray.position, managers.player:player_unit():rotation())
		if Lego.record then
			local fh = io.open( "Trainer/lego/save.lua", "a" )
			fh:write( "GrenadeCrateBase.spawn( ",tostring(col_ray.position)," , managers.player:player_unit():rotation()) \n" )
			io.close( fh )
		end
	end
else
	--PlayMedia("Trainer/media/effects/access.mp3")
end