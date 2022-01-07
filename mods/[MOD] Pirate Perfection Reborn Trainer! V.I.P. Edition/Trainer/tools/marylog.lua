--Logs to file, simple
--Purpose: simple logging scripts

local unpack = unpack
local type = type
local select = select
local tostring = tostring
local pcall = pcall
local pairs = pairs
local pro_pairs = pro_pairs

--Utility method to help you with memory consuming stuff
--Modes: 0 - string, 1 - table
local mebuff = nil
local meflusher = nil
local mesize = nil
local memode = nil

local insert = table.insert
local traceback = debug.traceback
local os = os
local os_date = os.date
local os_clock = os.clock
local io_open = ppr_io.open
local string = string
local str_len = string.len
local str_rep = string.rep

local function unpack_m_buff()
	if type(mebuff) == 'string' then
		return mebuff
	elseif type(mebuff) == 'table' then
		return unpack(mebuff)
	end
end
	
--Flushes buffer and resets its settings
local function m_buff_flush()
	if meflusher then
		safecall( meflusher, unpack_m_buff() )
		mebuff = nil
		mesize = nil
		memode = nil
		meflusher = nil
	end
end

--clbk is the flush function, that will take 1 string or unpacked mebuff table, size is the max len of string or table, where after reaching max limit, it calls flush function and clears mebuff
--Modes: 0 string mode, 1 table
--If buffer was setted up before, it just resets and flush old one.
local function m_buff_flusher( clbk, size, mode )
	m_buff_flush()
	
	memode = type(mode) == 'number' and mode or 0
	
	if memode == 0 then
		mebuff = ''
	elseif memode == 1 then
		mebuff = {}
	end
	
	mesize = size or 100
	
	meflusher = type(clbk) == 'function' and clbk or void
end

--Pushes data into buffer
local function m_buff( ... )
	
	if ( select('#', ...) == 0 ) then
		return m_log_error('m_buff()', 'Arguments expected!')
	end
	
	if not mebuff then
		return m_log_error('m_buff()', 'No m_buffer! Call m_buff_flusher!')
	end
	
	local args = { ... }
	local safecall = safecall or pcall
	for _,arg in pairs( args ) do
		if memode == 0 then
			mebuff = mebuff..tostring(arg)
			if str_len(mebuff) > mesize then
				safecall( meflusher, mebuff )
				mebuff = ''
			end
		elseif memode == 1 then
			insert(mebuff, arg)
			if #mebuff > mesize then
				safecall( meflusher, unpack(mebuff) )
				mebuff = {}
			end
		end
	end
	
end

--Some devs using custom log function
local logme = logme or function( ... ) log( ... ) end

local LogErr = true --Enable logs of errors
local deep_error = false --Displays traceback when error function called
--M_LOG_SHORT = { "c", "s" }
--M_LOG_FULL = { "f", "c", "t", "m", "d" }

local m_log = function( ... ) --Write to file, display to console
	if ( select('#', ...) == 0 ) then
		return
	end
	local str = "["..os_date().."]"
	local args = { ... }
	for _,arg in pairs(args) do
		str = str .. ' ' .. tostring(arg)
	end
	logme(str..'\n')
	local f = io_open("log.txt", "a")
	if f then
		f:write(str..'\n')
		f:close()
	end
end

local m_log_vs = function( ... ) --Other style of display
	if ( select('#', ...) == 0 ) then
		return
	end
	local str = "["..os_date().."]"
	local args = { ... }
	for _,arg in pairs(args) do
		str = str .. ' ' .. tostring(arg)
	end
	logme(str..'\n')
end

local m_log_v = function( ... ) --Doesn't display date (short log)
	if ( select('#', ...) == 0 ) then
		return
	end
	local str = ''
	local args = {...}
	for _,arg in pairs(args) do
		str = str .. tostring(arg) .. ' '
	end
	logme(str..'\n')
end

local error_to_file
local error_file
local error_write
error_to_file = function( input )
	if ( ppr_config.LogErrorsToFile) then
		error_file = io_open("Log Files/Error.log", "a")
		if (error_file) then
			error_write = error_file.write
			error_to_file = function( data ) error_write( error_file, data ) end
			error_to_file( input )
		end
	else
		error_to_file = nil
	end
