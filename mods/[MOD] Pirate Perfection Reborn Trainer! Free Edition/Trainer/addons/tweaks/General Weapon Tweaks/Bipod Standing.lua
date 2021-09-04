function WeaponLionGadget1:_shoot_bipod_rays(debug_draw)
	local mvec1 = Vector3()
	local mvec2 = Vector3()
	local mvec3 = Vector3()
	local mvec_look_dir = Vector3()
	local mvec_gun_down_dir = Vector3()
	local from = mvec1
	local to = mvec2
	local from_offset = mvec3
	local bipod_max_length = WeaponLionGadget1.bipod_length or 9000
	if not self._bipod_obj then
		return nil
	end
	mrotation.y(self._bipod_obj:rotation(), mvec_look_dir)
	mrotation.x(self._bipod_obj:rotation(), mvec_gun_down_dir)
	if mvec_look_dir:to_polar().pitch > 60 then
		return nil
	end
	mvector3.set(from, self._bipod_obj:position())
	mvector3.set(to, mvec_gun_down_dir)
	mvector3.multiply(to, bipod_max_length)
	mvector3.rotate_with(to, Rotation(mvec_look_dir, 120))
	mvector3.add(to, from)
	local ray_bipod_left = self._unit:raycast(from, to)
	if not debug_draw then
		self._left_ray_from = Vector3(from.x, from.y, from.z)
		self._left_ray_to = Vector3(to.x, to.y, to.z)
	else
		if not ray_bipod_left or not {
			0,
			1,
			0
		} then
			local color = {
				1,
				0,
				0
			}
		end
		Application:draw_line(from, to, unpack(color))
	end
	mvector3.set(to, mvec_gun_down_dir)
	mvector3.multiply(to, bipod_max_length)
	mvector3.rotate_with(to, Rotation(mvec_look_dir, 60))
	mvector3.add(to, from)
	local ray_bipod_right = self._unit:raycast(from, to)
	if not debug_draw then
		self._right_ray_from = Vector3(from.x, from.y, from.z)
		self._right_ray_to = Vector3(to.x, to.y, to.z)
	else
		if not ray_bipod_right or not {
			0,
			1,
			0
		} then
			local color = {
				1,
				0,
				0
			}
		end
		Application:draw_line(from, to, unpack(color))
	end
	mvector3.set(to, mvec_gun_down_dir)
	mvector3.multiply(to, bipod_max_length * math.cos(30))
	mvector3.rotate_with(to, Rotation(mvec_look_dir, 90))
	mvector3.add(to, from)
	local ray_bipod_center = self._unit:raycast(from, to)
	if not debug_draw then
		self._center_ray_from = Vector3(from.x, from.y, from.z)
		self._center_ray_to = Vector3(to.x, to.y, to.z)
	else
		if not ray_bipod_center or not {
			0,
			1,
			0
		} then
			local color = {
				1,
				0,
				0
			}
		end
		Application:draw_line(from, to, unpack(color))
	end
	mvector3.set(from_offset, Vector3(0, -100, 0))
	mvector3.rotate_with(from_offset, self._bipod_obj:rotation())
	mvector3.add(from, from_offset)
	mvector3.set(to, mvec_look_dir)
	mvector3.multiply(to, 500)
	mvector3.add(to, from)
	local ray_bipod_forward = self._unit:raycast(from, to)
	if debug_draw then
		if not ray_bipod_forward or not {
			1,
			0,
			0
		} then
			local color = {
				0,
				1,
				0
			}
		end
		Application:draw_line(from, to, unpack(color))
	end
	return {
		left = ray_bipod_left,
		right = ray_bipod_right,
		center = ray_bipod_center,
		forward = ray_bipod_forward
	}
end