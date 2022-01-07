--Purpose: instantly plays bullet effect instead of queueing it.
--Idea by SquareOne

backuper:backup('GamePlayCentralManager.play_impact_sound_and_effects')
function GamePlayCentralManager:play_impact_sound_and_effects( params )
	self:_play_bullet_hit(params)
end