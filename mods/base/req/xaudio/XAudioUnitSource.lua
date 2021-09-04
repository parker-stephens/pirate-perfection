local C = blt_class(XAudio.Source)
XAudio.UnitSource = C

function C:init(unit, ...)
	self.super.init(self, ...)
	self._unit = unit
end

function C:update(...)
	self.super.update(self, ...)

	-- If we were just closed, or the unit is dead, do nothing
	if self:is_closed() then return end

	local unit = self._unit
	if self._unit == XAudio.PLAYER then
		unit = XAudio._player_unit
	end

	-- If the unit is dead, we're done.
	if not alive(unit) then
		self:close()
		return
	end

	local pos = unit:position()
	self:set_position(pos)
	-- TODO velocity and direction
end
