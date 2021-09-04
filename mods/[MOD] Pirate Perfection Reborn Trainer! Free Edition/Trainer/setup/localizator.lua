--Translation class by baldwin
--Purpose: Translate text using text ids
--Instructions: localisation file must look like this: { text_id = 'Localised string', text_id2 = 'Another string', ... }
--Once any language translation was implemented, add the name of language txt file into available_languages list
--To get text of your language from id, use next format: localizator.translate[text_id]

--Uncommon errors and their solutions:
--If console says that here is unknown symbol before some other unicode symbol, change translation's encoding to ASCII (faced in turkish translation)

--For writing translation files I suggest to use ZeroBrane editor and temporary change txt extension to lua to easier detect mistakes.

local loadstring_execute = loadstring_execute
local setmetatable = setmetatable
local m_log_error = m_log_error
local m_log_vs = m_log_vs
local next = next
local io_open = ppr_io.open
local string = string
local str_format = string.format
local str_match = string.match
local Steam = Steam
local http_request = Steam.http_request
local executewithdelay = executewithdelay
local ppr_config = ppr_config

local DEFAULT_LANGUAGE = 'english'
--[[
local available_languages = {
	english = true,
	russian = true,
	german = true,
	portuguese = true,
	turkish = true,
	italian = true,
	spanish = true,
}
]]

local localizator = class()

local init, mt_table, text, load_language, change_language, _load_language, grab_list, download_translation

init = function(self, language)
	self.lan = language or DEFAULT_LANGUAGE
	self.translate = {}
	load_language( self )
end
localizator.init = init

mt_table = function(self)
	local default = self.default_lan
	if ( not default ) then
		default = _load_language(DEFAULT_LANGUAGE)
		self.default_lan = default
	end
	
	local mt = {
		__index = 
		function(_,k)
			local language = self.lan
			if language ~= DEFAULT_LANGUAGE then
				local def_str = default[k]
				if ( def_str ) then
					m_log_error('localizator.translate','definition for',k,'isn\'t found in', language, 'translation. Using', DEFAULT_LANGUAGE, 'string instead')
					return def_str
				end
			end
			m_log_error('localizator.translate','definition for',k,'isn\'t found!')
			return k --If no localisation string in english localisation was found, then table returns id, that was queried.
		end
	}
	setmetatable(self.translate, mt)
end
localizator.mt_table = mt_table

_load_language = function( language )
	local path = 'Trainer/translations/'..language..'.txt'
	local f = io_open(path,'rb')
	if f then
		local contents = f:read('*all')
		f:close()
		if contents then
			return loadstring_execute('return '..contents, {}, path) or {}
		end
	end
end
localizator._load_language = _load_language

text = function( self, id, ...)
	return str_format(self.translate[id], ...)
end
localizator.text = text

--Tries to load language inputed into "lan" key.
--Returns true, if language exists and it was loaded successfully.
load_language = function( self )
	local language = self.lan
	local result = _load_language( language )
	if ( result ) then
		self.translate = result
	end
	mt_table( self )
	if not next(self.translate) then
		m_log_error('localizator:load_language()','Localization failed to load or empty')
		if language ~= DEFAULT_LANGUAGE then
			m_log_vs('Loading', DEFAULT_LANGUAGE, 'localization.')
			change_language(self, DEFAULT_LANGUAGE)
		end
		return false
	end
	return true
end
localizator.load_language = load_language

download_translation = function( self, language, reply )
	local net_data = self.__net_data
	if ( net_data ) then
		local dl_data = net_data[language]
		if ( dl_data ) then
			local url = dl_data.u
			if ( url ) then
				local function clbk( s, data )
					m_log_vs('localizator.lua http_request report in dl callback', 'Success?', s )
					if (s) then
						data = str_match( data, "{.*}" ) --Filter table contents only (to filter memory leaks from http_request)
						if ( data ) then
							--If loaded from network string returns table, then translation should be ok
							local sanity = loadstring_execute( 'return '..data, {}, language..'.txt' )
							if ( sanity ) then
								local f = io_open( 'Trainer/translations/'..language..'.txt', 'wb' )
								if ( f ) then
									f:write( data )
									f:close()
									if ( reply ) then
										reply( language, data )
									end
									return
								end
								m_log_error('localizator.lua on download callback', 'Failed to write to Trainer/translations/'..language..'.txt' )
							end
						end
						m_log_error('localizator.lua on download callback', 'Data corrupted?')
					end
					if ( reply ) then
						reply( false )
					end
				end
				http_request( Steam, url, clbk )
				return
			end
			m_log_error('localizator.lua download_translation', 'Failed to get url from', language)
		end
		m_log_error('localizator.lua download_translation', 'language id', language, 'wasn\'t found!')
	end
	if ( reply ) then
		reply( false )
	end
end
localizator.download_translation = download_translation


--Data format: { ['translation_id'] = { l = 'language name in english', l2 = 'language name on its language', u = 'url_to_translation', v = 'version_number' }, ... }
grab_list = function( self, reply )
	local retry_id
	local function grab_clbk( s, data )
		StopLoopIdent(retry_id)
		m_log_vs('localizator.lua http_request report. Success ?', s, 'Data:\n==========\n', data, '\n==========')
		if (s) then
			local net_data = loadstring_execute( 'return '..data, {} )
			if ( net_data ) then
				self.__net_data = net_data
				if ( reply ) then
					reply( net_data )
				end
				return
			end
		end
		reply( false )
	end
	http_request( Steam, "https://bitbucket.org/SoulHipHop/pirate-perfection/downloads/hiphop.txt", grab_clbk )
	retry_id = executewithdelay( { func = grab_list, params = { self } }, 3.9 )
end
localizator.grab_list = grab_list

change_language = function( self, language, saveme )
	self.lan = language
	
	if load_language( self ) and saveme then
		--Average solution. What if ppr_config have changes user don't want to accept ?
		--Will be great to implement function, that change only 1 value
		ppr_config.Language = language
		ppr_config()
	end
end
localizator.change_language = change_language

return localizator