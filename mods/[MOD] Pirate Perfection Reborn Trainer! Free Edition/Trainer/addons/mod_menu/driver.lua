-- Driver mod
-- Author: Main code: Simplity, fixes: baldwin

local plugins = plugins
plugins:new_plugin('driver')

DESCRIPTION = 'Play as driver and manually rescue your crew from police. Made by Simplity, severaly fixed by baldwin.'

CATEGORY = 'mods'

VERSION = '1.3'

local pairs = pairs
local tostring = tostring
local find = string.find
local sin = math.sin
local cos = math.cos
local floor = math.floor
local max = math.max
local min = math.min

local Idstring = Idstring
local Vector3 = Vector3
local Rotation = Rotation
local mvector3 = mvector3
local World = World
local W_delete_unit = World.delete_unit
local W_spawn_unit = World.spawn_unit
local Overlay_gui = Overlay:gui()
local RenderSettings = RenderSettings

local managers = managers
local M_player = managers.player
local player = M_player:player_unit()
local warp_to = M_player.warp_to
local M_nav = managers.navigation

local unit, unit_name, speed_up, move_back
local kb = Input:keyboard()
local kb_down = kb.down
local car_t = {}
local car_speedometer

local speed = 0
local max_forward_speed = 40
local max_backward_speed = 30

--Tweaks
local inc_speed_up = 0.05 --Forward speed increase
local slowdown_speed = 0.02 --Inactive speed decrease
local inc_speed_back = 0.02 --Backward speed increase

local brake_dec = 0.08 --Brake speed modifier

local turn_speed = 0.7 --Turning speed

--Don't edit these ones, If you don't know what you're doing
local speedometer_x = 0.89583333333333333333333333333333 -- 1720
local speedometer_y = 0.68518518518518518518518518518519 -- 740

local speedometer_size = 0.03125 -- 60

local function move_car(pos, rot)
	pos = pos or unit:position()
	rot = rot or unit:rotation()
	local nav = M_nav:create_nav_tracker( pos )
	W_delete_unit( World, unit )
	unit = W_spawn_unit( World, Idstring(unit_name), Vector3(pos.x, pos.y, nav:field_z() - 25), rot)
	M_player:warp_to( unit:position() + Vector3(0,0,100), player:camera():rotation() )
end

local function move_forward()
	if speed < 0 then 
		return
	end
	local x_rot = unit:rotation():yaw()
	local x = sin(x_rot) * speed
	local y = cos(x_rot) * speed
	local new_pos = unit:position() - Vector3(x, -y, 0)
	move_car(new_pos, nil)
end

local function move_rightward()
	local x_rot = unit:rotation():yaw()
	local new_rot = speed <= 0 and Rotation((x_rot + turn_speed), 0, 0) or Rotation((x_rot - turn_speed), 0, 0)
	move_car(nil, new_rot)
end
	 
local function move_leftward()
	local x_rot = unit:rotation():yaw()
	local new_rot = speed <= 0 and Rotation((x_rot - turn_speed), 0, 0) or Rotation((x_rot + turn_speed), 0, 0)
	move_car(nil, new_rot)
end
	 
local function move_backward()
	if speed > 0 then 
		return
	end
	local x_rot = unit:rotation():yaw()
	local x = sin(x_rot) * speed
	local y = cos(x_rot) * speed
	local new_pos = unit:position() - Vector3(x,-(y),0)
	move_car(new_pos, nil)
end

local function check_ai(group)
	for u_key,u_data in pairs(group) do
		local d_unit = u_data.unit
		local d_pos = d_unit:position()
		local dis = mvector3.distance_sq( unit:position(), d_pos )
		if dis < 20000 then
			local col_ray = { }
			col_ray.ray = Vector3(100, 100, 100)
			col_ray.position = d_pos
			local action_data = {}
			action_data.variant = "explosion"
			action_data.damage = 1000
			action_data.attacker_unit = managers.player:player_unit()
			action_data.col_ray = col_ray
			d_unit:character_damage():damage_explosion(action_data)
		end
	end
