-- MEDIA MODULE SCRIPT v1.1

function openmenu(menu)
    menu:show()
end

-- function lua_run(path)
		-- local file = io.open(path, "r")
		-- if file then
			-- local exe = loadstring(file:read("*all"))
				-- if exe then
					-- exe()
				-- else
					-- io.stderr:write("Error in '" .. path .. "'.\n")
				-- end
				-- file:close()
		-- else
				-- io.stderr:write("Couldn't open '" .. path .. "'.\n")
		-- end
-- end
dofile("mods/Pirate Perfection Reborn/Trainer/tools/INTERCEPTION.lua")
Interception.RestoreAll()
---------------------------
-------- FUNCTIONS --------
---------------------------
if inGame() then
---------------------------
-- UNREAL TOURNAMENT MOD --
---------------------------
utkilling_sprees = { }
utkilling_sprees[10] = "killingspree.mp3"
utkilling_sprees[25] = "rampage.mp3"
utkilling_sprees[35] = "dominating.mp3"
utkilling_sprees[60] = "unstoppable.mp3"
utkilling_sprees[80] = "godlike.mp3"
utkilling_sprees[100] = "maytheforce.mp3"
utconsecutive_kills = { }
utconsecutive_kills[2] = "doublekill.mp3"
utconsecutive_kills[4] = "multikill.mp3"
utconsecutive_kills[6] = "ultrakill.mp3"
utconsecutive_kills[8] = "megakill.mp3"
utconsecutive_kills[10] = "monsterkill.mp3"
utconsecutive_kills[12] = "oneandonly.mp3"
utconsecutive_kills[15] = "holyshit.mp3"
 
if not _bodyCount then _bodyCount = 0 end
if not _consecBodyCount then _consecBodyCount = 0 end
if not _lastConsec then _lastConsec = nil end
 
 
local _deadCop = Interception.Backup(CopDamage, "die")
utstart = utstart or function()
	local function check_death(self, variant)
	if not self._dead and self._unit:base().attacker == managers.player:player_unit() then
	_bodyCount = _bodyCount + 1
       
		if utkilling_sprees[_bodyCount] then
			PlayMedia("mods/Pirate Perfection Reborn/media/ut/" .. utkilling_sprees[_bodyCount] .. "")
		if _bodyCount == 111 then _bodyCount = 0 end
		end
 
		if not _lastConsec or Application:time() - _lastConsec > 4 then _consecBodyCount = 0 end
		_consecBodyCount = _consecBodyCount + 1
		_lastConsec = Application:time()
		if utconsecutive_kills[_consecBodyCount] then
			PlayMedia("mods/Pirate Perfection Reborn/media/ut/" .. utconsecutive_kills[_consecBodyCount] .. "")
			end
		end
	end
 
 
	local _deadCop = Interception.Backup(CopDamage, "die")
	function CopDamage:die( variant )
		check_death(self, variant)
		return _deadCop(self, variant)
	end
 
	local _deadHusk = Interception.Backup(HuskCopDamage, "die")
	function HuskCopDamage:die( variant )
		check_death(self, variant)
		return _deadHusk(self, variant)
	end
 
	local _damageBullet = Interception.Backup(CopDamage, "damage_bullet")
	function CopDamage:damage_bullet( attack_data )
		self._unit:base().attacker = attack_data.attacker_unit
		return _damageBullet(self, attack_data)
	end
	local _damageExplosion = Interception.Backup(CopDamage, "damage_explosion")
	function CopDamage:damage_explosion( attack_data )
		self._unit:base().attacker = attack_data.attacker_unit
		return _damageExplosion(self, attack_data)
	end
	local _damageMelee = Interception.Backup(CopDamage, "damage_melee")
	function CopDamage:damage_melee( attack_data )
		self._unit:base().attacker = attack_data.attacker_unit
		return _damageMelee(self, attack_data)
	end

	-- PLAYER DOWN SOUND UT
	local _chgPlayerState = Interception.Backup(PlayerManager, "_change_player_state")
	-- plydownut = plydownut or function()
	function PlayerManager:_change_player_state()
		if self._current_state == "arrested" or self._current_state == "bleed_out" then
			PlayMedia("mods/Pirate Perfection Reborn/media/ut/humiliation.mp3")
		end
			return _chgPlayerState(self)
		end
