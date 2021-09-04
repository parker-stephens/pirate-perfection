-- Instant deployments

plugins:new_plugin('instant_deployments')

VERSION = '1.0'

function MAIN()
	backuper:backup('PlayerManager.selected_equipment_deploy_timer')
	function PlayerManager.selected_equipment_deploy_timer() return 0 end
end

function UNLOAD()
	backuper:restore('PlayerManager.selected_equipment_deploy_timer')
end

FINALIZE()