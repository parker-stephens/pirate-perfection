--Purpose: checks for new updates and shows message, if updates are available.

local Global = Global
if ( Global.update_checked ) then
	return
end
local tonumber = tonumber
local tostring = tostring
local ppr_require = ppr_require
local m_log_error = m_log_error
local string = string
local str_match = string.match
local str_find = string.find
local ppr_config = ppr_config
local executewithdelay = executewithdelay

local Steam = Steam
local http_request = Steam.http_request
local function go_to()
	--To which one we should lead ?
	Steam:overlay_activate( "url", 'http://www.pirateperfection.com/forum/23-download-section/' )
end

local delayed__ident
local _ = function(success, data)
	StopLoopIdent(delayed__ident)
	m_log_vs("Update checker report. Is success ?", success, "Data received:", data)
	if (success and data and data ~= '' and not str_find(data, '<.-html.->.*<.-/html.->')) then
		data = str_match(data, '%d+.%d+') --Data's sanity check. Find float number only
		if ( data ) then
			Global.update_checked = true
			local ver = tonumber(data)
			if (ver) then --NaN check
				if (ppr_config.const_version < data) then
					local tr = Localization
					
					ppr_require('Trainer/tools/new_menu/menu')
					local options = {
						{ text = tr.translate.update_goto, callback = go_to },
						{ text = tr.translate.btn_close },
					}
					Menu:open{ title = tr.translate.update_title, description = tr:text('update_desc',data), button_list = options}
				end
			end
		end
	end
end

local fetch
fetch = function()
	http_request( Steam, 'https://bitbucket.org/SoulHipHop/pirate-perfection/downloads/version.txt', _ )
	delayed__ident = executewithdelay(fetch, 2.5)
end

fetch()