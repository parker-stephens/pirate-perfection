-- Interact and look around by someone

plugins:new_plugin('interact_and_look')

CATEGORY = 'interaction'

VERSION = '1.0'

function MAIN()
	backuper:backup('PlayerStandard._check_action_interact')
	function PlayerStandard:_check_action_interact( t, input )
		local new_action,timer,interact_object
		local interaction_wanted = input.btn_interact_press
		self._unit:base():set_slot( self._unit, 4 )
		if interaction_wanted then
			local action_forbidden = self:chk_action_forbidden( "interact" ) 
			or self._unit:base():stats_screen_visible() 
			or self:_interacting() 
			or self._ext_movement:has_carry_restriction()
			or self:is_deploying()
			or self:_changing_weapon()
			if not action_forbidden then   
			new_action,timer,interact_object = managers.interaction:interact( self._unit )
			if new_action then
			   self:_play_interact_redirect( t, input )
			end
			if timer then
			   new_action = true
			   self:_start_action_interact( t, input, timer, interact_object )
			end
			new_action = new_action or self:_start_action_intimidate( t )
			end
		end
		if input.btn_interact_release then
			self:_interupt_action_interact()
		end
		return new_action
	end
end

function UNLOAD()
	backuper:restore('PlayerStandard._check_action_interact')
end

FINALIZE()