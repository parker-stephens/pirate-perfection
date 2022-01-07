--Purpose: Game's way of hooking keys
--Interesting fact: Input:keyboard():add_trigger( id_key, clbk ) will work aswell!. (Be aware, Stealth Suite dev. (B1313) stole this idea, original idea is by baldwin)

--[[local keyinput_config = {
	['0'] = { script = 'Trainer/keybinded/xray.lua' }, --Test config, don't use it in release
	['num enter'] = { script = 'Trainer/equipment_stuff/place_ammo.lua' },
}]]

local ppr_require = ppr_require
local type = type
local pairs = pairs
local ppr_dofile = ppr_dofile
local split = string.split
local gsub = string.gsub
local safecall = safecall
local in_chat = in_chat
local RunNewLoop = RunNewLoop
local StopLoopIdent = StopLoopIdent
local void = void

local repeated_delay = 0.75 --Delay after key will repeate executing itself

local kb = Input:keyboard()
local kb_down = kb.down
local kb_pressed = kb.pressed

local mouse = Input:mouse()
local mouse_down = mouse.down
local mouse_pressed = mouse.pressed

--Mouse mess
local left_btn = mouse:button_name(0)
local right_btn = mouse:button_name(1)
local middle_btn = mouse:button_name(2)
local xmouse_1 = mouse:button_name(3)
local xmouse_2 = mouse:button_name(4)
local xmouse_3 = mouse:button_name(5)
local xmouse_4 = mouse:button_name(6)
local xmouse_5 = mouse:button_name(7)
local wheel_up = mouse:button_name(8)
local wheel_down = mouse:button_name(9)

--Table to easier id mouse name
local key_to_mouse = { left_button = left_btn, right_button = right_btn, middle_button = middle_btn, x_button_1 = xmouse_1, x_button_2 = xmouse_2, x_button_3 = xmouse_3, x_button_4 = xmouse_4, x_button_5 = xmouse_5, wheel_up = wheel_up, wheel_down = wheel_down  }

 --[[ Keys table:
	It maybe updated, keep your eyes on it!
	Keyboard: a-z (lowered!), 0-9, left shift, right shift, left ctrl, right ctrl, space, f1-14 num 0-9, num +, num -,  num . , num *, num enter, num lock, num /
	Mouse: 0 - 7 (Different mouse button, 0 - 2: left, right, middle mouse buttons, 3 - 7: Extra mouse buttons; mouse wheel down, mouse wheel up)
 ]]

local held_keys = {}

local Idstring = Idstring

local Application = Application
local A_time = Application.time
local function pressed(key, no_hold)
	local hold
	local t = A_time(Application)
	local mouse_key = key_to_mouse[key]
	if mouse_key then --Mouse special case
		local k = mouse_key
		if not no_hold then
			local held_key = held_keys[key]
			held_key = mouse_down(mouse, k) and (held_key or t) or nil --Checks if key is still held or if it isn't, it just removes it from the table.
			if (held_key and (t - held_key >= repeated_delay)) then
				hold = true
			end
			held_keys[key] = held_key
		end
		return hold or mouse_pressed(mouse, k)
	else
		local id_key = Idstring(key)
		if not no_hold then
			local held_key = held_keys[key]
			held_key = kb_down(kb, id_key) and (held_key or t) or nil --Checks if key is still held or if it isn't, it just removes it from the table.
			if (held_key and (t - held_key >= repeated_delay)) then
				hold = true
			end
			held_keys[key] = held_key
		end
		return hold or kb_pressed(kb, id_key)
	end
end

--Function, that returns void if ppr_dofile haven't returned callback function from ppr_dofile
local function handled_callback( path )
	local clbk = ppr_require(path)
	if type(clbk) == 'function' then
		return clbk
	else
		return void
	end
end

local keyinput = class()

function keyinput:init(settings)
	self.keys = settings or {}
end

function keyinput:run_updating( toggle )
	local updator_id = self.upd_id
	if ( not toggle and updator_id ) then
		StopLoopIdent(updator_id)
	elseif ( toggle ) then
		self.upd_id = RunNewLoop( self.update, self )
	end
end

--As value use table in example config
function keyinput:edit_key(key, value)
	self.keys[key] = value
end

function keyinput:update(t, dt)
	for key,value in pairs(self.keys) do
		if pressed(key, value.no_stuck) and (value.ig_chat or not in_chat()) then
			local scr = value.script
			if (scr) then
				ppr_dofile(scr)
			end
			local clbk = value.callback
			if (clbk) then
				safecall(value.callback)
			end
		end
	end
end

function keyinput:help_setup()
	self.filenames = {}
	for key, value in pairs(self.keys) do
		local filename = split(value.script or value.handled_callback, "/")
		filename = gsub(filename[#filename], ".lua", "")
		self.filenames[filename] = key
		if value.handled_callback then
			value.callback = handled_callback(value.handled_callback)
			value.handled_callback = nil
		end
	end
end

return keyinput