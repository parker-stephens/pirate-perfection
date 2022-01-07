-- Increase interaction speed
-- Author: baldwin

--TO DO:
--Add slider, so user can specify his own interaction speed
--Maybe not force some time value, but divide it ?

local backuper = backuper
local BaseInteractionExt = BaseInteractionExt
local backup = backuper.backup
local restore = backuper.restore

plugins:new_plugin('interactions_speed_modifier')

VERSION = '1.0'

DESCRIPTION = 'Provides functions to easly modify interaction speed.'

function MAIN()
	function BaseInteractionExt:toggle_int_speed(speed)
		if self.speed_changed and self.speed_changed == speed then
			self:restore_speed()
			return
		end
		self:set_int_speed(speed)
	end

	function BaseInteractionExt:set_int_speed(speed)
		self.speed_changed = speed
		backup(backuper, 'BaseInteractionExt._get_timer')
		function BaseInteractionExt._get_timer() return speed end
	end

	function BaseInteractionExt:restore_speed()
		restore(backuper, 'BaseInteractionExt._get_timer')
		self.speed_changed = nil
	end
end

function UNLOAD()
	BaseInteractionExt:restore_speed()
	--Cleanup
	BaseInteractionExt.toggle_int_speed = nil
	BaseInteractionExt.set_int_speed = nil
	BaseInteractionExt.restore_speed = nil
end

FINALIZE()