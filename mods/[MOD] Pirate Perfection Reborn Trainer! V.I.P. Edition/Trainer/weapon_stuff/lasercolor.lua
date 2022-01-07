--Purpose: changes weapon's color. This touches all weapons, not only player's one!

local ppr_config = ppr_config
local laser_color = Color(ppr_config.LaserColorR / 255, ppr_config.LaserColorG / 255, ppr_config.LaserColorB / 255)

local check = type(laser_color)
if ( check == 'userdata' ) then
	local orig_init = backuper:backup('WeaponLaser.init')
	local constEntry = { light = laser_color*10, glow = laser_color, brush = laser_color:with_alpha(0.05) }
	
	function WeaponLaser:init( ... )
		local ret = orig_init(self, ...)
		local themes = self._themes
		if themes then --Crash happens (probably due hoxhud stuff, why they just can't remove it ?) (poepsnol38 reported)
			themes.custom_laser = constEntry
			self:set_color_by_theme("custom_laser")
		end
		return ret
	end
else
	m_log_error( 'lasercolor.lua', 'Color must be userdata created from Color(R/255,G/255,B/255) method. Data type in config', check )
end