end

---------------------------
--- EPIC RAP BATTLES MOD --
---------------------------
erbkilling_sprees = { }
erbkilling_sprees[10] = "notenjoy.mp3"
erbkilling_sprees[25] = "isplituass.mp3"
erbkilling_sprees[35] = "tangocash.mp3"
erbkilling_sprees[60] = "philosophy.mp3"
erbkilling_sprees[80] = "imthedanger.mp3"
erbkilling_sprees[100] = "imthedanger.mp3"
 
erbconsecutive_kills = { }
erbconsecutive_kills[2] = "yahtsee.mp3"
erbconsecutive_kills[4] = "bangarang.mp3"
erbconsecutive_kills[6] = "thisissparta.mp3"
erbconsecutive_kills[8] = "300asses.mp3"
erbconsecutive_kills[10] = "bringiton.mp3"
 
if not _bodyCount then _bodyCount = 0 end
if not _consecBodyCount then _consecBodyCount = 0 end
if not _lastConsec then _lastConsec = nil end
 
local _deadCop = Interception.Backup(CopDamage, "die")
erbstart = erbstart or function()
	local function check_death2(self, variant)
	if not self._dead and self._unit:base().attacker == managers.player:player_unit() then
		_bodyCount = _bodyCount + 1
	if erbkilling_sprees[_bodyCount] then
		PlayMedia("mods/Pirate Perfection Reborn/media/erb/" .. erbkilling_sprees[_bodyCount] .. "")
		if _bodyCount == 123 then _bodyCount = 0
		end
	end
	
	if not _lastConsec or Application:time() - _lastConsec > 4 then _consecBodyCount = 0 end
	_consecBodyCount = _consecBodyCount + 1
	_lastConsec = Application:time()
	if erbconsecutive_kills[_consecBodyCount] then
		PlayMedia("mods/Pirate Perfection Reborn/media/erb/" .. erbconsecutive_kills[_consecBodyCount] .. "")
		end
	end
	end
	
	local _deadCop = Interception.Backup(CopDamage, "die")
	function CopDamage:die( variant )
		check_death2(self, variant)
		return _deadCop(self, variant)
	end
 
	local _deadHusk = Interception.Backup(HuskCopDamage, "die")
	function HuskCopDamage:die( variant )
		check_death2(self, variant)
		return _deadHusk(self, variant)
	end
 
	local _damageBullet = Interception.Backup(CopDamage, "damage_bullet")
	function CopDamage:damage_bullet( attack_data )
		self._unit:base().attacker = attack_data.attacker_unit
		return _damageBullet(self, attack_data)
	end
       
	local _damageExplosion = Interception.Backup(CopDamage, "damage_explosion")
	function CopDamage:damage_explosion( attack_data )
	self._unit:base().attacker = attack_data.attacker_unit
	return _damageExplosion(self, attack_data)
	end

	local _damageMelee = Interception.Backup(CopDamage, "damage_melee")
	function CopDamage:damage_melee( attack_data )
		self._unit:base().attacker = attack_data.attacker_unit
		return _damageMelee(self, attack_data)
	end

	--PLAYER DOWN SOUND ERB
	local _chgPlayerState = Interception.Backup(PlayerManager, "_change_player_state")
	--plydownerb = plydownerb or function()
	function PlayerManager:_change_player_state()
		if self._current_state == "arrested" or self._current_state == "bleed_out" then
			PlayMedia("mods/Pirate Perfection Reborn/media/erb/epicfail.mp3")
		end
			return _chgPlayerState(self)
	end
	end
end 

------------------------------
------- EFFECTS SETUP --------
------------------------------
-- PLAY HEADSHOT EFFECTS
playhead = playhead or function()
	PlayMedia("mods/Pirate Perfection Reborn/media/headshot/headshot1.mp3") 
