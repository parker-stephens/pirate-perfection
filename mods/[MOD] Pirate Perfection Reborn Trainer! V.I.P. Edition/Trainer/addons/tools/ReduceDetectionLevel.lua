-- Change detection level
-- Author: Simplity

local MenuCallbackHandler = MenuCallbackHandler
local update_outfit_information = MenuCallbackHandler._update_outfit_information

local backuper = backuper
local backup = backuper.backup
local restore = backuper.restore

plugins:new_plugin('ReduceDetectionLevel')

CATEGORY = 'tools'

function MAIN()	
	backup(backuper, "BlackMarketManager.visibility_modifiers")	
	function BlackMarketManager:visibility_modifiers()
		return -999
	end

	update_outfit_information(MenuCallbackHandler)
end

function UNLOAD()
	restore(backuper, "BlackMarketManager.visibility_modifiers")
	update_outfit_information(MenuCallbackHandler)
end

FINALIZE()