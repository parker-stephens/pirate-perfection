-- Purpose: rewrite of stealth_cheating.lua, using same idea but better code

local pairs = pairs
local loadstring = loadstring
local unpack = unpack
local select = select
local backuper = backuper
local add_clbk = backuper.add_clbk
local remove_clbk = backuper.remove_clbk
local GetNetSession = GetNetSession
local void = void
--local table = table
--local clone = table.copy
--local tab_update = table.update
local alive = alive
local executewithdelay = executewithdelay
local query_execution = query_execution
local World = World
local spawn_unit = World.spawn_unit
local delete_unit = World.delete_unit
--local W_raycast = World.raycast
local Vector3 = Vector3
local down_vec3 = Vector3(0,0,-400)
local mvec_copy = mvector3.copy
local mrot_copy = mrotation.copy

local world_geometry_mask = managers.slot:get_mask("world_geometry")

local ECMJammerBase = ECMJammerBase
local SentryGunBase = SentryGunBase
local TripMineBase = TripMineBase

--Make it no more than 55 seconds! Or else detection will be probably thrown
--Too low values may cause sync issues with clients
local respawn_delay = 45

local respawn_IT, turn_to_respawnable

--Function name, make func/false.
--Make func is function, that takes self as 1st argument and unit as 2nd and returns new spawn function
local l_funces = {
	['SentryGunBase.spawn'] = function(self, u)
		--TO DO:
		--Ammo resync
		--Health resync
		local owner = self._owner
		local ammo_multiplier = self._ammo_multiplier
		local armor_multiplier = self._armor_multiplier
		local damage_multiplier = self._damage_multiplier
		local pos,rot = u:position(), u:rotation()
		--m_log_vs( "Owner: ", owner, "Ammo mul", ammo_multiplier, "Armor mul", armor_multiplier, "Damage mul", damage_multiplier, "Pos, rot", pos, rot )
		return function() return SentryGunBase.spawn( owner, pos, rot, ammo_multiplier, armor_multiplier, damage_multiplier ) end
	end,
	['GrenadeCrateBase.spawn'] = false,
	['FirstAidKitBase.spawn'] = false,
	['ECMJammerBase.spawn'] = function(self, u)
		local pos,rot = u:position(), u:rotation()
		local owner = self._owner
		local battery_life = self._battery_life
		return function() return ECMJammerBase.spawn( pos, rot, battery_life, owner ) end
	end,
	['DoctorBagBase.spawn'] = false,
	['BodyBagsBagBase.spawn'] = false,
	['AmmoBagBase.spawn'] = false,
	['TripMineBase.spawn'] = function(self, u)
		local owner = self._owner
		--[[local is_active = self._is_active
		local armed = self._armed]]
		local sensor_upgrade = self._sensor_upgrade
		local pos = u:position()
		local rot = u:rotation()
		return function()
			local unit = TripMineBase.spawn(pos, rot, sensor_upgrade)
			local u_base = unit:base()
			u_base:set_active( true, owner ) 
			u_base._activate_timer = nil --So laser armed state synces properly
			return unit
		end
	end,
}

--pack must contain: { (spawn_function)[, id, pos, rot, ...] }
respawn_IT = function( unit, make_func )
	if ( alive(unit) ) then
		local u_base = unit:base()
		--local old_base = clone( u_base )
		local id, body, pos, rot
		local do_spawn
		if ( not make_func ) then
			id = unit:name()
			pos = unit:position()
			rot = unit:rotation()
		else
			do_spawn = make_func( u_base, unit )
		end
		local save = {}
		local save_func = u_base.save
		if (save_func) then
			save_func(u_base, save)
		end
		delete_unit(World, unit)
		unit = do_spawn and do_spawn() or spawn_unit(World, id, pos, rot)
		u_base = unit:base()
		--tab_update( u_base, old_base )
		local load_func = u_base.load
		--m_log_full_inspect(save)
		if (load_func) then
			load_func(u_base, save)
		end
		--turn_to_respawnable( unit, make_func )
	end
end

turn_to_respawnable = function( unit, make_func )
	if ( alive(unit) ) then
		executewithdelay( { func = respawn_IT, params = { unit, make_func } }, respawn_delay, unit:key() )
	end
end

local function disable_network_sync()
	--Disable networking sync for duration of spawn method execution
	local s = GetNetSession()
	s.o_send_to_peers_synched = s.send_to_peers_synched
	s.send_to_peers_synched = void
end

for name,make_func in pairs(l_funces) do
	add_clbk( backuper, name, disable_network_sync, 'lobotomied_spawn', 1)
	local function hook_on( ret, self )
		--Enable it back, turn resulting unit into "respawnable" unit
		local s = GetNetSession()
		s.send_to_peers_synched = s.o_send_to_peers_synched or s.send_to_peers_synched
		local unit = ret[1]
		turn_to_respawnable(unit, make_func)
	end
	add_clbk( backuper, name, hook_on, 'lobotomied_spawn', 2)
end