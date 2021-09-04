-- Players don't Shout at tied civilians
if inGame() and isPlaying() then
	PlayerStandard.__get_unit_intimidation_action = PlayerStandard.__get_unit_intimidation_action or PlayerStandard._get_unit_intimidation_action
	function PlayerStandard:_get_unit_intimidation_action(...)
		local args = {...}
		if args[2] then
			for k,v in pairs(managers.enemy:all_civilians() ) do
				if v.unit:in_slot(21) and v.unit:anim_data().tied then
					v.unit:set_slot(22)
				end
			end
		end
	return	self:__get_unit_intimidation_action(...)
	end
end