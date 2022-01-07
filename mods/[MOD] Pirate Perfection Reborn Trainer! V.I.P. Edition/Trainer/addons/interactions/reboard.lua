--Puprose: allows you to put boards again, once you place it
--Note: premiums release only!
--Author: ****

plugins:new_plugin('reboard')

VERSION = '1.0'

CATEGORY = 'interaction'

function MAIN()
	--tweak_data of barricades, add more if devs will add new barricades
	local barricades = { stash_planks = true, need_boards = true }

	backuper:hijack('UseInteractionExt.interact', function( o, self, ... )
		local r = o(self, ...)
		if barricades[self.tweak_data] then
			self:set_active(true, true)
		end
		return r
	end)
end

function UNLOAD()
	backuper:restore('UseInteractionExt.interact')
end

FINALIZE()