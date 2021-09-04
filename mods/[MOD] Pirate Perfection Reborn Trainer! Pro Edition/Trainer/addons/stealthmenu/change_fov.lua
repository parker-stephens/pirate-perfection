-- Change FOV on mouse scroll
-- Author: Simplity

local plugins = plugins
plugins:new_plugin('change_fov')

local managers = managers
local M_player = managers.player
local M_mission = managers.mission

local get_player_unit = M_player.player_unit
local Idstring = Idstring
local alive = alive

local mouse = Input:mouse()
local mouse_pressed = mouse.pressed

local id_wh_up = Idstring("mouse wheel up")
local id_wh_down = Idstring("mouse wheel down")
local col_green = Color.green

local ply --Here will be player
local ply_camera --Here will be ply:camera()

local o__fov --Old fov will be stored here

local RunNewLoopIdent = RunNewLoopIdent
local StopLoopIdent = StopLoopIdent

VERSION = '1.0'

local function catch_player()
	if ( not alive(ply) ) then
		ply = get_player_unit(M_player)
		if ( alive(ply) ) then
			ply_camera = ply:camera()
		end
	end
	return ply
end

local function update()
	if catch_player() then
		if mouse_pressed( mouse, id_wh_down ) then
			ply_camera:set_FOV( ply_camera._camera_object:fov() + 1 )
		elseif mouse_pressed( mouse, id_wh_up ) then
			ply_camera:set_FOV( ply_camera._camera_object:fov() - 1 )
		end
	end
end

local main
main = function()
	if ( catch_player() ) then
		o__fov = ply_camera._camera_object:fov()
		M_mission:_show_debug_subtitle("Turn the mouse wheel to change the FOV", Color.Pro)
		RunNewLoopIdent('update_fov', update)
	else
		RunNewLoopIdent('pending_load_fov', function() if ( catch_player() ) then main() end end)
	end
end

MAIN = main

function UNLOAD()
	-- Stop the update function
	if ( catch_player() ) then
		ply_camera:set_FOV( o__fov )
		o__fov = nil
	end
	StopLoopIdent('pending_load_fov')
	StopLoopIdent('update_fov')
end

FINALIZE()