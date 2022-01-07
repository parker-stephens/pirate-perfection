--Origbackuper by baldwin, extended by ThisJazzman
--Purpose: easy backuping and restoring functions.
--Instructions: create new class, using new_backuper = new_backuper or Backuper:new('new_backuper')
--Use new_backuper:backup('function_name') to backup function. Function returns original function and cannot be overriden once backuped
--Use new_backuper:restore('function_name') to restore the function
--Use new_backuper:restore_all() to restore all functions, backuped by new_backuper
--If you can improve this script, please discuss changes to baldwin before commiting.

local loadstring = loadstring
local pcall = pcall
local pairs = pairs
local next = next
local unpack = unpack
local clone = clone
local tab_insert = table.insert
local m_log_error = m_log_error

local safecall = safecall

local Backuper = class()

function Backuper:init(class_name)
	self._name = class_name
	self._originals = {}
	self._hacked = {}
	self._callbacks = {}
end

function Backuper:backup(stuff_string,name) --Original function name!
	local O = self._originals
	local have_orig = O[name] or O[stuff_string]
	if have_orig then
		return have_orig
	end

	local execute, serr = loadstring(self._name..'._originals[\"'..(name or stuff_string)..'\"] = '..stuff_string)
	
	if serr then
		return m_log_error('Backuper:backup()', 'Failed to backup string', stuff_string, 'Error thrown:', serr)
	end

	local success, err = pcall(execute)

	--m_log_vs("Tables:", self._originals[name], self._originals[stuff_string])
	if success then
		return O[name] or O[stuff_string]
	else
		m_log_error('Backuper:backup()','Failed to backup string',stuff_string,'Error thrown:',err)
	end
end

--This will allow to hijack single function with different multiple functions!
--As the 1st argument here will be array containing original function as 1st argument and then array of hijacked functions, 2nd argument reserved for your needs in order to structure calls (by default it passes number 1 as a sign of that function was called first).
--NOTE: Avoid using this at all costs! If you see any functions hijacked using this, better find other way of hijacking it!
function Backuper:hijack_adv(fstr, new_function)
	if not self._hacked[fstr] then
		self:backup(fstr)
		self._hacked[fstr] = {}
		local exec, serr = loadstring(fstr..' = function(...) local tb = { '..self._name..'._originals[\''..fstr..'\'] } \
			for _,func in ipairs('..self._name..'._hacked[\''..fstr..'\']) do table.insert(tb, func) end	\
				return '..self._name..'._hacked[\''..fstr..'\'][1](  tb, 1, ... )  end')
			
		if serr then
			return m_log_error('Backuper:hijack_adv()', 'Error hijacking function',fstr,'Error thrown:',serr)
		end
		
		local s,res = pcall(exec)
		if not s then
			return m_log_error('Backuper:hijack_adv()', 'Error hijacking function',fstr,'Error thrown:',res)
		end
	end
	tab_insert(self._hacked[fstr], new_function)
	return new_function
	--return #self._hacked[fstr]
end

--This will pop hijacked function from array
--If table is empty, then original function being restored
function Backuper:unhijack_adv(fstr, new_func)
	local remove = table.remove
	for index,func in pairs(self._hacked[fstr]) do
		if func == new_func then
			remove(self._hacked[fstr], index)
		end
	end
	if #self._hacked[fstr] == 0 then
		self:restore(fstr)
	end
end

--Experimental feature! I will not move all functions into this. This will hijack function with new_function. When hacked function being executed, new_function recieve original function as 1st argument, then other arguments. So now when you hijack class function, new_function should look like this: function(orig, self, ...) methods end Personally I suggest to use it only when you need to hijack advanced function, that require original function execution aswell.
function Backuper:hijack(function_string, new_function)
	local H = self._hacked
	
	local o = self:backup(function_string)
	H[function_string] = function( ... ) return new_function( o, ... ) end
	
	local exec, serr = loadstring(function_string..' = '..self._name..'._hacked[\''..function_string..'\']')
	
	if serr then
		return m_log_error('Backuper:hijack()', 'Error hijacking function',function_string, 'Error thrown:', serr)
	end
	
	local s,res = pcall(exec)
	if s then
		return H[function_string]
	else
		m_log_error('Backuper:hijack()', 'Error hijacking function',function_string, 'Error thrown:', res)
	end
