-- WARP TO BULLET

if inGame() and isPlaying() and not inChat() and not InOverlay() then
	local rot0 = Rotation(0,0,0)
	if not _lastBullet then
		_lastBullet = nil 
	end
	if _lastBullet then
		managers.player:warp_to(_lastBullet, managers.player:player_unit():position(), 1, rot0 )
	end
	if not _bulletCollision then
		_bulletCollision = InstantBulletBase.on_collision 
	end
	function InstantBulletBase:on_collision( col_ray, weapon_unit, user_unit, damage, blank )
		if user_unit == managers.player:player_unit() then
			_lastBullet = col_ray.hit_position
		end
		return _bulletCollision(self, col_ray, weapon_unit, user_unit, damage, blank)
	end
	show_mid_text("To Bullet","Teleport",0.25)
	beep()
end