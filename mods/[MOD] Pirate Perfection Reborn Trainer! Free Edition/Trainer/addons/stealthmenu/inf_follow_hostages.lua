-- No limit how many hostages can follow you
-- Author: v00d00

plugins:new_plugin('inf_follow_hostages')

VERSION = '1.0'

function MAIN()
	backuper:backup('tweak_data.player.max_nr_following_hostages')
	tweak_data.player.max_nr_following_hostages = 500
end

function UNLOAD()
	backuper:restore('tweak_data.player.max_nr_following_hostages')
end

FINALIZE()