-- AMMO AND HEALTH REFILL + RESET SELF STATE
	if	inGame()	and	isPlaying()	and	not	inChat()	and	not	InOverlay()	then
		local	player	=	managers.player:player_unit()
		if	alive(player)	then
			player:base():replenish()
			show_mid_text("Ammo Refilled","Health and",1.5)
		end
		managers.player:set_player_state("standard")
		else
	end