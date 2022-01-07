--Purpose: restores drill once it's jammed.
--Author: baldwin

plugins:new_plugin('drill_auto_service')

local alive = alive
local managers = managers
local M_player = managers.player

FULL_NAME = 'Drill auto service'

VERSION = '1.0'

DESCRIPTION = 'Automatically restores drill when it jams'

function MAIN()
	backuper:hijack('Drill.set_jammed',function(o,self, jammed, ... )
		local r = o(self,jammed, ...)
		local player = M_player:local_player()
		local unit = self._unit
		if alive( unit ) then
			local interaction = unit.interaction
			if interaction then
				interaction = interaction( unit )
			end
			local interact = interaction and interaction.interact
			if interact then
				interact( interaction, player )
			end
		end
		return r
	end)
end

function UNLOAD()
	backuper:restore('Drill.set_jammed')
end

FINALIZE()