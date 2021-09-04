--Authors: ****
--Purpose: Lua script encapsulation

--[[
Small documentation:
	
	PluginManager:new_plugin( name [, strict ]) : Creates new plugin and sets new envirnoment to the caller, that will be stored inside new plugin (Declare MAIN and UNLOAD inside new envirnoment! These methods are required!)
	
	PluginManager:load( name [, forced, ... ]) : Loads plugin into caller's envirnoment (and also calls plugin's entry, remember that methods MAIN, UNLOAD, UPDATE and FINALIZE will be ignored!) "forced" boolean optional, this will execute MAIN function of plugin again. "..." are optional arguments, passed to MAIN function.
	
	PluginManager:g_load( name [, forced, ...]) : Just loads plugin into plugin manager and doesn't do anything with envirnoment (cheap variant for just plug-in and plug-out)
	
	( string ) PluginManager:pre_require( path ) : Preloads plugin and if preload was successfull, it returns name of loaded plugin.
	
	PluginManager:ppr_require( path [, cheap, force, ...] ) : Preloads plugin from filepath. If it is preloaded successfully manager loads it into caller's envirnoment. If "cheap" is true, it will call g_load instead.
	
	( boolean ) PluginManager:loaded( name ) : Checks, if plugin loaded in caller's envirnoment
	
	( boolean ) PluginManager:g_loaded( name ) : Checks, whenever plugin loaded in any envirnoment
	
	PluginManager:flush_unloaded() : This will unload all registered plugins, these never being loaded anywhere
	
	PluginManager:unload( name [, full ]) : This will unload plugin from all envirnoments. "full" is optional boolean, that will remove plugin from memory, if it wasn't stored anywhere else. (Read garbage collecting topic for more info)
	
	( boolean ) PluginManager:l_unload( name ) : This will unload plugin from current envirnoment, though it will not destroy or unload it from every envirnoment
	
	PluginManager:unload_by_cat( cat [, full ]) : This will unload all plugins in some category. "full" is optional boolean, that will remove plugin from memory, if it wasn't stored anywhere else. (Read garbage collecting topic for more info)
	
	PluginManager:unload_except_by_cat( cat, full ) : This will unload all plugins, except plugins in some category
	
	PluginManager:unload_except_by_cats( cats, full ) : This will unload all plugins, except plugins in some categories. Cats is table of categories
	
	PluginManager:update() : Calls update function on all registered plugins
	
	PluginManager:set_update( boolean ) : Toggles plugin's manager auto updating depending on boolean
	
	PluginManager:unload_all([ full ]) : Unloads all registered plugins. "full" is optional boolean, that will remove plugin from memory, if it wasn't stored anywhere else. (Read garbage collecting topic for more info)
	
	( boolean ) PluginManager:register( plugin [, cheap] ) : Used by plugin manager to register plugin. Returns true, if plugin was succefully registered. Cheap option calls PluginManager:g_load() instead of load.
	
	( boolean ) PluginManager:unregister( plugin ) : Used by plugin manager to unregister plugin.
	
	PluginManager:destroy() : Call this when lua being destroyed. It executes unload_all and set_update methods.
]]

local ppr_require = ppr_require

ppr_require 'Trainer/experimental/dev/pluginbase'

local ppr_dofile = ppr_dofile

local PluginBase = PluginBase

local gm = getmetatable
local setmetatable = setmetatable
local assert = assert
local setfenv = setfenv
local getfenv = getfenv
local pairs = pairs
local copy_pairs = copy_pairs

local insert = table.insert
local m_log_error = m_log_error
local m_log_vs = m_log_vs

local callback = callback
local RunNewLoop = RunNewLoop
local StopLoopIdent = StopLoopIdent

local PluginManager = class()

local init,new_plugin,pre_prequire,prequire,pload,g_pload,loaded,g_loaded,get_environment,flush_unloaded,l_unload,unload,unload_by_cat,set_update,update,unload_except_by_cat,unload_all, unload_except_by_cats,register,unregister,destroy

init = function( self )
	self.plugins = {}
	self.last_plugin = false
	self.required = {} --dll's ppr_require works not as intended here
end
PluginManager.init = init

