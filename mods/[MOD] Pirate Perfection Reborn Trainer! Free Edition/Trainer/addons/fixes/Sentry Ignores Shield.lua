if not SentryGunBrain then return nil end
local mvec3_dir = mvector3.direction
local mvec3_dot = mvector3.dot
local math_max = math.max
local tmp_vec1 = Vector3()

function SentryGunBrain:_choose_focus_enemy(t)
	local delay = 1
	local enemies = managers.enemy:all_enemies()
	local my_tracker = self._unit:movement():nav_tracker()
	local chk_vis_func = my_tracker.check_visibility
	local my_pos = self._m_head_object_pos
	local my_team = self._unit:movement():team()
	for e_key, enemy_data in pairs(enemies) do
		local enemy_unit = enemy_data.unit
		if not my_team.foes[enemy_data.unit:movement():team().id] or enemy_unit:brain()._current_logic_name == "trade" or enemy_unit:base()._tweak_table == "shield" then
			self._AI_data.detected_enemies[e_key] = nil
		elseif self._AI_data.detected_enemies[e_key] then
			local enemy_data = self._AI_data.detected_enemies[e_key]
			local visible
			local enemy_pos = enemy_data.m_com
			local vis_ray = World:raycast("ray", my_pos, enemy_pos, "slot_mask", self._visibility_slotmask, "ray_type", "ai_vision", "report")
			if not vis_ray then
				visible = true
			end
			enemy_data.verified = visible
			if visible then
				delay = math.min(0.6, delay)
				enemy_data.verified_t = t
				enemy_data.verified_dis = mvector3.distance(enemy_pos, my_pos)
			elseif not enemy_data.verified_t or t - enemy_data.verified_t > 3 then
				enemy_unit:base():remove_destroy_listener(enemy_data.destroy_clbk_key)
				enemy_unit:character_damage():remove_listener(enemy_data.death_clbk_key)
				self._AI_data.detected_enemies[e_key] = nil
			end
		elseif chk_vis_func(my_tracker, enemy_data.tracker) then
			local my_pos = self._m_head_object_pos
			local enemy_pos = enemy_unit:movement():m_head_pos()
			local enemy_dis = mvector3.distance(enemy_pos, my_pos)
			local dis_multiplier
			dis_multiplier = enemy_dis / self._AI_data.detection.dis_max
			if dis_multiplier < 1 then
				delay = math.min(delay, dis_multiplier)
				if not World:raycast("ray", my_pos, enemy_pos, "slot_mask", self._visibility_slotmask, "ray_type", "ai_vision", "report") then
					local enemy_data = self:_create_enemy_detection_data(enemy_unit)
					enemy_data.verified_t = t
					enemy_data.verified = true
					self._AI_data.detected_enemies[e_key] = enemy_data
				end
			end
		end
	end
	local focus_enemy = self._AI_data.focus_enemy
	local cam_fwd
	if focus_enemy then
		cam_fwd = tmp_vec1
		mvec3_dir(cam_fwd, my_pos, focus_enemy.m_com)
	else
		cam_fwd = self._ext_movement:m_head_fwd()
	end
	local max_dis = 15000
	local function _get_weight(enemy_data)
		local dis = mvec3_dir(tmp_vec1, my_pos, enemy_data.m_com)
		local dis_weight = math_max(0, (max_dis - dis) / max_dis)
		local dot_weight = 1 + mvec3_dot(tmp_vec1, cam_fwd)
		return dot_weight * dot_weight * dot_weight * dis_weight
	end

	local focus_enemy_weight
	if focus_enemy then
		focus_enemy_weight = _get_weight(focus_enemy) * 4
	end
	for e_key, enemy_data in pairs(self._AI_data.detected_enemies) do
		if not enemy_data.death_verify_t then
			local weight = _get_weight(enemy_data)
			if not focus_enemy_weight or focus_enemy_weight < weight then
				focus_enemy_weight = weight
				focus_enemy = enemy_data
			end
		end
	end
	if self._AI_data.focus_enemy ~= focus_enemy then
		if focus_enemy then
			local attention = {
				unit = focus_enemy.unit
			}
			self._ext_movement:set_attention(attention)
		else
			self._ext_movement:set_attention()
		end
		self._AI_data.focus_enemy = focus_enemy
	end
	return delay
end