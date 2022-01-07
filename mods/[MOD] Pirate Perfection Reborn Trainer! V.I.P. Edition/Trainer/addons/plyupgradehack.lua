--Purpose: due upgrade values hacks being commonly used, hack_upgrade_value comes to save the day

local pairs = pairs
local type = type
local select = select
local function is_str( ... )
	local max = select('#', ...)
	if max == 0 then
		return false
	end
	for i = 1, max do
		if type( select(i, ...) ) ~= 'string' then
			return false
		end
	end
	return true
end

--Use: cat (category of upgrades), upg (name of upgrade), new_value (value of upgrade(s))
--If cat == '', then same upgrade will be hijacked for all categories
--If upg == '*', then all upgrades will be hijacked for (cat) category
local PlayerManager = PlayerManager
function PlayerManager:hack_upgrade_value( cat, upg, new_value )
	if not is_str( cat, upg ) then
		return
	end
	local hacked_upgrades = self.hacked_upgrades
	if not hacked_upgrades then
		hacked_upgrades = {}
		self.hacked_upgrades = hacked_upgrades
	end
	
	--If cat is empty string, then this upgrade hack for all categories
	if cat == '' then
		hacked_upgrades[upg] = new_value
	else
		hacked_upgrades[cat..':'..upg] = new_value
	end
end

function PlayerManager:restore_hacked_upgrades()
	if self.hacked_upgrades then
		self.hacked_upgrades = nil
		return true
	end
end
--[[local m_log_v = m_log_v
local dbg = function(...)
	m_log_v('(plyupgradehack.lua)', ...)
end]]

local backuper = backuper
local hijack = backuper.hijack

--Hijacks will also affect this method
hijack(backuper, 'PlayerManager.has_category_upgrade', function( o, self, cat, upg, ... )
	local hacked_upgrades = self.hacked_upgrades
	if ( hacked_upgrades and is_str( cat, upg ) ) then
		--Updated: If we use false boolean as upgrade value, has_category_upgrade will be still affected
		local ret = hacked_upgrades[cat..':'..upg]
		if ( ret == nil ) then
			ret = hacked_upgrades[cat..':*']
			if ( ret == nil ) then
				ret = hacked_upgrades[upg]
			end
		end
		if ( ret ~= nil ) then
			--dbg('Succeed has_category_upgrade', cat, upg)
			return true
		end
	end
	return o(self, cat, upg, ...)
end)

hijack(backuper, 'PlayerManager.upgrade_value', function( o, self, cat, upg, ... )
	local hacked_upgrades = self.hacked_upgrades
	if ( hacked_upgrades and is_str( cat, upg ) ) then
		local v = hacked_upgrades[cat..':'..upg]
		if ( v == nil ) then
			v = hacked_upgrades[cat..':*']
			if ( v == nil ) then
				v = hacked_upgrades[upg]
			end
		end
		if v ~= nil then
			--dbg('Succeed upgrade_value', cat, upg, v)
			return v
		end
	end
	return o(self, cat, upg, ...)
end)