
-- BLT Mod
BLTMod = blt_class()
BLTMod.enabled = true
BLTMod._enabled = true
BLTMod.path = ""
BLTMod.json_data = ""
BLTMod.id = "blt_mod"
BLTMod.name = "Unnamed BLT Mod"
BLTMod.desc = "No description."
BLTMod.version = "1.0"
BLTMod.author = "Unknown"
BLTMod.contact = "N/A"
BLTMod.priority = 0

function BLTMod:init( ident, data )

	assert( ident, "BLTMods can not be created without a mod identifier!" )
	assert( data, "BLTMods can not be created without json data!" )

	self._errors = {}

	-- Mod information
	self.json_data = data
	self.id = ident
	self.path = string.format("mods/%s/", ident)
	self.name = data["name"] or "Error: No Name!"
	self.desc = data["description"] or self.desc
	self.version = data["version"] or self.version
	self.blt_version = data["blt_version"] or "unknown"
	self.author = data["author"] or self.author
	self.contact = data["contact"] or self.contact
	self.priority = tonumber(data["priority"]) or 0
	self.dependencies = data["dependencies"] or {}
	self.image_path = data["image"] or nil
	self.disable_safe_mode = data["disable_safe_mode"] or false
	self.undisablable = data["undisablable"] or false
	self.safe_mode = true
	self.library = data["is_library"] or false

	-- Parse color info
	-- Stored as a table until first requested due to Color not existing yet
	if data["color"] and type(data["color"]) == "string" then
		local colors = string.blt_split( data["color"], ' ' )
		local cp = {}
		local divisor = 1
		for i = 1, 3 do
			local c = tonumber(colors[i] or 0)
			table.insert( cp, c )
			if c > 1 then
				divisor = 255
			end
		end
		if divisor > 1 then
			for i, val in ipairs( cp ) do
				cp[i] = val / divisor
			end
		end
		self.color = cp
	end

	-- Updates data
	self.updates = {}
	for i, update_data in ipairs( self.json_data["updates"] or {} ) do
		local new_update = BLTUpdate:new( self, update_data )
		if new_update:IsPresent() then
			table.insert( self.updates, new_update )
		end
	end

end

function BLTMod:Setup()

	print("[BLT] Setting up mod: ", self:GetId())

	-- Check mod is compatible with this version of the BLT
	if self:GetBLTVersion() ~= BLT:GetVersion() then
		self._outdated = true
		table.insert( self._errors, "blt_mod_outdated" )
	end

	-- Check dependencies are installed for this mod
	if not self:AreDependenciesInstalled() then
		table.insert( self._errors, "blt_mod_missing_dependencies" )
		self:RetrieveDependencies()
		return
	end

	-- Hooks data
	self.hooks = {}
	self:AddHooks( "hooks", BLT.hook_tables.post, BLT.hook_tables.wildcards )
	self:AddHooks( "pre_hooks", BLT.hook_tables.pre, BLT.hook_tables.wildcards )

	-- Keybinds
	if BLT.Keybinds then
		for i, keybind_data in ipairs( self.json_data["keybinds"] or {} ) do
			BLT.Keybinds:register_keybind_json( self, keybind_data )
		end
	end

	-- Persist Scripts
	for i, persist_data in ipairs( self.json_data["persist_scripts"] or {} ) do
		if persist_data and persist_data["global"] and persist_data["script_path"] then
			self:AddPersistScript( persist_data["global"], persist_data["script_path"] )
		end
	end	

	-- Set up the supermod instance
	self.supermod = BLTSuperMod.try_load(self, self.json_data["supermod_definition"])

end

function BLTMod:AddHooks( data_key, destination, wildcards_destination )

	for i, hook_data in ipairs( self.json_data[data_key] or {} ) do

		local hook_id = hook_data["hook_id"] and hook_data["hook_id"]:lower()
		local script = hook_data["script_path"]

		self:AddHook( data_key, hook_id, script, destination, wildcards_destination )

	end

end

function BLTMod:AddHook( data_key, hook_id, script, destination, wildcards_destination )

	self.hooks[data_key] = self.hooks[data_key] or {}

	-- Add hook to info table
	local unique = true
	for i, hook in ipairs( self.hooks[data_key] ) do
		if hook == hook_id then
			unique = false
			break
		end
	end
	if unique then
		table.insert( self.hooks[data_key], hook_id )
	end

	-- Add hook to hooks tables
	if hook_id and script and self:IsEnabled() then

		local data = {
			mod = self,
			script = script
		}

		if hook_id ~= "*" then
			destination[ hook_id ] = destination[ hook_id ] or {}
			table.insert( destination[ hook_id ], data )
		else
			table.insert( wildcards_destination, data )
		end

	end

