
BLTSuperMod = blt_class()

BLT:Require("req/supermod/SuperModAssetLoader")

function BLTSuperMod.try_load(mod, file_name)
	local supermod_path = "mods/" .. mod:GetId() .. "/" .. (file_name or "supermod.xml")

	-- Attempt to read the mod defintion file
	local file = io.open(supermod_path)
	if file then

		-- Read the file contents
		local file_contents = file:read("*all")
		file:close()

		-- Parse it
		local xml = blt.parsexml(file_contents)
		xml._doc = {
			filename = supermod_path
		}

		return BLTSuperMod:new(mod, xml)
	end

	return nil
end

function BLTSuperMod:init(mod, xml)
	self._mod = mod

	if mod:IsEnabled() then
		self._assets = self.AssetLoader:new(self)
	end

	self:_replace_includes(xml)

	self:_load_xml(xml, {})
end

function BLTSuperMod:GetAssetLoader()
	return self._assets
end

function BLTSuperMod:_load_xml(xml, parent_scope)
	BLTSuperMod._recurse_xml(xml, parent_scope, {
		assets = function(tag, scope)
			if self._assets then
				self._assets:FromXML(tag, scope)
			end
		end,
		hooks = function(tag, scope)
			self:_add_hooks(tag, scope)
		end,
		native_module = function(tag, scope)
			self:_add_native_module(tag, scope)
		end,

		-- These tags are used by the Wren-based XML Tweaker
		wren = function(tag, scope) end,
		tweak = function(tag, scope) end,
	})
end

function BLTSuperMod:_add_hooks(xml, parent_scope)
	BLTSuperMod._recurse_xml(xml, parent_scope, {
		pre = function(tag, scope)
			self:_add_hook(tag, scope, "pre_hooks", "pre")
		end,
		post = function(tag, scope)
			self:_add_hook(tag, scope, "hooks", "post")
		end,
		entry = function(tag, scope)
			self:_run_entry_script(tag, scope, "hooks", "post")
		end,
		wildcard = function(tag, scope)
			error("TODO implement wildcard")
		end,
	})
end

function BLTSuperMod:_add_hook(tag, scope, data_key, destination)
	local hook_id = scope.hook_id
	local script_path = scope.script_path

	assert(hook_id, "missing parameter hook_id" .. tag._doc.filename)
	assert(script_path, "missing parameter script_path in " .. tag._doc.filename)

	self._mod:AddHook(data_key, hook_id, script_path, BLT.hook_tables[destination])
end

function BLTSuperMod:_run_entry_script(tag, scope, data_key, destination)
	BLT:RunHookFile(scope.script_path, {
		mod = self._mod,
		script = scope.script_path
	})
end

function BLTSuperMod:_add_native_module(tag, scope)
	if scope.loading_vector == "preload" then
		return -- Uses Wren
	end

	if not blt.load_native or not blt.blt_info then
		log("[BLT] Cannot load native module for mod " .. self._mod:GetId()
			.. " as such functionality is not available in this version of the SuperBLT DLL/SO")
		return
	end

	if blt.blt_info().platform ~= scope.platform then
		log("[BLT] Incorrect platform for native module for " .. self._mod:GetId())
		return
	end

	log("[BLT] Loading native module for " .. self._mod:GetId())
	blt.load_native(self._mod:GetPath() .. scope.filename)
end

function BLTSuperMod:_replace_includes(xml)
	for i, tag in ipairs(xml) do
		tag._doc = xml._doc

		if tag.name == ":include" then
			local file_path = "mods/" .. self._mod:GetId() .. "/" .. tag.params.src

			-- Attempt to read the mod defintion file
			local file = io.open(file_path)
			assert(file, "Could not open " .. file_path)

			-- Read the file contents
			local file_contents = file:read("*all")
			file:close()

			-- Parse it
			local included = blt.parsexml(file_contents)
			assert(included, "Parsed file " .. file_path .. " resolves to nil. Is it valid?")
			included._doc = {
				filename = file_path
			}

			-- Substitute it in
			tag = included
			xml[i] = included
		end

		self:_replace_includes(tag)
	end
end

function BLTSuperMod._recurse_xml(xml, parent_scope, callbacks)
	for _, tag in ipairs(xml) do
		local scope = {}
		setmetatable(scope, {__index = parent_scope})

		for name, val in pairs(tag.params) do
			while true do
				local first, last = val:find("#{%a[%w_]-}")
				if not first then break end

				local name = val:sub(first + 2, last - first)
				local target_var = scope[name]

				assert(target_var, "Trying to use missing parameter '"
					.. name .. "' as a #{value} in " .. tag._doc.filename)

				val = val:sub(1, first - 1) .. target_var .. val:sub(last + 1)
			end

			if name:sub(1,1) == ":" then
				name = name:sub(2)
				if not scope[name] then
					error("Trying to append to missing parameter '" .. name
							.. "' in " .. tag._doc.filename)
				end
				scope[name] = scope[name] .. val
			else
				scope[name] = val
			end
		end

		if tag.name == "group" then
			BLTSuperMod._recurse_xml(tag, scope, callbacks)
		elseif callbacks[tag.name] then
			callbacks[tag.name](tag, scope, callbacks)
		else
			error("Unknown tag name '" .. tag.name .. "' in: " .. tag._doc.filename)
		end
	end
end
