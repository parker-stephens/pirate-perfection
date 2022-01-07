--Carrystacker by Harfatus.
--Slightly modified by baldwin.

if not in_game() then
	return
end

local managers = managers
local _debugEnabled = false
local BagIcon = "pd2_loot"

if not carry_stacker_setup then
	local backup_func
	do
		local backuper = backuper
		local backup = backuper.backup
		backup_func = function( ... )
			return backup(backuper, ...)
		end
	end
	
	local table = table
	local tab_insert = table.insert
	local tab_remove = table.remove
	local PlayerManager = PlayerManager
	PlayerManager.carry_stack = {}
	PlayerManager.carrystack_lastpress = 0
	PlayerManager.drop_all_bags = false
	
	local HUDManager = HUDManager
	
	local ofuncs = {
		managers_player_set_carry = backup_func('PlayerManager.set_carry'),
		managers_player_drop_carry = backup_func('PlayerManager.drop_carry'),
		IntimitateInteractionExt__interact_blocked = backup_func('IntimitateInteractionExt._interact_blocked'),
	}

	function PlayerManager:refresh_stack_counter()
		local count = #self.carry_stack + (self:is_carrying() and 1 or 0)
		managers.hud:remove_special_equipment("carrystacker")
		if count > 0 then
			managers.hud:add_special_equipment({id = "carrystacker", icon = BagIcon, amount = count})
		end
	end

	function PlayerManager:rotate_stack(dir)
		if #managers.player.carry_stack < 1 or (#managers.player.carry_stack < 2 and not self:is_carrying()) then
			return
		end
		if self:is_carrying() then
			tab_insert(self.carry_stack, self:get_my_carry_data())
		end
		if dir == "up" then
			tab_insert(self.carry_stack, 1, tab_remove(self.carry_stack))
		else
			tab_insert(self.carry_stack, tab_remove(self.carry_stack, 1))
		end
		local cdata = tab_remove(self.carry_stack)
		if cdata then
			if self:is_carrying() then self:carry_discard() end
			ofuncs.managers_player_set_carry(self, cdata.carry_id, cdata.value or 100, cdata.dye_initiated, cdata.has_dye_pack, cdata.dye_value_multiplier)
		end
	end

	-- pops an item from the stack when the player drops their carried item
	function PlayerManager:drop_carry( ... ) 
		ofuncs.managers_player_drop_carry(self, ... )
		if #self.carry_stack > 0 then
			local cdata = tab_remove(self.carry_stack)
			if cdata then
				self:set_carry(cdata.carry_id, cdata.value or 100, cdata.dye_initiated, cdata.has_dye_pack, cdata.dye_value_multiplier)
			end
		end
		self:refresh_stack_counter()
		if self.drop_all_bags then
			if #self.carry_stack > 0 or self:is_carrying() then
				self:drop_carry()
			end
			self.drop_all_bags = false
		end
	end

	-- saves the current item to the stack if we're already carrying something
	function PlayerManager:set_carry( ... )
		if self:is_carrying() and self:get_my_carry_data() then
			tab_insert(self.carry_stack, self:get_my_carry_data())
		end
		ofuncs.managers_player_set_carry(self, ...)
		self:refresh_stack_counter()
	end

	-- new function to discard the currently carried item
	function PlayerManager:carry_discard()
		local M_hud = managers.hud
		M_hud:remove_teammate_carry_info( HUDManager.PLAYER_PANEL )
		M_hud:temp_hide_carry_bag()
		self:update_removed_synced_carry_to_peers()
		if self._current_state == "carry" then
			managers.player:set_player_state( "standard" )
		end
	end

	local IntimitateInteractionExt = IntimitateInteractionExt
	local CarryInteractionExt = CarryInteractionExt
	-- overridden to prevent blocking us from picking up a dead body
	function IntimitateInteractionExt:_interact_blocked( player )
		if self.tweak_data == "corpse_dispose" then
			if not managers.player:has_category_upgrade( "player", "corpse_dispose" ) then
				return true
			end
			return not managers.player:can_carry( "person" )
		end
		return ofuncs.IntimitateInteractionExt__interact_blocked(self, player)
	end

	-- overridden to always allow us to pick up a carry item
	function CarryInteractionExt:_interact_blocked( player )
		return not managers.player:can_carry( self._unit:carry_data():carry_id() )
	end

	-- overridden to always allow us to select a carry item
	function CarryInteractionExt:can_select( player )
		return CarryInteractionExt.super.can_select( self, player )
	end

	-- custom function. Pushes a carried item to stack and discards it or pops one if we're not carrying anything.
	-- this function is called every time the script gets run.
	function PlayerManager:carry_stacker()
		if _debugEnabled then
			io.stderr:write("current stack size: ".. tostring(#managers.player.carry_stack) .. "\n")
			if #managers.player.carry_stack > 0 then
				for _,v in pairs(managers.player.carry_stack) do
				   io.stderr:write("item: ".. v.carry_id .. "\n")
				end
			end
		end
		local cdata = self:get_my_carry_data()
		if self:is_carrying() and cdata then
			tab_insert(self.carry_stack, self:get_my_carry_data())
			self:carry_discard()
			managers.hud:present_mid_text( { title = "Carry Stack", text = cdata.carry_id .. " Pushed", time = 1 } )
		elseif #self.carry_stack > 0 then
			cdata = tab_remove(self.carry_stack)
			self:set_carry(cdata.carry_id, cdata.value, cdata.dye_initiated, cdata.has_dye_pack, cdata.dye_value_multiplier)
			managers.hud:present_mid_text( { title = "Carry Stack", text = cdata.carry_id .. " Popped", time = 1 } )
		else
			managers.hud:present_mid_text( { title = "Carry Stack", text = "Empty", time = 1 } )
		end
		if (Application:time() - self.carrystack_lastpress) < 0.3 and (self:is_carrying() or #self.carry_stack > 0) then
			self.drop_all_bags = true
			self:drop_carry()
		end
		self.carrystack_lastpress = Application:time()
		self:refresh_stack_counter()
	end
	carry_stacker_setup = true
end

managers.player:carry_stacker()