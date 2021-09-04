--Remade function for rain menu. Now it will test, If bag will fall into something collidable.
--Purpose: rain bags
--Author: baldwin

local random = math.random

local is_client = is_client
local managers = managers
local M_network = managers.network
local M_player = managers.player
local player_list = M_player._players
local Vector3 = Vector3
local Rotation = Rotation
local M_slot = managers.slot
local get_mask = M_slot.get_mask
local World = World
local W_raycast = World.raycast
local m_log_error = m_log_error
local T_carry = tweak_data.carry

local radius = 20000 --Radius for bag storming
local vec0 = Vector3(0,0,-40000)
local UP = math.UP

local rand_pos

local function testray(reach)
	return W_raycast(World, "ray", reach, reach + vec0, "slot_mask", get_mask(M_slot, "bullet_impact_targets"))
end

rand_pos = function(pos)
	local p = Vector3(random(radius*-1,radius),random(radius*-1,radius),6000)
	p = pos + p
	if testray(p) then
		return p
	else
		return rand_pos(pos) --Test failed, try again
	end
end

local rand_rot = function()
	return Rotation(random(-180,180),random(-180,180),0)
end

local rain_bag = function(name, amount)
	local session = M_network._session
	local camera_ext = (player_list[1]):camera()
	local carry_data = T_carry[ name ]
	if not carry_data then
		return m_log_error('RainBags()','Invalid bag data',name)
	end
	local cam_pos = camera_ext:position()
	local mul = carry_data.multiplier
	local dye_initiated = carry_data.dye_initiated
	local has_dye_pack = carry_data.has_dye_pack
	local dye_value_multiplier = carry_data.dye_value_multiplier
	if is_client() then
		local send_to_host = session.send_to_host
		for _=1,amount do
			send_to_host(session, "server_drop_carry", name, mul, dye_initiated, has_dye_pack, dye_value_multiplier, rand_pos(cam_pos), rand_rot(), UP, 100, nil)
		end
	else
		local server_drop_carry = M_player.server_drop_carry
		for _=1,amount do
			server_drop_carry(M_player, name, mul, dye_initiated, has_dye_pack, dye_value_multiplier, rand_pos(cam_pos), rand_rot(), UP, 100, nil, nil)
		end
	end
end

RainBags = function(name, amount) --Global function, call this!
	if not amount then
		amount = 100
	end
	rain_bag(name, amount)
end