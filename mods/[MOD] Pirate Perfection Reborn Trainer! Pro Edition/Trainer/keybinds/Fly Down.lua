-- DESCEND/FLY DOWN SCRIPT
function inGame() 
  if not game_state_machine then return false end 
  return string.find(game_state_machine:current_state_name(), "game") 
end 
function show_mid_text( msg, msg_title, show_secs ) 
    if managers and managers.hud then 
    managers.hud:present_mid_text( { text = msg, title = msg_title, time = show_secs } ) 
    end 
end 
if inGame() and managers.platform:presence() == "Playing" and not inChat() then
	managers.player:player_unit():mover():set_velocity( Vector3(0,0,0) )
	managers.player:player_unit():mover():set_gravity( Vector3( 0, 0,-400 ) )
	managers.player:player_unit():mover():jump()
else
	--PlayMedia("Trainer/media/effects/access.mp3")
end