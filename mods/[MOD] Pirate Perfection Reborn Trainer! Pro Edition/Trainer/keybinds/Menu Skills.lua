-- SKILL MENU SCRIPT v1.1

-- OPEN MENU
function openmenu(menu)
	menu:show()
end

---------------
-- MAIN --
---------------
if not inGame() then
	-- SET SKILLPOINTS TO 1
	setskill1 = setskill1 or function()
		managers.skilltree:_set_points(1)
	end
	-- SET SKILLPOINTS TO 3
	setskill3 = setskill3 or function()
		managers.skilltree:_set_points(3)
	end
	-- SET SKILLPOINTS TO 8
	setskill8 = setskill8 or function()
		managers.skilltree:_set_points(8)
	end
	-- SET SKILLPOINTS TO 50
	setskill50 = setskill50 or function()
		managers.skilltree:_set_points(50)
	end
	-- SET SKILLPOINTS TO 120 (LEGIT MAX AT LVL100)
	setskill120 = setskill120 or function()
		managers.skilltree:_set_points(120)
	end
	-- SET SKILLPOINTS TO 580 (MAX NEEDED FOR ALL SKILLS)
	setskill580 = setskill580 or function()
		managers.skilltree:_set_points(580)
	end
	-- RESET SKILLPOINTS
	resetskill = resetskill or function()
		managers.skilltree:_set_points(0)
	end
	-- SET INFAMY
	resetinfy = resetinfy or function()
		managers.infamy:_set_points(0)
	end
	setinf1 = setinf1 or function()
		managers.infamy:_set_points(1)
	end
	setinf2 = setinf2 or function()
		managers.infamy:_set_points(2)
	end
	setinf3 = setinf3 or function()
		managers.infamy:_set_points(3)
	end
	setinf4 = setinf4 or function()
		managers.infamy:_set_points(4)
	end
	setinf5 = setinf5 or function()
		managers.infamy:_set_points(5)
	end
	-- SET CURRENT INFAMY LEVEL
	setcurinfres = setcurinfres or function()
		managers.experience:set_current_rank(0)
	end
	setcurinf = setcurinf or function()
		managers.experience:set_current_rank(1)
	end
	setcurinf2 = setcurinf2 or function()
		managers.experience:set_current_rank(2)
	end
	setcurinf3 = setcurinf3 or function()
		managers.experience:set_current_rank(3)
	end
	setcurinf4 = setcurinf4 or function()
		managers.experience:set_current_rank(4)
	end
	setcurinf5 = setcurinf5 or function()
		managers.experience:set_current_rank(5)
	end
	setcurinf6 = setcurinf6 or function()
		managers.experience:set_current_rank(6)
	end
	setcurinf7 = setcurinf7 or function()
		managers.experience:set_current_rank(7)
	end
	setcurinf8 = setcurinf8 or function()
		managers.experience:set_current_rank(8)
	end
	setcurinf9 = setcurinf9 or function()
		managers.experience:set_current_rank(9)
	end
	setcurinf10 = setcurinf10 or function()
		managers.experience:set_current_rank(10)
	end
	setcurinf11 = setcurinf11 or function()
		managers.experience:set_current_rank(11)
	end
	setcurinf12 = setcurinf12 or function()
		managers.experience:set_current_rank(12)
	end
	setcurinf13 = setcurinf13 or function()
		managers.experience:set_current_rank(13)
	end
	setcurinf14 = setcurinf14 or function()
		managers.experience:set_current_rank(14)
	end
end
-- UNLOCK MESSIAH CHARGES SKILL ((SELF-REVIVE) normalizable)
unlmessiah = unlmessiah or function()
	function PlayerDamage:got_messiah_charges() 
		return true 
	end
end
-------------------------------
-- SKILL PROFILER --
-------------------------------
startprof = startprof or function()
	dofile("Trainer/assets/skillprofiler.lua")
end
-------------------------------
-- MENU CONTENT --
-------------------------------
callinmaster = callinmaster or function()
	openmenu(mastermenu)
end
callinmaster2 = callinmaster2 or function()
	openmenu(mastermenu2)
end
callinenforcer = callinenforcer or function()
	openmenu(enforcermenu)
end
callinenforcer = callinenforcer or function()
	openmenu(enforcermenu2)
end
callintechnician = callintechnician or function()
	openmenu(technicianmenu)
end
callintechnician2 = callintechnician2 or function()
	openmenu(technicianmenu2)
end
endcallinghost = callinghost or function()
	openmenu(ghostmenu)
