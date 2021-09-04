-- Better FreeFlight with teleport (optional)
if RequiredScript == "lib/entry" then
	core:import("CoreFreeFlight")
	Global.DEBUG_MENU_ON = true
	local FF_ON, FF_OFF, FF_ON_NOCON = 0, 1, 2

	function CoreFreeFlight.FreeFlight:_attach_unit()
		local cam = self._camera_object
		local ray = World:raycast( "ray", cam:position(), cam:position() + cam:rotation():y() * 10000 )
		if ray then
			if alive( self._attached_to_unit ) and self._attached_to_unit == ray.unit then
				self:attach_to_unit( nil )
			else
				self:attach_to_unit( ray.unit )
			end 
		end
	end
			
	function CoreFreeFlight.FreeFlight:disable()
		for _,a in ipairs(self._actions) do
			a:reset()
		end
		self._state = FF_OFF
		self._con:disable()
		self._workspace:hide()
		self._vp:set_active(false)
		if ppr_config.FreeFlightTeleport then
			managers.player:warp_to(self._camera_pos, Rotation(0,0,0))
		end
		if managers.enemy then
			managers.enemy:set_gfx_lod_enabled( true )
		end
	end
end