-- Purpose: Toggle X-Ray V4.0
-- Author: Slynderdale
-- Update: Baddog-11

-- Color List
local ColorList = {	default								= '336699', -- Light Blue
							friendly								= 'A3FFA3', -- Light Green
							camera								= 'CC0000', -- Dark Red
							hostage								= '009933', -- Dark Green
							pickup								= '003399', -- Dark Blue
							civpickup							= '003399', -- Dark Blue
							enepickup							= '003399', -- Dark Blue
							civilian								= 'FFFFFF', -- White
							civilian_female					= 'E0A3C2', -- Light Pink
							spooc									= '0000FF', -- Navy Blue
							taser									= 'FF66FF', -- Pink
							shield								= 'CC0000', -- Red
							tank									= 'FFFF00', -- Yellow
							sniper								= 'FF9933', -- Gold
							gangster								= '660066', -- Purple
							security								= '9932CC', -- Dark Orchid
							medic									= 'E00AB9', -- Shocking Pink
							gensec								= '87EC62',	--	
							swat									= '650ced',	--	
							heavy_swat							= 'eb3a22',	--	
							fbi									= '961857',	--	
							fbi_swat								= '119ef8',	--	
							fbi_heavy_swat						= '08bda3',	--	
							cop_female							= '0c9a8d',	--	
							city_swat							= '7e8bdd',	--	
							mobster_boss						= '671939',	--	
							mobster								= 'bb279a',	--	
							hector_boss							= 'ae519e',	--	
							hector_boss_no_armor				= '8ab167',	--	
							biker_boss							= '927d5b',	--	
							chavez_boss							= '9ef129',	--	
							biker									= 'e41efb',	--	
							bolivians							= '71ffe9',	--	
							tank_mini							= 'c4e0ee',	--	
							tank_medic							= '9108f7',	--	
							tank_hw								= '8abc81',	--	
							swat_van_turret_module			= '632943',	--	
							ceiling_turret_module_no_idle	= 'e88d32',	--	
							aa_turret_module					= 'd3838e',	--	
							Phalanx								= 'e4c6ac',	--	
							Phalanx_minion						= '0b7750',	--	
							}

-- Not Necessary ?
--if not toggleMark then toggleMark = false end
--if not syncMark then syncMark = false end

-- Get Unit Color
function getUnitColor(unit)
	local unitType = unit:base()._tweak_table
	if unit:base().security_camera then unitType = 'camera' end
	if unit:base().is_converted then unitType = 'friendly' end
	if unit:base().is_hostage then unitType = 'hostage' end
	if unit:base().has_pickup then unitType = 'pickup' end
	if not unitType then return nil end
	return Color(ColorList[unitType] and ColorList[unitType] or ColorList['default'])
end

-- Mark Enemies
function markEnemies()
	if not toggleMark or not inGame() then return end
	local multi = managers.player:upgrade_value("player", "mark_enemy_time_multiplier", 1)
	if isHost() then
		for u_key, u_data in pairs( managers.groupai:state()._security_cameras ) do
			if u_data.contour then u_data:contour():add( "mark_unit", syncMark, multi ) end
		end
	else
		for _, unit in ipairs( SecurityCamera.cameras ) do
			if unit and unit:contour() and unit:enabled() and unit:base() and not unit:base():destroyed() then
			unit:contour():add("mark_unit", syncMark, multi )
			end
		end
	end
	for u_key,u_data in pairs(managers.enemy:all_civilians()) do
		if u_data.unit.contour and alive(u_data.unit) then
			if isHostage(u_data.unit) then u_data.unit:contour():setData({is_hostage = true}) end
			if isHost() and u_data.unit:character_damage():pickup() then u_data.unit:contour():setData({has_pickup = true}) end
			u_data.unit:contour():add("mark_enemy", syncMark, multi)
		end
	end
	for u_key,u_data in pairs(managers.enemy:all_enemies()) do
		if u_data.unit.contour and alive(u_data.unit) then
			if u_data.is_converted then
				-- Optional Contour Fadeout Timer
				--ContourExt._types.friendly.fadeout = 3
				--ContourExt._types.friendly.fadeout_silent = 7	
				u_data.unit:contour():setData({is_converted = true})
				u_data.unit:contour():add("friendly", syncMark, multi)
			else
				if isHostage(u_data.unit) then u_data.unit:contour():setData({is_hostage = true}) end
				if isHost() and  u_data.unit:character_damage():pickup() and  u_data.unit:character_damage():pickup() ~= "ammo" then
					u_data.unit:contour():setData({has_pickup = true})
				end
				u_data.unit:contour():add("mark_enemy", syncMark, multi)
			end
		end
	end
