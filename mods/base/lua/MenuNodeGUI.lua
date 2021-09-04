
CloneClass( MenuNodeGui )

Hooks:RegisterHook("CustomizeControllerOnKeySet")
function MenuNodeGui._key_press(self, o, key, input_id, item, no_add)

	if managers.system_menu:is_active() then
		return
	end

	if self._skip_first_activate_key then
		self._skip_first_activate_key = false
		if input_id == "mouse" then
			if key == Idstring("0") then
				return
			end
		elseif input_id == "keyboard" and key == Idstring("enter") then
			return
		end
	end

	local row_item = self:row_item(item)
	if key == Idstring("esc") then
		self:_end_customize_controller(o, item)
		return
	end

	if input_id ~= "mouse" or not Input:mouse():button_name_str(key) then
	end

	local key_name = "" .. Input:keyboard():button_name_str(key)
	if not no_add and input_id == "mouse" then
		key_name = "mouse " .. key_name or key_name
	end
	if key == Idstring("mouse wheel up") then
		key_name = "mouse wheel up"
	elseif key == Idstring("mouse wheel down") then
		key_name = "mouse wheel down"
	end

	local forbidden_btns = {
		"esc",
		"tab",
		"num abnt c1",
		"num abnt c2",
		"@",
		"ax",
		"convert",
		"kana",
		"kanji",
		"no convert",
		"oem 102",
		"stop",
		"unlabeled",
		"yen",
		"mouse 8",
		"mouse 9",
		""
	}

	if not key_name:is_nil_or_empty() then
		for _, btn in ipairs(forbidden_btns) do
			if Idstring(btn) == key then
				managers.menu:show_key_binding_forbidden({KEY = key_name})
				self:_end_customize_controller(o, item)
				return
			end
		end
	end

	local button_data = MenuCustomizeControllerCreator.CONTROLS_INFO[item:parameters().button]
	if not button_data then
		button_data = {
			text_id = "",
			category = "normal"
		}
	end
	local button_category = button_data.category
	local connections = managers.controller:get_settings(managers.controller:get_default_wrapper_type()):get_connection_map()
	for _, name in ipairs(MenuCustomizeControllerCreator.controls_info_by_category(button_category)) do
		local connection = connections[name]
		if connection._btn_connections then
			for name, btn_connection in pairs(connection._btn_connections) do
				if btn_connection.name == key_name and item:parameters().binding ~= btn_connection.name then
					managers.menu:show_key_binding_collision({
						KEY = key_name,
						MAPPED = managers.localization:text(MenuCustomizeControllerCreator.CONTROLS_INFO[name].text_id)
					})
					self:_end_customize_controller(o, item)
					return
				end
			end
		else
			for _, b_name in ipairs(connection:get_input_name_list()) do
				if tostring(b_name) == key_name and item:parameters().binding ~= b_name then
					managers.menu:show_key_binding_collision({
						KEY = key_name,
						MAPPED = managers.localization:text(MenuCustomizeControllerCreator.CONTROLS_INFO[name].text_id)
					})
					self:_end_customize_controller(o, item)
					return
				end
			end
		end
	end

	local connection = nil
	if item:parameters().axis then
		
		connections[item:parameters().axis]._btn_connections[item:parameters().button].name = key_name
		managers.controller:set_user_mod(item:parameters().connection_name, {
			axis = item:parameters().axis,
			button = item:parameters().button,
			connection = key_name
		})
		item:parameters().binding = key_name
		connection = connections[item:parameters().axis]

	else

		if connections[item:parameters().button] == nil then
			for k, v in pairs( connections ) do
				connections[item:parameters().button] = clone(v)
				break
			end
			connections[item:parameters().button]._name = item:parameters().connection_name
		end

		connections[item:parameters().button]:set_controller_id(input_id)
		connections[item:parameters().button]:set_input_name_list({key_name})
		managers.controller:set_user_mod(item:parameters().connection_name, {
			button = item:parameters().button,
			connection = key_name,
			controller_id = input_id
		})
		item:parameters().binding = key_name
		connection = connections[item:parameters().button]

	end

	if connection then
		local key_button = item:parameters().binding
		Hooks:Call( "CustomizeControllerOnKeySet", item:parameters().connection_name, key_button )
	end

	managers.controller:rebind_connections()
	self:_end_customize_controller(o, item)

end
