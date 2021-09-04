if not MissionDoor then return nil end
function MissionDoor:device_placed(unit, type)
	if  unit == nil or type == nil then
		return
	end
	local device_unit_data = self:_get_device_unit_data(unit, type)
	if device_unit_data.placed then
		CoreDebug.cat_debug("gaspode", "MissionDoor:device_placed", "Allready placed")
		return
	end
	self._devices[type].placed_counter = self._devices[type].placed_counter + 1
	device_unit_data.placed = true
	self:trigger_sequence(type .. "_placed")
	self:_check_placed_counter(type)
end