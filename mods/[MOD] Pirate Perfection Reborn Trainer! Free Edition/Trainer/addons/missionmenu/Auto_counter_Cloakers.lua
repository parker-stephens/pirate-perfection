-- AUTO COUNTER CLOAKER ATTACKS
plugins:new_plugin('Auto_counter_Cloakers')

VERSION = '1.0'

--local backuper = backuper

function MAIN()
	if PlayerMovement then
		function PlayerMovement:on_SPOOCed(enemy_unit)
			return "countered"
		end
	end

	if TeamAIMovement then
		function TeamAIMovement:on_SPOOCed(enemy_unit)
			return "countered"
		end
	end
end

function UNLOAD()

end

FINALIZE()