end

function BLTMod:AddPersistScript( global, file )
	self._persists = self._persists or {}
	table.insert( self._persists, {
		global = global,
		file = file
	} )
end

function BLTMod:GetHooks()
	return (self.hooks or {})["hooks"]
end

function BLTMod:GetPreHooks()
	return (self.hooks or {})["pre_hooks"]
end

function BLTMod:GetPersistScripts()
	return self._persists or {}
end

function BLTMod:Errors()
	if #self._errors > 0 then
		return self._errors
	else
		return false
	end
end

function BLTMod:LastError()
	local n = #self._errors
	if n > 0 then
		return self._errors[n]
	else
		return false
	end
end

function BLTMod:IsOutdated()
	return self._outdated
end

function BLTMod:IsEnabled()
	return self.enabled
end

function BLTMod:WasEnabledAtStart()
	return self._enabled
end

function BLTMod:CanBeDisabled()
	return self.id ~= "base"
end

function BLTMod:SetEnabled( enable, force )
	if not self:CanBeDisabled() then
		-- Base mod must always be enabled
		enable = true
	end
	self.enabled = enable
	if force then
		self._enabled = enable
	end
end

function BLTMod:GetPath()
	return self.path
end

function BLTMod:GetJsonData()
	return self.json_data
end

function BLTMod:GetId()
	return self.id
end

function BLTMod:GetName()
	return self.name
end

function BLTMod:GetDescription()
	return self.desc
end

function BLTMod:GetVersion()
	return self.version
end

function BLTMod:GetBLTVersion()
	return self.blt_version
end

function BLTMod:GetAuthor()
	return self.author
end

function BLTMod:GetContact()
	return self.contact
end

function BLTMod:GetPriority()
	return self.priority
end

function BLTMod:GetColor()
	if not self.color then
		return tweak_data.screen_colors.button_stage_3
	end
	if type(self.color) == "table" then
		self.color = Color(unpack(self.color))
	end
	return self.color
end

function BLTMod:HasModImage()
	return self.image_path ~= nil
end

function BLTMod:GetModImagePath()
	return self:GetPath() .. tostring(self.image_path)
end

function BLTMod:GetModImage()

	if self.mod_image_id then
		return self.mod_image_id
	end

	if not self:HasModImage() or not DB or not DB.create_entry then
		return nil
	end

	-- Check if the file exists on disk and generate if it does
	if SystemFS:exists( Application:nice_path( self:GetModImagePath(), true ) ) then
		
		local new_textures = {}
		local type_texture_id = Idstring( "texture" )
		local path = self:GetModImagePath()
		local texture_id = Idstring(path)

		DB:create_entry( type_texture_id, texture_id, path )
		table.insert( new_textures, texture_id )
		Application:reload_textures( new_textures )

		self.mod_image_id = texture_id

		return texture_id

	else
		log("[Error] Mod image at path does not exist! " .. tostring(self:GetModImagePath()))
		return nil
	end

end

function BLTMod:HasUpdates()
	return table.size(self:GetUpdates()) > 0
end

function BLTMod:GetUpdates()
	return self.updates or {}
end

function BLTMod:GetUpdate( id )
	for _, update in ipairs( self:GetUpdates() ) do
		if update:GetId() == id then
			return update
		end
	end
end

function BLTMod:AreUpdatesEnabled()
	for _, update in ipairs( self:GetUpdates() ) do
		if not update:IsEnabled() then
			return false
		end
	end
	return true
end

function BLTMod:SetUpdatesEnabled( enable )
	for _, update in ipairs( self:GetUpdates() ) do
		update:SetEnabled( enable )
	end
end

function BLTMod:CheckForUpdates( clbk )

	self._update_cache = self._update_cache or {}
	self._update_cache.clbk = clbk

	for _, update in ipairs( self:GetUpdates() ) do
		update:CheckForUpdates( callback(self, self, "clbk_check_for_updates") )
	end

end

function BLTMod:IsCheckingForUpdates()
	for _, update in ipairs( self.updates ) do
		if update:IsCheckingForUpdates() then
			return true
		end
	end
	return false
end

function BLTMod:GetUpdateError()
	for _, update in ipairs(self:GetUpdates()) do
		if update:GetError() then
			return update:GetError(), update
		end
	end
	return false
