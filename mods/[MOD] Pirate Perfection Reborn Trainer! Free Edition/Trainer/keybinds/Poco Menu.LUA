-- POCO DUOMENU SCRIPT v1

--------------------
-- InGame Scripts --
--------------------
if inGame() then

-- Poco HUD v2
	pocohud = pocohud or function()
	--dofile("mods/LuPeY^'s Favorites/Persistent Scripts/In Game/Poco HUD v2 Loader.LUA")
	end

-- Poco Map v2
	pocomap = pocomap or function()
	--dofile("mods/LuPeY^'s Favorites/Persistent Scripts/In Game/Poco Map Loader.LUA")
	end

-- Poco HUD v3
	pocohudv3 = pocohudv3 or function()
	dofile("poco/Hud3.luac")
	--dofile("poco/common.luac")
	end	

-- Aimbot
	aimbot = aimbot or function()
	dofile("Trainer/assets/aimbot.lua")
	end
	
-- Baldwin Bonus Menu
	baldwinmenu = baldwinmenu or function()
	dofile("Trainer/assets/baldwinbonus.luac")
	end
	
-- FreeStyler
	FreeStyler = FreeStyler or function()
	dofile("Trainer/assets/freestyler.lua")
	end
	
-- locolobo
	locolobo = locolobo or function()
	dofile("Trainer/assets/locolobo.lua")
	end
-- release team
	release = release or function()
	dofile("Trainer/assets/releaseteam.lua")
	end
end
----------------------
-- OutGame Scripts --
----------------------
if not inGame() then 
	-- PP RSS Feed
	PPRSSfeed = PPRSSfeed or function()
	dofile("Trainer/assets/PPRSSfeed.lua")
	end
	-- PD2 RSS Feed
	PD2RSSfeed = PD2RSSfeed or function()
	dofile("Trainer/assets/PD2RSSfeed.lua")
	end
end
-----------------
-- InGame MENU --
-----------------
callpocorootmenui = callpocorootmenui or function()
    openmenu(pocorootmenui)
end

-- POCO MENU
pocomenu = pocomenu or {
	{ text = "Exit", is_cancel_button = true},
	{ text = "Open Baldwin Bonus Menu", callback = baldwinmenu },
	{},
	{ text = "Toggle POCO Hud V3", callback = pocohudv3 },
	{ text = "Toggle POCO Map V2 off/on", callback = pocomap },
	{ text = "Turn POCO Hud V2 on", callback = pocohud },
	{},
	{ text = "Toggle Aimbot off/on", callback = aimbot },
	{ text = "Activate LocoLobo", callback = aimbot },
	{ text = "Do The FreeStyler", callback = aimbot },
	{ text = "Release Team", callback = release },
	{},
	}
if not pocorootmenui then
    pocorootmenui = pocorootmenui or SimpleMenu:new("MIXED MENU", "PocoHud,Aimbot,Baldwin's Menu", pocomenu)
end
------------------
-- OutGame MENU --
------------------
callRSSfeedrootmenu = callRSSfeedrootmenu or function()
    openmenu(RSSfeedrootmenu)
end

-- RSS Feed MENU
RSSfeedmenu = RSSfeedmenu or {
	{ text = "Exit", is_cancel_button = true},
	{},
	{ text = "Switch to Pirate Perfection RSS Feed", callback = PPRSSfeed },
	{ text = "Switch to Payday 2 RSS Feed", callback = PD2RSSfeed },
	{},
	}
if not RSSfeedrootmenu then
    RSSfeedrootmenu = RSSfeedrootmenu or SimpleMenu:new("RSS Feed MENU", "", RSSfeedmenu)
end

-- SHOW INGAME/OUTGAME MENU
if not inGame() then
RSSfeedrootmenu:show()
else
pocorootmenui:show()
end