The SuperBLT XAudio 'eXtended Audio' API (coincedentally the same as the DirectX audio system) is an API
that allows BLT mods to use 3D audio effects. It is based upon OpenAL, currently
using OpenALSoft. HRTF support is planned.

XAudio works on the basis of sources and buffers:

## Buffers
A piece of audio can be loaded from an OGG file into a buffer. The memory used in the buffer is shared between
all sources playing it, so once a source is loaded it's memory consumption does not change.

Buffers are cached, so if you create two buffers with the same filename there will be no difference in memory
consumption as if you'd only created one. Additionally, buffers are retained when starting/stopping a heist
to speed up loading.

A buffer is created with `XAudio.Buffer:new(filename)`, where `filename` is the path to a OGG file you
want to load (note the path is the same type as used in dofile, so you should use something
like `ModPath .. "sounds/myfile.ogg"`).

When you're done with a buffer, close it with `buff:close()`. This tells the system you're done with it. Note
it does not actually destroy the buffer and free up it's memory use (done in case you want to use the buffer
later on) - for that, use `buff:close(true)` (note this only has an effect if this is done on the last buffer
object referencing the physical buffer).

You can also find the length in seconds of a buffer with `buff:get_length()`.

## Sources
A basic source is an instance of `XAudio.Source`. You probably won't use these basic sources very much, if
at all. They are Lua objects (via `blt_class`), and can be subclassed and extended to perform custom tasks.

There are two basic ways to use a source:
- Create a source with `XAudio.Source:new()`, load buffers into it with `src:set_buffer(buffer)`, and
close it when you're done
- Create a source and supply a buffer as you create it with `XAudio.Source:new(buffer)`. The source
will immediately start playing the supplied buffer, and will automatically close itself when it is finished. After
creating one of these, you don't have to pay any further attention to it.

Note at at present, using OpenALsoft, there is a maximum of 256 sources you can use at any one time. Don't pay
too much attention to this particular number, as in the future when hardware acceleration is supported it will
vary depending on your motherboard/soundcard drivers.

This means that you should not hold onto open sources. Using the second method presented above will likely clear
your mod from having any issues with this, as it is unlikely more than 256 sounds will need to be played at any
one time.

If you do have to use the former method for whatever reason, be absolutely sure you close your sources with
the `src:close()` method.

You can check if a source is closed with the `src:is_closed()` method, and note that trying to call almost any
other method on a closed source will result in a Lua error.

You can get the current state of a source using `src:get_state()`. This will return `XAudio.Source.PLAYING`,
`.PAUSED`, `.STOPPED`, `.INITIAL` or `.OTHER`.

You can set the volume of a source using `src:set_volume(val)` where `val` is the volume between `0` and `1`.

You can set the position, velocity and direction of a source using `src:set_position`, `src:set_velocity`,
and `src:set_direction`, respectively. These functions accept world positions either as vectors or as x,y,z sets
for their arguments.

## Unit Sources
A unit source is similar to a basic source, only it is attached to a unit - if you attach a unit source to a cop,
then the source will move to follow the cop around.

A unit source is created in a very similar way to a basic source - use `XAudio.UnitSource:new(unit, buffer)` to create
the unit source. If you want the source to follow the player, provide `XAudio.PLAYER` as the unit argument.

## Voiceline Manager
A voiceline manager is a utility to help you with making units speak (and ensuring they don't say two lines at
the same time). They can be created with `XAudio.VoicelineManager:new(unit)` (also accepting `XAudio.PLAYER`).

You must constantly call `vm:update()`. This function starts new sounds playing, so not calling it will result
in no sounds coming out. Stopping calling it will result in all currently-playing sounds continue to the end, however.

When you've created one, use `vm:play(buffer[, channel])` to play a sound. Voiceline manager support using multiple
channels - it will happily play two sounds at once if they're one seperate channels. If `channel` is not
speicifed, it defaults to `XAudio.VoicelineManager.DEFAULT`. Trying to play a sound while another sound is busy
playing on the same channel will result in it being queued until the first source is done.

