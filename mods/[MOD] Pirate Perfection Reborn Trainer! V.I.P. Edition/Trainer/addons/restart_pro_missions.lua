--Restart pro missions
local JobManager = JobManager

local function no_longer_professional()
	JobManager.is_current_job_professional = function() return false end
end
--Here earlier was long and messy script, that did unnecessary relocations of original and new is_current_job_professional
--Replaced with just this string after some analyze
backuper:add_clbk('GameOverState.at_enter', no_longer_professional, 'no_longer_professional', 1)

ppr_require('Trainer/addons/restart_jobs')