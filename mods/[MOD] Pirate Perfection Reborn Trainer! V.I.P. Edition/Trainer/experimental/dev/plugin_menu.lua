--Purpose: gives more control over plugins

local menu_open
do
	local Menu = Menu
	local open = Menu.open
	menu_open = function( ... )
		open(Menu, ...)
	end
end

local function plugin_options( plugin )
	local data = {}
	menu_open(plugin.name, '', data)
end

local data = {}

local assert = assert
local plugins = assert(plugins, 'No plugins!')

for name, plugin in (plugins.plugins) do
	
end