end
playhead2 = playhead2 or function()
	PlayMedia("mods/Pirate Perfection Reborn/media/headshot/headshot2.mp3")
end
playhead3 = playhead3 or function()
	PlayMedia("mods/Pirate Perfection Reborn/media/headshot/headshot3.mp3")
end
playhead4 = playhead4 or function()
	PlayMedia("mods/Pirate Perfection Reborn/media/headshot/headshot4.mp3")
end
playhead5 = playhead5 or function()
	PlayMedia("mods/Pirate Perfection Reborn/media/headshot/nicehat.mp3")
end
-- PLAY UT EFFECTS
playdominate = playdominate or function()
	PlayMedia("mods/Pirate Perfection Reborn/media/ut/dominating.mp3")
end
playdkill = playdkill or function()
	PlayMedia("mods/Pirate Perfection Reborn/media/ut/doublekill.mp3")
end
playgod = playgod or function()
	PlayMedia("mods/Pirate Perfection Reborn/media/ut/godlike.mp3")
end
playholy = playholy or function()
	PlayMedia("mods/Pirate Perfection Reborn/media/ut/holyshit.mp3")
end
playhumil = playhumil or function()
	PlayMedia("mods/Pirate Perfection Reborn/media/ut/humiliation.mp3")
end
playkspree = playkspree or function()
	PlayMedia("mods/Pirate Perfection Reborn/media/ut/killingspree.mp3")
end
playforce = playforce or function()
	PlayMedia("mods/Pirate Perfection Reborn/media/ut/maytheforce.mp3")
end
playmega = playmega or function()
	PlayMedia("mods/Pirate Perfection Reborn/media/ut/megakill.mp3")
end
playmons = playmons or function()
	PlayMedia("mods/Pirate Perfection Reborn/media/ut/monsterkill.mp3")
end
playmkill = playmkill or function()
	PlayMedia("mods/Pirate Perfection Reborn/media/ut/multikill.mp3")
end
playone = playone or function()
	PlayMedia("mods/Pirate Perfection Reborn/media/ut/oneandonly.mp3")
end
playprep = playprep or function()
	PlayMedia("mods/Pirate Perfection Reborn/media/ut/prepare.mp3")
end
playramp = playramp or function()
	PlayMedia("mods/Pirate Perfection Reborn/media/ut/rampage.mp3")
end
playukill = playukill or function()
	PlayMedia("mods/Pirate Perfection Reborn/media/ut/ultrakill.mp3")
end
playunstop = playunstop or function()
	PlayMedia("mods/Pirate Perfection Reborn/media/ut/unstoppable.mp3")
end
-- PLAY ERB EFFECTS
play300a = play300a or function()
	PlayMedia("mods/Pirate Perfection Reborn/media/erb/300asses.mp3")
end
playbang = playbang or function()
	PlayMedia("mods/Pirate Perfection Reborn/media/erb/bangarang.mp3")
end
playbring = playbring or function()
	PlayMedia("mods/Pirate Perfection Reborn/media/erb/bringiton.mp3")
end
playfail = playfail or function()
	PlayMedia("mods/Pirate Perfection Reborn/media/erb/epicfail.mp3")
end
playdanger = playdanger or function()
	PlayMedia("mods/Pirate Perfection Reborn/media/erb/imthedanger.mp3")
end
playsplit = playsplit or function()
	PlayMedia("mods/Pirate Perfection Reborn/media/erb/isplituass.mp3")
end
playenjoy = playenjoy or function()
	PlayMedia("mods/Pirate Perfection Reborn/media/erb/notenjoy.mp3")
end
playphilo = playphilo or function()
	PlayMedia("mods/Pirate Perfection Reborn/media/erb/philosophy.mp3")
end
playtango = playtango or function()
	PlayMedia("mods/Pirate Perfection Reborn/media/erb/tangocash.mp3")
end
playsparta = playsparta or function()
	PlayMedia("mods/Pirate Perfection Reborn/media/erb/thisissparta.mp3")
