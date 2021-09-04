function changetime(data)
	for _,unit in pairs(World:find_units_quick("all", 1)) do
		local timer = unit:base() and unit:timer_gui() and unit:timer_gui()._current_timer
		if timer and math.floor(timer)~=-1 then
			local newvalue = data -- (new)
			unit:timer_gui():_start(newvalue)
			if managers.network:session() then
			managers.network:session():send_to_peers_synched("start_timer_gui", unit:timer_gui()._unit, newvalue)
			end
			-- we jamm it because the old drill sound stills, when we jamm it the old sound stops.
			if not unit:timer_gui()._jammed then
			unit:timer_gui():set_jammed(true)
			end
			if unit:timer_gui()._jammed then
			unit:timer_gui():set_jammed(false)
			end
			--managers.chat:_receive_message(1, "LOBBY", "Drills were set to "..data, tweak_data.system_chat_color)
		end
	end
end