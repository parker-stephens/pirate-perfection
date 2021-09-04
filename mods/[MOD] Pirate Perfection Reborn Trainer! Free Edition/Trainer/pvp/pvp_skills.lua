local AI_state = managers.groupai:state()
local M_player = managers.player
local M_network = managers.network
local player = M_player:player_unit()
local my_id = player:network():peer():id()
local my_name = player:base():nick_name()
local is_server = Network:is_server()
local M_session = M_network:session()
local player_damage = player:character_damage()
local server_throw_grenade = GrenadeBase.server_throw_grenade

Skills = class()

function Skills:init( pvp )
	self.pvp = pvp
	
	self.all_skills = { 
		[1] = { text = "FUS RO DAH", callback = self.fus_ro_dah },
		[2] = { text = "AIRSTRIKE", callback = self.airstrike },
		[3] = { text = "TASER attack", callback = self.taser },
		[4] = { text = "SPOOC attack", callback = self.spooc },
		[5] = { text = "AIR DANCING", callback = self.air_dance },
		[6] = { text = "AUTO AIRSTRIKE", callback = self.auto_airstrike },
		[7] = { text = "AIR BOMB", callback = self.air_bomb },
		[12] = { text = "DRUNK CAMERA", callback = self.drunk_camera },
		[21] = { text = "JIHAD MODE", callback = self.jihad },
		[31] = { text = "TANK MODE", callback = self.tank },
	}
end

function Skills:fus_ro_dah()
	self.pvp:system_mess("FUS RO DAH!")

	local command = { "push" }
	self:send_to_all( command )
		
	return true
end

function Skills:airstrike()
	local ray = get_ray()
	
	if not ray then 
		return false
	end
	
	self.pvp:system_mess( my_name .. " USE AIRSTRIKE!" )

	local num = 0
	local money_value = managers.money:get_bag_value("money")
	local pos = ray.position
	for i = 1, 5 do
		if is_server then
			M_player:server_drop_carry( "ammo", money_value, nil, nil, 0, pos + Vector3(num,0,900), Rotation(0,0,0), Vector3( 0,0,0 ), 0 )
		else
			M_session:send_to_host( "server_drop_carry", "ammo", money_value, nil, nil, 0, pos + Vector3(num,0,900), Rotation(0,0,0), Vector3( 0,0,0 ), 0, nil )
		end
		num = num + 40
	end

		
	return true
end

function Skills:taser()
	local ray = get_ray( false, "raycastable_characters" )
	
	if ray and ray.unit and ray.unit:base() and ray.unit:base():nick_name() then 
		self.pvp:system_mess( my_name .. " USE TASER ATTACK!" )
		ray.unit:network():send_to_unit({ "sync_player_movement_state", ray.unit, "tased", 3, ray.unit:id() })
		
		return true
	end
	
	return false
end

function Skills:spooc()
	local ray = get_ray( false, "raycastable_characters" )
	
	if ray and ray.unit and ray.unit:base() and ray.unit:base():nick_name() then
		local dis = mvector3.distance_sq( player:position(), ray.unit:position() )
		if dis < 65000 then
			self.pvp:system_mess( my_name .. " USE SPOOC ATTACK!" )
			ray.unit:network():send_to_unit( { "sync_player_movement_state", ray.unit, "damage", my_id, 200 } )
			return true
		end
	end
	
	return false
end

function Skills:air_dance()
	local ray = get_ray( false, "raycastable_characters" )
	
	if ray and ray.unit and ray.unit:base() and ray.unit:base():nick_name() then
		self.pvp:system_mess( ray.unit:base():nick_name() .. " IS DANCING!" )
		ray.unit:network():send_to_unit( { "sync_player_movement_state", ray.unit, "dance" } )
		return true
	end
	
	return false
end

function Skills:auto_airstrike()
	local all_players = AI_state:all_player_criminals()
	local possible_criminals = {}
	for u_key, u_data in pairs( all_players ) do
		if u_data.status ~= "dead" and u_data.unit ~= player then
			table.insert( possible_criminals, u_key )
		end
	end
	
	local player = all_players[ possible_criminals[ math.random(#possible_criminals) ] ]
	if not player then
		return false
	end
	
	local unit = player.unit
	local pos = unit:position()
	for i = 1, 5 do
		if is_server then
			server_throw_grenade( 1, pos, Vector3(0,0,0) )
		else
			M_session:send_to_host( "server_throw_grenade", 1, pos, Vector3(0,0,0) )
		end
	end
	
	self.pvp:system_mess( my_name .. " USE AUTO AIRSTRIKE!" )
	return true
end

function Skills:air_bomb()
	local ray = get_ray()
	
	if not ray then 
		return false
	end
	
	local pos = ray.position + Vector3(0,0,300)
	for i = 1, 3 do
		if is_server then
			server_throw_grenade( 2, pos, Vector3(0,0,0) )
		else
			M_session:send_to_host( "server_throw_grenade", 2, pos, Vector3(0,0,0) )
		end
	end
	
	self.pvp:system_mess( my_name .. " USE AIR BOMB!" )
	return true
end

function Skills:drunk_camera()
	local ray = get_ray( false, "raycastable_characters" )
	
	if ray and ray.unit and ray.unit:base() and ray.unit:base():nick_name() then
		self.pvp:system_mess( ray.unit:base():nick_name() .. " IS DRUNK!" )
		ray.unit:network():send_to_unit( { "sync_player_movement_state", ray.unit, "drunk" } )
		return true
	end
	
	return false
end

function Skills:jihad()
	local init_timer = tweak_data.grenades.launcher_frag.init_timer
	
	init_timer = 0
	local pos = player:position()
	for i = 1, 5 do
		if is_server then
			server_throw_grenade( 2, pos, Vector3(0,0,0) )
		else
			M_session:send_to_host( "server_throw_grenade", 2, pos, Vector3(0,0,0) )
		end
	end
	init_timer = 2
	self.pvp:system_mess( my_name .. " SACRIFICED HIMSELF!" )
	
	return true
end

function Skills:tank()
	self.pvp:system_mess( my_name .. " IS TANK!" )
	
	self.pvp.tank_mode = true
	local __max_health = backuper:backup('PlayerDamage._max_health')
	function PlayerDamage:_max_health()
		return __max_health( self ) * 10
	end
	
	player_damage:replenish()
	return true
end

function Skills:send_to_all( command )
	local all_players = AI_state:all_player_criminals()
	for pl_key, pl_record in pairs( all_players ) do
		local unit = all_players[ pl_key ].unit
		
		if unit then
			unit:network():send_to_unit( { "sync_player_movement_state", unit, command[1], command[2], command[3] } )
		end
	end
end