-- Use only all unlocked Perks at once
function SkillTreeManager:enable_all_perks()
	local specialization_tweak = tweak_data.skilltree.specializations
	local points, points_left, data
	local current_specialization = self:digest_value(self._global.specializations.current_specialization, false)
	for tree, data in ipairs(self._global.specializations) do
		if specialization_tweak[tree] then
			points = self:digest_value(data.points_spent, false)
			points_left = points
			for tier, spec_data in ipairs(specialization_tweak[tree]) do
				if points_left >= spec_data.cost then
					points_left = points_left - spec_data.cost
					for _, upgrade in ipairs(spec_data.upgrades) do
						managers.upgrades:aquire(upgrade, true, UpgradesManager.AQUIRE_STRINGS[3] .. tostring(current_specialization))
					end
					if tier == #specialization_tweak[tree] then
						data.tiers.current_tier = self:digest_value(tier, true)
						data.tiers.max_tier = self:digest_value(#specialization_tweak[tree], true)
						data.tiers.next_tier_data = false
					end
				else
					data.tiers.current_tier = self:digest_value(tier - 1, true)
					data.tiers.max_tier = self:digest_value(#specialization_tweak[tree], true)
					data.tiers.next_tier_data = {	current_points = self:digest_value(points_left, true),
													points = self:digest_value(spec_data.cost, true)
												}
					points_left = 0
					break
				end
			end
			data.points_spent = self:digest_value(points - points_left, true)
		end
	end
end
managers.skilltree:enable_all_perks()