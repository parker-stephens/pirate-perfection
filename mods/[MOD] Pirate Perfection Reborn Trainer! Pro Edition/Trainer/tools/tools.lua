--Some dev scripts by baldwin
--Purpose: Some core addons, feel free to expand them.

local ppr_require = ppr_require
local select = select
local pairs = pairs
local type = type
local getmetatable = getmetatable
local setmetatable = setmetatable
local unpack = unpack
local pcall = pcall
local tostring = tostring
local loadstring = loadstring
local setfenv = setfenv
local table = table
local string = string

local str_len = string.len
local sub = string.sub
local insert = table.insert
local os = os
local os_date = os.date

function void()end --Empty function

function pro_pairs(...) --It will be much better, I promise. For now, It just handles userdatas and ignore errors. New: abillity to iterate through multiple tables.
	local t = {}
	if select('#', ...) <= 1 then
		t = ...
	else 
		for _,tab in pairs({...}) do
		  t = table.update(t, type(tab) == 'userdata' and getmetatable(tab) or tab)
		end
	end
	if type(t) == "userdata" then
		return pairs(getmetatable(t) or {})
	end
	return pairs(t or {})
end
local pro_pairs = pro_pairs

function copy_pairs(t,deep) --Same as pairs, but also copies given table
	local f = deep and deep_clone or clone
	return pairs(f(t))
end

--Like ipairs, but iterates from the end of the table
function ripairs(t)
	local pos = #t+1
	local iterator = function()
		pos = pos - 1
		if (pos > 0) then
			return pos,t[pos]
		end
	end
	return iterator
end

function pro_callback(env,func,t,wrapped) --Return callback function
	if ( type(env) ~= 'table' or not getmetatable(env) ) then
		return
	end
	if ( type(func) == 'function' ) then
		if ( type(t) == 'table' ) then
			return function( ... )
				return func( unpack(t) )
			end
		else
			return func
		end
	else
		if ( type(t) == 'table' ) then
			return function(...) 
				local f = env[func]
				if f then
					return f(unpack(t))
				end
			end
		elseif ( t ~= nil ) then
			return function( ... )
				local f = env[func]
				if ( f ) then
					return f(t, ...)
				end
			end
		else
			return function( ... )
				local f = env[func]
				if ( f ) then
					return f( ... )
				end
			end
		end
	end
end

ppr_require('Trainer/tools/marylog')

local m_log_error = m_log_error

secure_debug_class = function(class, error_handler)
	if not error_handler then
		error_handler = function(k, ...)
			m_log_error('class error','key', k, ...)
		end
	end
	for k,d in pro_pairs(class) do
		if type(d) == 'function' then
			class[k] = function(...) 
				local res = { pcall(d, ...) } --Function may return multiple arguments
				if not res[1] then
					error_handler(k,res[2])
					return
				end
				if res[2] == nil then
					return
				end
				return unpack(res, 2)
			end
		end
	end
end

function table.update(t1,t2) --t1 being updated from t2
	if #t1 ~= 0 then
		for _,value in pairs(t2) do
			insert(t1, value)
		end
		return t1
	end
	for key,value in pairs(t2) do
		t1[key] = value
	end
	return t1
end

function table.expand(t1,t2) --Keys, these aren't in t1 but in t2 being copied into t1
	for key,value in pairs(t2) do
		if not t1[key] then
			t1[key] = value
		end
	end
	return t1
end

--Creates read-only table
function table.readonly( input )
	local final = {}
	local mt = {
		__index = function( t, k ) return input[k] end,
		__newindex = function( t, k, v ) m_log_error(tostring(t),'Attempted to assign value to read only table', t, k ) end
	}
	setmetatable(final, mt)
	return final
end

--Copies table
function table.copy( input )
	local new = {}
	for key,val in pairs( input ) do
		new[key] = val
	end
	setmetatable(new, getmetatable(input))
	return new
end

--Converts table to string in minified format
function table.to_string( input )
	local str = '{'
	local cache = {}
	--Main recursive function
	local function iterate(t)
		for k,v in pairs(t) do
			if type(v) == 'string' then
				str = str..(type(k) == 'number' and '['..k..']' or '["'..k..'"]')..'="'..v..'",'
			elseif type(v) == 'number' or type(v) == 'boolean' then
				str = str..(type(k) == 'number' and '['..k..']' or '["'..k..'"]')..'='..tostring(v)..','
			elseif type(v) == 'table' and not cache[v] then
				str = str..(type(k) == 'number' and '['..k..']' or '["'..k..'"]')..'={'
				cache[v] = true
				iterate(v)
				str = str..'},'
			end
		end
	end
	iterate(input)
	str = str..'}'
	return str
