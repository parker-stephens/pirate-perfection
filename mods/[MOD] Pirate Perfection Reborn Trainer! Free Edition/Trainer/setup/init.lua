--Primary scripts, being used by PPR.
--Purpose: initate commonly used scripts and requires
--Main Pirate Perfection Reborn configuration file

--Early init, so managers will be initiated succefully.
init()

local _G = _G

--Lobotomy init function, so it will not execute 2nd time
rawset( _G, 'init', function() end )

local assert = assert
local ppr_require = ppr_require
local type = type
local ppr_dofile = ppr_dofile
local ME_CREATOR = 'Baddog-11'
local ME_VERSION = '2.0.0'
local ME_EDITION = 'Free'
local BLT_VERSION = 'v3.1.2 (R026)'

local ppr_config = ppr_require('Trainer/config')

assert(ppr_config,'No config has been loaded!')
_G.ppr_config = ppr_config

local user_file = 'Trainer/configs/menu_config.lua'
ppr_config.auto_config = user_file

--Config extension method ApplyConfigExtension
--Used with ppr_config and game_config
ppr_require('Trainer/tools/configmt')
--Apply extension
ApplyConfigExtension(ppr_config, user_file)

do
	--Check if we can apply changes saved by user or automatically from game
	local modify_func = ppr_dofile(user_file)
	if type(modify_func) == 'function' then
		modify_func(ppr_config)
	end
end

ppr_config.const_creator = ME_CREATOR
ppr_config.const_version = ME_VERSION
ppr_config.const_edition = ME_EDITION
ppr_config.const_blt_version = BLT_VERSION

local Vector3 = Vector3
local Rotation = Rotation
local Network = Network
local World = World
local W_raycast = World.raycast
local Idstring = Idstring

local n_is_server = Network.is_server
local n_is_client = Network.is_client

local pairs = pairs
local unpack = unpack
local loadstring = loadstring
local io = io
local io_open = ppr_io.open
local io_popen = ppr_io.io_popen
local io_close = io.stdout.close
local string = string
local str_find = string.find
local str_split = string.split

local alive = alive
local managers = managers
local M_blackmarket = managers.blackmarket
local M_hud = managers.hud
local hud_present_mid_text
local hud_show_hint
if ( M_hud ) then
	hud_present_mid_text = M_hud.present_mid_text
	hud_show_hint = M_hud.show_hint
end
local M_chat = managers.chat
local chat_receive_message_by_name
local chat__receive_message
local chat_send_message
if ( M_chat ) then
	chat_receive_message_by_name = M_chat.receive_message_by_name
	chat__receive_message = M_chat._receive_message
	chat_send_message = M_chat.send_message
end
local M_network = managers.network
local M_localization = managers.localization
local M_trade = managers.trade
local trade_is_peer_in_custody
if ( M_trade ) then
	trade_is_peer_in_custody = M_trade.is_peer_in_custody
end
local M_player = managers.player
local M_slot = managers.slot
local get_mask = M_slot.get_mask
local tweak_data = tweak_data
local game_state_machine = game_state_machine
--game_state_machine:current_state_name
local game_current_state_name = game_state_machine.current_state_name

local m_log_error = m_log_error

local Global = Global

local Steam = Steam
local http_request = Steam.http_request

if ( not ppr_config.no_liberty_hook ) then
	local f = io_open("IPHLPAPI.dll", "rb")
	assert( not f, "Please, remove IPHLPAPI.dll from game folder.")
end