end

function BLTMod:clbk_check_for_updates( update, required, reason )

	self._update_cache = self._update_cache or {}
	self._update_cache[ update:GetId() ] = {
		requires_update = required,
		reason = reason,
		update = update
	}

	if self._update_cache.clbk and not self:IsCheckingForUpdates() then
		local clbk = self._update_cache.clbk
		self._update_cache.clbk = nil
		clbk( self._update_cache )
	end

end

function BLTMod:IsSafeModeEnabled()
	return self.safe_mode
end

function BLTMod:SetSafeModeEnabled( enabled )
	if enabled == nil then
		enabled = true
	end
	if self:DisableSafeMode() then
		enabled = false
	end
	self.safe_mode = enabled
end

function BLTMod:DisableSafeMode()
	if self:IsUndisablable() then
		return true
	end
	return self.disable_safe_mode
end

function BLTMod:IsUndisablable()
	return self.undisablable or false
end

function BLTMod:HasDependencies()
	return next(self.dependencies) and true or false
end

function BLTMod:GetDependencies()
	return self.dependencies or {}
end

function BLTMod:GetMissingDependencies()
	return self.missing_dependencies or {}
end

function BLTMod:GetDisabledDependencies()
	return self.disabled_dependencies or {}
end

function BLTMod:AreDependenciesInstalled()

	local installed = true
	self.missing_dependencies = {}
	self.disabled_dependencies = {}

	-- Iterate all mods and updates to find dependencies, store any that are missing
	for key, value in pairs( self:GetDependencies() ) do
		local id, download_data

		if type(value) == "string" then
			id = value
		else
			id = key
			download_data = value
		end

		local found = false
		for _, mod in ipairs( BLT.Mods:Mods() ) do
			for _, update in ipairs( mod:GetUpdates() ) do
				if update:GetId() == id then
					found = true
					break
				end
			end
			if found then
				if not mod:IsEnabled() then
					installed = false
					table.insert( self.disabled_dependencies, mod )
					table.insert( self._errors, "blt_mod_dependency_disabled" )
				end
				break
			end
		end

		if not found then
			installed = false
			local dependency = BLTModDependency:new( self, id, download_data )
			table.insert( self.missing_dependencies, dependency )
		end

	end

	return installed

end

function BLTMod:RetrieveDependencies()
	for _, dependency in ipairs( self:GetMissingDependencies() ) do
		dependency:Retrieve( function(dependency, exists_on_server)
			self:clbk_retrieve_dependency( dependency, exists_on_server )
		end )
	end
end

function BLTMod:clbk_retrieve_dependency( dependency, exists_on_server )
	-- Register the dependency as a download
	if exists_on_server then
		BLT.Downloads:add_pending_download( dependency )
	end
end

function BLTMod:GetDeveloperInfo()

	local str = ""
	local append = function( ... )
		for i, s in ipairs( {...} ) do
			str = str .. (i > 1 and "    " or "") .. tostring(s)
		end
		str = str .. "\n"
	end

	local hooks = self:GetHooks() or {}
	local prehooks = self:GetPreHooks() or {}
	local persists = self:GetPersistScripts() or {}

	append( "Path:", self:GetPath() )
	append( "Load Priority:", self:GetPriority() )
	append( "Version:", self:GetVersion() )
	append( "BLT-Version:", self:GetBLTVersion() )
	append( "Disablable:", not self:IsUndisablable() )
	append( "Allow Safe Mode:", not self:DisableSafeMode() )

	if table.size( hooks ) < 1 then
		append( "No Hooks" )
	else
		append( "Hooks:" )
		for _, hook in ipairs( hooks ) do
			append( "", tostring(hook) )
		end
	end

	if table.size( prehooks ) < 1 then
		append( "No Pre-Hooks" )
	else
		append( "Pre-Hooks:" )
		for _, hook in ipairs( prehooks ) do
			append( "", tostring(hook) )
		end
	end

	if table.size( persists ) < 1 then
		append( "No Persisent Scripts" )
	else
		append( "Persisent Scripts:" )
		for _, script in ipairs( persists ) do
			append( "", script.global, "->", script.file )
		end
	end

	return str

end

function BLTMod:GetSuperMod()
	return self.supermod
end

function BLTMod:IsLibrary()
	return self.library
end

function BLTMod:__tostring()
	return string.format("[BLTMod %s (%s)]", self:GetName(), self:GetId())
end
