if not HuskPlayerMovement then return nil end
_CheckMeleeAttack = _CheckMeleeAttack or HuskPlayerMovement.anim_cbk_spawn_melee_item
function HuskPlayerMovement:anim_cbk_spawn_melee_item(unit, graphic_object)
	if ( graphic_object ) then
		_CheckMeleeAttack(self, unit,graphic_object)
	end
end