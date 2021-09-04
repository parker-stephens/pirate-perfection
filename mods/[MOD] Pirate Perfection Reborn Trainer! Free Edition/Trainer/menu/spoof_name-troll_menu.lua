-- Switch scripts between Spoof Name menu and Troll menu

if (GameSetup) then
	return ppr_dofile('Trainer/menu/ingame/troll_menu')
else
	return ppr_dofile('Trainer/menu/pre-game/spoof_name')
end