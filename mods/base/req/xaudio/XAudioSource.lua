local C = blt_class()
XAudio.Source = C

C.PLAYING = 1
C.PAUSED = 2
C.STOPPED = 3
C.INITIAL = 4
C.OTHER = 5

C.SOUND_EFFECT="sfx"
C.MUSIC="music"

function C:init(buffer, source)
	self._source = source and source._buffer or blt.xaudio.newsource()

	-- Get a source ID
	self._source_id = XAudio._next_source_id
	XAudio._next_source_id = XAudio._next_source_id + 1

	-- Add ourselves to the sources list
	XAudio._sources[self._source_id] = self

	-- Set our game paused paramter
	-- This determines if actions should be held until the game is un-paused again.
	self._pause_held = false

	-- Should the source pause when the game pauses
	self._auto_pause = true

	-- Set initial values for the gain and raw gain
	self._gain = 1
	self._raw_gain = 1
	self:set_type(C.SOUND_EFFECT)

	if buffer then
		-- Set the initial buffer
		self:set_buffer(buffer)

		-- Enable single-sound mode
		-- This destroyes the source when done playing, and automatically starts
		--  the source playing if this is not disabled before the first update
		--  or passing 'false' as the buffer argument
		self._single_sound = true
	end

	-- We're currently open
	self._closed = false

	-- Default state
	self._looping = false
	self._relative = false
end

function C:close()
	-- Remove ourselves from the sources table
	XAudio._sources[self._source_id] = nil

	-- Close the audio source
	self._source:close()

	-- Mark ourselves as closed
	self._closed = true
end

for _, name in ipairs({
	"play",
	"pause",
	"stop"
}) do
	C[name] = function(self, ...)
		self._source[name](self._source)
	end
end

function C:set_buffer(buffer, set)
	if self:is_active() then
		if set then
			self:stop()
		else
			error("Cannot set buffer on source with state " .. self._source:getstate())
		end
	end

	self._buffer = buffer
	self._source:setbuffer(buffer._buffer)
end

function C:set_single_sound(enable)
	self._single_sound = enable
end

function C:set_auto_pause(enable)
	self._auto_pause = enable
end

function C:is_active()
	local state = self:get_state()
	return state == C.PLAYING or state == C.PAUSED
end

function C:is_closed()
	return self._closed
end

function C:is_auto_pausing()
	return self._auto_pause
end

function C:get_state()
	local state = ({
		playing = C.PLAYING,
		paused = C.PAUSED,
		stopped = C.STOPPED,
		initial = C.INITIAL
	})[self._source:getstate()]

	return state or C.OTHER
end

local function process_vector(x, y, z)
	if type(x) == "userdata" then -- We were passed a vector
		z = x.z
		y = x.y
		x = x.x
	end

	return x, y, z
end

function C:set_position(...)
	self._source:setposition(process_vector(...))
end

function C:set_velocity(...)
	self._source:setvelocity(process_vector(...))
end

function C:set_direction(...)
	self._source:setdirection(process_vector(...))
end

function C:set_volume(gain)
	if gain > 1 then
		error("Cannot set gain to more than 1")
	elseif gain < 0 then
		error("Cannot set gain to less than 0")
	end

	self._gain = gain
end

function C:set_type(typ)
	if typ == C.SOUND_EFFECT or typ == C.MUSIC then
		self._type = typ
	else
		error("Audio type can only be set to XAudioSource.SOUND_EFFECT and XAudioSource.MUSIC")
	end
end

function C:set_looping(looping)
	self._looping = looping
	self._source:setlooping(looping)
end

function C:set_relative(relative)
	self._relative = relative
	self._source:setrelative(relative)
end

function C:is_looping()
	return self._looping
end

function C:is_relative()
	return self._relative
end

function C:get_type()
	return self._type
end

function C:get_volume()
	return self._gain
end

function C:get_raw_volume()
	return self._raw_gain
end

function C:update(t, dt, paused)
	if self:is_closed() then
		error("Cannot update closed source")
	end

	-- Pause/unpause this source when the game is paused/unpaused
	if paused ~= self._pause_held and self:is_active() and self:is_auto_pausing() then
		self._pause_held = paused

		if paused and self:get_state() == C.PLAYING then
			self:pause()
			self._queue_paused = true
		elseif not paused and self._queue_paused then
			self:play()
			self._queue_paused = false
		end
	end

	local last_gain = self._raw_gain
	self:_compute_gains()
	if self._raw_gain ~= last_gain then
		self._source:setgain(self._raw_gain)
	end

	if self._single_sound then
		local state = self:get_state()
		if state == C.INITIAL then
			self:play()
		elseif state == C.STOPPED then
			self:close()
		elseif state == C.PLAYING then
			-- We're fine, do nothing
		elseif state == C.PAUSED and paused then
			-- Game is paused, not a problem
		else
			error("Illegal state " .. tostring(self._source:getstate()) ..
				" for single-sound audio source")
		end
	end
end

function C:_compute_gains()
	self._raw_gain = self._gain * XAudio._base_gains[self._type]
end
