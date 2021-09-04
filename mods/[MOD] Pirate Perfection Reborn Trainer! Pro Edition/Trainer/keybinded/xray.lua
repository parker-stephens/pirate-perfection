--This is my editied xray from pdth, just using contour game's contour extension instead of my own.
--Purpose: Highlight civilians and enemies on the map.
--Note: before adding new unit key, check if it have husk unit, if it is, add husk unit aswell or else colors for specials will not be applied properly!
--Author: **** & baldwin

if (not GameSetup) then
	return
end

local alive = alive

local pairs = pairs
local backuper = backuper
--Brand new callbacks!
local remove_clbk = backuper.remove_clbk
local add_clbk = backuper.add_clbk
--local in_chat = in_chat

local xray_enabled = false --Now can be local

local managers = managers
local M_enemy = managers.enemy
local AllEnemies = M_enemy:all_enemies()
local AllCivilians = M_enemy:all_civilians()
local interactive_units = managers.interaction._interactive_units
local SecurityCameras = SecurityCamera.cameras
local ppr = ppr_config
local m_log_error = m_log_error

local civilians = 'xray_civilians'
local civilians_keycard = 'xray_civilians_keycard'
local enemies = 'xray_enemies'
local enemies_keycard = 'xray_enemies_keycard'
local specials = 'xray_specials'
local snipers = 'xray_snipers'
local cameras = 'xray_cams'
local friendly = 'xray_friendly'

local keycard = 'keycard'

local sync = false --Synces contours (synces only cameras currently)

local function remove_mark(unit)
	local contour = unit.contour
	contour = contour and contour( unit )
	if contour then
		local custom = contour.__custom_type
		if ( custom ) then
			contour:remove(custom,sync)
			contour.__custom_type = nil
		else
			--m_log_error("{xray.lua}", "Missing custom type from unit (probably called on non-xrayed unit)")
		end
	end
end

local Color = Color
local _types = ContourExt._types
_types.xray_civilians = { priority = 1, color = ppr.xray_CivColR and Color(ppr.xray_CivColR / 255, ppr.xray_CivColG / 255, ppr.xray_CivColB / 255) or Color.cyan, material_swap_required = true }
_types.xray_civilians_keycard = { priority = 1, color = ppr.xray_CivKeyColR and Color(ppr.xray_CivKeyColR / 255, ppr.xray_CivKeyColG / 255, ppr.xray_CivKeyColB / 255) or Color.yellow, material_swap_required = true }
_types.xray_enemies = { priority = 1, color = ppr.xray_CopsColR and Color(ppr.xray_CopsColR / 255, ppr.xray_CopsColG / 255, ppr.xray_CopsColB / 255) or Color.red, material_swap_required = true }
_types.xray_enemies_keycard = { priority = 1, color = ppr.xray_CopsKeyColR and Color(ppr.xray_CopsKeyColR / 255, ppr.xray_CopsKeyColG / 255, ppr.xray_CopsKeyColB / 255) or Color(1,0.4,0), material_swap_required = true }
_types.xray_specials = { priority = 1, color = ppr.xray_SpecialColR and Color(ppr.xray_SpecialColR / 255, ppr.xray_SpecialColG / 255, ppr.xray_SpecialColB / 255) or Color.purple, material_swap_required = true }
_types.xray_snipers = { priority = 1, color = ppr.xray_SniperColR and Color(ppr.xray_SniperColR / 255, ppr.xray_SniperColG / 255, ppr.xray_SniperColB / 255) or Color(0,0.5,0), material_swap_required = true }
_types.xray_cams = { priority = 1, color = ppr.xray_CamsColR and Color(ppr.xray_CamsColR / 255, ppr.xray_CamsColG / 255, ppr.xray_CamsColB / 255) or Color(1,0.2,0) }
_types.xray_friendly = { priority = 1, color = ppr.xray_FriendlyR and Color(ppr.xray_FriendlyR / 255, ppr.xray_FriendlyG / 255, ppr.xray_FriendlyB / 255) or Color(0.2,0.8,1), material_swap_required = true }

local function mark(unit,color)
	if alive(unit) then
		local contour = unit.contour
		contour = contour and contour( unit )
		if contour then
			local custom = contour.__custom_type
			if ( custom ) then --Was xrayed before, remove his mark
				contour:remove(custom,sync)
			end
			contour:add(color,sync)
			contour.__custom_type = color
		end
	end
end

local mark_enable = {
	'enable_outline',
	'state_outline_enabled',
	'switch_to_glow_mtr'
}
local mark_disable = {
	'disable_outline',
	'state_outline_disabled',
	'switch_to_no_glow_mtr'
}

local function mark_item( unit, index, remove )
	if (index) then
		local damage_ext = unit:damage()
		if (damage_ext) then
			local sequence = remove and mark_disable[index] or mark_enable[index]
			if damage_ext:has_sequence(sequence) then
				damage_ext:run_sequence_simple(sequence)
			end
		end
	end
end

--Special enemies
local special_ids = {
	['b37f2c8943a4ceb0'] = true,
	['d46d8583bb15b100'] = true,
	['69fc875bba3e5fb5'] = true,
	['bfd2c56d614d0228'] = true,
	['3e0f1a532450d565'] = true,
	['e64b375ced655166'] = true,
	['d8e8276a44b4dad5'] = true,
	['f0fec102c6f850ec'] = true,
	['bc078a7d66cfe569'] = true,
	--Husk units below!
	['28a21b4d89c298cf'] = true,
	['efc7018e740fd64d'] = true,
	['3b62cdab5b11dce1'] = true,
	['916cf573a64bfe03'] = true,
	['f1ce7cceec821a08'] = true,
	['07534523e98821ac'] = true,
	['ce5593a811a21c90'] = true,
	['d213ea0f22d1ca49'] = true,
	['73d547546ef5ff5c'] = true,
	['ecab43ba164a3a09'] = true,
	['b940dc2975f1bbf0'] = true,
}

