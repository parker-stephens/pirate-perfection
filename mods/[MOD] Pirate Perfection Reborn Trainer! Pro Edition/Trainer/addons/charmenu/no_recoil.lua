-- No recoil for weapon
-- Author: baldwin

plugins:new_plugin('no_recoil')

VERSION = '1.0'

CATEGORY = 'character'

function MAIN()
	local backuper = backuper
	
	backuper:backup('FPCameraPlayerBase.recoil_kick')
	function FPCameraPlayerBase.recoil_kick()end

	backuper:hijack('PlayerCamera.play_shaker',function( orig, self, effect, ... ) 
		if effect == 'fire_weapon_kick' or effect == 'fire_weapon_rot' then --These shakers are annoying and disturbs you when sniping with high rate of fire.
			return
		end
		return orig(self, effect, ...) 
	end)
end

function UNLOAD()
	local backuper = backuper
	local restore = backuper.restore
	restore(backuper, 'FPCameraPlayerBase.recoil_kick')
	restore(backuper, 'PlayerCamera.play_shaker')
end

FINALIZE()