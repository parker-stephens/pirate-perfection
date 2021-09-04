-- LightMachineGuns with Scopes

-- M249
_initM249 = _initM249 or PlayerTweakData._init_m249
function PlayerTweakData:_init_m249()
	_initM249(self)
	local pivot_shoulder_translation = Vector3( 10.775, 5.09, -1.2 )
	local pivot_shoulder_rotation = Rotation( 0, -58.75, 0 )
	local pivot_head_rotation = Rotation( 0, 0.2, 0 )
	self.stances.m249.steelsight.shoulders.translation = Vector3( 0, 5.5, .75 ) - pivot_shoulder_translation:rotate_with( pivot_shoulder_rotation:inverse() ):rotate_with( pivot_head_rotation )
	self.stances.m249.steelsight.shoulders.rotation = pivot_head_rotation
end

_initM249Tweak = _initM249Tweak or WeaponFactoryTweakData._init_m249
function WeaponFactoryTweakData:_init_m249()
	_initM249Tweak(self)
	for _,part in ipairs(self.parts.wpn_fps_shot_r870_s_folding.forbids) do
		if ( part ~= "wpn_fps_upg_o_acog" and part ~= "wpn_fps_shot_r870_ris_special" ) then
			table.insert(self.wpn_fps_lmg_m249.uses_parts, part)
		end
	end
end

-- RPK
_initRPK = _initRPK or PlayerTweakData._init_rpk
function PlayerTweakData:_init_rpk()
	_initRPK(self)
	local pivot_shoulder_translation = Vector3( 10.69, 33, -1.84 )
	local pivot_shoulder_rotation = Rotation( 0.1067, -0.0850111, 0.629008 )
	local pivot_head_rotation = Rotation( 0, 0.2, 0 )
	self.stances.rpk.steelsight.shoulders.translation = Vector3( .1, 7, 0.22 ) - pivot_shoulder_translation:rotate_with( pivot_shoulder_rotation:inverse() ):rotate_with( pivot_head_rotation )
	self.stances.rpk.steelsight.shoulders.rotation = pivot_head_rotation
end

_initRPKTweak = _initRPKTweak or WeaponFactoryTweakData._init_rpk
function WeaponFactoryTweakData:_init_rpk()
	_initRPKTweak(self)
	for _,part in ipairs(self.parts.wpn_fps_shot_r870_s_folding.forbids) do
		if ( part ~= "wpn_fps_upg_o_acog" and part ~= "wpn_fps_shot_r870_ris_special" ) then
			table.insert(self.wpn_fps_lmg_rpk.uses_parts, part)
		end
	end
end

-- Brenner
_initBrenner = _initBrenner or PlayerTweakData._init_hk21
function PlayerTweakData:_init_hk21()
	_initBrenner(self)
	local pivot_shoulder_translation = Vector3( 10.83, 26, 1.37 )
	local pivot_shoulder_rotation = Rotation( 3.03061, 1.08595, 1.87441 )
	local pivot_head_rotation = Rotation( -3, -1, -2 )
	self.stances.hk21.steelsight.shoulders.translation = Vector3( .98, 10, 0.1 ) - pivot_shoulder_translation:rotate_with( pivot_shoulder_rotation:inverse() ):rotate_with( pivot_head_rotation )
	self.stances.hk21.steelsight.shoulders.rotation = pivot_head_rotation
end

_initBrennerTweak = _initBrennerTweak or WeaponFactoryTweakData._init_hk21
function WeaponFactoryTweakData:_init_hk21()
	_initBrennerTweak(self)
	for _,part in ipairs(self.parts.wpn_fps_shot_r870_s_folding.forbids) do
		if ( part ~= "wpn_fps_upg_o_acog" and part ~= "wpn_fps_shot_r870_ris_special" ) then
			table.insert(self.wpn_fps_lmg_hk21.uses_parts, part)
		end
	end
end

-- MG42
_initMG42 = _initMG42 or PlayerTweakData._init_mg42
function PlayerTweakData:_init_mg42()
	_initMG42(self)
	local pivot_shoulder_translation = Vector3( 10.713, 47.8277, 0.873785 )
	local pivot_shoulder_rotation = Rotation( 0.10662, -0.0844545, 0.629209 )
	local pivot_head_rotation = Rotation( 0, 0, 0 )
	self.stances.mg42.steelsight.shoulders.translation = Vector3( 0, 40.5, -2.7 ) - pivot_shoulder_translation:rotate_with( pivot_shoulder_rotation:inverse() ):rotate_with( pivot_head_rotation )
	self.stances.mg42.steelsight.shoulders.rotation = pivot_head_rotation
end

_initMG42Tweak = _initMG42Tweak or WeaponFactoryTweakData._init_mg42
function WeaponFactoryTweakData:_init_mg42()
	_initMG42Tweak(self)
	for _,part in ipairs(self.parts.wpn_fps_shot_r870_s_folding.forbids) do
		if ( part ~= "wpn_fps_upg_o_acog" and part ~= "wpn_fps_shot_r870_ris_special" ) then
			table.insert(self.wpn_fps_lmg_mg42.uses_parts, part)
		end
	end
end