--Purpose: Troll drilling. Toggle method. You can even force drills to loop If they are already started.
--Author: King Nothing

plugins:new_plugin('trolldrills')

local type = type
local tonumber = tonumber
local M_network = managers.network
local backuper = backuper

VERSION = '1.0'

function MAIN()
	backuper:add_clbk('TimerGui.update', function( o, self, ... )
		local current_timer = self._current_timer
		if(type(current_timer) == 'number' and current_timer or tonumber(current_timer) or -1) < 5 then
			self._current_timer = 30
			M_network._session:send_to_peers( "start_timer_gui", self._unit, 30 )
		end	
	end, 'trolldrills', 1)
end

function UNLOAD()
	backuper:remove_clbk('TimerGui.update', 'trolldrills', 1)
end

FINALIZE()