--Purpose: notices user if crash happened
--Method used: everytime user legitly quits or switches between different game's setups it creates file called "safe.check" with a char, t once Trainer gets executed, it will check if file have any bytes and if everything correct, then it will erase "safe.check" file.
local io_open = ppr_io.open
local managers = managers
local M_exception = managers.exception

local backuper = backuper
local hijack = backuper.hijack
local add_clbk = backuper.add_clbk
--local remove_clbk = backuper.remove_clbk

local function check_danger()
	local r = io_open('Trainer/configs/checks/safe.check','r')
	if r then
		r = r:read('*all') ~= ''
	end
	if not r and M_exception then
		M_exception:catch('crash_t')
		return
	end
	io_open('Trainer/configs/checks/safe.check','w'):close()
end

local function safe_to_quit()
	local f = io_open('Trainer/configs/checks/safe.check','w')
	if f then
		f:write(' ')
		f:close()
	end
end

hijack(backuper, 'Setup.quit',function(o, ...)
    o(...)
	safe_to_quit()
end)

hijack(backuper, 'Setup.exec', function(o, ... )
	o(...)
	safe_to_quit()
end)
add_clbk(backuper, 'MenuMainState.at_enter', check_danger, 'crashnoticer', 2)

--[[local Application = Application
local A_time = Application.time
local __T = A_time(Application)
query_execution_testfunc(function() return managers.system_menu and (A_time(Application) - __T >= 5.0) end, { f = check_danger })]]