new_plugin = function( self, name, strict )
	assert( not self.plugins[name], 'Plugin with name '..name..' already exsists!' ) --This mustn't happen at all! Fix your plugins or whatever happens to cause this
	local plugin = PluginBase:new( name, strict )
	
	if register( self, plugin ) then
		--Setting envirnoment for plugin creation
		setfenv(2, plugin.env)
	else
		m_log_error('PluginManager:new_plugin()', 'Failed to start new plugin', name)
		self.last_plugin = false
	end
end
PluginManager.new_plugin = new_plugin

pre_prequire = function( self, path )
	self.last_plugin = false
	local last_plug
	local was_required = self.required[path]
	if not was_required then
		ppr_dofile(path)
		last_plug = self.last_plugin
		self.required[path] = last_plug
		if ( not last_plug ) then
			m_log_vs('\n(plugins) failed to pre-ppr_require', path)
		end
	else
		last_plug = was_required
	end
	return last_plug
end
PluginManager.pre_require = pre_prequire

prequire = function( self, path, cheap, forced, ... )
	local last_plug = pre_prequire( self, path )
	if last_plug then
		if cheap then
			return g_pload( self, last_plug, forced, ... )
		end
		pload( self, last_plug, forced, ... )
		local my = getfenv(1)
		local caller = getfenv(2)
		if my ~= caller then --Check if envirnoment changed after load
			setfenv(2, my)
		end
		return last_plug
	end
end
PluginManager.ppr_require = prequire

pload = function( self, name, forced, ... )
	local p = self.plugins[name]
	if not p then
		return m_log_error('PluginManager:load()', 'Plugin not found.', name)
	end
	if not p.version then
		m_log_vs('(Warning !!!) PluginManager:load() plugin ', name, 'is not finalized! Maybe something wrong happened during loading')
	end
	
	local ENV = getfenv(2) --Getting envirnoment of caller
	ENV = gm(ENV) or ENV
	if not ENV then
		return m_log_error('PluginManager:load()', 'Failed to recognize envirnoment')
	end
	local PLUG_ENV = ENV.__PLUGINS
	if (PLUG_ENV) then --Check if envirnoment is already hacked
		if (not PLUG_ENV[name]) then
			PLUG_ENV[name] = true
			p:entry( forced, ... )
		end
	else --Hacking envirnoment
		local prohibited = { MAIN=true, UPDATE=true, FINALIZE=true, UNLOAD=true, DESCRIPTION = true, EXTEND = true, FULL_NAME = true, CATEGORY = true, VERSION = true, MENU_DATA = true }
		
		local index_func = function(t, k)
			local mt = gm(t)
			local __PLUGINS = mt.__PLUGINS
			if __PLUGINS and not prohibited[k] then
				local to_clear = {}
				for pname,_ in pairs(__PLUGINS) do
					--I store name of plugin only to make sure that garbage collector will fully get rid of this if it was removed
					local plug = self.plugins[pname]
					if plug and plug.loaded then
						local value = plug.env[k]
						if value ~= nil then
							return value
						end
					else
						--Collect no longer registered or no longer loaded plugins
						insert(to_clear, pname)
					end
				end
				if #to_clear > 0 then
					for _,pname in pairs(to_clear) do
						__PLUGINS[pname] = nil
					end
				end
			end
			local _G = getfenv( 0 )
			return _G[k]
		end
		local newindex_func = function( t, k, v )
			local _G = getfenv( 0 ) _G[k] = v
		end
		
		local NEW_ENV = {
			__index = index_func,
			__newindex = newindex_func,
			__PLUGINS = { [name] = true },
		}
		local __ENV = {}
		setmetatable( __ENV, NEW_ENV )
		setfenv( 2, __ENV ) --Setting caller's envirnoment
		p:entry( forced, ... )
	end
end
PluginManager.load = pload

g_pload = function( self, name, forced, ... )
	local plugin = self.plugins[name]
	if not plugin then
		return m_log_error('PluginManager:g_load()', 'Plugin',name,'isn\'t found')
	end
	if not plugin.version then
		m_log_vs('(Warning !!!) PluginManager:g_load() plugin', name, 'is not finalized! Maybe something wrong happened during loading')
	end
	plugin:entry(forced, ...)
