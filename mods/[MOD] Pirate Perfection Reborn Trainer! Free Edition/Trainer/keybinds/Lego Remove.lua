-- REMOVE LEGO PIECE SCRIPT

if inGame() and isPlaying() and isHost() and not inChat() then
	local camera = managers.player:player_unit():movement()._current_state._ext_camera
	local mvec_to = Vector3()
	local from_pos = camera:position()
	mvector3.set( mvec_to, camera:forward() )
	mvector3.multiply( mvec_to, 20000 )
	mvector3.add( mvec_to, from_pos )
	local col_ray = World:raycast( "ray", from_pos, mvec_to, "slot_mask", managers.slot:get_mask( "bullet_impact_targets" ) )
	if col_ray and col_ray.unit:name() == Idstring("units/payday2/equipment/gen_equipment_grenade_crate/gen_equipment_grenade_crate") then 
		local fh = io.open( "Trainer/lego/save.lua", "r+" )
		local b = fh:read( '*all' )
		a = tostring(col_ray.unit:position())
		a =  string.gsub(a, '%(', '%%(')
		a =  string.gsub(a, '%)', '%%)')
		a =  string.gsub(a, '%-', '%%-')
		a =  string.gsub(a, '%.', '%%.')
		b = string.gsub(tostring(b), 'GrenadeCrateBase%.spawn%( '..a..' , managers%.player:player_unit%(%):rotation%(%)%) \n', '')
		local file = io.open( "Trainer/lego/save.lua", "w" )
		file:write(b)
		file:close()
		fh:close()
		World:delete_unit(col_ray.unit)
	end
else
	--PlayMedia("Trainer/media/effects/access.mp3")
end