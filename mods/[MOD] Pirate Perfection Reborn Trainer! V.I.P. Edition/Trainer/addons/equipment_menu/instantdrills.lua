--Purpose: Instant drilling. Toggle method. You can even force drills to finish If they are already started.
--Author: ****

plugins:new_plugin('instantdrills')

local type = type
local tonumber = tonumber
local M_network = managers.network
local backuper = backuper

VERSION = '1.0'

function MAIN()
	backuper:add_clbk('TimerGui.update', function( o, self, ... )
		local current_timer = self._current_timer
		if (type(current_timer) == 'number' and current_timer or tonumber(current_timer) or -1) > 0 then --I'm 100% serious, current_timer can be string!
			self._current_timer = -1
			M_network._session:send_to_peers( "start_timer_gui", self._unit, -1 ) --Don't include this part to release versions
		end
	end, 'insta_drill', 1)
end

function UNLOAD()
	backuper:remove_clbk('TimerGui.update', 'insta_drill', 1)
end

FINALIZE()