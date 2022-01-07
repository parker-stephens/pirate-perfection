-- Purpose: Sets your Lobby to Not modded
-- Author: Baddog-11
function MenuCallbackHandler:is_modded_client()
	return false
end

function MenuCallbackHandler:is_not_modded_client()
	return true
end