end

local call_clbks_arr = function( arr, ... )
	for _,clbk in pairs(arr) do
		safecall(clbk, ... ) --safecall is temporary solution, it is planned to be removed
	end
end

--Hijacks function, if it wasn't hijacked earlier, function being hijacked and adds callback before and after original function being executed.
--Usefull when you want to hook single method with multiple methods of your choice
--pos: 1 - Before execution, 2 - after execution
--id: any, use it in order to perform remove_clbk in future
function Backuper:add_clbk(function_string, new_function, id, pos)
	if not id or not pos then
		return m_log_error('Backuper:add_clbk()', 'No pos or id was provided')
	end
	local CLBKS = self._callbacks
	local f_clbks = CLBKS[function_string]
	local bef_clbks
	local aft_clbks
	if not f_clbks then
		aft_clbks = {}
		bef_clbks = {}
		f_clbks = { [1] = bef_clbks, [2] = aft_clbks }
		CLBKS[function_string] = f_clbks
	else
		bef_clbks = f_clbks[1]
		aft_clbks = f_clbks[2]
	end
	if not self._hacked[function_string] then
		self:hijack( function_string,
			function( o, ... )
				call_clbks_arr( bef_clbks, o, ... )
				local r = { o( ... ) }  --Function may return multiple arguments
				call_clbks_arr( aft_clbks, r, ... )
				return unpack(r)
			end
		)
	end
	local have_clbk = f_clbks[pos][id]
	if not have_clbk then
		f_clbks[pos][id] = new_function
		return new_function
	else
		return have_clbk
	end
end

--id and/or pos can be nil
--If pos nil, this will remove before and after callbacks by id
--If id is nil, then it will remove all callbacks by pos
--If both id and pos are nil, this will just restore function, aswell will remove all callbacks
function Backuper:remove_clbk( function_string, id, pos )
	local CLBKS = self._callbacks
	local f_clbks = CLBKS[function_string]
	if f_clbks then
		local b_clbks = f_clbks[1]
		local a_clbks = f_clbks[2]
		local p_clbks = pos == 1 and b_clbks or pos == 2 and a_clbks or {}
		if id and pos then
			p_clbks[id] = nil
		elseif not pos then
			b_clbks[id] = nil
			a_clbks [id] = nil
		elseif not id then
			for id,_ in pairs(clone(p_clbks)) do --Don't reassign table in [self], since callbacks table in hijacked functions is upvalue.
				p_clbks[id] = nil
			end
		elseif not id and not pos then
			self:restore( function_string )
			return true
		else
			return false
		end
		if not next(b_clbks) and not next(a_clbks) then
			--No callbacks left, restore function
			self:restore(function_string)
		end
		return true
	else
		return false
	end
end

function Backuper:restore(stuff_string, name)
	local O = self._originals
	local n = O[name] or O[stuff_string]
	if n then
		local exec, serr = loadstring(stuff_string..' = '..self._name..'._originals[\"'..stuff_string..'\"]')
		if serr then
			return m_log_error('Backuper:restore()','Failed to restore string',stuff_string,'Error thrown:',serr)
		end
		local success, err = pcall(exec)
		if success then
			O[stuff_string] = nil
			self._hacked[stuff_string] = nil
			self._callbacks[stuff_string] = nil
		else
			m_log_error('Backuper:restore()','Failed to restore string',stuff_string,'Error thrown:',err)
		end
	end
end

function Backuper:restore_all() --Currently works only, if stuff_string was used as key
	local name = self._name
	local _O = self._originals
	local _H = self._hacked
	local CLBKS = self._callbacks
	for n,_ in pairs(self._originals) do
		local exec, serr = loadstring(n..' = '..name..'._originals[\"'..n..'\"]')
		if serr then
			m_log_error('Backuper:restore_all()','Failed to restore string',n,'Error thrown:',serr)
		else
			local success, err = pcall(exec)
			if success then
				_O[n] = nil
				_H[n] = nil
				CLBKS[n] = nil
			else
				m_log_error('Backuper:restore_all()','Failed to restore string',n,'Error thrown:',err)
			end
		end
	end
end

function Backuper:destroy()
	self:restore_all()
end

return Backuper