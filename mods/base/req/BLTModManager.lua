
BLTModManager = blt_class( BLTModule )
BLTModManager.__type = "BLTModManager"

function BLTModManager:init()

	BLTModManager.super.init(self)

	Hooks:Register( "BLTOnSaveData" )
	Hooks:Register( "BLTOnLoadData" )

end

function BLTModManager:Mods()
	return self.mods
end

function BLTModManager:GetMod( id )
	for _, mod in ipairs( self:Mods() ) do
		if mod:GetId() == id then
			return mod
		end
	end
end

function BLTModManager:GetModOwnerOfFile( file )
	for _, mod in pairs( self:Mods() ) do
		if string.find( file, mod:GetPath() ) == 1 then
			return mod
		end
	end
end

function BLTModManager:SetModsList( mods_list )

	-- Set mods
	self.mods = mods_list

	-- Load data
	self:Load()

end

function BLTModManager:IsExcludedDirectory( directory )
	return BLTModManager.Constants.ExcludedModDirectories[directory]
end

--------------------------------------------------------------------------------
-- Autoupdates

function BLTModManager:RunAutoCheckForUpdates()

	-- Don't run the autocheck twice
	if self._has_checked_for_updates then
		return
	end
	self._has_checked_for_updates = true

	call_on_next_update( callback(self, self, "_RunAutoCheckForUpdates") )

end

function BLTModManager:_RunAutoCheckForUpdates()

	-- Place a notification that we're checking for autoupdates
	if BLT.Notifications then 
		local icon, rect = tweak_data.hud_icons:get_icon_data("csb_pagers")
		self._updates_notification = BLT.Notifications:add_notification( {
			title = managers.localization:text("blt_checking_updates"),
			text = managers.localization:text("blt_checking_updates_help"),
			icon = icon,
			icon_texture_rect = rect,
			color = Color.white,
			priority = 1000,
		} )
	end

	-- Start checking all enabled mods for updates
	local count = 0
	for _, mod in ipairs( self:Mods() ) do
		for _, update in ipairs( mod:GetUpdates() ) do
			if update:IsEnabled() then
				update:CheckForUpdates( callback(self, self, "clbk_got_update") )
				count = count + 1
			end
		end
	end

	-- -- Remove notification if not getting updates
	if count < 1 and self._updates_notification then
		BLT.Notifications:remove_notification( self._updates_notification )
		self._updates_notification = nil
	end

end

function BLTModManager:clbk_got_update( update, required, reason )

	-- Add the pending download if required
	if required then
		BLT.Downloads:add_pending_download( update )
	end

	-- Check if any mods are still updating
	local still_checking = false
	for _, mod in ipairs( self:Mods() ) do
		if mod:IsCheckingForUpdates() then
			still_checking = true
			break
		end
	end

	if not still_checking then

		-- Remove the old notification
		if self._updates_notification then
			BLT.Notifications:remove_notification( self._updates_notification )
			self._updates_notification = nil
		end

		-- Add notification if we need updates
		if table.size( BLT.Downloads:pending_downloads() ) > 0 then

			local icon, rect = tweak_data.hud_icons:get_icon_data("csb_pagers")
			self._updates_notification = BLT.Notifications:add_notification( {
				title = managers.localization:text("blt_checking_updates_required"),
				text = managers.localization:text("blt_checking_updates_required_help"),
				icon = icon,
				icon_texture_rect = rect,
				color = Color.white,
				priority = 1000,
			} )

		else

			local icon, rect = tweak_data.hud_icons:get_icon_data("csb_pagers")
			self._updates_notification = BLT.Notifications:add_notification( {
				title = managers.localization:text("blt_checking_updates_none_required"),
				text = managers.localization:text("blt_checking_updates_none_required_help"),
				icon = icon,
				icon_texture_rect = rect,
				color = Color.white,
				priority = 0,
			} )

		end

	end

end

--------------------------------------------------------------------------------
-- Saving and Loading

function BLTModManager:Load()

	-- If we have old save files, then load their data
	if self:HasOldSaveFiles() then
		self:ConvertOldSaveFiles()
	end

	-- Load data
	local saved_data = io.load_as_json( BLTModManager.Constants:ModManagerSaveFile() ) or {}

	-- Process mods
	if saved_data["mods"] then

		for index, mod in ipairs( self.mods ) do
			if saved_data["mods"][mod:GetId()] then

				local data = saved_data["mods"][mod:GetId()]

				mod:SetEnabled( data["enabled"], true )
				mod:SetSafeModeEnabled( data["safe"] )
				
				local updates = data["updates"]
				if updates then
					for update_id, enabled in pairs( updates ) do
						local update = mod:GetUpdate( update_id )
						if update then
							update:SetEnabled( enabled )
						end
					end
				end

			end
		end

	end

	-- Setup mods
	for index, mod in ipairs( self.mods ) do
		mod:Setup()
	end

	-- Call load hook
	Hooks:Call("BLTOnLoadData", saved_data)
	
	-- Stash it for use later
	self._saved_data = saved_data

