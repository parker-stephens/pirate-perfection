-- Tie all civilians 
-- Author: Simplity

local managers = managers
local M_player = managers.player
local M_enemy = managers.enemy

local HUGE = math.huge
local pairs = pairs

return function()
	local player = M_player:player_unit()
	local all_civilians = M_enemy:all_civilians()
	
	for u_key, u_data in pairs( all_civilians ) do	
		local unit = u_data.unit
		local brain = unit:brain()
		if not brain:is_tied() then
			local action_data = { type = "act", body_part = 1, clamp_to_graph = true, variant = "halt" }
			brain:action_request( action_data )
			brain._current_logic.on_intimidated( brain._logic_data, HUGE, player, true )
			brain:on_tied( player )
		end
	end
end