--[[
	Init file for some helpfull core functions.
	ppr_require it before init.lua being executed.
]]

local ppr_require = ppr_require
local rawget = rawget
ppr_require('Trainer/tools/tools')

--Setup for underground light hook

local __require_after = rawget(_G, '__require_after')
if (__require_after) then
	local ppr_dofile = ppr_dofile
	local rawset = rawset
	local getmetatable = getmetatable
	local Application = Application
	
	__require_after['lib/entry'] = 
	function()
		--Inits Trainer
		ppr_dofile('Trainer/Setup/init')
		--ppr_dofile('Trainer/addons/freeflight')
	end

	__require_pre['core/lib/system/coresystem'] =
	function()
		--Enables freeflight
		rawset(getmetatable(Application),"debug_enabled",function() return true end)
	end
end
