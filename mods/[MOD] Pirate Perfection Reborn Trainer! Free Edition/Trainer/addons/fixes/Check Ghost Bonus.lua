-- check if accumulated_ghost_bonus is not nil
if not HUDMissionBriefing then return nil end
function HUDMissionBriefing:_apply_ghost_color(ghost, i, is_unknown)
	local accumulated_ghost_bonus = managers.job:get_accumulated_ghost_bonus()
	if accumulated_ghost_bonus then
		local agb = accumulated_ghost_bonus and accumulated_ghost_bonus[i]
		if is_unknown then
			ghost:set_color(Color(64, 255, 255, 255) / 255)
		elseif i == managers.job:current_stage() then
			if not managers.groupai or not managers.groupai:state():whisper_mode() then
				ghost:set_color(Color(255, 255, 51, 51) / 255)
			else
				ghost:set_color(Color(128, 255, 255, 255) / 255)
			end
		elseif agb and agb.ghost_success then
			ghost:set_color(tweak_data.screen_colors.ghost_color)
		elseif i < managers.job:current_stage() then
			ghost:set_color(Color(255, 255, 51, 51) / 255)
		else
			ghost:set_color(Color(128, 255, 255, 255) / 255)
		end
	else
		ghost:set_color(Color(64, 255, 255, 255) / 255)
	end
end