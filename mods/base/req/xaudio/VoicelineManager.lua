local C = blt_class()
XAudio.VoicelineManager = C

C.DEFAULT = "default"

function C:init(unit)
	assert(unit ~= nil, "Must supply unit parameter to VoicelineManager")

	self._queues = {}
	self._sources = {}

	self:set_unit(unit)
end

function C:update()
	for channel, src in pairs(self._sources) do
		if src:is_closed() then
			self._sources[channel] = nil
		end
	end

	for channel, queue in pairs(self._queues) do
		if not self._sources[channel] then
			-- Play the first item in the queue
			local toplay = queue[1]
			self:_start(toplay, channel)

			-- Remove the buffer we just started playing
			table.remove(queue, 1)

			-- If there's nothing left to play, remove the queue
			if #queue == 0 then
				self._queues[channel] = nil
			end
		end
	end
end

function C:play(buffer, channel)
	channel = channel or C.DEFAULT

	if self._queues[channel] then
		table.insert(self._queues[channel], buffer)
	else
		self._queues[channel] = {buffer}
	end
end

function C:_start(buffer, channel)
	self._sources[channel] = XAudio.UnitSource:new(self._unit, buffer)
end

function C:set_unit(unit)
	self._unit = unit
end

function C:get_unit()
	return self._unit
end
