-- GODMODE TOGGLE SCRIPT v2.1

if inGame() and isPlaying() and not inChat() then
	if _godLike then
		-- GOD MODE OFF
		managers.player:player_unit():character_damage():set_god_mode( false )
		_godLike = false
		show_mid_text("Be careful now...", "GOD MODE OFF", 1.0 )
		--SetConfig('GodMode', false, true)
	else
		-- GOD MODE ON
		managers.player:player_unit():character_damage():set_god_mode( true )
		_godLike = true
		show_mid_text("VENI VIDI VICI!!", "GOD MODE ON", 1.0 )	
		--SetConfig('GodMode', true, true)
	end
else
end