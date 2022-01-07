local Steam = Steam
local steam_uid = Steam.userid
local Global = Global
local select = select
local name = Global.spoofed_name or 'Without passport'

backuper:hijack('(getmetatable(Steam)).username', function(o, self, userid, ...)
	if not userid or userid == steam_uid(Steam) then
		return name
	else
		return o(self, userid, ...)
	end
end)

local update = function()
	local s = managers.network:session()
	if not s then
		return
	end
	
	local my_peer = s:local_peer()
	my_peer:set_name( name )
	
	for _, peer in pairs( s._peers ) do
		if not peer:loaded() or not my_peer:loaded() then
			peer:send( "request_player_name_reply", name )
		end
	end
end

RunNewLoopIdent('update_name_spoof', update)