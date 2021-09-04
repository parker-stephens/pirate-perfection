--Purpose: Simple announcements

--[[ 
Details:
  - It will check for text file on specific url and after it downloads it, script will firstly check for its id. (id can be any text information) If id is stored in text file you provided, then script discards message or else it will write id to provided text file and will display message using SimpleMenuV3.
  
Message format: 
{ id = 'any_text_infomation', title = 'Title', message = 'Announcement body message', link = { text = 'Link button text', l = 'http://someurl.com' } } Note: title isn't required, default title will be: 'Global announcement'. You may not add l into link table, If your announcement don't have any links and just message. (then text in link must be equal "")
]]

local io_open = ppr_io.open
local string = string
local str_match = string.match
local str_find = string.find
local m_log_error = m_log_error
local ppr_require = ppr_require
local pairs = pairs
local loadstring = loadstring

local Steam = Steam
local overlay_activate = Steam.overlay_activate
--local http_request = Steam.http_request
local retry_http_request = retry_http_request

local function read(name)
	local f = io_open(name,'rb')
	if f then
		local d = f:read('*all')
		if d then
			f:close()
			return d
		end
		f:close()
		return
	end
	m_log_error('read() in announcements.lua','Failed to load file',name)
end

local function show_msg(title,text,data)
	ppr_require 'Trainer/tools/new_menu/menu'
	Menu:open{ title = title, description = text, button_list = data}
end

local function write_tab_lite(fn,tab)
	local data = '{'
	for key,value in pairs(tab) do
		data = data..' [\''..key..'\']='..value..','
	end
	data = data..'}'
	local f = io_open(fn,'wb')
	if f then
		f:write(data)
		f:close()
	end
end

local announce = class()

function announce:init(link, cookiefile)
	self.url = link
	self.cookies_loc = cookiefile
	self:load_cookies()
end

function announce:load_cookies()
	local data = read(self.cookies_loc)
	if data then
		local l = loadstring('return '..data)
		if l then
			self.cookies = l()
		end
	else
		write_tab_lite(self.cookies_loc, { })
		self.cookies = {}
	end
end

function announce:store_cookies()
	write_tab_lite(self.cookies_loc, self.cookies)
end

function announce:cookie(id)
	if not self.cookies[id] then
		self.cookies[id] = 1
		self:store_cookies()
		return false
	end
	return true
end

function announce:check_and_announce()
	local _ = function(is,d)
		if (is) then
			self:announce(d)
		end
	end
	self:check(_)
	m_log_vs('announce:check_and_announce()')
end

function announce:check(clbk)
	--http_request(Steam, self.url, clbk)
	--clbk(true, read('ann.txt'))
	retry_http_request( self.url, clbk, 3.4, 'announce_retry_dl' )
end

function announce:announce(data)
	m_log_vs('announce:announce() data\n==================\n', data,'\n==================')
	if not data or data == '' or str_find(data, '<.-html.->.*<.-/html.->') then
		return
	end
	data = str_match(data,'({.*})') --Data's sanity check
	if data then
		local s = loadstring('return '..data)
		if s then
			local tab = s()
			if tab and tab.message and not self:cookie(tab.id) then
				m_log_vs('announce:announce() Extra! Extra! Here is something new!')
				show_msg(tab.title or 'Global Announcement',tab.message, {
					{ text = tab.link.text, callback = tab.link.l and function() overlay_activate( Steam, "url", tab.link.l ) end or void },
					--{ text = 'Close', is_cancel_button = true },
				})
			end
		end
	end
end

managers.announce_manager = announce:new('https://bitbucket.org/SoulHipHop/pirate-perfection/downloads/announcements.txt','Trainer/configs/checks/Announcement.Check')