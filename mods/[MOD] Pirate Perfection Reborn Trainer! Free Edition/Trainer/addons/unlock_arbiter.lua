backuper:backup('BlackMarketManager.has_unlocked_arbiter')
function BlackMarketManager:has_unlocked_arbiter()
	return managers.tango:has_unlocked_arbiter()
end
backuper:backup('TangoManager.has_unlocked_arbiter')
function TangoManager:has_unlocked_arbiter()
	return true
end