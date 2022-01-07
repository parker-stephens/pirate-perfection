--Purpose: shows version text in main menu

backuper:hijack('MenuNodeMainGui._add_version_string', function(o, self, ... )
	local r = o(self, ...)
		self._version_string:set_text(string.format(" Pirate Perfection Reborn Trainer! \n Version: %s-%s Edition \n Game Version: %s \n SuperBLT Version: %s \n by %s ", ppr_config.const_version or '0', ppr_config.const_edition or 'Fix Me!',Application:version(), ppr_config.const_blt_version or 'X',ppr_config.const_creator or 'Baddog-11'))
		self._version_string:set_align(SystemInfo:platform() == Idstring("WIN32") and "center")
		self._version_string:set_color(Color.VIP)
		self._version_string:set_name(version_string)
		self._version_string:set_vertical(bottom)
		self._version_string:set_font_size(20)	
		self._version_string:set_alpha(1.00)
		self._version_string:set_w(1234)
		self._version_string:set_h(666)	
	return r
end)