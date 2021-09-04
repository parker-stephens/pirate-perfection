-- LEVEL MENU DUOSCRIPT v1.1

-------------------
-- GLOBAL --
-------------------

testlevelcounter = testlevelcounter or function( n )
  local peer = managers.network:session():local_peer()
  peer:set_level( n )
  managers.experience:_set_current_level( math.floor(n) )
  managers.network:session():send_to_peers( "sync_level_up", peer:id(), n )
end
gADelay = gADelay or nil
gALvl = gALvl or 75
inclevelcounter = inclevelcounter or function()
  if not gADelay or os.clock() - gADelay >= 1 then --Prevents network flood
    gADelay = os.clock()
    gALvl = gALvl + 1 or 1
    if gALvl>=256 then
      gALvl = 75
    end
    testlevelcounter(gALvl)
  end
end
addtestlevelcounter = addtestlevelcounter or function()
	if not removeFromQueue( inclevelcounter, nil ) then
		addToQueue( inclevelcounter, nil )
	end
end
queueFunc = queueFunc or {} --Simple function to repeat some functions over time by baldwin.
function addToQueue( func, data )
	table.insert(queueFunc, { f=func, d=data })
end
function removeFromQueue( func, data )
	for key,tdata in pairs(queueFunc) do
		if tdata.f==func and tdata.d==data then
			table.remove(queueFunc, key)
			--break --Stop loop after removing function
			return true
		end
	end
return false
end
function flushQueue()
	queueFunc = {}
end
function NetworkPeer:on_send()
	for _,data in pairs(queueFunc) do
		if data.d then
			data.f(data.d)
		else
			data.f()
		end
	end
self:flush_overwriteable_msgs()
end
function fplayer_name(id)
	if managers.platform:presence() ~= "Playing" then
		return ""
	end
	
	for pl_key, pl_record in pairs( managers.groupai:state():all_player_criminals() ) do
		local unit = managers.groupai:state():all_player_criminals()[ pl_key ].unit 		
		if unit:network():peer():id() == id then
			return unit:base():nick_name()
		end
	end 
	return ""
end

---------------
-- GAME --
---------------
if inGame() and isPlaying() then
	-- PLY1 LVL1
	fply1level1 = fply1level1 or function()
		local peer = managers.network:session():peer( 1 )
		if peer then
		peer:set_level( 1 )
		end
		managers.network:session():send_to_peers_synched( "sync_level_up", 1, 1 )
	end
	-- PLY2 LVL1
	fply2level1 = fply2level1 or function()
		local peer = managers.network:session():peer( 2 )
		if peer then
		peer:set_level( 1 )
		end
		managers.network:session():send_to_peers_synched( "sync_level_up", 2, 1 )
	end
	-- PLY3 LVL1
	fply3level1 = fply3level1 or function()
		local peer = managers.network:session():peer( 3 )
		if peer then
		peer:set_level( 1 )
		end
		managers.network:session():send_to_peers_synched( "sync_level_up", 3, 1 )
	end
	-- PLY4 LVL1
	fply4level1 = fply4level1 or function()
		local peer = managers.network:session():peer( 4 )
		if peer then
		peer:set_level( 1 )
		end
		managers.network:session():send_to_peers_synched( "sync_level_up", 4, 1 )
	end
	-- PLY1 LVL100
	fply1level100 = fply1level100 or function()
		local peer = managers.network:session():peer( 1 )
		if peer then
		peer:set_level( 100 )
		end
		managers.network:session():send_to_peers_synched( "sync_level_up", 1, 100 )
	end
	-- PLY2 LVL100
	fply2level100 = fply2level100 or function()
		local peer = managers.network:session():peer( 2 )
		if peer then
		peer:set_level( 100 )
		end
		managers.network:session():send_to_peers_synched( "sync_level_up", 2, 100 )
	end
	-- PLY3 LVL100
	fply3level100 = fply3level100 or function()
		local peer = managers.network:session():peer( 3 )
		if peer then
		peer:set_level( 100 )
		end
		managers.network:session():send_to_peers_synched( "sync_level_up", 3, 100 )
	end
	-- PLY4 LVL100
	fply4level100 = fply4level100 or function()
		local peer = managers.network:session():peer( 4 )
		if peer then
		peer:set_level( 100 )
		end
		managers.network:session():send_to_peers_synched( "sync_level_up", 4, 100 )
	end
	-- PLY1 LVL255
	fply1level255 = fply1level255 or function()
		local peer = managers.network:session():peer( 1 )
		if peer then
		peer:set_level( 255 )
		end
		managers.network:session():send_to_peers_synched( "sync_level_up", 1, 255 )
	end
	-- PLY2 LVL255
	fply2level255 = fply2level255 or function()
		local peer = managers.network:session():peer( 2 )
		if peer then
		peer:set_level( 255 )
		end
		managers.network:session():send_to_peers_synched( "sync_level_up", 2, 255 )
	end
	-- PLY3 LVL255
	fply3level255 = fply3level255 or function()
		local peer = managers.network:session():peer( 3 )
		if peer then
		peer:set_level( 255 )
		end
		managers.network:session():send_to_peers_synched( "sync_level_up", 3, 255 )
	end
	-- PLY4 LVL255
	fply4level255 = fply4level255 or function()
		local peer = managers.network:session():peer( 4 )
		if peer then
		peer:set_level( 255 )
		end
		managers.network:session():send_to_peers_synched( "sync_level_up", 4, 255 )
	end
	-- SET TEAM LEVEL 1
	fteamlvl1 = fteamlvl1 or function()
		local i = 1
		for pl_key, pl_record in pairs( managers.groupai:state():all_player_criminals() ) do
			if pl_record.status ~= "dead" then
			local unit = managers.groupai:state():all_player_criminals()[ pl_key ].unit
			local peer = managers.network:session():peer( i )
			peer:set_level( 1 )
			managers.network:session():send_to_peers_synched( "sync_level_up", i, 1 )
			end
		i = i + 1
		end
	end
	-- SET TEAM LEVEL 100
	fteamlvl100 = fteamlvl100 or function()
		local i = 1
		for pl_key, pl_record in pairs( managers.groupai:state():all_player_criminals() ) do
			if pl_record.status ~= "dead" then
			local unit = managers.groupai:state():all_player_criminals()[ pl_key ].unit
			local peer = managers.network:session():peer( i )
			peer:set_level( 100 )
			managers.network:session():send_to_peers_synched( "sync_level_up", i, 100 )
			end
		i = i + 1
		end
	end
	-- SET TEAM LEVEL 255
	fteamlvl255 = fteamlvl255 or function()
		local i = 1
		for pl_key, pl_record in pairs( managers.groupai:state():all_player_criminals() ) do
			if pl_record.status ~= "dead" then
			local unit = managers.groupai:state():all_player_criminals()[ pl_key ].unit
			local peer = managers.network:session():peer( i )
			peer:set_level( 255 )
			managers.network:session():send_to_peers_synched( "sync_level_up", i, 255 )
			end
		i = i + 1
		end
	end
