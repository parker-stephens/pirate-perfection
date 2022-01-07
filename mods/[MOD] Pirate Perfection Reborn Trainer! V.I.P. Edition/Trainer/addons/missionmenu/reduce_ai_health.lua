-- Reduce AI health
-- Author: Simplity

local managers = managers
local M_enemy = managers.enemy
local M_player = managers.player
local Vector3 = Vector3
local pairs = pairs

plugins:new_plugin('reduce_ai_health')

local reduce_health = function()
	local all_enemies = M_enemy:all_enemies()
	for u_key, u_data in pairs(all_enemies) do
		local unit = u_data.unit
		
		local health = unit:character_damage()._health
		if health > 2 then			
			local action_data = {
				damage = health - 2,
				damage_effect = 0,
				attacker_unit = M_player:player_unit(),
				attack_dir = Vector3(0,0,0),
				name_id = 'rambo',
				col_ray = {
					position = unit:position(),
					body = unit:body("body"),
				}
			}
			
			local dmg_ext = unit:character_damage()
			if dmg_ext.damage_dot then
				dmg_ext:damage_dot(action_data)
			end
		end
	end
end

VERSION = '1.0'

function MAIN()
	RunNewLoopIdent('update_reduce_health', reduce_health)
end	

function UNLOAD()
	StopLoopIdent('update_reduce_health')
end

FINALIZE()