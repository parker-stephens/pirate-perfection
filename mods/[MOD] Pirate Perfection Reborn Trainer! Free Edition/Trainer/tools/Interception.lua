--INTERCEPTION
Interception = Interception or class()
Interception.Backups = Interception.Backups or { }

--eg. local old_function = Interception.Backup(PlayerManager, "upgrade_value")
	function Interception.Backup(class, func)
		if not class[func] then
			io.stderr:write("Cannot	backup '".. func .."'.\n")
			return nil
		end
		local prefix = "__"
		if not class[prefix .. func] then
			class[prefix .. func] = class[func]
			table.insert(Interception.Backups, {class = class, func = func})
		end
		return class[func]
	end

	function Interception.RestoreAll()
		for	_,v in pairs(Interception.Backups) do Interception.Restore(v.class, v.func) end
		Interception.Backups = { }
	end

--eg. Interception.Restore("PlayerManager", "upgrade_value")
	function Interception.Restore(class, func)
		local prefix = "__"
		if class[prefix .. func] then
			class[func] = class[prefix .. func] class[prefix .. func] = nil
		end
	end