end

---------------------------------------
-- MAINMENU SETTINGS --
---------------------------------------
-- LEVEL CHANGE FUNCTIONS 
if not inGame() then 
	-- SET LEVEL TO 1
	level1 = level1 or function()
		managers.experience :_set_current_level(1)
	end
	-- SET LEVEL TO 13
	level13 = level13 or function()
		managers.experience :_set_current_level(13)
	end
	-- SET LEVEL TO 25
	level25 = level25 or function()
		managers.experience :_set_current_level(25)
	end
	-- SET LEVEL TO 37
	level37 = level37 or function()
		managers.experience :_set_current_level(37)
	end
	-- SET LEVEL TO 50 
	level50 = level50 or function()
		managers.experience :_set_current_level(50)
	end
	-- SET LEVEL TO 66
	level66 = level66 or function()
		managers.experience :_set_current_level(66)
	end
	-- SET LEVEL TO 75
	level75 = level75 or function()
		managers.experience :_set_current_level(75)
	end
	-- SET LEVEL TO 87
	level87 = level87 or function()
		managers.experience :_set_current_level(87)
	end
	-- SET LEVEL TO 99
	level99 = level99 or function()
		managers.experience :_set_current_level(99)
	end
	-- SET LEVEL TO 100
	level100 = level100 or function()
		managers.experience :_set_current_level(100)
	end
	-- SET LEVEL TO 101
	level101 = level101 or function()
		managers.experience :_set_current_level(101)
	end
	-- SET LEVEL TO 255
	level255 = level255 or function()
		managers.experience :_set_current_level(255)
	end
	-- ADD 100 EXP
	xpadder = xpadder or function()
		managers.experience:debug_add_points( 100, false )
	end
	-- ADD 1.000 EXP
	xpadder1 = xpadder1 or function()
		managers.experience:debug_add_points( 1000, false )
	end
	-- ADD 10.000 EXP
	xpadder2 = xpadder2 or function()
		managers.experience:debug_add_points( 10000, false )
	end
	-- ADD 100.000 EXP
	xpadder3 = xpadder3 or function()
		managers.experience:debug_add_points( 100000, false )
	end
	-------------------------------
	-- MENU SETTINGS --
	-------------------------------
	fcallsync1menu = fcallsync1menu or function()
		openmenu(fsyncp1menu)
	end
	fcallsync2menu = fcallsync2menu or function()
		openmenu(fsyncp2menu)
	end
	fcallsync3menu = fcallsync3menu or function()
		openmenu(fsyncp3menu)
	end
	fcallsync4menu = fcallsync4menu or function()
		openmenu(fsyncp4menu)
	end
	-- SYNC PLAYERS STATE MENU INGAME
	fsyncp1opt = {
		{ text = "Set player level to 1", callback = fply1level1 },
		{ text = "Set player level to 100", callback = fply1level100 },
		{ text = "Set player level to 255", callback = fply1level255 },
		}
	fsyncp1menu = SimpleMenu:new("MESS WITH "..fplayer_name(1).."", "..and change his level",fsyncp1opt)
	fsyncp2opt = {
		{ text = "Back", callback = callsyncmainmenu },
		{ text = "", is_cancel_button = true},
		{ text = "Set player level to 1", callback = fply2level1 },
		{ text = "Set player level to 100", callback = fply2level100 },
		{ text = "Set player level to 255", callback = fply2level255 },
		}
	fsyncp2menu = SimpleMenu:new("MESS WITH "..fplayer_name(2).."", "..and change his level",fsyncp2opt)
	fsyncp3opt = {
		{ text = "Back", callback = callsyncmainmenu },
		{ text = "", is_cancel_button = true},
		{ text = "Set player level to 1", callback = fply3level1 },
		{ text = "Set player level to 100", callback = fply3level100 },
		{ text = "Set player level to 255", callback = fply3level255 },
		}
	fsyncp3menu = SimpleMenu:new("MESS WITH "..fplayer_name(3).."", "..and change his level",fsyncp3opt)
	fsyncp4opt = {
		{ text = "Back", callback = callsyncmainmenu },
		{ text = "", is_cancel_button = true},
		{ text = "Set player level to 1", callback = fply4level1 },
		{ text = "Set player level to 100", callback = fply4level100 },
		{ text = "Set player level to 255", callback = fply4level255 },
		}
	fsyncp4menu = SimpleMenu:new("MESS WITH "..fplayer_name(4).."", "..and change his level",fsyncp4opt)
	-- LEVEL ROOT MENU OUTGAME
	levelropt = levelropt or {
		{ text = "Exit", is_cancel_button = true },
		{},
		{ text = "Add 100.000 exp", callback = xpadder3 },
		{ text = "Add 10.000 exp", callback = xpadder2 },
		{ text = "Add 1000 exp", callback = xpadder1 },
		{ text = "Add 100 exp", callback = xpadder },
		{},
		{ text = "Level revolver : toggle", callback = addtestlevelcounter },
		{},
		{ text = "Set level to 255 for the lulz", callback = level255 },
		{ text = "Set level to 101 for the lulz", callback = level101 },
		{},
		{ text = "Set level to 100", callback = level100 },
		{ text = "Set level to 99", callback = level99 },
		{ text = "Set level to 87", callback = level87 },
		{ text = "Set level to 75", callback = level75 },
		{ text = "Set level to 66", callback = level66 },
		{ text = "Set level to 50", callback = level50 },
		{ text = "Set level to 37", callback = level37 },
		{ text = "Set level to 25", callback = level25 },
		{ text = "Set level to 13", callback = level13 },
		{ text = "Set level to 1", callback = level1 },
		}
	if not levelrootmenu then
		levelrootmenu = levelrootmenu or SimpleMenu:new("LEVEL/EXP MENU", "Change your level / add experience points.", levelropt)
	end
	levelrootmenu:show()