end
function UnitNetworkHandler:mark_enemy( unit, marking_strength, sender ) end

-- Mark Items / Show Framing Frame Day 3 Items
function markMissionItems()
	_toggleItemFinder = not _toggleItemFinder
	if _toggleItemFinder then
		for k,v in pairs(managers.mission._scripts.default._elements) do
			if v._values and v._values.trigger_list and v._values.trigger_list[1] and (v._values.trigger_list[1].notify_unit_sequence == "state_outline_enabled" or v._values.trigger_list[1].notify_unit_sequence == "enable_outline") then
				v:on_executed()
			end
		end
	else
		for k,v in pairs(managers.mission._scripts.default._elements) do
			if v._values and v._values.trigger_list and v._values.trigger_list[1] and (v._values.trigger_list[1].notify_unit_sequence == "state_outline_disabled" or v._values.trigger_list[1].notify_unit_sequence == "disable_outline") then
				v:on_executed()
			end
		end
	end
end

-- Update Mark
if GameSetup then
	if not _gameUpdate then _gameUpdate = GameSetup.update end
	local _gameUpdateLastMark
	function GameSetup:update(t, dt)
		_gameUpdate(self, t, dt)
		if not _gameUpdateLastMark or t - _gameUpdateLastMark > 3 then
			_gameUpdateLastMark = t
			markData()
		end
	end
end

-- Clear Mark
function markClear()
	if not inGame() then return end
	if isHost() then
		for u_key, u_data in pairs(managers.groupai:state()._security_cameras) do
			if u_data.contour then u_data:contour():removeAll() end
		end
	else
		for _, unit in ipairs( SecurityCamera.cameras ) do unit:contour():removeAll() end
	end
	for u_key,u_data in pairs(managers.enemy:all_civilians()) do
		if u_data.unit.contour then u_data.unit:contour():removeAll() end
	end
	for u_key,u_data in pairs(managers.enemy:all_enemies()) do
		if u_data.unit.contour then u_data.unit:contour():removeAll() end
	end
end

-- Contours
if ContourExt then
	if not _nhUpdateColor then _nhUpdateColor = ContourExt._upd_color end
	function ContourExt:_upd_color()
		if toggleMark then
			if self._unit:name() ~= Idstring("units/pickups/ammo/ammo_pickup") then
				local color = getUnitColor(self._unit)
				if color then
					self._materials = self._materials or self._unit:get_objects_by_type(Idstring("material"))
					for _, material in ipairs(self._materials) do
						material:set_variable(Idstring( "contour_color" ), color)
					end
				return
				end
			end
		end
		_nhUpdateColor(self)
	end
	function ContourExt:removeAll(sync)
		if not self._contour_list or not type(self._contour_list) == 'table' then return end
		for id, setup in ipairs(self._contour_list) do self:remove(setup.type, sync) end
	end
	function ContourExt:setData(data)
		if not data or not type(data) == 'table' then return end
		for k, v in pairs(data) do self._unit:base()[k] = v end
	end
end

if CopDamage then
	if not _copDamageDie then _copDamageDie = CopDamage.die end
	function CopDamage:die( variant )
		if toggleMark and self._unit:contour() then self._unit:contour():removeAll() end
		_copDamageDie(self, variant)
	end
end

if HuskCopDamage then
	if not _huskDamageDie then _huskDamageDie = HuskCopDamage.die end
	function HuskCopDamage:die( variant )
		if toggleMark and self._unit:contour() then self._unit:contour():removeAll() end
		_huskDamageDie(self, variant)
	end
end

if ElementSecurityCamera then
	if not _cameraDestroyed then _cameraDestroyed = ElementSecurityCamera.on_destroyed end
	function ElementSecurityCamera:on_destroyed()
		if toggleMark then
			local camera_unit = self:_fetch_unit_by_unit_id( self._values.camera_u_id )
			if camera_unit:contour() then camera_unit:contour():removeAll() end
		end
		_cameraDestroyed(self)
	end
end

-- X-Ray Toggle
function markData()
	markEnemies()
end

function markToggle(toggleSync)
	if not inGame() then return end
	if toggleSync then
		syncMark = not syncMark
		showHint("Synced Marked Enemies: "..tostring(syncMark))
	else
		toggleMark = not toggleMark
		if not toggleMark then markClear()
			--PlayMedia("trainer/media/effects/xrayoff.mp3")
		else 
			--PlayMedia("trainer/media/effects/xrayon.mp3")
		end
		showHint("Marked Enemies: "..tostring(toggleMark))
	end
	markData()
end

markMissionItems()
markToggle()