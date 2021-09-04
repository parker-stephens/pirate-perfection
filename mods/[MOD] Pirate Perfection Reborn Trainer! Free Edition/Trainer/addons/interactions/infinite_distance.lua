-- Increase interaction distance
-- Author: baldwin

plugins:new_plugin('infinite_distance')

CATEGORY = 'interaction'

VERSION = '1.0'

function MAIN()
	local ignore_objects = { access_camera = true, open_slash_close_sec_box = true } --List of objects, these will be ignored at long distance.
	local HUGE = math.huge
	backuper:hijack('BaseInteractionExt.interact_distance',function(orig,self, ...)
		if ignore_objects[self.tweak_data] then
			return orig(self, ...)
		end
		return HUGE
	end)
end

function UNLOAD()
	backuper:restore('BaseInteractionExt.interact_distance')
end

FINALIZE()