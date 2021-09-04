--Community DLC weapons unlock
function GenericDLCManager:has_pd2_clan()
	return true
end

--OJ Simpson's Master DLC Unlock
for dlc_name, dlc_data in pairs( Global.dlc_manager.all_dlc_data ) do
	dlc_name = { app_id = "218620", no_install = true }
	dlc_data.verified = true
end