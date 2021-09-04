-- Instant intimidation by Transcend

plugins:new_plugin('instant_intimidation')

local managers = managers
local M_player = managers.player

VERSION = '1.0'

CATEGORY = 'interaction'

function MAIN()
	local backuper = backuper
	local backup = backuper.backup
	local CopLogicIdle = CopLogicIdle
	local surrender = CopLogicIdle._surrender
	local on_intimidated = backup(backuper, "CopLogicIdle.on_intimidated")
	local hacked_on_intimidated = function( data, amount, aggressor_unit, ... )
		if aggressor_unit == M_player:player_unit() then
			surrender( data, amount )
			return true
		else
			return on_intimidated( data, amount, aggressor_unit, ...)
		end
	end
	CopLogicIdle.on_intimidated = hacked_on_intimidated
	
	backup(backuper, "CopLogicAttack.on_intimidated")
	backup(backuper, "CopLogicArrest.on_intimidated")
	backup(backuper, "CopLogicSniper.on_intimidated")
	CopLogicAttack.on_intimidated = hacked_on_intimidated
	CopLogicArrest.on_intimidated = hacked_on_intimidated
	CopLogicSniper.on_intimidated = hacked_on_intimidated

	-- Shield logic
	local CopLogicIntimidated = CopLogicIntimidated
	backup(backuper, 'CopBrain._logic_variants.shield.intimidated')
	CopBrain._logic_variants.shield.intimidated = CopLogicIntimidated
	local _do_tied = CopLogicIntimidated._do_tied
	local _chk_spawn_shield = CopInventory._chk_spawn_shield
	local on_intimidated = backup(backuper, 'CopLogicIntimidated.on_intimidated')
	function CopLogicIntimidated.on_intimidated( data, amount, aggressor_unit, ... ) 
		local unit = data.unit
		if unit:base()._tweak_table == "shield" then
			_do_tied( data, aggressor_unit )
			_chk_spawn_shield( unit:inventory(), nil )
		else
			on_intimidated( data, amount, aggressor_unit, ... )
		end
	end
end

function UNLOAD()
	local backuper = backuper
	local restore = backuper.restore
	restore(backuper, "CopLogicIdle.on_intimidated")
	restore(backuper, "CopLogicAttack.on_intimidated")
	restore(backuper, "CopLogicArrest.on_intimidated")
	restore(backuper, "CopLogicSniper.on_intimidated")
	restore(backuper, "CopLogicIntimidated.on_intimidated")
	restore(backuper, 'CopBrain._logic_variants.shield.intimidated')
end

FINALIZE()