ppr_require 'Trainer/tools/new_menu/menu'

local ppr_config = ppr_config
local pairs = pairs
local type = type
local ppr_dofile = ppr_dofile
local tonumber = tonumber
local tostring = tostring
local rawget = rawget

local managers = managers
local M_player = managers.player

--local dev_func = __require_after['lib/entry']
local dev_reset = reset_requires
local restore_all_func
do
	local backuper = backuper
	local restore_all = backuper.restore_all
	restore_all_func = function( ... )
		return restore_all( backuper, ... )
	end
end

local changes = {}

local function change_var( e, v )
	if rawget( ppr_config, e ) ~= nil then
		changes[e] = v
	end
end

local function save_vars()
	for e, v in pairs(changes) do
		ppr_config[e] = v
	end
end

local function restart_init()
	if xray_enabled then
		ppr_dofile 'Trainer/keybinded/xray'
	end
		
	if plugins then
		plugins:unload_except_by_cat("dev_tools", true)
	end
	
	local restore_hacked_upgrades = M_player.restore_hacked_upgrades
	if restore_hacked_upgrades then
		restore_hacked_upgrades(M_player)
	end
	
	--Restore remaining functions
	restore_all_func()
	
	if dev_reset then
		dev_reset()
	end
	
	--Reinit
	ppr_dofile('Trainer/Setup/init')
	ppr_dofile('Trainer/Setup/main_init')
	ppr_dofile('Trainer/Setup/auto_init')
	ppr_dofile('Trainer/Setup/auto_ingame')
	ppr_dofile('Trainer/personal/dev_init')
end

local function save_vars_file()
	save_vars()
	ppr_config()
	--restart_init()
end

local function get_button( e, v )
	local button = {}
	button.text = e
	if type( v ) == 'boolean' then
		button.type = 'toggle'
		button.callback = function()
			local state = changes[e]
			if state == nil then
				state = ppr_config[e]
			end
			change_var( e, not state )
		end
		button.toggle = function()
			local ret = changes[e]
			if ret == nil then
				ret = ppr_config[e]
			end
			return ret
		end
		button.switch_back = true
		return button
	elseif type( v ) == 'number' then
		--I will figure out it later with strings and numbers
		button.type = 'input'
		button.callback_input = function( t )
			t = tonumber(t)
			if t then
				change_var( e, t )
			end
		end
		button.value = tostring( ppr_config[e] )
		button.switch_back = true
		return button
	elseif type( v ) == 'string' then
		button.type = 'input'
		button.callback_input = function( t )
			change_var( e, t )
		end
		button.value = ppr_config[e]
		button.switch_back = true
		return button
	end
end

local data = { { text = 'Save all changes', callback = save_vars_file } }

local tab_insert = table.insert
for entry, value in pairs(ppr_config) do
	local btn = get_button( entry, value )
	if btn then
		tab_insert( data, btn )
	end
end

Menu:open({ title = 'config.lua', description = 'Test', button_list = data})