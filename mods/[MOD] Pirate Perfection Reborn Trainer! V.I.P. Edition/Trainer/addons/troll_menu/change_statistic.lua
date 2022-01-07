-- Change own statistic
-- Author: Simplity

plugins:new_plugin('change_statistic')

local managers = managers
local M_network = managers.network
local Network = Network

VERSION = '1.0'

function MAIN()
	backuper:backup('StatisticsManager.send_statistics')
	function StatisticsManager:send_statistics()
		local session = M_network:session()
		if not session then
			return
		end
		
		local peer_id = session:local_peer():id()
		local total_kills = 1337
		local total_specials_kills = 1337
		local total_head_shots = 666
		local accuracy = 1000
		local downs = 0
		if Network:is_server() then
			M_network:session():on_statistics_recieved( peer_id, total_kills, total_specials_kills, total_head_shots, accuracy, downs )
		else
			session:send_to_host( "send_statistics", total_kills, total_specials_kills, total_head_shots, accuracy, downs )
		end
	end
end

function UNLOAD()
	backuper:restore('StatisticsManager.send_statistics')
end

FINALIZE()