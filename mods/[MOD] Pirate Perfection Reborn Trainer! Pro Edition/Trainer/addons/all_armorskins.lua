-- Unlock Armor Skins
function BlackMarketManager:_remove_unowned_armor_skin()
	local armor_skins = {}
	Global.blackmarket_manager.armor_skins = armor_skins
	for id, skin in pairs(tweak_data.economy.armor_skins) do
		armor_skins[id] = {unlocked = true}
	end
	return false
end