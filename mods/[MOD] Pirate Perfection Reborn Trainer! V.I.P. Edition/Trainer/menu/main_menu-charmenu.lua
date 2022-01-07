-- Switch scripts between main menu and char menu

if (GameSetup) then
	return ppr_dofile('Trainer/menu/ingame/charmenu')
else
	return ppr_dofile('Trainer/menu/pre-game/main_menu')
end