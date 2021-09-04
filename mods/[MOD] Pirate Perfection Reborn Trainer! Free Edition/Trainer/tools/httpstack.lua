--Purpose: attempt to fix dumb behavior of Steam::http_request
--What have I done: since Steam::http_request cannot process more than 1 request in single frame, I've decided to stack requests.
--Abandoned: Steam::http_request leaking, avoid using this at all!


--Private vars
local stack = {}

local timeout = 15 --Timeout in seconds

--Private methods
local function http_request( url, clbk )
	Steam:http_request( url, clbk )
end

--Constructing new callback
local function new_clbk( old_clbk, clbk_confirm )
	local function new_clbk(res, data)
		clbk_confirm()
		old_clbk(res and data or false)
	end
	return new_clbk
end

local function AddToStack( url, callback, highest )
	table.insert(stack, highest and 1 or #stack+1, { url, callback })
end

local function RemoveFromStack( url, clbk )
	for i,entry in ripairs(stack) do --I use ripairs in order to remove latest entry from stack, not the 1st
		if entry[1] == url then
			table.remove(stack, i)
			return
		end
	end
end

local function OnProcessedHTTP( entry )
	for i,entr in pairs(stack) do
		if entr == entry then
			table.remove(stack, i)
			return
		end
	end
	m_log_error('OnProcessedHTTP()',entry,'not found!')
end

local function ProcessStack()
	if table.empty( stack ) then
		return --Stack is empty
	end
	
	local entry = stack[1]
	if entry[3] then
		if (Application:time() - entry[3] >= timeout) then
			entry[2]( false )
			OnProcessedHTTP(entry) --Timed out!!
			m_log_vs('Timed out entry',entry, entry[1], Application:time() - entry[3])
		end
		return
	end
	local url = entry[1]
	local clbk = entry[2]
	http_request( url, new_clbk( clbk, function() OnProcessedHTTP( entry ) end ) )
	--3d element in the array shows time, when request started processing
	entry[3] = Application:time()
end

function StackHTTPRequest( url, callback, highest )
	return AddToStack( url, callback, highest )
end

function StackHTTPStack()
	return stack
end

RunNewLoopIdent('http_processor', ProcessStack)