end

function loadstring_execute( input, sandbox, dbg )
	local l,err = loadstring( input, dbg )
	if (l) then
		if ( sandbox ) then
			setfenv( l, sandbox )
		end
		return l()
	end
	m_log_error( 'loadstring_execute()', err )
end

function get_time()
	--Solves problem with in-game's os.time()
	local t = os_date("*t")
	local func = function( t )
		if ( t < 10 ) then
			return '0'..t
		end
		return t
	end
	return ''..t.year..func(t.month)..func(t.day)..func(t.hour)..func(t.min)..func(t.sec)
end

local mrotation = mrotation
local Rotation = Rotation
function mrotation.turn(rot) --Turns anything into 180 degrees
	local l = rot:yaw()
	if l > 0 then
		l = l - 180
	else
		l = l + 180
	end
	return Rotation(l,0,0)
end

function mrotation.copy(rot) --Overkill didn't implement copy for rotations
	return Rotation(rot:yaw(),rot:pitch(),rot:roll())
end

--Returns iterator function, which iterates through all symbols in given string
local function string_symbols(str)
	local pos = 0
	local max = str_len(str)
	local sym
	local iterator
	iterator = function()
		pos = pos + 1
		sym = sub(str, pos,pos)
		if pos > max then
			return
		end
		return pos,sym
	end
	return iterator
end
string.symbols = string_symbols

--Custom search string to search for word with special characters (with string.find it won't be easy to search for string like, "Is something wrong here ?!" I.e. it searches string by string, not by pattern!)
local function string_search(text, str, p)
	--local magic_chars = { '^','$','(',')','%','.','[',']','*','+','-','?' }
	local start_from = p or 1
	local wpos = 1
	local len = str_len(str)
	for pos,s in string_symbols(text) do
		if pos >= start_from then
			if s == sub(str, wpos,wpos) then
				wpos = wpos + 1
				if wpos > len then
					return pos-len+1, pos
				end
			else
				wpos = 1
			end
		end
	end
end
string.search = string_search

--Replaces all words "from" to "to" in given "text" (New: single attribute to replace only 1st occured word. pos: from where to start replacing)
function string.replace(text, from, to, pos, single)
	local cp = pos or 1
	repeat
		local p1,p2 = string_search(text, from, cp)
		if p1 and p2 then
			text = sub(text, 1, p1-1)..to..sub(text, p2+1)
			if single then
				break
			end
			cp = p2+1
		else
			break
		end
	until false
	return text
end

if not orig__dofile then
	--Safier version of ppr_dofile
	--Though I suggest to give explicit filenames, implicit takes a bit more time to search.
	
	orig__dofile = ppr_dofile
	local io_open = ppr_io.open
	local pcall = pcall
	or
	function( clbk, ... )
		return true, clbk( ... )
	end
	
	local unpack = unpack
	local loadstring = loadstring
	local exts = {
		'', --As is
		'.lua', --Implicit
		'.luac' --Implicit
	}
	
	function ppr_dofile(name)
		local err_msg = 'nil argument was given'
		if ( name ) then
			local check
			for _,ext in pairs(exts) do
				check = io_open(name..ext, 'rb')
				if ( check ) then
					break
				end
			end
			
			if ( check ) then
				local data = check:read('*all')
				check:close()
				if ( data ) then
					local l,lerr = loadstring( data, name )
					if ( l ) then
						local res = { pcall( l ) }
						if ( res[1] ) then
							return unpack( res, 2 )
						else
							err_msg = res[2]
						end
					else
						err_msg = lerr
					end
				else
					err_msg = 'File '..name..' failed to load!'
				end
			else
				err_msg = 'File '..name..' isn\'t found!'
			end
		end
		local m_log_error = m_log_error
		if ( m_log_error ) then
			m_log_error('ppr_dofile()',err_msg)
		end
	end
end

local m_log_v = m_log_v
function table.log_calls( input, log_func, funny_name )
	if (not input.hoooked) then
		funny_name = funny_name or "handler"
		log_func = log_func or m_log_v
		for key,vfunc in pairs(input) do
			if type(vfunc) == "function" then
				input[key] = function( self, ... )
					log_func(key, "called on", funny_name, "with params", ...)
					return vfunc( self, ... )
				end
			end
		end
		input.hoooked = true
	end
end