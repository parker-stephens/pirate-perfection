--Host forces plan by baldwin
--Purpose: Ignores votes and let the host choose his plans.

local M_network = managers.network
local is_client = is_client
local pairs = pairs

backuper:hijack('PrePlanningManager._update_majority_votes', function(o, self, ...)
	if is_client() then
		return o(self, ...)
	end
	--What it do in general: It is modified cutout of original _update_majority_votes, it selects your choosed plan_data and makes it always winner by default
	local local_peer_id = M_network._session._local_peer._id
	local vote_council = self:get_vote_council()
	local plan_data = vote_council[local_peer_id]
	--Since hotline miami heist, plan_data maybe nil
	if plan_data then
		local winners = {}
		for plan,data in pairs( plan_data ) do
			winners[plan] = { data[1], data[2] }
		end
		self._saved_majority_votes = winners
		return winners
	end
	--If plan data nil, just call original method to handle this
	return o(self, ...)
end)