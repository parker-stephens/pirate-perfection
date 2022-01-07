--Author: ****
--That will be new envirnoment for plugin

--When you want to change something in global envirnoment, use _G or getfenv(0) to get global envirnoment table

local rawget = rawget
local pcall = pcall
local getfenv = getfenv
local setmetatable = setmetatable
local format = string.format
local ppr_require = ppr_require

local pro_callback = pro_callback

local m_log_error = m_log_error
local m_log_vs = m_log_vs

local function check_config( key, val ) --Macro that changes config's value, if it exists.
	local config = game_config
	if rawget( config, key ) ~= nil then
		config[key] = val
	end
end

local PluginBase = class()

function PluginBase:init( name, strict )
	self.loaded = false
	self.name = name
	self.strict = strict or false
	self.prohibited = {
	os = true,
	debug = true,
	}
	self:setup_envirnoment()
end

function PluginBase:setup_envirnoment()
	local prohibited = self.prohibited
	local mt = {
		__index = function( t, k )
			if ( not prohibited[k] ) then
				local _G = getfenv( 0 )
				return _G[k]
			end
		end,
	}
	local env = {}
	self.env = env
	setmetatable(env, mt)
	env.FINALIZE = function() self:finalize() end --Call this when plugin finished loading
	env.EXTEND = function( k, v ) --You can set some values to plugin directly instead of envirnoment (unless plugin is strict)
		if self.strict then
			return m_log_error(format('EXTEND() in plugin %s',self.name), 'Attempted to extend plugin in strict mode.')
		end
		if self[k] == nil then
			self[k] = v
		end
	end
end

function PluginBase:finalize()
	local me_env = self.env
	self.version = me_env.VERSION or '0'
	self.description = me_env.DESCRIPTION or ''
	self.full_name = me_env.FULL_NAME or ''
	self.cat = me_env.CATEGORY or 'cheat'
	self.toggle = function() return me_env.TOGGLE end --Codes: nil - No support, 0 - Off, 1 - On
	self.menu_data = me_env.MENU_DATA
	self.config_value = me_env.CONFIG_VALUE or self.name --Setting in config.lua or in game_config.lua
	me_env.EXTEND = nil --We can no longer extend plugin on finalization.
	if (me_env.UPDATE) then
		m_log_vs('(Warning PluginBase:finalize() in ', self.name, ') Update method deprecated. Use RunNewLoop inside plugin and implement the way to stop it through destroy.')
	end
end

--[[local traceback = debug.traceback
local function handle(p)
	return p..'\ntraceback:\n'..traceback('',2)
end
local xpcall = xpcall]]

function PluginBase:entry( forced, ... )
	local main_func = self.env.MAIN
	if ( main_func and (not self.loaded or forced) ) then
		local succ, res = pcall(main_func, ... )
		if not succ then
			m_log_error(format('PluginBase:entry( ... ) (plugin %s)', self.name), res)
		else
			self.loaded = true
			check_config( self.config_value, true )
		end
	elseif ( not main_func ) then
		m_log_error(format('PluginBase:entry( ... ) (plugin %s)', self.name),'No main function!!!!')
	end
end

function PluginBase:open_menu()
	local menu_data = self.menu_data
	if ( menu_data ) then
		local M = ppr_require('Trainer/tools/new_menu/menu')
		M:open(menu_data)
		return true
	else
		m_log_error(format("PluginBase:open_menu() (plugin %s)", self.name), "Failed to retrieve menu data from plugin.")
	end
	return false
end

function PluginBase:destroy( ... )
	if ( self.loaded ) then
		local unload_func = self.env.UNLOAD
		if unload_func then
			local succ, res = pcall(unload_func, ... )
			if not succ then
				m_log_error(format('PluginBase:destroy( ... ) (plugin %s)',self.name), res)
			else
				self.loaded = false
				check_config( self.config_value, false )
			end
		else
			m_log_error(format('PluginBase:destroy() (plugin %s)', self.name), 'No unload function!!!!')
		end
	end
end

function PluginBase:update( ... )
end

local G = getfenv(0)
G.PluginBase = PluginBase