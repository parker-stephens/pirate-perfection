--Equipment control for not being marked cheater.
--Author: ThisJazzman
--Purpose: Controls how many equipment you can place, before game gonna detect you as cheater. Blocks placing other equipments once any was used.

plugins:new_plugin('equipment_control')

VERSION = '1.1'

DESCRIPTION = 'Prevents you from randomly placing another equipment or throwing grenade. This will help you to prevent being cheat marked'

CATEGORY = 'no_reload'

local pairs = pairs
local tostring = tostring
local unpack = unpack
local tab_insert = table.insert

local warn = m_log_vs
local managers = managers
local M_exception = managers.exception
local M_network = managers.network

local tweak_data = tweak_data
local T_equipments = tweak_data.equipments
local LimitTable = T_equipments.max_amount

local PlayerEquipment = PlayerEquipment

local hijack_func
local restore_func
local backup_func
local add_clbk_func
local rem_clbk_func
do
	local backuper = backuper
	local hijack = backuper.hijack
	local restore = backuper.restore
	local backup = backuper.backup
	local add_clbk = backuper.add_clbk
	local remove_clbk = backuper.remove_clbk
	hijack_func = function( ... )
		return hijack( backuper, ... )
	end
	restore_func = function( ... )
		return restore( backuper, ... )
	end
	backup_func = function( ... )
		return backup( backuper, ... )
	end
	add_clbk_func = function( ... )
		return add_clbk( backuper, ... )
	end
	rem_clbk_func = function( ... )
		return remove_clbk( backuper, ... )
	end
end

local function catch_session()
	return M_network._session
end

local me_equipment --Here will be equipment, that is currently used by you
local me_count = 0 --Here will be amount of times, you used some equipment
local equipment_excepted = false --Variables for managers.exceptions
local grenades_excepted = false
local me_grenade_count = 0 --Amount of times, you throw grenade

local to_restore = {} --Table containing strings of functions, needed to be restored, when plugin being unloaded

--Small tweak data
local grenade_func_str = 'PlayerEquipment.throw_grenade' --Throw function
local grenade_rep_str = 'PlayerManager.register_grenade' --Called, when you interact with grenade base

local catch_exception = M_exception and M_exception.catch
local function catch( ... )
	if ( catch_exception ) then
		catch_exception( M_exception, ... )
	end
end

local verify_placement = function( e )
	if ( equipment_excepted ) then
		return true
	end
	local max = LimitTable[e]
	if ( not max ) then
		return true,warn('(verify equipment) I don\'t know equipment', e) --Unknown, don't block it
	end
	if ( not me_equipment ) then
		me_equipment = e --First time we place something
	end
	if ( me_equipment ~= e ) then
		catch( 'equipment_control' )
		return false,'Tried to place different from 1st placed equipment. 1st placed: '..me_equipment..' tried to place: '..tostring(e)
	end
	local total = me_count + 1
	if ( total > max ) then
		catch( 'equipment_control' )
		return false,'Max limit of '..me_equipment..' reached. Limit: '..tostring(max) --Overused
	end
	me_count = total
	return true --OK
end

local verify_throw = function( e, a ) --Where a is amount. Can be negative
	if ( grenades_excepted ) then
		return true
	end
	local max = LimitTable[e]
	if ( not max ) then
		return true,warn('(verify throw) I don\'t know grenade', e) --Unknown, don't block it
	end
	local total = me_grenade_count + a
	if ( total > max ) then
		catch( 'grenade_control' )
		return false,'Max limit of '..tostring(e)..' reached. Limit: '..tostring(max)
	end
	me_grenade_count = total
	return true
end

local function init_exceptions()
	if ( M_exception ) then
		local tr = Localization.translate
		local _add = M_exception.add
		--Equipment control catch
		_add(M_exception, { id = 'equipment_control', title = tr.except_title_warn, text = tr.except_equipment_warn, clbk = function() equipment_excepted = true  end})
		--Grenades control catch
		_add(M_exception, { id = 'grenade_control', title = tr.except_title_warn, text = tr.except_grenades_warn, clbk = function() grenades_excepted = true end})
	end
end

function MAIN()
	init_exceptions()
	for item,data in pairs(T_equipments) do
		if ( data.text_id ) then
			--warn('Data have text_id', data)
			local func_name = data.use_function_name
			--warn('Is data have func_name ?', func_name and true or false)
			if ( func_name ) then
				local func_str = 'PlayerEquipment.'..func_name
				--warn('Final string', func_str)
				local new_func = function( o, self, ... )
					local ok, msg = verify_placement(item)
					if ( ok ) then
						return o(self, ...)
					else
						warn('(verify equipment)', msg)
						return false
					end
				end
				if ( not hijack_func( func_str, new_func ) ) then
					warn('Failed to hijack func_str', func_str)
				end
				to_restore[func_str] = true
			end
		end
	end
	hijack_func( grenade_func_str,
		function( o, self, ... )
			local ok, msg = verify_throw('grenades', 1)
			if ( ok ) then
				return o(self, ...)
			else
				warn('(verify throw)', msg)
				return false
			end
		end
	)
	add_clbk_func( grenade_rep_str,
		function( r, self, peer_id )
			local s = catch_session()
			if ( r[1] and peer_id == s:local_peer():id() ) then
				verify_throw('grenades', -1)
			end
		end,
		'register_grenade', 2
	)
end

function UNLOAD()
	for func,_ in pairs(to_restore) do
		restore_func( func )
	end
	--Grenade related methods
	restore_func( grenade_func_str )
	rem_clbk_func(grenade_rep_str, 'register_grenade', 2)
	--
	me_count = 0
	me_equipment = nil
	to_restore = {}
end

FINALIZE()