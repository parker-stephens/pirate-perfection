-- Unlock all skill tiers
-- Author: Simplity

function SkillTreeManager:tier_unlocked()
	return true
end

for _, data in pairs( Global.skilltree_manager.trees ) do
	data.unlocked = true
end