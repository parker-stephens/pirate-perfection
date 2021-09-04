
-- BLT Update Callbacks
-- If you want to only conditionally enable updates for your mod, define
--   a function onto this table and add a present_func tag to your update block
BLTUpdateCallbacks = {}

function BLTUpdateCallbacks.blt_can_update_dll(update)
	if not file.FileExists then
		return update.hash_file == "./IPHLPAPI.dll"
	end

	return file.FileExists(update.hash_file)
end
