--[[
    Patched Lua require method
    Authors:
	<Mary> - Base script
	<JazzMan, http://pirate-perfection.com/user/3-jazzydude/> - Crashproofed & extended functionality in general
	
	V2:
	-> Multiple return support added.
	-> "safe" argument also controls, whenever compiled chunk will be pcalled or no
	
	This script is part of underground light hook.
]]

-- Fix for blt
ppr_io = {}
local io_open = io.open
local io_lines = io.lines
local io_popen = io.popen

ppr_io.open = function( file, mode )
	file = "mods/[MOD] Pirate Perfection Reborn Trainer! Free Edition/" .. file
	return io_open( file, mode )
end

ppr_io.lines = function( file )
	file = "mods/[MOD] Pirate Perfection Reborn Trainer! Free Edition/" .. file
	return io_lines( file )
end

ppr_io.io_popen = function( command )
	command = command:gsub("Trainer/", "mods/[MOD] Pirate Perfection Reborn Trainer! Free Edition/Trainer/")
	return io_popen( command )
end

do
	
	if not ( orig__require ) then
		local orig__require = ppr_require
		local _G = _G
		local str_lower = string.lower
		local logme = logme or m_log_v
		local loadstring = loadstring
		local pcall = pcall
		local tostring = tostring
		local unpack = unpack
		local io_open = ppr_io.open
		
		local __require_pre = {} --Callbacks executed before script required
		local __require_after = {} --Callbacks executed after script required
		local __require_override = {} --Overriden ppr_require requests
		
		local G = getfenv(0)
		G.orig__require = orig__require
		G.__require_pre = __require_pre
		G.__require_after = __require_after
		G.__require_override = __require_override
		
		local was__required = {}
		
		local first_require_clbk
		first_require_clbk = function()
			if rawget(_G, '__first_require_clbk') then
				local exec = __first_require_clbk
				__first_require_clbk = nil
				exec()
			end
			first_require_clbk = function()end
		end
		
		local function exec_before_clbks( path )
			local before_clbk = __require_pre[path]
			if before_clbk then
				before_clbk()
			end
		end
		
		local function exec_after_clbks( path )
			local after_clbk = __require_after[path]
			if after_clbk then
				after_clbk()
			end
		end
		
		local exts = { '', '.lua', '.luac' }
		
		--[[
		Arguments:
			(in_path, type: string) : path to the required file, if file wasn't found, it calls original ppr_require function, if safe is false/nil
			[safe, type: boolean/anything] : If isn't false or nil, it doesn't call original ppr_require function and pcalls loaded chunk, in the result preventing crashes, when you ppr_require file from disk.
			[reload, type: boolean/anything] : If isn't false or nil, it ignores was__required check and loads script again. (So it acts like dofile)
		Returns:
			true or non-false/nil result from dofile, if dofile returns anything
		]]
		function ppr_require( in_path, safe, reload )
			--Executing clbk on 1st ppr_require, function will void itself on execution, result doesn't matter
			first_require_clbk()
			
			--logme('Requring',in_path)
			local path = str_lower(in_path)
			
			--Check if we were required already, if yes, return what returned dofile or true
			local __was_required = was__required[path]
			if (__was_required ~= nil and not reload) then
				return unpack( __was_required )
			end
			--------ppr_require function patch-------
			
			--Executing clbks before ppr_require
			local before_clbk = __require_pre[path]
			if before_clbk then
				before_clbk()
			end
			
			--Executing overriden clbks
			local override_clbk = __require_override[path]
			if override_clbk then
				return override_clbk()
			end
			
			local f
			local final_path
			local i = 1
			repeat
				final_path = path..exts[i]
				f = io_open(final_path, 'rb')
				i = i + 1
			until f or i > 3
			if not f then
				if safe then
					return logme("Error: filename "..in_path.." wasn't found!\n")
				end
				local ret = orig__require( in_path )
				local after_clbk = __require_after[path]
				if after_clbk then
					after_clbk()
				end
				return ret
			end
			local exec, str_err = loadstring( f:read('*all'), final_path )
			f:close()
			if exec then
				if ( safe ) then
					--Multiple return support
					local res = { pcall(exec) }
					if res[1] then
						res = { unpack( res, 2 ) }
						was__required[path] = res
						local after_clbk = __require_after[path]
						if after_clbk then
							after_clbk()
						end
						return unpack(res)
					else
						logme('Error: '..res[2]..'\n')
					end
				else
					local res = { exec() }
					was__required[path] = res
					local after_clbk = __require_after[path]
					if after_clbk then
						after_clbk()
					end
					return unpack( res )
				end
			elseif str_err then
				logme('Error: '..str_err..'\n')
			end
		end
		--Clear old required stuff
		function reset_requires()
			was__required = {}
		end
	end
end