else
	-- LEVEL ROOT MENU INGAME
	levelropt = levelropt or {
		{ text = "Exit", is_cancel_button = true },
		{},
		{ text = "Mess with "..fplayer_name(4).." --OBS!! NOT WORKING--", callback = fcallsync4menu },
		{ text = "Mess with "..fplayer_name(3).." --OBS!! NOT WORKING--", callback = fcallsync3menu },
		{ text = "Mess with "..fplayer_name(2).." --OBS!! NOT WORKING--", callback = fcallsync2menu },
		{ text = "Mess with "..fplayer_name(1).." --OBS!! NOT WORKING--", callback = fcallsync1menu },
		{},
		{ text = "Elite team, all teammembers level 255", callback = fteamlvl255 },
		{ text = "Pro team, all teammembers level 100", callback = fteamlvl100 },
		{ text = "Noob team, all teammembers level 1", callback = fteamlvl1 },
		{},
		{ text = "Level revolver : toggle", callback = addtestlevelcounter },
		{},
		{ text = "Spoof own level to 255", callback = fselflevel255 },
		{ text = "Spoof own level to 100", callback = fselflevel100 },
		{ text = "Spoof own level to 1", callback = fselflevel1 },
		}
	if not levelrootmenu then
		levelrootmenu = levelrootmenu or SimpleMenu:new("LEVEL MENU", "Change your level.", levelropt)
	end
	levelrootmenu:show()
end