--Fixes dumb behavior of _G
ppr_require('Trainer/tools/gfix')

 --[[
  Log scripts.
  
    m_log(...) --Logs to file and console
    m_log_v(...) --Logs to console only
    m_log_vs(...) --Logs to console only (on 1 line)
    m_log_a(mode, ...) --(Under rework)
    m_log_inspect(...) --Display table's contents into console
    m_log_full_inspect(...) --Display table's and other table's contents into console
    m_log_error(category, ...) --Displays warning in console and logs it into errlog, if user enabled to do so
	m_log_assert( obj [, msg]) --Displays message in console if obj is false or nil. Default message can be overriden using "msg" argument.
	safecall( func [, ...]) --Shortened xpcall, returns function's result or nil, if any error happened. Errors displayed into console with full traceback
	m_log_testfunc( function [, ...] ) --Tests how much it takes in order to execute single function. Results aren't 100% accurate. Function returns clocks/1000000.
]]
ppr_require('Trainer/tools/marylog')
--[[
  Backuper script for easy backing up and restoring functions.
  
    (Backuper) Backuper:new('backuper_name') --Initate new backuper for functions. Function returns new backuper.
    (function) Backuper:backuper('function_string') --Store new original function into backuper, once function is stored here, It cannot be overriden. As argument use function string. Function returns first function being stored here.
    Backuper:restore('function_string') --Restore original function, that was stored here.
    Backuper:restore_all() --Restores all original functions stored in backuper.
	(new_function) Backuper:hijack('function_string', new_function) --Backups function and then replace it by new_function. Just note, that new_function will always receive original function as 1st argument.
	(new_function) Backuper:hijack_adv('function_string', new_function) --Backups function and then replace it by special function, this will execute 1st new_function stored in backuper's hijacked table. new_function will receive array of hijacked functions( where 1st element is the original function) as 1st argument and 2nd argument reserved to help you implement ordinal system. 1st function executed receives number 1 as 2nd argument.
	Backuper:unhijack_adv('function_string', new_function) --Pops 1 of hijacked function from hijacked functions table. (new_function must be exact as it was stored in table) Function being restored, if hijacked functions table is empty.
	Backuper:add_clbk( 'function_string', new_function, id, pos ) --Adds callback function, this being executed before function being called (pos == 1) or after call (pos == 2). You can add multiple callbacks and all of them will be executed. id can be any, it will be used in order to remove callback
	Backuper:remove_clbk( 'function_string', [id, pos] ) --Performs operation, depending on id and pos arguments. If pos is nil, this will remove before and after callbacks by id. If id is nil, this will remove all callbacks, depending on pos. If both id and pos are nil, this will be equivalent to Backuper:restore()
]]
local backuper = ppr_require('Trainer/tools/origbackuper'):new("backuper")
_G.backuper = backuper
--[[ 
  Run new loop script. See pubinfloopv2.lua for more information.
]]
ppr_require('Trainer/tools/pubinfloopv2')

local RunNewLoop = RunNewLoop
local StopLoopIdent = StopLoopIdent
local executewithdelay = executewithdelay

--[[
	Experimental plugin manager
	See pluginmanager.lua and pluginbase.lua
]]
ppr_require('Trainer/experimental/dev/pluginmanager')
plugins = PluginManager:new()
local plugins = plugins
local plug_gloaded = plugins.g_loaded
local plug_unload = plugins.unload
local plug_require = plugins.ppr_require
local required_plugins = plugins.required

--[[
	Localization script for PPR menus and texts.
	Use Localization.translate[text_id] to get translation.
	Assign table above to local variable "tr" to follow our coding style.
	---------------------------------------------------------------------
	Localization:grab_list([ reply_clbk ]) --Gets lists of available translations. Calls reply_clbk with net_data table or false, depending on status.
	Localization:download_translation( id[,reply_clbk]) --Downloads translations and saves it into translations under name of (name).txt. Calls reply_clbk with language id and downloaded translation or false, depending on status.
]]
local localizator = ppr_require('Trainer/Setup/localizator')

local my_language = ppr_config.Language or Steam:current_language()
local Localization = localizator:new(my_language) --Is steam language same as game language ? Confirm it please. @baldwin
_G.Localization = Localization
local tr = Localization.translate
--[[Still lazy to finish it :/
if (ppr_config.check_language_updates) then
	local function reply( net_data )
		local data = net_data[my_language]
		if ( data ) then
			if ( data.v > tr.lan_ver ) then
				ppr_require("Trainer/tools/new_menu/menu")
				
			end
			return
		end
		m_log_error("{init.lua}","Failed to find language_id in net_data.")
	end
	Localization:grab_list( reply )
end
]]
--[[
	Helper module, that gives abillity to block game from destroying lua state, when some important threaded tasks are doing something.
	AddParallelTask( id ) --Adds id to task table
	EndedParallelTask( id ) --Removes id from task table
	RunParallelTask( func, id ) --Runs Lua function in separate thread. Usefull for heavy function, these stuns your game. Very unstable and tends to crash game in most of cases, + it maybe not supported by your hook.
]]	
local add_ptask
local end_ptask
do
	local parallelism = ppr_require("Trainer/tools/parallel_tasks")
	add_ptask = parallelism.AddParallelTask
	end_ptask = parallelism.EndedParallelTask
