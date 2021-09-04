
local c = blt_class()
BLTSuperMod.AssetLoader = c

c.DYNAMIC_LOAD_TYPES = {
	unit = true,
	effect = true
}

local _dynamic_unloaded_assets = {}
local _flush_assets
local _currently_loading_assets = {}

local next_asset_id = 1

function c:init(mod)
	self._mod = mod

	self.script_loadable_packages = {
	}
end

function c:FromXML(xml, parent_scope)
	-- Prevent the :name parameter from entering the <assets> scope
	parent_scope.name = nil

	-- Recurse over the XML, and find all the <file/> tags
	BLTSuperMod._recurse_xml(xml, parent_scope, {
		file = function(...) self:_asset_from_xml(...) end,
		xml = function(...) self:_converted_xml_file(...) end,
	})
end

function c:_asset_from_xml(tag, scope)
	local name = scope.name
	local path = scope.path or (scope.base_path .. name)
	self:LoadAsset(name, path, scope)
end

function c:_converted_xml_file(tag, scope)
	local name = scope.name
	local path = scope.path or (scope.base_path .. name)
	local built_path = path .. ".sblt_autoconvert"

	local from_type = scope.from_type
	local to_type = scope.to_type
	assert(from_type, "Missing 'from_type' tag in converted XML asset tag for '" .. name .. "'")
	assert(to_type, "Missing 'to_type' tag in converted XML asset tag for '" .. name .. "'")

	local convert_params = {
		path = self._mod._mod:GetPath() .. path,
		built_path = self._mod._mod:GetPath() .. built_path,
		from_type = from_type,
		to_type = to_type,
	}

	self:LoadAsset(name, built_path, scope, convert_params)
end

function c:LoadAsset(name, file, params, xml_convert)
	local dot_index = name:find(".", 1, true)
	local dbpath = name:sub(1, dot_index - 1)
	local extension = name:sub(dot_index + 1)

	local dyn_package = c.DYNAMIC_LOAD_TYPES[extension] or false
	if params.dyn_package == "true" then
		dyn_package = true
	elseif params.dyn_package == "false" then
		dyn_package = false
	end

	local spec = {
		dbpath = dbpath,
		extension = extension,
		file = self._mod._mod:GetPath() .. file,
		dyn_package = dyn_package,
		id = next_asset_id,
		xml_convert = xml_convert,
	}

	next_asset_id = next_asset_id + 1

	if params.target == "immediate" or not params.target then
		_dynamic_unloaded_assets[spec.id] = spec
		_flush_assets()
	elseif params.target == "scripted" then
		local group_name = params.load_group

		local group = self.script_loadable_packages[group_name] or {
			assets = {},
			loaded = false
		}
		self.script_loadable_packages[group_name] = group

		table.insert(group.assets, spec)
	else
		error("Unrecognised load type " .. params.target)
	end
end

function c:LoadAssetGroup(group_name)
	assert(group_name, "cannot load nil group")
	local group = self.script_loadable_packages[group_name]

	if not group then
		error("Group '" .. group_name .. "' does not exist")
	end

	if group.loaded then return end

	group.loaded = true

	for _, spec in ipairs(group.assets) do
		_dynamic_unloaded_assets[spec.id] = spec
	end

	_flush_assets()
end

function c:FreeAssetGroup(group_name)
	assert(group_name, "cannot free nil group")
	local group = self.script_loadable_packages[group_name]

	if not group then
		error("Group '" .. group_name .. "' does not exist")
	end

	-- We don't care if the group is loaded or not, as each asset
	-- is checked if it's unloaded.

	group.loaded = false

	for _, spec in ipairs(group.assets) do
		-- If it's queued to be loaded, ignore it.
		_dynamic_unloaded_assets[spec.id] = nil

		local ext = Idstring(spec.extension)
		local dbpath = Idstring(spec.dbpath)

		if spec._entry_created then
			spec._entry_created = false
			DB:remove_entry(ext, dbpath)
		end

		if spec._targeted_package then
			managers.dyn_resource:unload(ext, dbpath, spec._targeted_package, false)
			spec._targeted_package = nil

			_currently_loading_assets[spec] = nil
		end
	end
end

local function convert_xml_asset(params)
	log("[BLT] Converting " .. tostring(params.path) .. " into " .. tostring(params.built_path))
	-- Read the source file
	local input_str
	do
		local file = io.open(params.path, "rb")
		assert(file, "Could not open XML file input " .. params.path)
		input_str = file:read("*a")
		file:close()
	end

	-- Convert it to data
	local data = nil
	do
		local from_type = params.from_type
		local func = ScriptSerializer["from_" .. from_type]
		assert(func, "Unknown XML input type '" .. from_type .. "'")
		data = func(ScriptSerializer, input_str)
	end

	-- Convert it to the desired format
	local output_str = nil
	do
		local to_type = params.to_type
		local func = ScriptSerializer["to_" .. to_type]
		assert(func, "Unknown XML output type '" .. to_type .. "'")
		output_str = func(ScriptSerializer, data)
		assert(output_str)
	end

	-- Write it out
	do
		local file = io.open(params.built_path, "wb")
		file:write(output_str)
		file:close()
	end
end

-- Asset system - independent of any object
_flush_assets = function(dres)
	dres = dres or (managers and managers.dyn_resource)
	if not dres then return end

	local next_to_load = {}

	local i = 1
	for id, asset in pairs(_dynamic_unloaded_assets) do
		local ext = Idstring(asset.extension)
		local dbpath = Idstring(asset.dbpath)
		local path = asset.file

		if asset.xml_convert and not asset.xml_convert._done then
			convert_xml_asset(asset.xml_convert)
			asset.xml_convert._done = true
		end

		if not io.file_is_readable(path) then
			error("Cannot load unreadable asset " .. path)
		end

		-- TODO a good way to log this
		-- log("Loading " .. asset.dbpath .. " " .. asset.extension .. " from " .. path)

		if not asset._entry_created then
			blt.ignoretweak(dbpath, ext)
			DB:create_entry(ext, dbpath, path)
			asset._entry_created = true
		end

		if asset.dyn_package and not asset._targeted_package then
			asset._targeted_package = dres.DYN_RESOURCES_PACKAGE

			_currently_loading_assets[asset] = {}

			dres:load(ext, dbpath, asset._targeted_package, function()
				-- This is called when the asset is done loading.
				-- Should we wait for these to all be called?

				_currently_loading_assets[asset] = nil

				if BLT.DEBUG_MODE then
					log("[BLT] Assets remaining to load:")
					for spec, info in pairs(_currently_loading_assets) do
						log("\t" .. spec.dbpath)
					end
					log("\tEnd of asset list")
				end
			end)

			-- Warn the user if a file has not loaded in the last fifteen seconds
			DelayedCalls:Add("SuperBLTAssetLoaderModelWatchdog", 15, function()
				if next(_currently_loading_assets) then
log("[BLT] No asset has been loaded in the last 15 seconds, and these assets have not yet loaded.")
log("[BLT] This suggests they may be corrupt, and could prevent the game from exiting the current level:")
					for spec, info in pairs(_currently_loading_assets) do
						log("\t" .. spec.dbpath .. "." .. spec.extension .. " (" .. path .. ")")
					end
				end
			end)

			i = i + 1
		end
	end

	_dynamic_unloaded_assets = {}
end
Hooks:Add("DynamicResourceManagerCreated", "BLTAssets.DynamicResourceManagerCreated", function(...)
	local success, err = pcall(_flush_assets, ...)
	if not success then
		log("[BLT] Error in asset loader: " .. tostring(err))
	end
end)