end
endcallinghost2 = callinghost2 or function()
	openmenu(ghostmenu2)
end
callinroot = callinroot or function()
	openmenu(skillsmenu)
end
callininfy = callininfy or function()
	openmenu(infamymenu)
end
-- INFAMY LEVEL MENU
infamyoptions = infamyoptions or {
	{ text = "Back", callback = callinroot },
	{},
	{ text = "-- Reset infamy level to 0 --", callback = setcurinfres },
	{ text = "", is_cancel_button = true},
	{ text = "Epeen champion - Infamy level 14", callback = setcurinf14 },
	{ text = "Home under foreclosure - Infamy level 13", callback = setcurinf13 },
	{ text = "Brainwashed to believe rats is still fun - Infamy level 12", callback = setcurinf12 },
	{ text = "Forgot what irl is like - Infamy level 11", callback = setcurinf11 },
	{ text = "Been there, done that - Infamy level 10", callback = setcurinf10 },
	{ text = "The word trainheist makes you puke -  Infamy level 9", callback = setcurinf9 },
	{ text = "Owns a shitbucket -  Infamy level 8", callback = setcurinf8 },
	{ text = "Hopefully outgrew trolling by now -  Infamy level 7", callback = setcurinf7 },
	{ text = "GF left a week ago -  Infamy level 6", callback = setcurinf6 },
	{ text = "Borderline addictive personality -  Infamy level 5", callback = setcurinf5 },
	{ text = "Obsessed fanboy -  Infamy level 4", callback = setcurinf4 },
	{ text = "Dedicated gamer -  Infamy level 3", callback = setcurinf3 },
	{ text = "Not impossible while having a life -  Infamy level 2", callback = setcurinf2 },
	{ text = "Could have done it without cheating -  Infamy level 1", callback = setcurinf },
	{},
	{ text = "-- Reset infamy point(s) --", callback = resetinfy },
	{},
	{ text = "Add 5 infamy points", callback = setinf5 },
	{ text = "Add 4 infamy points", callback = setinf4 },
	{ text = "Add 3 infamy points", callback = setinf3 },
	{ text = "Add 2 infamy points", callback = setinf2 },
	{ text = "Add 1 infamy point", callback = setinf1 },
	}
infamymenu = infamymenu or SimpleMenu:new("INFAMY MENU", "Re/Set your infamy level/points", infamyoptions)
-- GHOST ACED MENU
ghostoptions2 = ghostoptions2 or {
	{ text = "Under construction", callback = endcall },
	{},
	{ text = "Cancel", is_cancel_button = true},
	{ text = "Back", callback = callinroot },
	}
ghostmenu2 = ghostmenu2 or SimpleMenu:new("GHOST MENU ACED", "..! = not working atm", ghostoptions2)
-- GHOST BASIC MENU
ghostoptions = ghostoptions or {
	{ text = "Under construction", callback = endcall },
	{},
	{ text = "Cancel", is_cancel_button = true},
	{ text = "Back", callback = callinroot },
	}
ghostmenu = ghostmenu or SimpleMenu:new("GHOST MENU BASIC", "..! = not working atm", ghostoptions)
-- TECHNICIAN ACED MENU
technicianoptions2 = technicianoptions2 or {
	{ text = "Under construction", callback = endcall },
	{},
	{ text = "Cancel", is_cancel_button = true},
	{ text = "Back", callback = callinroot },
	}
technicianmenu2 = technicianmenu2 or SimpleMenu:new("TECHNICIAN MENU BASIC", "..! = not working atm", technicianoptions2)
-- TECHNICIAN BASIC MENU
technicianoptions = technicianoptions or {
	{ text = "Under construction", callback = endcall },
	{},
	{ text = "Cancel", is_cancel_button = true},
	{ text = "Back", callback = callinroot },
	}
technicianmenu = technicianmenu or SimpleMenu:new("TECHNICIAN MENU ACED", "..! = not working atm", technicianoptions)
-- ENFORCER ACED MENU
enforceroptions2 = enforceroptions2 or {
	{ text = "Under construction", callback = endcall },
	{},
	{ text = "Cancel", is_cancel_button = true},
	{ text = "Back", callback = callinroot },
	}
enforcermenu2 = enforcermenu2 or SimpleMenu:new("ENFORCER MENU ACED", "..! = not working atm", enforceroptions2)
-- ENFORCER BASIC MENU
enforceroptions = enforceroptions or {
	{ text = "Under construction", callback = endcall },
	{},
	{ text = "Cancel", is_cancel_button = true},
	{ text = "Back", callback = callinroot },
	}
