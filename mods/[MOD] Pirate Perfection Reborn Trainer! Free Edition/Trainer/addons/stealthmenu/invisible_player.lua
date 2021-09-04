-- Makes you invisible for AI
-- Author: Simplity

local pairs = pairs
local alive = alive

local managers = managers
local M_player = managers.player

plugins:new_plugin('invisible_player')

CATEGORY = 'stealth'

VERSION = '1.0'

function MAIN()
	local player = M_player:player_unit()
	if not alive(player) then
		return
	end
	local ply_key = player:key()
	local AI_State = managers.groupai:state()
	for attention_object, data in pairs( AI_State._attention_objects.all ) do
		if ply_key == attention_object then
			AI_State.backuped_attention_object = data
		end
	end
	AI_State:unregister_AI_attention_object( player:key() )
end

function UNLOAD()
	local player = managers.player:player_unit()
	if not alive(player) then
		return
	end
	local ply_key = player:key()
	local AI_State = managers.groupai:state()
	AI_State._attention_objects.all[ ply_key ] = AI_State.backuped_attention_object
	AI_State:on_AI_attention_changed( ply_key )
end

FINALIZE()