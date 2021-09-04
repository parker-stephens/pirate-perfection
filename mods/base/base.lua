local DEBUG_MODE = false

-- Create console
if false then
	console.CreateConsole()
end

-- Only run if we have the global table
if not _G then
	return
end

-- Localise globals
local _G = _G
local io = io
local file = file

-- BLT Global table
_G.BLT = { version = 2.0, DEBUG_MODE = DEBUG_MODE }
_G.BLT.Base = {}

_G.print = function(...)
	local s = ""
	for i, str in ipairs( {...} ) do
		if type(str) == "string" then
			str = string.gsub(str, "%%", "%%%%%")
		end
		s = string.format("%s%s%s", s, i > 1 and "\t" or "", tostring(str))
	end
	log(s)
end

-- Load modules
_G.BLT._PATH = "mods/base/"
function BLT:Require( path )
	dofile( string.format("%s%s", BLT._PATH, path .. ".lua") )
end
BLT:Require("req/utils/UtilsClass")
BLT:Require("req/utils/UtilsCore")
BLT:Require("req/utils/UtilsIO")
BLT:Require("req/utils/json-1.0")
BLT:Require("req/utils/json-0.9")
BLT:Require("req/utils/json")
BLT:Require("req/core/Hooks")
BLT:Require("req/supermod/BLTSuperMod")
BLT:Require("req/BLTMod")
BLT:Require("req/BLTUpdate")
BLT:Require("req/BLTUpdateCallbacks")
BLT:Require("req/BLTModDependency")
BLT:Require("req/BLTModule")
BLT:Require("req/BLTLogs")
BLT:Require("req/BLTModManager")
BLT:Require("req/BLTDownloadManager")
BLT:Require("req/BLTLocalization")
BLT:Require("req/BLTNotificationsManager")
BLT:Require("req/BLTPersistScripts")
BLT:Require("req/BLTKeybindsManager")
BLT:Require("req/xaudio/XAudio")

-- BLT base functions
function BLT:Initialize()

	-- Create hook tables
	self.hook_tables = {
		pre = {},
		post = {},
		wildcards = {}
	}

	-- Override require and setup self
	self:OverrideRequire()

	self:Setup()

end

function BLT:Setup()

	log("[BLT] Setup...")

	-- Setup modules
	self.Logs = BLTLogs:new()
	self.Mods = BLTModManager:new()
	self.Downloads = BLTDownloadManager:new()
	self.Keybinds = BLTKeybindsManager:new()
	self.PersistScripts = BLTPersistScripts:new()
	self.Localization = BLTLocalization:new()
	self.Notifications = BLTNotificationsManager:new()

	-- Create the required base directories, if necessary
	self:CheckDirectory(BLTModManager.Constants:DownloadsDirectory())
	self:CheckDirectory(BLTModManager.Constants:LogsDirectory())
	self:CheckDirectory(BLTModManager.Constants:SavesDirectory())

	-- Initialization functions
	self.Logs:CleanLogs()
	self.Mods:SetModsList( self:ProcessModsList( self:FindMods() ) )

	-- Some backwards compatibility for v1 mods
	local C = self.Mods.Constants
	_G.LuaModManager = {}
	_G.LuaModManager.Constants = C
	_G.LuaModManager.Mods = {} -- No mods are available via old api
	rawset(_G, C.logs_path_global, C.mods_directory .. C.logs_directory)
	rawset(_G, C.save_path_global, C.mods_directory .. C.saves_directory)

end

function BLT:GetVersion()
	return self.version
end

function BLT:GetOS()
	return os.getenv("HOME") == nil and "windows" or "linux"
end

function BLT:RunHookTable( hooks_table, path )
	if not hooks_table or not hooks_table[path] then
		return false
	end
	for i, hook_data in pairs( hooks_table[path] ) do
		self:RunHookFile( path, hook_data )
	end
end

function BLT:RunHookFile( path, hook_data )
	rawset( _G, BLTModManager.Constants.required_script_global, path or false )
	rawset( _G, BLTModManager.Constants.mod_path_global, hook_data.mod:GetPath() or false )
	rawset( _G, BLTModManager.Constants.mod_instance_global, hook_data.mod or false )
	dofile( hook_data.mod:GetPath() .. hook_data.script )
end

function BLT:OverrideRequire()

	if self.require then
		return false
	end

	-- Cache original require function
	self.require = _G.require

	-- Override require function to run hooks
	_G.require = function( ... )

		local args = { ... }
		local path = args[1]
		local path_lower = path:lower()
		local require_result = nil

		self:RunHookTable( self.hook_tables.pre, path_lower )
		require_result = self.require( ... )
		self:RunHookTable( self.hook_tables.post, path_lower )

		for k, v in ipairs( self.hook_tables.wildcards ) do
			self:RunHookFile( path, v )
		end

		return require_result

	end

end

function BLT:FindMods()

	log("[BLT] Loading mods for state: " .. tostring(_G))

	-- Get all folders in mods directory
	local mods_list = {}
	local folders = file.GetDirectories( BLTModManager.Constants.mods_directory )

	-- If we didn't get any folders then return an empty mods list
	if not folders then
		return {}
	end

	for index, directory in pairs( folders ) do

		-- Check if this directory is excluded from being checked for mods (logs, saves, etc.)
		if not self.Mods:IsExcludedDirectory( directory ) then

			log("[BLT] Loading mod: " .. tostring(directory))

			local mod_path = "mods/" .. directory .. "/"
			local mod_defintion = mod_path .. "mod.txt"

			-- Attempt to read the mod defintion file
			local file = io.open(mod_defintion)
			if file then

				-- Read the file contents
				local file_contents = file:read("*all")
				file:close()

				-- Convert json data in a pcall so any errors won't crash the game
				local mod_content = nil
				local json_success = pcall(function()
					mod_content = json.decode(file_contents)
				end)

				-- Create a BLT mod from the loaded data
				if json_success and mod_content then
					local new_mod = BLTMod:new( directory, mod_content )
					table.insert( mods_list, new_mod )
				else
					log("[BLT] An error occured while loading mod.txt from: " .. tostring(mod_path))
				end

			else
				log("[BLT] Could not read or find mod.txt in " .. tostring(directory))
			end

		end

	end

	return mods_list

end

function BLT:ProcessModsList( mods_list )

	-- Prioritize mod load order
	table.sort( mods_list, function(a, b)
		return a:GetPriority() > b:GetPriority()
	end)

	return mods_list

end

function BLT:CheckDirectory(path)
	path = path:sub(1, #path - 1)
	if not file.DirectoryExists(path) then
		log("[BLT] Creating missing directory " .. path)
		file.CreateDirectory(path)
	end
end

-- Perform startup
BLT:Initialize()