end

local m_log_error = function( cat, ... ) --Loogging of errors.
	if not LogErr then
		return --Error logging disabled
	end
	
	if ( select('#', ...) == 0 ) then
		return
	end
	local str = "("..os_date()..") [ERROR "..cat.." ]:"
	local args = { ... }
	for _,arg in pairs(args) do
		str = str .. ' ' .. tostring(arg)
	end
	if deep_error then
		str = str .. '\n' .. (traceback()..'\n')
	end
	str = str.."\n"
	logme(str)
	if (error_to_file) then
		error_to_file(str)
	end
	--return error()
end

local m_log_assert = function( obj, msg )
	if obj then
		return obj
	else
		logme((msg or 'Assertion happened! Callstack:\n'..traceback('',2))..'\n')
	end
end

--m_log_a to be remade
local m_log_a = function( _, ... ) m_log_v( ... ) end

local m_log_inspect = function( ... ) --Destructs table to console
	if ( select('#', ...) == 0 ) then
		return
	end
	m_buff_flusher(logme, 0x2710, 0)
	local args = {...}
	for _,tab in pairs(args) do
		m_buff("Inspecting "..tostring(tab)..":\n")
		for k,d in pro_pairs(tab) do
			m_buff("  ["..tostring(k).."] = "..tostring( d )..'\n')
		end
	end
	m_buff_flush()
end

local m_log_full_inspect = function( ... )
	if ( select('#', ...) == 0 ) then
		return
	end
	local cache = {}
	local iterate
	m_buff_flusher( logme, 0x2710, 0 )
	iterate = function(t, push)
		local spacing = str_rep("\t", push)
		for k,d in pro_pairs(t) do
			if type(d) == 'table' and not cache[d] then
				cache[d] = true
				m_buff(spacing.."["..tostring(k).."] = {\n")
				iterate(d, push+1)
				m_buff(spacing.."}\n")
			else
				m_buff(spacing.."["..tostring(k).."] = "..tostring(d)..'\n')
			end
		end
	end
	local args = {...}
	for _,t in pairs(args) do
		m_buff('Inspecting '..tostring(t)..'\n')
		iterate(t, 0)
	end
	m_buff_flush()
end

local m_log_clear = function()
	logme(str_rep('\n\r', 600))
end

local m_log_hook_print = function()
	if not orig__print then
		orig__print = print
	end
	print = m_log_v
end

local G = getfenv(0)
------------------------------------------------------------------------------------------------------------------------------------
local xpcall = G.logme and xpcall or
xpcall and
--Xpcall exists, just modify it a bit
function(errf, obj, ...)
	local p = { ... }
	return xpcall(function() obj( unpack(p) ) end, errf)
end
or
--Fallback to this function, if it isn't exist (compatibility with old lua hooks)
function(errf, obj, ...)
	return pcall(obj, ...)
end

local on_error_func = function( m )
	local str = m..'\n'..traceback('',2) --Get callstack from caller
	return str
end

local safecall = function( func, ... ) --A bit comfortable way of using pcall (also it provides call stack)
	local succ,ret = xpcall( on_error_func, func, ... )
	if succ then
		return ret
	else
		m_log_error( 'in safecall', ret )
		--logme( traceback()..'\n' )
	end
end

--Behold! Performance test! It isn't 100% accurate, but still better than nothing.
local m_log_testfunc = function( func, ... )
	local s = os_clock()
	func( ... )
	s = os_clock() - s
	return s
end

--Buff utilities
G.m_buff            	= m_buff
G.m_buff_flusher    	= m_buff_flusher
G.m_buff_flush      	= m_buff_flush

--Log stuff
G.m_log             	= m_log
G.m_log_v           	= m_log_v
G.m_log_vs          	= m_log_vs
G.m_log_a           	= m_log_a
G.m_log_clear			= m_log_clear
G.m_log_inspect     	= m_log_inspect
G.m_log_full_inspect	= m_log_full_inspect
G.m_log_error       	= m_log_error
G.m_log_assert      	= m_log_assert
G.m_log_hook_print  	= m_log_hook_print
G.m_log_testfunc    	= m_log_testfunc
G.safecall          	= safecall