end

local Application = Application
local A_time = Application.time
local function car_update()
	local t = A_time(Application)
	local self = car_t
	if not self._last_upd_t then
		if car_speedometer then
			Overlay_gui:destroy_workspace( self.speedometer.ws)
			car_speedometer = nil
		end
		self._last_upd_t = t
		return
	end
	
	local dt = t - self._last_upd_t
	self.speed = speed

	--Bug: when you change resolution when speedometer placed, it isn't update its location and size
	if not car_speedometer then
		car_speedometer = {}
		car_speedometer.ws = Overlay:newgui():create_screen_workspace()
		car_speedometer.lbl = car_speedometer.ws:panel():text{ name="lbl_speed" , x = speedometer_x * RenderSettings.resolution.x, y = speedometer_y * RenderSettings.resolution.y, text="", font=tweak_data.menu.pd2_large_font, font_size = speedometer_size * RenderSettings.resolution.x, color = Color.Free, layer=2000 }
	end
	car_speedometer.lbl:set_text(tostring( floor(speed + 0.5) ).." km/h")

	if speed_up and speed <= max_forward_speed then
		if speed < 0 then
			speed = speed + brake_dec
		else
			speed = speed + inc_speed_up
		end
	elseif not speed_up then
		if speed > 0 then
			move_forward()
			speed = max(speed - slowdown_speed, 0)
		end
	end
	
	if move_back and speed >= max_backward_speed*-1 then
		if speed > 0 then
			speed = speed - brake_dec
		else
			speed = speed - inc_speed_back
		end
	elseif not move_back then
		if speed < 0 then
			move_backward()
			speed = min(speed + slowdown_speed, 0)
		end
	end
	
	check_ai( managers.enemy:all_enemies() )
	check_ai( managers.enemy:all_civilians() )

	self._last_upd_t = t
end


local function update_input()
	if kb_down( kb, Idstring("up") ) then 
		move_forward()
		speed_up = true
	else
		speed_up = false
	end
	if kb_down( kb, Idstring("down") ) then 
		move_backward()
		move_back = true
	else
		move_back = false
	end
	if kb_down( kb, Idstring("left") ) then 
		move_leftward()
	end  
	if kb_down( kb, Idstring("right") ) then 
		move_rightward()
	end	
end

function MAIN()
	-- Load unit
	local unit_names = { "units/payday2/vehicles/str_vehicle_car_police_washington/str_vehicle_car_police_washington",
						 "units/payday2/vehicles/str_vehicle_car_taxi/str_vehicle_car_taxi", "units/payday2/vehicles/str_vehicle_suburban_fbi/str_vehicle_suburban_fbi",
						 "units/pd2_dlc1/vehicles/str_vehicle_truck_gensec_transport/str_vehicle_truck_gensec_transport", "units/payday2/vehicles/str_vehicle_van_player/str_vehicle_van_player", }
						 
	for _,id in pairs(unit_names) do
		if unit_on_map(id) then
			unit_name = id
			break
		end
	end

	if not unit_name then
		m_log_error('Driver', 'Unit cannot be spawn on this map.')
		return
	end
	
	unit = W_spawn_unit( World, Idstring(unit_name), player:position(), player:camera():rotation() )
	M_player:warp_to( unit:position() + Vector3(0,0,300), player:camera():rotation() )
	
	local RunNewLoopIdent = RunNewLoopIdent
	RunNewLoopIdent('driver_car_update', car_update)
	RunNewLoopIdent('driver_update', update_input)
end


function UNLOAD()
	local StopLoopIdent = StopLoopIdent
	StopLoopIdent('driver_update')
	StopLoopIdent('driver_car_update')
	
	if car_speedometer then
		Overlay_gui:destroy_workspace( car_speedometer.ws )
		car_speedometer = nil
	end
end

FINALIZE()