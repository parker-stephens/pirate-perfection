--Purpose: giveouts exceptions on certain blocked functions (like allow to overspawn equipments and etc.)

local ppr_require = ppr_require
local pro_callback = pro_callback
local tr = Localization.translate
local insert = table.insert

local Global = Global

local ppr_config = ppr_config

local clbk_delay = 0.75

local open_menu
open_menu = function( ... )
	ppr_require 'Trainer/tools/new_menu/menu'
	local Menu = Menu
	local open = Menu.open
	open_menu = function( ... )
		return open(Menu , ...)
	end
	return open_menu( ... )
end

local function sh(self, title, text, btn_ok, btn_cancel, res, ...)
	if res.showing then
		return
	end
	local data = {
		{ text = btn_ok, callback = pro_callback(self,'_ok', {self, res, ...} ) },
		{ text = btn_cancel, callback = pro_callback(self, '_cancel', {self, res, ...}), is_cancel_button = true },
	}
	if not res.NEXC then
		insert(data,{ text = btn_cancel..tr.except_ignore_futher, callback = pro_callback(self, '_cancel_remove', {self, res, ...}) })
	end
	local m = open_menu({ title = title, description = text, button_list = data, w_mul = 2.4, h_mul = 3.2 })
	m.close_clbks['exception'] = function() res.showing = false end
	res.showing = true
end

local exception_manager = class()

function exception_manager:init()
	if not ppr_config.ExceptionsEnabled then
		self.disabled = true
	end
	if not Global.exception_manager then
		local exception_manager = {}
		exception_manager.SavedIgnore = {}
		Global.exception_manager = exception_manager
	end
	self.G = Global.exception_manager
	self.trigger_on = {}
end

function exception_manager:catch(id)
	if self.G.SavedIgnore[id] then
		return false
	end
	local r = self.trigger_on[id]
	if r then
		sh(self, r.t, r.txt, r.ok, r.cancel, r, id)
		return true
	end
	return false
end

function exception_manager:add( res )
	if self.trigger_on[res.id] then
		return --Remove res by id first, If you want to override!
	end
	local new_res = {
		f = res.clbk, --Callback on "OK" button
		cf = res.c_clbk or void, --Callback on "CANCEL" button
		t = res.title, --Title
		txt = res.text, --Description
		ok = res.ok or tr.except_ok, --Text for "OK" button
		cancel = res.cancel or tr.except_cancel, --Test for "CANCEL" button
		G = res.global, --Test
		NEXC = res.no_except, --Hides (no longer show this exception in future) button
		spam = res.allow_spam, --This will allow exceptions spamming
	}
	self.trigger_on[res.id] = new_res
end

function exception_manager:remove( id )
	self.trigger_on[id] = nil
end

--[[function exception_manager:add_trigger( fstr, res )
	self:add(res)
	backuper:hijack(fstr,function( o, ... )
		if not res.f then
			local args = {...}
			res.f = function() return o( unpack(args) ) end
		end
		if not self:catch(res.id) then
			return o( ... )
		end
	end)
end

function exception_manager:remove_trigger( fstr, id )
	backuper:restore(fstr)
	if id then
		self.trigger_on[id] = nil
	end
end]]

function exception_manager:_ok( res, id, ... )
	res.showing = false
	self:remove(id)
	res.f(...)
end

function exception_manager:_cancel( res, id, ... )
	res.showing = false
	res.cf(...)
end

function exception_manager:_cancel_remove( res, id, ... )
	self:_cancel( res, id, ... )
	self:remove(id)
	if res.G then
		self.G.SavedIgnore[id] = true
	end
end

local G = getfenv(0)
G.exception_manager = exception_manager