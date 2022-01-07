-- People don't call police
-- Authors: Remade: Simplity, Original: Transcend

local backuper = backuper
local backup = backuper.backup
local restore = backuper.restore

local GroupAIStateBase = GroupAIStateBase
local CivilianLogicFlee = CivilianLogicFlee

plugins:new_plugin('dont_call_police')

VERSION = '1.0'

function MAIN()
	backup(backuper, 'GroupAIStateBase.on_police_called')
	backup(backuper, 'CivilianLogicFlee.clbk_chk_call_the_police')
	
	function GroupAIStateBase.on_police_called()end
	function CivilianLogicFlee.clbk_chk_call_the_police()end
end

function UNLOAD()
	restore(backuper, 'GroupAIStateBase.on_police_called')
	restore(backuper, 'CivilianLogicFlee.clbk_chk_call_the_police')
end

FINALIZE()