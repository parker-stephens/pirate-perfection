--Debug enabler by baldwin
--Purpose: enables debug menu

rawset(getmetatable(Application),"debug_enabled",function() return true end)