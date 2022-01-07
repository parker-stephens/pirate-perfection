-- Lobotomize all AI
-- Author: Simplity

local managers = managers
local pairs = pairs

plugins:new_plugin('lobotomize_ai')
--plugins:set_update( true )

local function toggle_ai_state( state )
	local M_enemy = managers.enemy
	local state = not state
	
	for u_key, u_data in pairs( M_enemy:all_enemies() ) do
		u_data.unit:brain():set_active( state )
	end
	
	for u_key, u_data in pairs( M_enemy:all_civilians() ) do
		u_data.unit:brain():set_active( state )
	end
	
	for _,unit in pairs( SecurityCamera.cameras ) do
		if unit:base()._last_detect_t ~= nil then
			unit:base():set_update_enabled( state )
		end
	end
end

local function bug_fix()
	--Fix by v00d00
	function CopBrain:set_followup_objective( followup_objective )
		if not self._logic_data.objective then
			return
		end
		local old_followup = self._logic_data.objective.followup_objective
		self._logic_data.objective.followup_objective = followup_objective
		
		if followup_objective and followup_objective.interaction_voice then
			self._unit:network():send( "set_interaction_voice", followup_objective.interaction_voice )
		elseif old_followup and old_followup.interaction_voice then
			self._unit:network():send( "set_interaction_voice", "" )
		end
	end
end

local function patch_ai()
	--This part was remade by baldwin I guess, not sure
	--Lobotomy, whenever new logic being setted up
	local patched_logic = function( o, self, ... )
		local r = o(self, ...)
		self:set_active( false )
		return r
	end
	
	local backuper = backuper
	local hijack = backuper.hijack
	hijack(backuper, 'CopBrain.set_logic', patched_logic)
	hijack(backuper, 'CopBrain.set_init_logic', patched_logic)
	
end

VERSION = '1.01'

function MAIN()
	toggle_ai_state( true )
	bug_fix()
	patch_ai()
end	

--[[function UPDATE()
	toggle_ai_state( true )
end]]

function UNLOAD()
	local backuper = backuper
	local restore = backuper.restore
	restore(backuper, 'CopBrain.set_logic')
	restore(backuper, 'CopBrain.set_init_logic')
	toggle_ai_state( false )
end

FINALIZE()