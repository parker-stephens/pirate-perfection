-- Switch scripts between job menu and stealth menu

if ( GameSetup ) then
	return ppr_dofile('Trainer/menu/ingame/stealthmenu')
else
	return ppr_dofile('Trainer/menu/pre-game/jobmenu')
end