end

--[[Gives exception dialogs
	res structure:
	{ id = 'exception_id', clbk = ok_dialog_callback, c_clbk = cancel_dialog_callback, title = 'Exception title', text = 'Exception Description', ok = 'Ok button text', cancel = 'Cancel button text' }
	
	exception_manager:add( res ) --Adds resource to the exception (that will be lately catched by exception_manager.catch
	exception_manager:remove( id ) --Removes resorce of the exception by id
	(Disabled currently) exception_manager:add_trigger( function_string, res ) --Hooks function string. If exception triggers, then execution of the function will be prevented
	(Disabled currently) exception_manager:remove_trigger( function_string [, id] ) --Removes hook from the function. Also can remove exception by its id aswell.
	exception_manager:catch( id ) --Returns true if id is catched or else returns false
]]
if ppr_config.ExceptionsEnabled then
	ppr_require('Trainer/menu/exceptions')
	local M_exception = exception_manager:new()
	local _add = M_exception.add
	
	if ppr_config.ExceptionsCrashDetect then
		--Crashed game catch
		_add(M_exception, { id = 'crash_t',
				title = tr.except_crash_title,
				text = tr.except_crash_warn,
				ok = tr.except_yes,
				cancel = tr.except_no,
				clbk = function() os.execute('start latestcrash') end,
				no_except = true }
			)
	end
	
	managers.exception = M_exception
end

--Table for toggle variables
togg_vars = {}
-- Colors
local Color = Color

Color.white = Color("FFFFFF")
Color.black = Color("000000")
Color.brown = Color("6B4423")
Color.grey = Color("B2BEB5")

Color.red = Color("FF0000")
Color.green = Color("00FF00")
Color.blue = Color("0000FF")
Color.yellow = Color("FFFF00")
Color.pink = Color("FF00FF")
Color.cyan = Color("00FFFF")

Color.purple = Color("9932CC")
Color.lila = Color("D891EF")
Color.labia = Color("E75480")

Color.neongreen = Color("39FF14")
Color.bluegreen = Color("0D98BA")
Color.budgreen = Color("7BB661")

Color.bronze = Color("CD7F32")
Color.silver = Color("CFCFC4")
Color.gold = Color("FFD700")

Color.limited = Color("4F7942")
Color.unlimited = Color("FDEE00")

Color.Free = Color("0032FF")
Color.Pro = Color("FF0A0A")
Color.VIP = Color("FFC700")
Color.Patron = Color("9000C4")
Color.Developer = Color("6BF64F")

Color.Unlocker = Color("C8C8C8")
Color.XRay = Color("0F0F0F")

load_plugin = function( path ) --Function, that constructs new load_plugin function (I hope you will get rid of this //baldwin)
	assert( plugins, 'Error! Plugin manger isn\'t loaded!' )
	return function( plugin, expensive )
		local real_name = required_plugins[path..plugin]
		if ( real_name and plug_gloaded( plugins, real_name ) ) then
			plug_unload( plugins, real_name --[[,true]] )
		else
			plug_require( plugins, path .. plugin, not expensive )
		end
	end
end

function GetNetSession()
	return M_network._session
end

local players_tab = M_player._players
function GetPlayerUnit()
	return players_tab[1]
end

--Like usuall Steam:http_request, but also retries request, if clbk isn't called
--"retry" param in seconds or nil, if you want regular http_request. Lower retry values may lead to other http_requests interupted for some reason!
--"id" param is anything, except booleans and nil. You can stop retries using id and StopLoopIdent( id )
function retry_http_request( url, clbk, retry, id )
	if ( retry and retry > 0 ) then
		local my_id
		local function success_clbk(...)
			StopLoopIdent( my_id )
			end_ptask( id or url )
			clbk(...)
		end
		local retry_func
		retry_func = function()
			http_request( Steam, url, success_clbk )
			my_id = executewithdelay( retry_func, retry, id )
		end
		retry_func()
		add_ptask( id or url )
		return my_id
	else
		http_request( Steam, url, clbk )
	end
end

--function baldwin(m)
if managers.network:session() then
	for _,peer in pairs(managers.network:session()._peers) do
		if peer:name() == "Baldwin" or peer:name() == "baldwin" or peer:name() == "PirateCaptain" or peer:name() == "piratecaptain" or peer:name() == "[PP]Baddog-11[GER]" or peer:name() == "Baddog-11" then
			io.stderr:write("Oh look, the mystic one is here\n")
			SendMessage("blood island awaits!")
			for i = 1, 4 do
				if managers.network:game():member(i) and alive(managers.network:game():member(i):unit()) then
					managers.network:game():member(i):unit():sound():say("g24", nil, true )
				end
			end
			return
		end
	end
io.stderr:write("The plot thickens, MYSTIC ...\n")
end

-- BEEP
function beep()
	if managers and managers.menu_component then
		managers.menu_component:post_event("menu_enter")
	end
end

-- IN CHAT CHECK
function inChat()
	if managers.hud._chat_focus == true then
		return true
	end
end

-- SHOW CHAT MESSAGE				
function ChatMessage(message, username)
	if	not managers or
		not managers.chat or
		not message then
		return
	end
	if not username then
		username = managers.network.account:username()
	end
	managers.chat:receive_message_by_name(1, username, message)
end

-- CONSOLE TEXT
function Console(text)
	io.stderr:write (text .. "\n")
end
	
-- FADING MESSAGE
function Fading(message,color)
	if managers and managers.mission then
		if not color then
			color = Color.Free
		end
		managers.mission._fading_debug_output:script().log(message,color)
	end
end

--SPAWN BAG ON SELF FUNCTION
function GiveBag(name, zipline_unit)
   if not alive (managers.player:player_unit()) then return end
   local carry_data = tweak_data.carry[ name ]
   local dye_initiated = carry_data.dye_initiated
   local has_dye_pack = carry_data.has_dye_pack
   local dye_value_multiplier = carry_data.dye_value_multiplier
   if Network:is_client() then
	  managers.network:session():send_to_host("set_carry", name, carry_data.multiplier, carry_data.dye_initiated, carry_data.has_dye_pack, carry_data.dye_value_multiplier, zipline_unit)
   else
	  managers.player:set_carry(name, carry_data.multiplier, carry_data.dye_initiated, carry_data.has_dye_pack, carry_data.dye_value_multiplier, zipline_unit, managers.network:session():local_peer():id())
   end
end

-- IN TABLE CHECK
function	in_table(table,value)
	if	table	~=	nil	then	
		for	i,x	in	pairs(table)	do	
			if	x	==	value	then
				return	true
			end
		end
	end
	return	false
end

-- IN CUSTODY CHECK
function	inCustody()
	local	player	=	managers.player:local_player()
	local	in_custody	=	false
	if	managers	and	managers.trade	and	alive(	player	)	then
		in_custody	=	managers.trade:is_peer_in_custody(managers.network:session():local_peer():id())
	end
	return	in_custody
end

-- IN GAME CHECK
function	inGame()
	if	not	game_state_machine	then
		return	false
	end
	return
	string.find	(game_state_machine:current_state_name(),	"game")
end

-- IN OVERLAY CHECK	
function InOverlay()
	return Steam:overlay_open()
end

function InOverlay()
	if Steam:overlay_open() == true then
		return true
	end
end

-- IN STEEL SIGHT CHECK
function inSteelsight()
	local player = managers.player:local_player()
	local in_steelsight = false
	if player and alive( player ) then
		in_steelsight = player:movement() and player:movement():current_state()	and	player:movement():current_state():in_steelsight()	or	false
	end
	return	in_steelsight
end

-- IN TITLESCREEN CHECK
function inTitlescreen()
	if	not	game_state_machine	then
		return	false
	end
	return
	string.find(game_state_machine:current_state_name(), "titlescreen")
end

-- IS HOST CHECK
function isHost()
	if	not	Network	then
		return	false
	end
	return	not	Network:is_client()
end

-- IS HOSTAGE CHECK
function isHostage(unit)
	if	unit	and	alive(unit)	and	((unit.brain	and	unit:brain().is_hostage	and	unit:brain():is_hostage())	or
		(unit.anim_data	and	(unit:anim_data().tied	or	unit:anim_data().hands_tied)))	then
		return	true
	end
	return	false
end

-- IS LOADING CHECK
function isLoading()
	if	not	BaseNetworkHandler	then
		return	false
	end
	return
	BaseNetworkHandler._gamestate_filter.waiting_for_players[	game_state_machine:last_queued_state_name()	]
end

-- IS PLAYING CHECK
function	isPlaying()
	if	not	BaseNetworkHandler	then
		return	false
	end
	return
	BaseNetworkHandler._gamestate_filter.any_ingame_playing[	game_state_machine:last_queued_state_name()	]
end

-- IS PRIMARY CHECK
function isPrimary(type)
	local primary	=	managers.blackmarket:equipped_primary()
	if	primary	then
		local	category	=	tweak_data.weapon[	primary.weapon_id	].category
		if	category	==	string.lower(type)	then
			return	true
		end
	end
	return	false
end

-- IS SECONDARY CHECK
function isSecondary(type)
	local secondary = managers.blackmarket:equipped_secondary()
	if secondary then
		local category = tweak_data.weapon[	secondary.weapon_id	].category
		if category == string.lower(type) then
			return	true
		end
	end
	return	false
end

-- IS SERVER CHECK				
function	isServer()
	if	not	Network	then
		return	false
	end
	return	Network:is_server()
end

-- IS SINGLEPLAYER
function	isSinglePlayer()
	return	Global.game_settings.single_player	or
	false
end

-- LUA RUN
function	lua_run(path)
	local	file	=	io.open(path,	"r")
	if	file	then
	local	exe	=	loadstring(file:read("*all"))
		if	exe	then
			exe()
			else
			io.stderr:write("Error	in	'"	..	path	..	"'.\n")
		end
		file:close()
		else
		io.stderr:write("Couldn't	open	'"	..	path	..	"'.\n")	
	end
end

-- SEND MESSAGE
function SendMessage(message, username)
if not managers or
	not managers.chat or
	not message then
	return
end
if not username then
	username = managers.network.account:username()
end
managers.chat:send_message(1, username, message)
end

-- OPEN MENU
function	openmenu(menu)
	menu:show()
end

-- OUTPUT MESSAGE
function output( message )
local outputMessage = "[" .. os.date("%H:%M:%S").. "] " .. message .. "\n"
local logFile = io.open("output.log", "a")
io.write(outputMessage)
logFile:write(outputMessage)
logFile:close()
end

-- SEND MESSAGE
function SendMessage(message, username)
if not managers or
	not managers.chat or
	not message then
	return
end
if not username then
	username = managers.network.account:username()
end
managers.chat:send_message(1, username, message)
end	

--SPAWN BAG FUNCTION
function ServerSpawnBag(name, zipline_unit)
   if not alive (managers.player:player_unit()) then return end
   local camera_ext = managers.player:player_unit():camera()
   local carry_data = tweak_data.carry[ name ]
   local dye_initiated = carry_data.dye_initiated
   local has_dye_pack = carry_data.has_dye_pack
   local dye_value_multiplier = carry_data.dye_value_multiplier
   if Network:is_client() then
	  managers.network:session():send_to_host("server_drop_carry", name, carry_data.multiplier, carry_data.dye_initiated, carry_data.has_dye_pack, carry_data.dye_value_multiplier, camera_ext:position(), camera_ext:rotation(), camera_ext:forward(), Vector3(0, 0, 0), zipline_unit)
   else
	  managers.player:server_drop_carry(name, carry_data.multiplier, carry_data.dye_initiated, carry_data.has_dye_pack, carry_data.dye_value_multiplier, camera_ext:position(), camera_ext:rotation(), camera_ext:forward(), Vector3(0, 0, 0), zipline_unit, managers.network:session():local_peer():id())
   end
end

-- SHOW MENU
function	show_menu(menu)
	menu:show()
end

-- SHOW MID TEXT
function show_mid_text(msg,msg_title,show_secs)
if managers and managers.hud then
	managers.hud:present_mid_text( { text = msg, title = msg_title, time = show_secs } )
end
end

-- SHOW HINT
function showHint(msg)
if not managers or
	not managers.hud then
	return
end
managers.hud:show_hint({text	=	msg})
end

-- SHOW SYSTEM MESSAGE
function SystemMessage(message)
if not managers or
	not managers.chat or
	not message then
	return
end
managers.chat:_receive_message(1, managers.localization:to_upper_text( "menu_system_message" ), message, tweak_data.system_chat_color)
end

-- TABLE PRINT
function	table_print	(tt,	done)
	done	=	done	or	{}
	if	type(tt)	==	"table"	then
		for	key,	value	in	pairs	(tt)	do
			if	type	(value)	==	"table"	and	not	done	[value]	then
				done	[value]	=	true
				Console(string.format("<%s>	=>	table",	tostring	(key)));
				table_print	(value,	done)
				else
				Console(string.format("[%s]	=>	%s",	tostring	(key),	tostring(value)))
			end
		end
		else
		Console(tt)
	end
end	
	
function in_game() -- In game check
	return str_find(game_current_state_name(game_state_machine), "game")
end

function show_hint(msg) -- Show hint
	if ( hud_show_hint ) then
		hud_show_hint(M_hud, {text = msg})
	end
end

function show_mid_text( msg, msg_title, show_secs ) -- Show mid text
	if ( hud_present_mid_text ) then
		hud_present_mid_text( M_hud, { text = msg, title = msg_title, time = show_secs } )
	end
end

function chat_message(message, username) -- Send chat message
	chat_receive_message_by_name(M_chat, 1, username, message)
end

function in_chat() -- In chat and in overlay check
	if ( M_hud and M_hud._chat_focus ) then
		return true
	end
	local account = M_network.account
	if ( account and account._overlay_opened ) then
		return true
	end
	local TextInput = TextInput
	if ( TextInput and TextInput.active ) then
		return true
	end
end

local menu_system_message_loc = M_localization:to_upper_text( "menu_system_message" )
local sys_chat_col = tweak_data.system_chat_color
function system_message(message) -- Send system message
	chat__receive_message(M_chat, 1, menu_system_message_loc, message, sys_chat_col)
end

function send_message(message, username)
	chat_send_message(M_chat, 1, username, message)
end

local any_ingame_playing = BaseNetworkHandler._gamestate_filter.any_ingame_playing
local last_queued_state_name = game_state_machine.last_queued_state_name
function is_playing() -- Is playing check
	return any_ingame_playing[ last_queued_state_name(game_state_machine) ]
end

function is_server() -- Is server check
	return n_is_server(Network)
end

function is_client() -- Is client check
	return n_is_client(Network)
end

function in_custody( id ) -- Is in custody
	return trade_is_peer_in_custody( M_trade, id or M_network._session._local_peer._id )
end

local T_weapon = tweak_data.weapon

function in_table(table, value) -- Is element in table
	if type(table) == 'table' then
		for i,x in pairs(table) do
			if x == value then
				return true
			end
		end
	end
	return false
end

-- local s_freeflight = setup:freeflight()
local mvector3 = mvector3
local mvec_set = mvector3.set
local mvec_mul = mvector3.multiply
local mvec_add = mvector3.add
function get_ray(penetrate, slotMask) -- Get col ray
	if not slotMask then
		slotMask = "bullet_impact_targets"
	end
	local player = players_tab[1]
	if (alive(player)) then
		local camera = --[[s_freeflight._state == 0 and s_freeflight._camera_object or]] player:camera()
		local fromPos = camera:position()
		local mvecTo = Vector3()
		local forward = camera:rotation():y()
		mvec_set(mvecTo, forward)
		mvec_mul(mvecTo, 99999)
		mvec_add(mvecTo, fromPos)
		local colRay = W_raycast(World, "ray", fromPos, mvecTo, "slot_mask", get_mask(M_slot, slotMask))
		if colRay and penetrate then
			local offset = Vector3()
			mvec_set(offset, forward)
			mvec_mul(offset, 100)
			mvec_add(colRay.hit_position, offset)
		end
		return colRay
	end
end

local trip_slot = M_slot:get_mask("trip_mine_placeables")
function ray_pos() --Returns position and rotation of your crosshair.
	local unit = players_tab[1]
	if (alive(unit)) then
		local from
		local to
		local m_head_rot
		
		-- if s_freeflight._state == 0 then
			-- local camera = s_freeflight._camera_object
			-- m_head_rot = camera:rotation()
			-- from = camera:position()
			-- to = from + m_head_rot:y() * 99999
		-- else
			local ply_movement = unit:movement()
			m_head_rot = ply_movement:m_head_rot()
			from = ply_movement:m_head_pos()
			to = from + m_head_rot:y() * 99999 -- Idstring('?v=jkcGSwZ36pk') ???
		-- end

		local ray = W_raycast(World, "ray", from, to, "slot_mask", trip_slot, "ignore_unit", {})
		if (ray) then
			return ray.position, Rotation( m_head_rot:yaw(), 0, 0 )
		end
	end
end


function lua_run(path) -- Run lua file (unlike ppr_dofile/dofiles/ppr_require, it can return results of execution)
	local file = io_open(path, "r")
	if file then
		local exe = loadstring(file:read("*all"), path)
		file:close()
		if exe then
			return exe()
		else
			m_log_error("lua_run()","Error in '" .. path .. "'.\n")
		end
	else
		m_log_error("lua_run()","Couldn't open '" .. path .. "'.\n")
	end
end

--Recursively lists files in some dirrectory. Kinda slow, should be implemented at low level.
--Returns table, containing short filenames.
function rlist_files( path, ext )
	if not ext then ext = 'lua' end
	local list = io_popen("@echo OFF & cd "..path.." & for /r %f in (*."..ext..") do echo %~nf"):read("*all")
	
	if list ~= '' then
		return str_split(list, '\n')
	else
		m_log_error("rlist_files()", "Failed to retrive files in", path)
	end
end

--Checks if file located in "path" exists
function file_exists( path )
	local f=io_open(path, "r")
	if ( f ) then
		io_close(f)
		return true
	end
	return false
end
   
function is_hostage(unit) --Checks, if unit's hands tied or unit being intimidated to cuff himself.
	if alive(unit) then
		local brain = unit.brain
		brain = brain and brain( unit )
		if brain then
			local is_hostage = brain.is_hostage
			is_hostage = is_hostage and is_hostage( brain )
			if is_hostage then
				return true
			end
		end
		local anim_data = unit.anim_data
		anim_data = anim_data and anim_data(unit)
		if anim_data then
			local tied = anim_data.tied or anim_data.hands_tied
			if tied then
				return true
			end
		end
	end
	return false
end

local PackageManager = PackageManager
local all_loaded_unit_data = PackageManager.all_loaded_unit_data
function unit_on_map(unit_name) -- Checks, if unit loaded on map (give unit name)
	local id = Idstring(unit_name)
	for _,x in pairs( all_loaded_unit_data( PackageManager ) ) do
		if x:name() == id then
			return true
		end
	end
	return false
end

--Example: func_array = { f = some_function, a = { ...arguments... }, }
local function query_execution(func_array) --Works like script persisting but with functions.
	local f = func_array.f
	local params = func_array.a or {}
	local updator
	local stop = StopLoopIdent
	local function __clbk()
		f(unpack(params))
		stop(updator)
	end
	updator = RunNewLoop(__clbk)
end
_G.query_execution = query_execution

--Same as above, but will execute function only when testfunc returns true. Also if function is failed to execute, it will try again
function query_execution_testfunc(testfunc, func_array)
	local f = func_array.f
	local params = func_array.a or {}
	local updator
	local stop = StopLoopIdent
	local function __clbk()
		if testfunc() then
			f(unpack(params))
			stop(updator)
		end
	end
	updator = RunNewLoop(__clbk) --RunNewLoop secured with pcall, so you don't have to worry about crashy code.
end


local KeyInputCls = ppr_require('Trainer/experimental/kbinput')
local KeyInput
if ( KeyInputCls ) then
	KeyInput = KeyInputCls:new()
	_G.KeyInput = KeyInput
end
if (KeyInput) then
	if ( not ppr_config.DisableBindings ) then
		KeyInput:run_updating( true )
		local keyboard_configuration,version = ppr_dofile(ppr_config.keyconfig or "Trainer/keyconfig.lua")
		if ( keyboard_configuration ) then
			KeyInput.keys = keyboard_configuration
			KeyInput:help_setup()
		else
			m_log_error('{init.lua}', 'Failed to load keyconfig!')
		end
	end
else
	m_log_error('{init.lua}', 'Failed to init KeyInput!')
end

backuper:hijack('TipsTweakData.get_a_tip', function(o, s)
	return math.random() > 0.8 and {image = "general_loot", index = 1, total = 1, title = "Pirate Perfection Reborn Trainer! Free Edition", text = "Trainer: v2.0.0-PaE\nSuperBLT: v3.1.2 (R026)\nCreator: Baddog-11\nVisit us at www.Pirateperfection.com"} or o(s)
end)

--Hud stuff
if ppr_config.HUD then
	ppr_require('Trainer/hud/init')
end

--ppr_require left scripts now.
ppr_require('Trainer/Setup/auto_init')

if GameSetup then --If GameSetup exsists, this means game being setted up.
	ppr_require('Trainer/Setup/auto_ingame')
end