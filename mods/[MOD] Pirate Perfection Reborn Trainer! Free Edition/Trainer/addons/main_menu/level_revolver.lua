--Purpose: increases level by 1 every second till 255 and resets to 0 again
--Author: ****

plugins:new_plugin('level_revolver')

VERSION = '1.1'

CATEGORY = 'main'

local Application = Application
local A_time = Application.time
local managers = managers
local M_experience = managers.experience
local get_current_level = M_experience.current_level
local set_current_level = M_experience._set_current_level
local M_network = managers.network
local RunNewLoopIdent = RunNewLoopIdent
local StopLoopIdent = StopLoopIdent

function MAIN()
	local mark = 0
	local function increase()
		local t = A_time(Application)
		if t - mark >= 1 then
			mark = t
			local level = get_current_level(M_experience)
			if not level then
				return
			end
			local new_level = level + 1
			if new_level > 255 then
				new_level = 1
			end
			set_current_level(M_experience, new_level)
			local s = M_network._session
			if s then
				s:send_to_peers('sync_level_up', new_level)
			end
		end
	end

	RunNewLoopIdent('level_increaser',increase)
end

function UNLOAD()
	StopLoopIdent('level_increaser')
end

FINALIZE()