end
playwazzup = playwazzup or function()
	PlayMedia("mods/Pirate Perfection Reborn/media/erb/whoabitches.mp3")
end
playyaht = playyaht or function()
	PlayMedia("mods/Pirate Perfection Reborn/media/erb/yahtsee.mp3")
end

----------------------------------------
-- YOUTUBE IN OVERLAY --
----------------------------------------
------------------------------------
-- PD2 - SOUNDTRACK --
------------------------------------
playsong1 = playsong1 or function()
	Steam:overlay_activate( "url", "http://www.youtube.com/watch?v=0a2fSWPrUvM&list=PLhoL0kkGmtaIlV1RjsYrLvWH1XGYF2lko" )
end
-------------------------------------
-- XMAS SOUNDTRACK --
-------------------------------------
playsong2 = playsong2 or function()
	Steam:overlay_activate( "url", "http://www.youtube.com/watch?v=_jSuCSkCqFE&list=PLhoL0kkGmtaLL_wpRlYiKjTL4qhgCIzv5" )
end
-----------------------------
-- OTHER SONGS --
-----------------------------
playsong3 = playsong3 or function() -- MIGHTY AMERICAN DOLLAR
	Steam:overlay_activate( "url", "http://www.youtube.com/watch?v=E98y92m6fN4" ) 
end
playsong4 = playsong4 or function() -- WERE COOKING METH
	Steam:overlay_activate( "url", "http://www.youtube.com/watch?v=UfQxr_HzelE" )
end
playsong5 = playsong5 or function() -- THE ONE WHO KNOCKS DUBSTEP
	Steam:overlay_activate( "url", "http://www.youtube.com/watch?v=GQPXDh840Eg" )
end
playsong6 = playsong6 or function() -- THE HEIST RAP REVIEW
	Steam:overlay_activate( "url", "http://www.youtube.com/watch?v=ZoYg9Zvgw5E" )
end
playsong7 = playsong7 or function() -- THE HEIST DUBSTEP REMIX
	Steam:overlay_activate( "url", "http://www.youtube.com/watch?v=T4fjtLPTuYI" )
end
playsong8 = playsong8 or function() -- FEUER FREI
	Steam:overlay_activate( "url", "http://www.youtube.com/watch?v=XHUsIU161w4" )
end
playsong9 = playsong9 or function() -- PUT THAT COOKIE DOWN
	Steam:overlay_activate( "url", "http://www.youtube.com/watch?v=_IROZqyCmn0" )
end
playsong10 = playsong10 or function() -- BREAKING BAD THEME REMIX
	Steam:overlay_activate( "url", "http://www.youtube.com/watch?v=HwmH0T5Ti5I" )
end
playsong11 = playsong11 or function() -- HEISENBERG SONG
	Steam:overlay_activate( "url", "http://www.youtube.com/watch?v=z0JPTgAtqzw" )
end
playsong12 = playsong12 or function() -- SMOKED PORK
	Steam:overlay_activate( "url", "http://www.youtube.com/watch?v=e2CrYPl5nQc" )
end
playsong13 = playsong13 or function() -- WARRIORS OF THE WORLD
	Steam:overlay_activate( "url", "http://www.youtube.com/watch?v=AJ0sW7KOFhU" )
end
playsong14 = playsong14 or function() --D12 FIGHT MUSIC
	Steam:overlay_activate( "url", "http://www.youtube.com/watch?v=rlytqMUyyyk" )
end
playsong15 = playsong15 or function() -- THERAPY COME AND DIE
	Steam:overlay_activate( "url", "http://www.youtube.com/watch?v=f7lNRXkuWNg#t=231" )
end
playsong16 = playsong16 or function() -- SNOOP DOG WEED EVERYDAY
	Steam:overlay_activate( "url", "http://www.youtube.com/watch?v=Tl7fGwLJMUI" )
