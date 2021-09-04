--Purpose: replenish player's health and ammo + restores standard state once script activated and if player is alive.
--Authors: PPR Devs

local managers = managers
local M_player = managers.player
local players_list = M_player._players
local set_player_state = M_player.set_player_state
local add_grenade_amount = M_player.add_grenade_amount
local alive = alive

local function REPLENISH()
	local ply = players_list[1]
	if alive(ply) then
		ply:base():replenish() --Gives health & ammo
		set_player_state(M_player, 'standard') --Restore tase or downed state
		--add_grenade_amount(M_player, 3) --Restores grenades
	end
end

return REPLENISH