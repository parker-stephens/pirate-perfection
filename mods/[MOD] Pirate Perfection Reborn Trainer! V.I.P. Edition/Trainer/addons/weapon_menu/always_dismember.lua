-- Always dismember cops

plugins:new_plugin('always_dismember')

VERSION = '1.0'

local backuper = backuper
local restore = backuper.restore
local random = math.random

function MAIN()
	local dismembers = {"head","body"}
	
	backuper:backup('CopDamage._dismember_condition')
	function CopDamage:_dismember_condition() return true end
	
	local die = backuper:backup('CopDamage.die')
	function CopDamage:die( attack_data )
		if not attack_data.body_name then
			attack_data.body_name = dismembers[random(#dismembers)]
		end
		self:_dismember_body_part( attack_data )
		
		return die( self, attack_data )
	end

	backuper:backup('CopDamage._check_special_death_conditions')
	function CopDamage:_check_special_death_conditions(variant, body, attacker_unit)
		local special_deaths = self._unit:base():char_tweak().special_deaths
		if not special_deaths or not special_deaths[variant] then
			return
		end
		local body_data = special_deaths[variant][body:name():key()]
		if not body_data then
			return
		end
		if self._unit:damage():has_sequence(body_data.sequence) then
			self._unit:damage():run_sequence_simple(body_data.sequence)
		end
		if body_data.special_comment and attacker_unit == managers.player:player_unit() then
			return body_data.special_comment
		end
	end
end

function UNLOAD()
	backuper:restore('CopDamage._dismember_condition')
	backuper:restore('CopDamage.die')
	backuper:restore('CopDamage._check_special_death_conditions')
end

FINALIZE()