if not NetworkMatchMakingSTEAM then return nil end
function NetworkMatchMakingSTEAM:set_num_players(num)
	print("NetworkMatchMakingSTEAM:set_num_players", num)
	self._num_players = num
	if self._lobby_attributes and self.lobby_handler then
		self._lobby_attributes.num_players = num
		self.lobby_handler:set_lobby_data(self._lobby_attributes)
	end
end