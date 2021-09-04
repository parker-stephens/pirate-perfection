--Sorted dialog by baldwin. Requires simple menu.
--Purpose: automatically sort entries to other pages, depending on max_entries setting.
--If you feel you can improve this script, please discuss changes to baldwin before commiting.

ppr_require 'Trainer/tools/menu'

local max_entries = 19 --Max ammount of entries being added into single dialog
local insert = table.insert
show_sorted_dialog = function(title,text,data,fallback,mx,n)
	if not n or n < 1 then
		n = 1
	end
	local max_entries = mx or max_entries
	local t_data = { { text = Localization.translate.exit, cancel_button = true } }
	if fallback then
		insert(t_data, { text = Localization.translate.retrn, callback = fallback })
	end
	if (#data - n >= max_entries) then --Since n starts with 1
		insert(t_data, { text = Localization.translate.next_page, callback = function() show_sorted_dialog(title,text,data,fallback,mx,n+max_entries) end })
	end
	if n > 1 then
		insert(t_data, { text = Localization.translate.prev_page, callback = function() show_sorted_dialog(title,text,data,fallback,mx,n-max_entries) end })
	end
	insert(t_data, {})
	for i=n,(max_entries+(n-1) < #data) and max_entries+(n-1) or #data do
		insert(t_data, data[i])
	end
	SimpleMenuV3:new(title, text, t_data)
end