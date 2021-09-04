-- Trigger Recorder

plugins:new_plugin('trigger_recorder')

VERSION = '1.0'

local backuper = backuper
local restore = backuper.restore
local backup = backuper.backup


function MAIN()
	function get_gametime_string()
		local current_game_time = managers.hud._hud_heist_timer._last_time
		current_game_time = math.floor(current_game_time)
		local hours = math.floor(current_game_time / 3600)
		current_game_time = current_game_time - hours * 3600
		local minutes = math.floor(current_game_time / 60)
		current_game_time = current_game_time - minutes * 60
		local seconds = math.round(current_game_time)
		local text = hours > 0 and (hours < 10 and "0" .. hours or hours) .. ":" or ""
		return text .. (minutes < 10 and "0" .. minutes or minutes) .. ":" .. (seconds < 10 and "0" .. seconds or seconds)
	end

	function MissionScriptElement:on_executed(...)
		if self:values().trigger_list then
			local write_file = ppr_io.open('Logfiles/Trigger List.txt','a')
			for _, trigger in pairs(self:values().trigger_list) do
				managers.mission._fading_debug_output:script().log(tostring(trigger.notify_unit_sequence), Color.gold)
				write_file:write(get_gametime_string()..': '..trigger.notify_unit_sequence..'\n')
			end
			write_file:write('\n')
			write_file:close()
		end
		MissionScriptElement.super.on_executed(self, ...)
	end
end

function UNLOAD()
	function get_gametime_string() return end
	function MissionScriptElement:on_executed(...) return end
end

FINALIZE()