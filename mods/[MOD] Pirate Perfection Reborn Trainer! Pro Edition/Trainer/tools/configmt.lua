--Purpose: metatable extension for configuration.

local io = io
local io_open = ppr_io.open
local type = type
local pairs = pairs
local loadstring = loadstring
local tostring = tostring
local rawget = rawget
local next = next
local getmetatable = getmetatable
local setmetatable = setmetatable
local string = string
local str_find = string.find
local str_replace = string.replace
local str_format = string.format

local deep_clone = deep_clone

local m_log_error = m_log_error
local m_log_vs = m_log_vs
local m_log_full_inspect = m_log_full_inspect

--Ignore changes done to these keys in config.
local ignore_keys = {
	__cloned			=true,
	const_version		=true,
	auto_config			=true,
}

--Private methods
local function write(name, data)
	local f = io_open(name,'wb')
	if f then
		f:write(data)
		f:close()
		return
	end
	m_log_error('write()','Failed to write file', name)
end

local function read(name)
	local f = io_open(name,'rb')
	if f then
		local d = f:read('*all')
		f:close()
		return d
	end
	m_log_error('read()','Failed to load file',name)
	return false
end

--It fixes case with incompatible with config symbols
local function parse_text( input )
	if type(input) ~= 'string' then
		return input
	end
	local out
	out = str_replace(input, "'","\\39")
	out = str_replace(out, '"',"\\34")
	return out
end

local function old_update_vars(loc, changes)
	local file = read(loc)
	if not file then
		return
	end
	local new_file = file
	for config,entry in pairs(changes) do
		local s,e = str_find( file, config )
		if s and e then
			local new_value = entry[1]
			local old_value = entry[2]
			if type(new_value) ~= type(old_value) then
				
				--Workaround for strings
				if type(new_value) == 'string' then
					new_value = "'"..parse_text(new_value).."'"
				end
				if type(old_value) == 'string' then
					old_value = "'"..parse_text(old_value).."'"
				end
				new_file = str_replace(new_file, old_value, new_value, e, true )
			else
				new_file = str_replace( new_file, tostring(old_value), tostring(new_value), e, true )
			end
		end
	end
	
	if file == new_file then
		return m_log_error('update_var() in configmt.lua', 'Nothing changed!')
	end
	
	--Just in case, let's check if we didn't break config
	local l, err = loadstring(new_file)
	if l then
		write(loc, new_file)
	else
		m_log_error('update_var() in configmt.lua' , err)
	end
end

local function update_vars(loc, changes)
	local f=io_open(loc, "w")
	if (f) then
		local io_write=f.write
		io_write(f, 'return function( cfg )\n')
		for entry,new_value in pairs(changes) do
			--Encapsulate into quotes in case it is string
			if ( type(new_value) == "string" ) then
				--The %q option formats a string in a form suitable to be safely read back by the Lua interpreter
				new_value=str_format('%q', new_value)
				m_log_vs("%q:", new_value)
			end
			local out=str_format('\tcfg.%s=%s\n', entry, tostring(new_value))
			io_write(f, out)
		end
		io_write(f, 'end\n')
		f:close()
	else
		m_log_error("update_vars()", "Failed to open file", loc)
	end
end

local mt__call = function(t, f)
	--Let's search for differences
	local changes = {}

	local old_cfg = t.__cloned
	for key,value in pairs(t) do
		local old_value = rawget( old_cfg, key )
		--Filter our reserved, unchanged and unneeded config entries
		if value ~= old_value and not ignore_keys[key] then
			--_changes[k] = { v, old_cfg[k] }
			changes[key] = value
		end
	end
	--Don't proceed if nothing changed
	if next(changes) then
		m_log_vs('Changed:')
		m_log_full_inspect(changes)
		update_vars(rawget( t, 'auto_config' ) or getmetatable(t).__location..'.auto', changes)
	end
end

local mt__index = function(t,k)
	m_log_vs('WARNING! Key',k,'isn\'t defined in config!',t)
end

local mt__tostring = function(t)
	return "Pirate Perfection Reborn Configuration file "..tostring(getmetatable(t))
end

function ApplyConfigExtension( cfg, path )
	--Storing unchanged config here
	cfg.__cloned = deep_clone(cfg)

	local mt = {
		__location = path,
		__call = mt__call,
		__index = mt__index,
		__tostring = mt__tostring
	}

	setmetatable(cfg, mt)
end