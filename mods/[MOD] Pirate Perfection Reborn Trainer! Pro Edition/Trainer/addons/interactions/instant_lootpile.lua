-- Purpose:  Instantly make lootpiles available after resetting
-- Author:  The Joker

plugins:new_plugin('instant_lootpile')

VERSION = '1.0'

CATEGORY = 'interaction'

local backuper = backuper

function MAIN()
	backuper:hijack('ElementLootPile.register_steal_SO', function(o, s)
		o(s)
		if s._next_steal_time then
			s._next_steal_time = 0
		end
	end)
end

function UNLOAD()
	backuper:restore('ElementLootPile.register_steal_SO')
end

FINALIZE()