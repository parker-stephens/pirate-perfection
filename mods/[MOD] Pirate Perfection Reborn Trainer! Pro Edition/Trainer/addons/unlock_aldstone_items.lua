-- Force Unlock All Aldstone Items

backuper:backup('BlackMarketManager.has_unlocked_breech')
function BlackMarketManager.has_unlocked_breech()
	return true, "bm_menu_locked_breech"
end

backuper:backup('BlackMarketManager.has_unlocked_ching')
function BlackMarketManager.has_unlocked_ching()
	return true, "bm_menu_locked_ching"
end

backuper:backup('BlackMarketManager.has_unlocked_erma')
function BlackMarketManager.has_unlocked_erma()
	return true, "bm_menu_locked_erma"
end
--[[
backuper:backup('GenericDLCManager.has_raidww2_clan')
function GenericDLCManager.has_raidww2_clan()
	return true
end]]