end
playsong17 = playsong17 or function() -- AVENGED SEVENFOLD NIGHTMARE
	Steam:overlay_activate( "url", "http://www.youtube.com/watch?v=BL4WEsabcwo&list=PLz0graUr6SQaZjsryP5-Bv-Qs9TWfZTrF&index=3" )
end
playsong18 = playsong18 or function() -- SKRILLEX MK THEME
	Steam:overlay_activate( "url", "http://www.youtube.com/watch?v=spitVENkpgw" )
end
-------------------------
-- MEDIA FILES --
-------------------------
playmedia1 = playmedia1 or function() -- PAYDAY 2 THE WEB SERIES
	Steam:overlay_activate( "url", "http://www.youtube.com/watch?v=O90W_yKFqsc&list=PLz0graUr6SQYznf5mRDtJeLh3uhC2jvns" )
end
playmedia2 = playmedia2 or function() -- ARMORED TRANSPORT DLC TRAILER
	Steam:overlay_activate( "url", "http://www.youtube.com/watch?v=jIpSXu0vmpw" )
end
playmedia3 = playmedia3 or function() -- LAUNCH TRAILER
	Steam:overlay_activate( "url", "http://www.youtube.com/watch?v=eaGXXwxguJE" )
end
playmedia4 = playmedia4 or function() -- PERFECT HEIST WALKTHROUGH
	Steam:overlay_activate( "url", "http://www.youtube.com/watch?v=hRoSc5QnfCI" )
end
playmedia5 = playmedia5 or function() -- TEASER TRAILER
	Steam:overlay_activate( "url", "http://www.youtube.com/watch?v=1TBYaXWZy_U" )
end
playmedia6 = playmedia6 or function() -- WHAT IS CRIMENET
	Steam:overlay_activate( "url", "http://www.youtube.com/watch?v=kF5Eo_fJEDE" )
end
playmedia7 = playmedia7 or function() -- WHAT IS LOOTDROP
	Steam:overlay_activate( "url", "http://www.youtube.com/watch?v=1iNJTcZPVAA" )
end
playmedia8 = playmedia8 or function() -- SKILLS
	Steam:overlay_activate( "url", "http://www.youtube.com/watch?v=1c3Fyst0ySE" )
end
playmedia9 = playmedia9 or function() -- DYNAMICS
	Steam:overlay_activate( "url", "http://www.youtube.com/watch?v=vctjE9f5ZTc" )
end
playmedia10 = playmedia10 or function() -- CHARLIE SANTA DLC
	Steam:overlay_activate( "url", "http://www.youtube.com/watch?v=dGn_gb6zelY" )
end
playmedia11 = playmedia11 or function() -- PD2 GAMEPLAY TRAILER
	Steam:overlay_activate( "url", "http://www.youtube.com/watch?v=gzDVJ0Y4BI8" )
end
playmedia12 = playmedia12 or function() -- THE SAFEHOUSE TRAILER
	Steam:overlay_activate( "url", "http://www.youtube.com/watch?v=wLsqQoE7_9o" )
end
-- playmedia13 = playmedia13 or function() --
	-- Steam:overlay_activate( "url", "" )
-- end
-- playmedia14 = playmedia14 or function() --
	-- Steam:overlay_activate( "url", "" )
-- end
-- playmedia15 = playmedia15 or function() --
	-- Steam:overlay_activate( "url", "" )
-- end
-- playmedia16 = playmedia16 or function() --
	-- Steam:overlay_activate( "url", "" )
-- end
-- playmedia17 = playmedia17 or function() --
	-- Steam:overlay_activate( "url", "" )
-- end
-- playmedia18 = playmedia18 or function() --
	-- Steam:overlay_activate( "url", "" )
-- end
-- playmedia19 = playmedia19 or function() --
	-- Steam:overlay_activate( "url", "" )
-- end
-- playmedia20 = playmedia20 or function() --
	-- Steam:overlay_activate( "url", "" )
-- end

pd2ost = pd2ost or function()
	dofile("mods/Pirate Perfection Reborn/media/soundtrack.lua")