end
PluginManager.g_load = g_pload

loaded = function( self, name )
	local plugin = self.plugins[name]
	if ( plugin ) then
		local ENV = getfenv(2)
		if ( ENV ) then
			ENV = gm(ENV) or ENV
			local plug_ext = ENV.__PLUGINS
			if ( plug_ext and plug_ext[name] ) then
				return plugin.loaded
			end
		end
	end
end
PluginManager.loaded = loaded

g_loaded = function( self, name )
	local p = self.plugins[name]
	return p and p.loaded
end
PluginManager.g_loaded = g_loaded

get_environment = function( self, name )
	local plugin = self.plugins[name]
	if not plugin then
		return m_log_error('PluginManager:get_environment()', 'Plugin',name,'isn\'t found')
	end
	return plugin.env
end
PluginManager.get_environment = get_environment

flush_unloaded = function(self)
	local plug_list = self.plugins
	for name,plugin in copy_pairs(plug_list) do
		if not plugin.loaded then
			plug_list[name] = nil
		end
	end
end
PluginManager.flush_unloaded = flush_unloaded

l_unload = function( self, name )
	if self.plugins[name] then
		local ENV = getfenv(2)
		ENV = gm(ENV) or ENV
		if ENV then
			local PLUG_ENV = ENV.__PLUGINS
			if (PLUG_ENV) then
				PLUG_ENV[name] = nil
				return true
			end
		end
	end
end
PluginManager.l_unload = l_unload

unload = function( self, name, full )
	local p = self.plugins[name]
	if p then
		p:destroy()
		if full then
			unregister( self, p )
		end
		return
	end
	m_log_error('PluginManager:unload_by_name()','No plugin by name',name,'found')
end
PluginManager.unload = unload

unload_by_cat = function( self, cat, full )
	local unregister = unregister
	for name,plugin in copy_pairs(self.plugins) do
		if plugin.cat == cat then
			plugin:destroy()
			if ( full ) then
				unregister( self, plugin )
			end
		end
	end
end
PluginManager.unload_by_cat = unload_by_cat

unload_except_by_cat = function( self, cat, full )
	local unregister = unregister
	for name,plugin in copy_pairs( self.plugins ) do
		if ( plugin.cat ~= cat ) then
			plugin:destroy()
			if ( full ) then
				unregister( self, plugin )
			end
		end
	end
end
PluginManager.unload_except_by_cat = unload_except_by_cat

unload_except_by_cats = function ( self, cats, full )
	local unregister = unregister
	for name,plugin in copy_pairs( self.plugins ) do
		if ( not cats[plugin.cat] ) then
			plugin:destroy()
			if ( full ) then
				unregister( self, plugin )
			end
		end
	end
end
PluginManager.unload_except_by_cats = unload_except_by_cats

update = function()end
PluginManager.update = update

set_update = function()
	m_log_vs('(Warning PluginManager:set_update()) Method deprecated and will be removed with the time. Adapt your plugins using plugins manager updator')
end
PluginManager.set_update = set_update

unload_all = function( self, full )
	local unregister = unregister
	for _,plugin in pairs(self.plugins) do
		plugin:destroy()
		if full then
			unregister( self, plugin )
		end
	end
end
PluginManager.unload_all = unload_all

register = function( self, plugin )
	local name = plugin.name
	local old_plugin = self.plugins[name]
	if old_plugin then
		if plugin.loaded then
			plugin:destroy()
		end
		return m_log_error('PluginManager:register()','Plugin',plugin,'conflicting with already registered plugin', old_plugin,'Please consider unloading registered plugin first!')
	end
	self.plugins[name] = plugin
	self.last_plugin = name
	return true
end
PluginManager.register = register

unregister = function( self, plugin )
	local name = plugin.name
	self.plugins[name] = nil
	
	local required = self.required
	--Make it requireable again
	for reg, v in pairs(required) do
		if v == name then
			required[reg] = nil
			break
		end	
	end
	return true
end
PluginManager.unregister = unregister

destroy = function( self )
	unload_all( self, true )
end
PluginManager.destroy = destroy

local G = getfenv(0)
G.PluginManager = PluginManager

--Plugins update
--plugins:set_update( true )