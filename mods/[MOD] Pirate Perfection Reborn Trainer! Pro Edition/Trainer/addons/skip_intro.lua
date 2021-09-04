local IngameWaitingForPlayersState__start_audio_original = IngameWaitingForPlayersState._start_audio
function IngameWaitingForPlayersState:_start_audio()
    IngameWaitingForPlayersState__start_audio_original(self)
    if managers.network.game and Network:is_server() then
        managers.network:game():spawn_players()
    end
end