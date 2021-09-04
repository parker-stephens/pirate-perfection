-- IMPROVED TRIPMINE
if not TripMineBase then return nil end
function TripMineBase:_set_armed(armed)
	self._armed = armed
	if not self._first_armed then
		self._first_armed = true
		self._activate_timer = nil
		if self._sensor_upgrade then
			self._armed = not managers.groupai:state():whisper_mode()
		end
		self._unit:sound_source():post_event("trip_mine_beep_armed")
	end
	self._g_laser:set_visibility(self._armed)
	self._g_laser_sensor:set_visibility(self._sensor_upgrade and not self._armed)
	if self._use_draw_laser then
		self._laser_brush:set_color(self._armed and self._laser_color or self._sensor_upgrade and self._laser_sensor_color or self._laser_color)
	end
	self._unit:sound_source():post_event(self._armed and "trip_mine_arm" or "trip_mine_disarm")
	self._unit:interaction():set_dirty(true)
end

function TripMineBase:interaction_text_id()
	if not self._first_armed and self._sensor_upgrade then
		return managers.groupai:state():whisper_mode() and "hud_int_equipment_sensor_mode_trip_mine" or "hud_int_equipment_normal_mode_trip_mine"
	end
	return self._sensor_upgrade and (self._armed and "hud_int_equipment_sensor_mode_trip_mine" or "hud_int_equipment_normal_mode_trip_mine") or "debug_interact_trip_mine"
end