end
------------------
-- MENU CONTENT --
------------------
callutmenu = callutmenu or function()
    openmenu(utmenu)
end
callerbmenu = callerbmenu or function()
    openmenu(erbmenu)
end
callheadmenu = callheadmenu or function()
    openmenu(headmenu)
end
calleffectsmenu = calleffectsmenu or function()
    openmenu(effectsmenu)
end
calltubemenu = calltubemenu or function()
    openmenu(tubemenu)
end
callmediamenu = callmediamenu or function()
    openmenu(mediamenu)
end
callarootmenu = callarootmenu or function()
    openmenu(arootmenu)
end
-- MUSIC MENU
tubeopt = tubeopt or {
	{ text = "Back", callback = callarootmenu },
	{ text = "", is_cancel_button = true},
	{ text = "Payday 2 official sound track", callback = playsong1 },
	{ text = "Payday 2 official xmas sound track", callback = playsong2 },
	{},
	{ text = "Snoop Dogg remix - Smoke weed everyday", callback = playsong16 },
	{ text = "Manowar - Warriors of the world", callback = playsong13 },
	{ text = "Douglby - Mighty american dollar", callback = playsong3 },
	{ text = "Therapy and Fatal - Come and die", callback = playsong15 },
	{ text = "Avenged Sevenfold - Nightmare", callback = playsong17 },
	{ text = "Mortal Kombat - Skrillex remix", callback = playsong18 },
	{ text = "The one who knocks dubstep", callback = playsong5 },
	{ text = "We're cooking meth musical", callback = playsong4 },
	{ text = "Put that cookie down remix", callback = playsong9},
	{ text = "Breaking Bad theme remix", callback = playsong10 },
	{ text = "Bodycount - Smoked pork", callback = playsong12 },
	{ text = "The Heist - Dubstep remix", callback = playsong7 },
	{ text = "Rammstein - Feuer frei", callback = playsong8 },
	{ text = "The Heisenberg song", callback = playsong11 },
	{ text = "The Heist rap review", callback = playsong6 },
	{ text = "D12 - Fight music", callback = playsong14 },
	}
tubemenu = tubemenu or SimpleMenu:new("MUSIC MENU", "play that funky music white boy!!",tubeopt)
-- MEDIA MENU
mediaopt = mediaopt or {
	{ text = "Back", callback = callarootmenu },
	{ text = "", is_cancel_button = true},
	{ text = "The web series", callback = playmedia1 },
	{},
	{ text = "Teaser Trailer", callback = playmedia5 },
	{ text = "Launch Trailer", callback = playmedia3 },
	{ text = "Gameplay trailer", callback = playmedia11 },
	{ text = "The safehouse trailer", callback = playmedia12 },
	{ text = "Charlie Santa DLC trailer", callback = playmedia10 },
	{ text = "Armored Transport DLC trailer", callback = playmedia2 },
	{},	
	{ text = "Perfect Heist Walkthrough", callback = playmedia4 },
	{},
	{ text = "What is a lootdrop", callback = playmedia7 },
	{ text = "What is crimenet", callback = playmedia6 },
	{ text = "Dynamics", callback = playmedia9 },
	{ text = "Skills", callback = playmedia8 },
	-- { text = "", callback = playmedia13 },
	-- { text = "", callback = playmedia14 },
	-- { text = "", callback = playmedia15 },
	-- { text = "", callback = playmedia16 },
	-- { text = "", callback = playmedia17 },
	-- { text = "", callback = playmedia18 },
	-- { text = "", callback = playmedia19 },
	-- { text = "", callback = playmedia20 },
	}