end

function BLTModManager:HasOldSaveFiles()
	return io.file_is_readable( BLTModManager.Constants:OldModManagerSaveFile() ) or
			io.file_is_readable( BLTModManager.Constants:OldModManagerKeybindsFile() ) or
			io.file_is_readable( BLTModManager.Constants:OldModManagerUpdatesFile() )
end

function BLTModManager:ConvertOldSaveFiles()

	print("[BLT] Converting old save data files to new format...")

	-- Load old files
	local enabled_mods = io.load_as_json( BLTModManager.Constants:OldModManagerSaveFile() )
	if enabled_mods == nil or type(enabled_mods) ~= "table" then
		enabled_mods = {}
	end

	-- Convert enabled mods data
	for mod_id, enabled in pairs( enabled_mods ) do
		for index, mod in ipairs( self.mods ) do
			if mod_id == mod:GetId() then
				mod:SetEnabled( enabled )
				break
			end
		end
	end

	-- Only remove old files if we sucessfully save the new data
	if self:Save() then
		os.remove( BLTModManager.Constants:OldModManagerSaveFile() )
		os.remove( BLTModManager.Constants:OldModManagerKeybindsFile() )
		os.remove( BLTModManager.Constants:OldModManagerUpdatesFile() )
		print("[BLT] ...Success!")
	else
		print("[BLT] ...Failed! Will try again at a later time!")
	end

end

function BLTModManager:Save()

	log("[BLT] Performing save...")

	local save_data = {}

	-- Write mod/updates data
	save_data["mods"] = {}
	for index, mod in ipairs( self.mods ) do

		-- Save mod updates enabled data
		local updates = {}
		for index, update in ipairs( mod:GetUpdates() ) do
			updates[update:GetId()] = update:IsEnabled()
		end

		save_data["mods"][mod:GetId()] = {
			["enabled"] = mod:IsEnabled(),
			["safe"] = mod:IsSafeModeEnabled(),
			["updates"] = updates
		}

	end

	-- Hook to allow modules to save data
	Hooks:Call("BLTOnSaveData", save_data)

	self._saved_data = save_data

	local success = io.save_as_json( save_data, BLTModManager.Constants:ModManagerSaveFile() )
	log("[BLT] Save complete? " .. tostring(success))
	return success

end

--------------------------------------------------------------------------------
-- Constants
--------------------------------------------------------------------------------

BLTModManager.Constants = BLTModManager.Constants or {
	["mods_directory"] = "mods/",
	["lua_base_directory"] = "base/",
	["downloads_directory"] = "downloads/",
	["logs_directory"] = "logs/",
	["saves_directory"] = "saves/",
}
BLTModManager.Constants.ExcludedModDirectories = {
	["logs"] = true,
	["saves"] = true,
	["downloads"] = true,
}
BLTModManager.Constants.required_script_global = "RequiredScript"
BLTModManager.Constants.mod_path_global = "ModPath"
BLTModManager.Constants.logs_path_global = "LogsPath"
BLTModManager.Constants.save_path_global = "SavePath"
BLTModManager.Constants.mod_instance_global = "ModInstance"

BLTModManager.Constants.lua_mods_menu_id = "blt_mods_new"
BLTModManager.Constants.lua_mod_options_menu_id = "blt_options"

function BLTModManager.Constants:ModsDirectory()
	return self["mods_directory"]
end

function BLTModManager.Constants:BaseDirectory()
	return self["mods_directory"] .. self["lua_base_directory"]
end

function BLTModManager.Constants:DownloadsDirectory()
	return self["mods_directory"] .. self["downloads_directory"]
end

function BLTModManager.Constants:LogsDirectory()
	return self["mods_directory"] .. self["logs_directory"]
end

function BLTModManager.Constants:SavesDirectory()
	return self["mods_directory"] .. self["saves_directory"]
end

function BLTModManager.Constants:ModManagerSaveFile()
	return self:SavesDirectory() .. "blt_data.txt"
end

function BLTModManager.Constants:OldModManagerSaveFile()
	return self:SavesDirectory() .. "mod_manager.txt"
end

function BLTModManager.Constants:OldModManagerKeybindsFile()
	return self:SavesDirectory() .. "mod_keybinds.txt"
end

function BLTModManager.Constants:OldModManagerUpdatesFile()
	return self:SavesDirectory() .. "mod_updates.txt"
end

function BLTModManager.Constants:LuaModsMenuID()
	return self["lua_mods_menu_id"]
end

function BLTModManager.Constants:LuaModOptionsMenuID()
	return self["lua_mod_options_menu_id"]
end

-- Backwards compatibility
BLTModManager.Constants._lua_mods_menu_id = BLTModManager.Constants.lua_mods_menu_id
BLTModManager.Constants._lua_mod_options_menu_id = BLTModManager.Constants.lua_mod_options_menu_id
