--Loop your functions, wrote by baldwin, improved by Jazzman
--Short description of function can be found after each function.
--To loop your function, use RunNewLoop( function, argument ) (argument can be nil, If you don't need to pass any argument to function) (Note: RunNewLoop( function(), argument ) will be incorrect, unless function() returns function. Same applies to RunNewLoop( someclass:function(),argument ), use RunNewLoop(someclass.function,argument) instead. )
--To stop your function from repeating, use StopLoopIdent( identity_returned_from_RunNewLoop ) or StopRnLoop( function, argument ).
--Function will not be repeated soo frequently, so It won't load your cpu hard (depends on function you will add to loop ofcourse)

local void = void

local table = table
local random = math.random
local insert = table.insert
local char = string.char

local unpack = unpack
local assert = assert
local type = type
local pcall = pcall
local tostring = tostring
local pairs = pairs
local next = next

--[[local Application = Application
local app_time = Application.time]]
local os_clock = os.clock

function GenerateRandomIdent(settings)	--Generates random string, depending on settings (may come in handy)
										--Use:( { len = length, num = true_to_include_numbers, up = true_to_include_uppercase_chars, low = true_to_include_lowercase_chars, char = true_to_include_special_chars } )
	local lenght = settings.len
	local num = settings.num
	local uppercase = settings.up
	local lowercase = settings.low
	local morechars = settings.char
	local result = {}
	local function randomChar()
		local possibilities = {}
		local rand_by_mode = { uppercase = random(65,90), 
			lowercase = random(97,122), 
			num = random(48,57),
			morechars = function()
				local poss = { random(33,47), random(58,64), random(91,96), random(123,126) }
				return poss[random(1,#poss)]
			end
		}
		if uppercase then
			insert(possibilities,"uppercase")
		end
		if lowercase then
			insert(possibilities,"lowercase")
		end
		if morechars then
			insert(possibilities,"morechars")
		end
		if num then
			insert(possibilities,"num")
		end
		local mode = possibilities[random(1,#possibilities)]
		local result
		if mode == "morechars" then
			result = rand_by_mode["morechars"]()
		else
			result = rand_by_mode[mode]
		end
		return result
	end
	for _=1,lenght do
		insert(result, char(randomChar()))
	end
	return table.concat(result)
end

local ranThreads = {}
--Queue all insertions/removes!
local toAdd = {}
local toRemove = {}

--Runs new loop. Returns loop's identity by what It can be easly stopped using StopLoopIdent. Use: RunNewLoop( function, single_argument )
function RunNewLoop( func, ... )
	assert(type(func) == 'function', 'Incorrect attributes passed')
	local ident = tostring(random())--GenerateRandomIdent{ len = 8, up = true, low = true, num = true }
	toAdd[ident] = { func, ... }
	return ident
end

--Same as above, but allows you to choose custom id.
function RunNewLoopIdent( id, func, ... )
	assert(type(func) == 'function', 'Incorrect attributes passed')
	toAdd[id] = { func, ... }
	return id
end

--Stops loop by its identity, returned from RunNewLoop. Use: StopLoopIdent( identity )
function StopLoopIdent( ident )
	local ret = false
	if ( toAdd[ident] ) then
		toAdd[ident] = nil
		ret = true
	end
	if ( not toRemove[ident] ) then
		local entry = ranThreads[ident]
		if ( entry ) then
			toRemove[ident] = true
			--Hack to prevent loop method from being executed
			entry[1] = void
			ret = true
		end
	end
	return ret
end

--Stops loop by passing exact function and argument from what you run new loop. Use: StopRnLoop( function, argument )
--Avoid using this, better stick to StopLoopIdent
function StopRnLoop( func, data )
	for key,tdata in pairs(ranThreads) do
		if tdata[1] == func and tdata[2] == data then
			toRemove[key] = true
			tdata[1] = void
			return true
		end
	end
	return false
end

--Stops all running loops. Use: StopAllLoops()
function StopAllLoops()
	ranThreads = {}
	toRemove = {}
	toAdd = {}
end

--Returns ranThreads table
function AllRunningLoops()
	return ranThreads
end

do
	if not orig__update then
		orig__update = update 
	end
	local orig__update = orig__update
	function update( ... )
		orig__update( ... )
		for k,f in pairs(ranThreads) do
			pcall(unpack(f))
		end
		--Process all insertions/removes
		if ( next(toRemove) ) then
			for key,v in pairs(toRemove) do
				ranThreads[key] = nil
			end
			toRemove = {}
		end
		if ( next(toAdd) ) then
			for key,v in pairs(toAdd) do
				ranThreads[key] = v
			end
			toAdd = {}
		end
	end
end

local RunNewLoopIdent = RunNewLoopIdent
local StopLoopIdent = StopLoopIdent
--Example, how RunNewLoop can be used in practice. 'executewithdelay' will delay execution of function, you passed into parameters.
--Use: executewithdelay( { func = function, params = { arguments } }, delay_in_seconds )
--Returns loop's ident
function executewithdelay(callback,delay, id)
	if type(callback) == "function" then
		callback = { func = callback, params = {} }
	end
	local updator
	local clbk = callback.func
	local params = callback.params
	local mark = os_clock()
	local r = function()
		if os_clock() - mark >= delay then
			clbk(unpack(params))
			StopLoopIdent(updator)
		end
	end
	if not id then
		id = tostring( random() )
	end
	updator = RunNewLoopIdent(id,r)
	return updator
end