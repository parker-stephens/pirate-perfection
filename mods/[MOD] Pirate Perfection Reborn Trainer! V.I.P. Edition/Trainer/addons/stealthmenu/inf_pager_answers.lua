-- Infinite pages answers
-- Author: Simplity, Original Script: Transcend

plugins:new_plugin('inf_pager_answers')

VERSION = '1.0'

function MAIN()
	backuper:backup('GroupAIStateBase.on_successful_alarm_pager_bluff')
	function GroupAIStateBase.on_successful_alarm_pager_bluff()end
end

function UNLOAD()
	backuper:restore('GroupAIStateBase.on_successful_alarm_pager_bluff')
end

FINALIZE()