mediamenu = mediamenu or SimpleMenu:new("MEDIA MENU", " bring out the popcorn...",mediaopt)
-- UNREAL TOURNAMENT EFFECTS MENU
utopt = utopt or {
	{ text = "Back", callback = calleffectsmenu },
	{ text = "", is_cancel_button = true},
	{ text = "Dominating", callback = playdominate },
	{ text = "Double kill", callback = playdkill },
	{ text = "Godlike", callback = playgod },
	{ text = "Headshot", callback = playhead5 },
	{ text = "Holy shit", callback = playholy },
	{ text = "Humiliation", callback = playhumil },
	{ text = "Killing spree", callback = playkspree },
	{ text = "May the force be with you", callback = playforce },
	{ text = "Mega kill", callback = playmega },
	{ text = "Monster kill", callback = playmons },
	{ text = "Multi kill", callback = playmkill },
	{ text = "The one and only", callback = playone },
	{ text = "Prepare", callback = playprep },
	{ text = "Rampage", callback = playramp },
	{ text = "Ultra kill", callback = playukill },
	{ text = "Unstoppable", callback = playunstop },
	}
utmenu = utmenu or SimpleMenu:new("Unreal Tournament effects", "good ol' unreal t",utopt)
-- EPIC RAP BATTLES EFFECTS MENU
erbopt = erbopt or {
	{ text = "Back", callback =  calleffectsmenu },
	{ text = "", is_cancel_button = true},
	{ text = "Yahtsee", callback = playyaht },
	{ text = "Bangarang", callback = playbang },
	{ text = "Epic fail", callback = playfail },
	{ text = "Philosophy", callback = playphilo },
	{ text = "Bring it on", callback = playbring },
	{ text = "I split u ass", callback = playsplit },
	{ text = "Tango and Cash", callback = playtango },
	{ text = "I'm the danger", callback = playdanger },
	{ text = "This is Sparta", callback = playsparta },
	{ text = "Nice hat.. dork", callback = playhead5 },
	{ text = "Whoaa.. wazzup bitches", callback = playwazzup },
	{ text = "You will not enjoy this", callback = playenjoy },
	{ text = "300 asses needs a kickin'", callback = play300a },
	}
erbmenu = erbmenu or SimpleMenu:new("Epic Rap Battles effects", " bcuz i love erb...",erbopt)
-- HEADSHOT EFFECTS MENU
headopt = headopt or {
	{ text = "Back", callback = calleffectsmenu },
	{ text = "", is_cancel_button = true},
	{ text = "Nice hat", callback = playhead5 },
	{ text = "Headshot 4", callback = playhead4 },
	{ text = "Headshot 3", callback = playhead3 },
	{ text = "Headshot 2", callback = playhead2 },
	{ text = "Headshot", callback = playhead },
	}
headmenu = headmenu or SimpleMenu:new("Headshot effects", " pop them melons...",headopt)
-- AUDIO EFFECTS MAIN MENU
effopt = effopt or {
	{ text = "Back", callback = callarootmenu },
	{ text = "", is_cancel_button = true},
	{ text = "Headshot effects", callback = callheadmenu },
	{ text = "Epic Rap Battles effects", callback = callerbmenu },
	{ text = "Unreal Tournament effects", callback = callutmenu },
	}
effectsmenu = effectsmenu or SimpleMenu:new("SOUND EFFECTS MENU", ".",effopt)
if inGame() then
	audioopt = audioopt or {
	{ text = "Exit", is_cancel_button = true},
	{},
	{ text = "Sound effects \[menu\]", callback = calleffectsmenu },
	{ text = "Music \[menu\]", callback = calltubemenu },
	{},
	{ text = "Payday Soundtrack", callback = pdost },
	{ text = "Payday 2 Soundtrack", callback = pd2ost },
	{ text = "Activate Epic rap battles mod", callback = erbstart },
	{ text = "Activate Unreal tournament mod", callback = utstart },
	}
	else
	audioopt = audioopt or {
	{ text = "Exit", is_cancel_button = true},
	{},
	{ text = "Sound effects \[menu\]", callback = calleffectsmenu },
	{ text = "Music \[menu\]", callback = calltubemenu },
	{ text = "Media \[menu\]", callback = callmediamenu },
	}
end
if not arootmenu then
    arootmenu = arootmenu or SimpleMenu:new("MEDIA MODULE MENU", "...chill with some music/videos", audioopt)
end
-- SHOW ROOT MENU
arootmenu:show()