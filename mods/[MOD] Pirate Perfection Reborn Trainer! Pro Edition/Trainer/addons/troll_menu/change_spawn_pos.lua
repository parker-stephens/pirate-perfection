-- Change spawn position for new players
-- Author: Simplity

local pos_s = managers.player:player_unit():position()
function NetworkMember:spawn_unit(spawn_point_id, is_drop_in, spawn_as)
	if self._unit then
		return
	end
	if not self._peer:synched() then
		return
	end
	local peer_id = self._peer:id()
	self._spawn_unit_called = true
	local pos_rot
	if is_drop_in then
		local spawn_on = self:_get_drop_in_spawn_on_unit()
		if spawn_on then
			local pos = spawn_on:position()
			local rot = spawn_on:rotation()
			pos_rot = {pos, rot}
		else
			local spawn_point = managers.network:game():get_next_spawn_point() or managers.network:spawn_point(1)
			pos_rot = spawn_point.pos_rot
		end
	else
		pos_rot = managers.network:spawn_point(spawn_point_id).pos_rot
	end
	local member_downed, member_dead, health, used_deployable, used_cable_ties, used_body_bags, hostages_killed, respawn_penalty, old_plr_entry = self:_get_old_entry()
	if old_plr_entry then
		old_plr_entry.member_downed = nil
		old_plr_entry.member_dead = nil
		old_plr_entry.hostages_killed = nil
		old_plr_entry.respawn_penalty = nil
	end
	local character_name = self._peer:character()
	local trade_entry, spawn_in_custody
	print("[NetworkMember:spawn_unit] Member assigned as", character_name)
	local old_unit
	trade_entry, old_unit = managers.groupai:state():remove_one_teamAI(character_name, member_downed or member_dead)
	if trade_entry and member_dead then
		trade_entry.peer_id = peer_id
	end
	local has_old_unit = alive(old_unit)
	local ai_is_downed = false
	if alive(old_unit) then
		ai_is_downed = old_unit:character_damage():bleed_out() or old_unit:character_damage():fatal() or old_unit:character_damage():arrested() or old_unit:character_damage():need_revive() or old_unit:character_damage():dead()
		World:delete_unit(old_unit)
	end
	spawn_in_custody = (member_downed or member_dead) and (trade_entry or ai_is_downed or not trade_entry and not has_old_unit)
	local lvl_tweak_data = Global.level_data and Global.level_data.level_id and tweak_data.levels[Global.level_data.level_id]
	local unit_name_suffix = lvl_tweak_data and lvl_tweak_data.unit_suit or "suit"
	local unit_name = Idstring(tweak_data.blackmarket.characters[self._peer:character_id()].fps_unit)
	local unit
	if self == Global.local_member then
		unit = World:spawn_unit(unit_name, pos_s, pos_rot[2])
	else
		unit = Network:spawn_unit_on_client(self._peer:rpc(), unit_name, pos_s, pos_rot[2])
	end
	local team_id = tweak_data.levels:get_default_team_ID("player")
	self:set_unit(unit, character_name, team_id)
	managers.network:session():send_to_peers_synched("set_unit", unit, character_name, self._peer:profile().outfit_string, self._peer:outfit_version(), peer_id, team_id)
	if self == Global.local_member then
		unit:character_damage():send_set_status()
	end
	if is_drop_in then
		managers.groupai:state():set_dropin_hostages_killed(unit, hostages_killed, respawn_penalty)
		self._peer:set_used_deployable(used_deployable)
		self._peer:set_used_body_bags(used_body_bags)
		if self == Global.local_member then
			managers.player:spawn_dropin_penalty(spawn_in_custody, spawn_in_custody, health, used_deployable, used_cable_ties, used_body_bags)
		else
			self._peer:send_queued_sync("spawn_dropin_penalty", spawn_in_custody, spawn_in_custody, health, used_deployable, used_cable_ties, used_body_bags)
		end
	end
	local vehicle = managers.vehicle:find_active_vehicle_with_player()
	if vehicle then
		Application:debug("[NetworkMember] Spawning peer_id in vehicle, peer_id:" .. peer_id)
		managers.player:server_enter_vehicle(vehicle, peer_id, unit)
	end
	return unit
end