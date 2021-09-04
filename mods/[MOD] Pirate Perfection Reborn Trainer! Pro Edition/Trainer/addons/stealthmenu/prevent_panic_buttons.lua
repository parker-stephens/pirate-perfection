-- Prevent panic button
-- Author: Transcend

plugins:new_plugin('prevent_panic_buttons')

VERSION = '1.0'

function MAIN()
	local actionRequest = backuper:backup('CopMovement.action_request')
	function CopMovement:action_request( action_desc )
		if action_desc.variant == "run" then return false end
		return actionRequest(self, action_desc)
	end
end

function UNLOAD()
	backuper:restore('CopMovement.action_request')
end

FINALIZE()