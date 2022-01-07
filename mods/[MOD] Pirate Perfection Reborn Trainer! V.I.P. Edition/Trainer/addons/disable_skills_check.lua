-- Disable skills check
-- TO DO: Don't hardcode function, may break within updates

function SkillTreeManager:_verify_loaded_data(points_aquired_during_load)
	local level_points = managers.experience:current_level()
	local assumed_points = level_points + points_aquired_during_load
	for i, switch_data in ipairs(self._global.skill_switches) do
		local points = assumed_points
		for skill_id, data in pairs(clone(switch_data.skills)) do
			if not tweak_data.skilltree.skills[skill_id] then
				print("[SkillTreeManager:_verify_loaded_data] Skill doesn't exists", skill_id, ", removing loaded data.", "skill_switch", i)
				switch_data.skills[skill_id] = nil
			end
		end
		for tree_id, data in pairs(clone(switch_data.trees)) do
			if not tweak_data.skilltree.trees[tree_id] then
				print("[SkillTreeManager:_verify_loaded_data] Tree doesn't exists", tree_id, ", removing loaded data.", "skill switch", i)
				switch_data.trees[tree_id] = nil
			end
		end
		for tree_id, data in pairs(clone(switch_data.trees)) do
			points = points - Application:digest_value(data.points_spent, false)
		end
		local unlocked = self:trees_unlocked(switch_data.trees)
		while unlocked > 0 do
			unlocked = unlocked - 1
		end
		switch_data.points = Application:digest_value(points, true)
	end

	if not self._global.skill_switches[self._global.selected_skill_switch] then
		self._global.selected_skill_switch = 1
	end
	local data = self._global.skill_switches[self._global.selected_skill_switch]
	self._global.points = data.points
	self._global.trees = data.trees
	self._global.skills = data.skills
	for tree_id, tree_data in pairs(self._global.trees) do
		if tree_data.unlocked and not tweak_data.skilltree.trees[tree_id].dlc then
			for tier, skills in pairs(tweak_data.skilltree.trees[tree_id].tiers) do
				for _, skill_id in ipairs(skills) do
					local skill = tweak_data.skilltree.skills[skill_id]
					local skill_data = self._global.skills[skill_id]
					for i = 1, skill_data.unlocked do
						self:_aquire_skill(skill[i], skill_id, true)
					end
				end
			end
		end
	end
	local specialization_tweak = tweak_data.skilltree.specializations
	local points, points_left, data
	local total_points_spent = 0
	local current_specialization = self:digest_value(self._global.specializations.current_specialization, false, 1)
	local spec_data = specialization_tweak[current_specialization]
	if not spec_data or spec_data.dlc and not managers.dlc:is_dlc_unlocked(spec_data.dlc) then
		local old_specialization = self._global.specializations.current_specialization
		current_specialization = 1
		self._global.specializations.current_specialization = self:digest_value(current_specialization, true, 1)
		for i, switch_data in ipairs(self._global.skill_switches) do
			if switch_data.specialization == old_specialization then
				switch_data.specialization = self._global.specializations.current_specialization
			end
		end
	end
	for tree, data in ipairs(self._global.specializations) do
		if specialization_tweak[tree] then
			points = self:digest_value(data.points_spent, false)
			points_left = points
			for tier, spec_data in ipairs(specialization_tweak[tree]) do
				if points_left >= spec_data.cost then
					points_left = points_left - spec_data.cost
					if tree == current_specialization then
						for _, upgrade in ipairs(spec_data.upgrades) do
							managers.upgrades:aquire(upgrade, true, UpgradesManager.AQUIRE_STRINGS[3] .. tostring(current_specialization))
						end
					end
					if tier == #specialization_tweak[tree] then
						data.tiers.current_tier = self:digest_value(tier, true)
						data.tiers.max_tier = self:digest_value(#specialization_tweak[tree], true)
						data.tiers.next_tier_data = false
					end
				else
					data.tiers.current_tier = self:digest_value(tier - 1, true)
					data.tiers.max_tier = self:digest_value(#specialization_tweak[tree], true)
					data.tiers.next_tier_data = {
						current_points = self:digest_value(points_left, true),
						points = self:digest_value(spec_data.cost, true)
					}
					points_left = 0
					break
				end
			end
			data.points_spent = self:digest_value(points - points_left, true)
			total_points_spent = total_points_spent + (points - points_left)
		end
	end
	total_points_spent = total_points_spent + self:digest_value(self._global.specializations.points, false)
	local max_points = self:digest_value(self._global.specializations.max_points, false)
	local points = self:digest_value(self._global.specializations.points, false)
	if total_points_spent > max_points or max_points < points then
		self._global.specializations.total_points = self:digest_value(max_points, true)
		self._global.specializations.points = self:digest_value(math.max(total_points_spent - max_points, 0), true)
		self._global.specializations.points_present = self:digest_value(0, true)
		self._global.specializations.xp_present = self:digest_value(0, true)
		self._global.specializations.xp_leftover = self:digest_value(0, true)
	end
end
