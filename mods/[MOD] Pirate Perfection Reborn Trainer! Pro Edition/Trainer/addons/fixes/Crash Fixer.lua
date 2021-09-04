-- CRASH FIXER
	if	RequiredScript	==	"lib/managers/group_ai_states/groupaistatebase"	then
		GroupAIStateBase.__check_gameover_conditions	=	GroupAIStateBase.check_gameover_conditions
		GroupAIStateBase.__unregister_criminal	=	GroupAIStateBase.unregister_criminal

		function	GroupAIStateBase:check_gameover_conditions(...)
			local	_,	ret	=	pcall(self.__check_gameover_conditions,	self,	...)
			return	ret	and	ret	or	false
		end
		
		function	GroupAIStateBase:unregister_criminal(...)
			local	ret	=	{pcall(self.__unregister_criminal,	self,	...)}
			if	#ret	>	0	then
				table.remove(ret,	1)
				return	unpack(ret)
			end
		end
		
		elseif	RequiredScript	==	"lib/units/enemies/cop/actions/lower_body/copactionwalk"	then
		CopActionWalk.___nav_point_pos	=	CopActionWalk._nav_point_pos
		CopActionWalk.___send_nav_point	=	CopActionWalk._send_nav_point
		
		function	CopActionWalk._nav_point_pos(...)
			local	_,ret	=	pcall(CopActionWalk.___nav_point_pos,	...)
			return	ret
		end
		
		function	CopActionWalk:_send_nav_point(...)
			local	_,ret	=	pcall(self.___send_nav_point,	self,	...)
			return	ret
		end
		
		elseif	RequiredScript	==	"lib/units/enemies/spooc/actions/lower_body/actionspooc"	then
		ActionSpooc.__upd_chase_path	=	ActionSpooc._upd_chase_path

		function	ActionSpooc:_upd_chase_path(...)
			pcall(self.__upd_chase_path,	self,	...)
		end
	end
