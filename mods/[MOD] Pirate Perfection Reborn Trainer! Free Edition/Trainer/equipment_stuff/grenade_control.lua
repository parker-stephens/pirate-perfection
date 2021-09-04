--Grenade control for not being marked by baldwin
--Purpose: prevent you randomly being detected as cheater by preventing throwing more than 3 grenades.
--	--	--	>>	>>	>>	>>	TO	REWORK	<<	<<	<<	<<	--	--	--

ppr_require 'Trainer/equipment_stuff/equipment_control'

GrenadeControl = GrenadeControl or equipment_control:new()

function GrenadeControl:on_reject()
	m_log_error('GrenadeControl:on_rejected()','You\'re throwing too many grenades')
	if managers.exception then
		managers.exception:catch('grenade_control')
	end
end

PlayerEquipment._throw_grenade = PlayerEquipment._throw_grenade or PlayerEquipment.throw_grenade
function PlayerEquipment:throw_grenade( ... )
	if GrenadeControl and not GrenadeControl:check_place('nades') then
		return
	end
	return self:_throw_grenade( ... )
end

GrenadeCrateBase._take_grenade = GrenadeCrateBase._take_grenade or GrenadeCrateBase.take_grenade
function GrenadeCrateBase:take_grenade( ... )
	local ret = self:_take_grenade(...)
	if ret then
		GrenadeControl.used = GrenadeControl.used - 1 --I'm legitimately used grenades case to add 1 grenade.
	end
	return ret
end