--Snipers
local sniper_ids = {
	['ffcb30c12128fc5b'] = true,
	['490944f03e56fcf0'] = true,
	--Husk units below!
	['44ffa22668e9271f'] = true,
	['2ef5563d908aa105'] = true,
}

--Items
--I use indexes, since different items need different sequences
local items_ids = {
	['dd0578dda618e1b0'] = 2, --pickup_phone
	['bb82cfc66c4ae490'] = 2, --pickup_tablet
	['cfbdf015882c1e9e'] = 2, --use_computer
	['54e8d784dbceaf07'] = 1, --stash_server_pickup
	['5422d8b99c7c1b57'] = 3, --pickup_keycard
	--['9c3047f8cc5c3d14'] = true,
	--['c9b068ac7994ad04'] = true,
	--['9ed5ee9a1ebb1f55'] = true,
	--['d904ebd1e81458a8'] = true,
}

local function id_color(unit) --Identity to what color we need color special enemy
	local u_key = unit:name():key()
	local movement = unit:movement()
	local team = movement and movement._team
	team = team and team.id
	return ((unit:in_slot( 16 ) or team == 'criminal1') and friendly) or (special_ids[u_key] and specials) or (sniper_ids[u_key] and snipers) or enemies
end
--Notes: 16th slot is for harmless criminal (converted cops use it)

local function on_enemy_registered(o,self,unit)
	executewithdelay( { func = mark, params = { unit, unit:character_damage():pickup() == keycard and enemies_keycard or id_color(unit) } }, 1 ) --Weird fix
end

local function on_civ_registered(o,self,unit)
	executewithdelay( { func = mark, params = { unit, unit:character_damage():pickup() == keycard and civilians_keycard or civilians } }, 1 )
end

local function on_unit_died(o,self,dead_unit) --Contour being removed once marked target is dead
	remove_mark(dead_unit)
end

local function before_criminal_convert( o, self )
	remove_mark( self._unit )
end

local function after_criminal_convert( r, self )
	mark( self._unit, friendly )
end
--[[TO DO
local function on_team_changed( r, self, team_data )
	if ( self.registered_xray ) then
		local id = team_data.id
		m_log_vs('{xray.lua} team change', id)
		local u = self._unit
		if ( id == 'criminal1' ) then
			m_log_vs('friendly')
			mark( u, friendly )
		elseif ( id == 'law1' or id == 'mobster1' ) then
			m_log_vs('enemy')
			mark( u, id_color(u) )
		end
	end
end
]]
local function TOGGLE()
--	if in_chat() then
--		return
--	end
	--Switch
	xray_enabled = not xray_enabled

	if not xray_enabled then
		--Switch OFF
		if ppr.xray_Cops then
			remove_clbk(backuper, 'EnemyManager.register_enemy', 'register', 1)
			remove_clbk(backuper, 'EnemyManager.on_enemy_died', 'die', 1)
			remove_clbk(backuper, 'CopBrain.convert_to_criminal', 'convert')
			--remove_clbk(backuper, 'CopMovement.set_team', 'xray_handle', 2)
			for _,ud in pairs(AllEnemies) do
				remove_mark(ud.unit)
			end
		end
		if ppr.xray_Civ then
			remove_clbk(backuper, 'EnemyManager.register_civilian', 'register', 1)
			remove_clbk(backuper, 'EnemyManager.on_civilian_died', 'die', 1)
			for _,ud in pairs(AllCivilians) do
				remove_mark(ud.unit)
			end
		end
		if ppr.xray_Cams then
			for _,unit in pairs(SecurityCameras) do
				remove_mark(unit)
			end
		end
		return
	end
	--Switch ON
	if ppr.xray_Cops then
		add_clbk(backuper, 'EnemyManager.register_enemy',on_enemy_registered,'register', 1) --Marks when unit just spawned
		add_clbk(backuper, 'EnemyManager.on_enemy_died',on_unit_died,'die', 1) --Removes mark when unit just died
		add_clbk(backuper, 'CopBrain.convert_to_criminal',before_criminal_convert, 'convert', 1) --Removes mark when cop being converted to criminal
		add_clbk(backuper, 'CopBrain.convert_to_criminal',after_criminal_convert,'convert', 2) --Mark again on full convertion
		--add_clbk(backuper, 'CopMovement.set_team', on_team_changed, 'xray_handle', 2) --Updates unit's color on team change
		
		for _,ud in pairs(AllEnemies) do
			local unit = ud.unit
			mark(unit,unit:character_damage():pickup() == keycard and enemies_keycard or id_color(unit))
		end
	end
	if ppr.xray_Civ then
		add_clbk(backuper, 'EnemyManager.on_civilian_died',on_unit_died,'die', 1)
		add_clbk(backuper, 'EnemyManager.register_civilian',on_civ_registered, 'register', 1)
		for _,ud in pairs(AllCivilians) do
			local unit = ud.unit
			mark(unit, unit:character_damage():pickup() == keycard and civilians_keycard or civilians)
		end
	end

	if ppr.xray_Cams then
		for _,unit in pairs(SecurityCameras) do
			mark(unit,cameras)
		end
	end

	if ppr.xray_Items then
		for _,unit in pairs(interactive_units) do
			local index = items_ids[unit:name():key()]
			if index then
				mark_item(unit, index)
			end
		end
	end
end

gxray_Toggle = function() return TOGGLE,xray_enabled end

return TOGGLE