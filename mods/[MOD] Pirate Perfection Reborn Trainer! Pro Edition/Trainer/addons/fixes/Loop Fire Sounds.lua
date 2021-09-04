-- LOOP FIRE SOUNDS
	if	not	LoopFireSounds	then
		LoopFireSounds	=	true
		if	inGame()	and	isPlaying()	then
			local	base_fire_sound	=	RaycastWeaponBase._fire_sound
			function	RaycastWeaponBase:_fire_sound()
				if	self:get_name_id()	==	"saw"	then
					base_fire_sound(self)
				end
			end
			local	old_fire	=	RaycastWeaponBase.fire
			function	RaycastWeaponBase:fire(...)
				local	result	=	old_fire(self,	...)
				if	self:get_name_id()	==	"saw"	then
					return	result
				end
				if	result	then
					self:play_tweak_data_sound("fire_single",	"fire")
				end
				return	result
			end
		end
	end