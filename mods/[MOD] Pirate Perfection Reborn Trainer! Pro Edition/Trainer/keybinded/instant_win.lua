--Purpose: Instantly win any game, host only.

if ( not GameSetup ) then
	return
end

local managers = managers
local M_network = managers.network
local game_state_machine = game_state_machine

local function you_winner()
	local num_winners = M_network:session():amount_of_alive_players()
	M_network._session:send_to_peers( "mission_ended", true, num_winners )
	game_state_machine:change_state_by_name( "victoryscreen", { num_winners = num_winners, personal_win = true } )
end

return you_winner