enforcermenu = enforcermenu or SimpleMenu:new("ENFORCER MENU BASIC", "..! = not working atm", enforceroptions)
-- MASTERMIND ACED MENU
masteroptions2 = masteroptions2 or {
	{ text = "!Cable guy", callback = endcall },
	{ text = "!Combat medic", callback = endcall },
	{ text = "!Endurance", callback = endcall },
	{ text = "!Inside man", callback = endcall },
	{ text = "!Fast learner", callback = endcall },
	{ text = "!Leadership", callback = endcall },
	{ text = "!Smooth talker", callback = endcall },
	{ text = "!Equilibrium", callback = endcall },
	{ text = "!Dominator", callback = endcall },
	{ text = "!Stockholm syndrome", callback = endcall },
	{ text = "!Combat doctor", callback = endcall },
	{ text = "!Joker", callback = endcall },
	{ text = "!Black marketeer", callback = endcall },
	{ text = "!Gunslinger", callback = endcall },
	{ text = "!Kilmer", callback = endcall },
	{ text = "!Control Freak", callback = endcall },
	{ text = "!Pistol messiah", callback = unlmessiah },
	{ text = "!Inspire", callback = endcall },
	{},
	{ text = "Cancel", is_cancel_button = true},
	{ text = "Back", callback = callinroot },
	}
mastermenu2 = mastermenu2 or SimpleMenu:new("MASTERMIND MENU ACED", "..! = not working atm", masteroptions2)
--MASTERMIND BASIC MENU
masteroptions = masteroptions or {
	{ text = "!Unlock messiah charges", callback = mssiahmenu },
	{ text = "!Cable guy", callback = enforcermenu },
	{ text = "!Combat medic", callback = ghostmenu },
	{ text = "!Endurance", callback = endcall },
	{ text = "!Inside man", callback = endcall },
	{ text = "!Fast learner", callback = endcall },
	{ text = "!Leadership", callback = endcall },
	{ text = "!Smooth talker", callback = endcall },
	{ text = "!Equilibrium", callback = endcall },
	{ text = "!Dominator", callback = endcall },
	{ text = "!Stockholm syndrome", callback = endcall },
	{ text = "!Combat doctor", callback = endcall },
	{ text = "!Joker", callback = endcall },
	{ text = "!Black marketeer", callback = endcall },
	{ text = "!Gunslinger", callback = endcall },
	{ text = "!Kilmer", callback = endcall },
	{ text = "!Control Freak", callback = endcall },
	{ text = "Pistol messiah", callback = endcall },
	{ text = "!Inspire", callback = endcall },
	{},
	{ text = "Exit", is_cancel_button = true},
	{ text = "Back", callback = callinroot },
	}
mastermenu = mastermenu or SimpleMenu:new("MASTERMIND MENU BASIC", "..! = not working atm", masteroptions)
if inGame() and managers.platform:presence() == "Playing" then
	skilloptions = skilloptions or {
	{ text = "Exit", is_cancel_button = true},
	{},
	{ text = "Under construction", callback = endcall },
	}
else
	skilloptions = skilloptions or {
	{ text = "Exit", is_cancel_button = true},
	{},
	{ text = "Mastermind basic skills", callback = callinmaster },
	{ text = "Mastermind aced skills", callback = callinmaster2 },
	{ text = "Enforcer basic skills", callback = callinenforcer },
	{ text = "Enforcer aced skills", callback = callinenforcer2 },
	{ text = "Technician basic skills", callback = callintechnician },
	{ text = "Technician aced skills", callback = callintechnician2 },
	{ text = "Ghost basic skills", callback = callinghost },
	{ text = "Ghost aced skills", callback = callinghost2 },
	{},
	{ text = "Skill profiler", callback = startprof },
	{},
	{ text = "Reset skillpoint(s)", callback = resetskill },
	{},
	{ text = "Add 580 skillpoints (all skills)", callback = setskill580 },
	{ text = "Add 120 skillpoints (legit max)", callback = setskill120 },
	{ text = "Add 50 skillpoints", callback = setskill50 },
	{ text = "Add 8 skillpoints", callback = setskill8 },
	{ text = "Add 3 skillpoints", callback = setskill3 },
	{ text = "Add 1 skillpoint", callback = setskill1 },
	{},
	{ text = "Infamy options", callback = callininfy },
	}
	-- ROOT MENU HEADER
	if not skillsmenu then
		skillsmenu = skillsmenu or SimpleMenu:new("SKILL/INFAMY MENU", "..how badass can you get?", skilloptions)
	end
	skillsmenu:show()
end