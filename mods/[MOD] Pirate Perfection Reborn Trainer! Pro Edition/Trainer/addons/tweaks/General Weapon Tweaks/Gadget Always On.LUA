-- KEEP GADGET ALWAYS ON
	if	not	_NewRaycastWeaponBase_on_equip	then
		_NewRaycastWeaponBase_on_equip	=	NewRaycastWeaponBase.on_equip
	end
	function	NewRaycastWeaponBase:on_equip()
		_NewRaycastWeaponBase_on_equip(self)
		self:set_gadget_on(self._stored_gadget_on	or	0,	false)
	end
	if	not	_NewRaycastWeaponBase_toggle_gadget	then
		_NewRaycastWeaponBase_toggle_gadget	=	NewRaycastWeaponBase.toggle_gadget
	end
	function	NewRaycastWeaponBase:toggle_gadget()
		_NewRaycastWeaponBase_toggle_gadget(self)
		self._stored_gadget_on	=	self._gadget_on
	end