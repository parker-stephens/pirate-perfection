--Purpose: allows prevent game from destroying lua state, when parallel tasks are run.

local NewThread = NewThread
local log = m_log_vs
local m_inspect = m_log_inspect
local _err = m_log_error
local backuper = backuper
local hijack = backuper.hijack
local restore = backuper.restore
local table = table
local next = next
local pairs = pairs
local ppr_require = ppr_require
local os_clock = os.clock
local NOT_ENDING = true
local LOCKED = false --Used to prevent multiple threads from accessing some critical functions at same moment

local tasks = {} --Custom parallel tasks (like Steam:http_request one)

local function AddParallelTask( id )
	if ( NOT_ENDING ) then
--		while ( LOCKED ) do end --Spin, wait till unlocked
--		LOCKED = true
		tasks[id] = true
--		LOCKED = false
	end
end

local function EndedParallelTask( id )
--	while ( LOCKED ) do end --Spin, wait till unlocked
--	LOCKED = true
	tasks[id] = nil
--	LOCKED = false
end

local function RunParallelTask( func, id )
	if ( NewThread ) then
		if ( NOT_ENDING and not tasks[id] ) then
			local thread = NewThread( func )
			AddParallelTask( id )
			--Thread must callback on EndedParallelTask, when it is done their job!
			--Also thread must be assigned somewhere, or else GC will collect it and its work will be broken.
			return thread
		else
			return false
		end
	end
	_err("{parallel_tasks.lua}", "Parallelism isn't supported.")
	return false
end

local tr = Localization.translate
local delayed_menu_data = {
	title = tr.prl_too_long, --"Too long"
	description = tr.prl_too_long_desc,--"Some tasks still aren't finished their work, do you want to end them and force game to proceed ?",
	button_list = { { text = tr.prl_proceed--[["Force to continue"]], callback = restore, data = { backuper, 'Setup.block_exec' } } }
}

local function show_too_long_alert()
	local M = ppr_require("Trainer/tools/new_menu/menu")
	M:open( delayed_menu_data )
end

--Main blocker
hijack( backuper, 'Setup.block_exec',
	function(o, self, ... )
		local ret = o( self, ... )
		NOT_ENDING = false --Prevent futher threads and tasks to be added
		--Check, if tasks and threads tables are emtpy
		if ( next(tasks) ) then
			if ( not self.__messaged_about_block ) then
				self.__messaged_about_block = true
				log("{parallel_tasks.lua} (Setup.block_exec) Still have parallel tasks and/or threads doing their job.")
				m_inspect(tasks)
			end
			local T = self.__tasks_T
			if ( not T ) then
				T = os_clock()
				self.__tasks_T = T
			elseif ( os_clock() - T >= 30 ) then
				local list = ""
				local tostr = tostring
				for task in pairs(tasks) do
					list = list .. " => " .. tostr(task) .. "\n"
				end
				self.__tasks_T = nil
				_err("{parallel_tasks.lua}", "Tasks are doing their job too long\n", list)
				--restore( backuper, 'Setup.block_exec' ) --Don't check for tasks anymore,they are taking too long
				show_too_long_alert()
			end
			ret = true
		end
		return ret
	end
)

return {
	RunParallelTask = RunParallelTask,
	AddParallelTask = AddParallelTask,
	EndedParallelTask = EndedParallelTask
}