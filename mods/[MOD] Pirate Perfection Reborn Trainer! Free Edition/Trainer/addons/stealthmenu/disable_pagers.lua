-- Disable Pagers with all kills
-- Author: ?

plugins:new_plugin('disable_pagers')

VERSION = '1.0'

function MAIN()
local old_init = PlayerTweakData.init
	function PlayerTweakData:init()
		old_init(self)
		self.alarm_pager = {	first_call_delay = {9999, 9999},
								call_duration = {{9999, 9999},{9999, 9999}},
								nr_of_calls = {9999, 9999},
								bluff_success_chance = { 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0 },
								bluff_success_chance_w_skill = { 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0 }
							}
	end
end

function UNLOAD()
local old_init = PlayerTweakData.init
	function PlayerTweakData:init()
		old_init(self)
		self.alarm_pager = {	first_call_delay = {2, 4},
								call_duration = {{6, 6},{6, 6}},
								nr_of_calls = {2, 2},
								bluff_success_chance = { 1, 1, 1, 1, 0 },
								bluff_success_chance_w_skill = { 1, 1, 1, 1, 0 }
							}
	end
end

FINALIZE()