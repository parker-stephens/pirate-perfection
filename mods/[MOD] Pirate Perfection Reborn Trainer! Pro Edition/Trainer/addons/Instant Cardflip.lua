function HUDLootScreen:begin_choose_card(peer_id, card_id)
	if not self._peer_data[peer_id].active then
		self._peer_data[peer_id].delayed_card_id = card_id

		return
	end

	print("YOU CHOSE " .. card_id .. ", mr." .. peer_id)

	local panel = self._peers_panel:child("peer" .. tostring(peer_id))

	panel:stop()
	panel:set_alpha(1)

	self._peer_data[peer_id].wait_t = 0
	local card_info_panel = panel:child("card_info")
	local main_text = card_info_panel:child("main_text")

	main_text:set_text(managers.localization:to_upper_text("menu_l_choose_card_chosen", {time = 0}))

	local _, _, _, hh = main_text:text_rect()

	main_text:set_h(hh + 2)

	local lootdrop_data = self._peer_data[peer_id].lootdrops
	local item_category = lootdrop_data[3]
	local item_id = lootdrop_data[4]
	local item_pc = lootdrop_data[6]
	local left_pc = lootdrop_data[7]
	local right_pc = lootdrop_data[8]

	if item_category == "weapon_mods" and managers.weapon_factory:get_type_from_part_id(item_id) == "bonus" then
		item_category = "weapon_bonus"
	end

	local cards = {}
	local card_one = card_id
	cards[card_one] = 3 or item_pc
	local card_two = #cards + 1
	cards[card_two] = left_pc
	local card_three = #cards + 1
	cards[card_three] = right_pc
	self._peer_data[peer_id].chosen_card_id = card_id
	local type_to_card = {
		weapon_mods = 2,
		materials = 5,
		colors = 6,
		safes = 8,
		cash = 3,
		masks = 1,
		xp = 4,
		textures = 7,
		drills = 9,
		weapon_bonus = 10
	}
	local card_nums = {
		"upcard_mask",
		"upcard_weapon",
		"upcard_cash",
		"upcard_xp",
		"upcard_material",
		"upcard_color",
		"upcard_pattern",
		"upcard_safe",
		"upcard_drill",
		"upcard_weapon_bonus"
	}

	for i, pc in ipairs(cards) do
		local my_card = i == card_id
		local card_panel = panel:child("card" .. i)
		local downcard = card_panel:child("downcard")
		local joker = pc == 0 and tweak_data.lootdrop.joker_chance > 0
		local card_i = my_card and type_to_card[item_category] or math.max(pc, 1)
		local texture, rect, coords = tweak_data.hud_icons:get_icon_data(card_nums[card_i] or "downcard_overkill_deck")
		local upcard = card_panel:bitmap({
			name = "upcard",
			halign = "scale",
			blend_mode = "add",
			valign = "scale",
			layer = 1,
			texture = texture,
			w = math.round(0.7111111111111111 * card_panel:h()),
			h = card_panel:h()
		})

		upcard:set_rotation(downcard:rotation())
		upcard:set_shape(downcard:shape())

		if joker then
			upcard:set_color(Color(1, 0.8, 0.8))
		end

		if coords then
			local tl = Vector3(coords[1][1], coords[1][2], 0)
			local tr = Vector3(coords[2][1], coords[2][2], 0)
			local bl = Vector3(coords[3][1], coords[3][2], 0)
			local br = Vector3(coords[4][1], coords[4][2], 0)

			upcard:set_texture_coordinates(tl, tr, bl, br)
		else
			upcard:set_texture_rect(unpack(rect))
		end

		upcard:hide()
	end

	panel:child("card" .. card_two):animate(callback(self, self, "flipcard"), 0)
	panel:child("card" .. card_three):animate(callback(self, self, "flipcard"), 0)

	self._peer_data[peer_id].wait_for_choice = nil
end

function HUDLootScreen:begin_flip_card(peer_id)
	self._peer_data[peer_id].wait_t = 0
	local type_to_card = {
		weapon_mods = 2,
		materials = 5,
		colors = 6,
		safes = 8,
		cash = 3,
		masks = 1,
		xp = 4,
		textures = 7,
		drills = 9,
		weapon_bonus = 10
	}
	local card_nums = {
		"upcard_mask",
		"upcard_weapon",
		"upcard_cash",
		"upcard_xp",
		"upcard_material",
		"upcard_color",
		"upcard_pattern",
		"upcard_safe",
		"upcard_drill",
		"upcard_weapon_bonus"
	}
	local lootdrop_data = self._peer_data[peer_id].lootdrops
	local item_category = lootdrop_data[3]
	local item_id = lootdrop_data[4]
	local item_pc = lootdrop_data[6]

	if item_category == "weapon_mods" and managers.weapon_factory:get_type_from_part_id(item_id) == "bonus" then
		item_category = "weapon_bonus"
	end

	local card_i = type_to_card[item_category] or math.max(item_pc, 1)
	local texture, rect, coords = tweak_data.hud_icons:get_icon_data(card_nums[card_i] or "downcard_overkill_deck")
	local panel = self._peers_panel:child("peer" .. tostring(peer_id))
	local card_info_panel = panel:child("card_info")
	local main_text = card_info_panel:child("main_text")

	main_text:set_text(managers.localization:to_upper_text("menu_l_choose_card_chosen", {time = 0}))

	local _, _, _, hh = main_text:text_rect()

	main_text:set_h(hh + 2)

	local card_panel = panel:child("card" .. self._peer_data[peer_id].chosen_card_id)
	local upcard = card_panel:child("upcard")

	upcard:set_image(texture)

	if coords then
		local tl = Vector3(coords[1][1], coords[1][2], 0)
		local tr = Vector3(coords[2][1], coords[2][2], 0)
		local bl = Vector3(coords[3][1], coords[3][2], 0)
		local br = Vector3(coords[4][1], coords[4][2], 0)

		upcard:set_texture_coordinates(tl, tr, bl, br)
	else
		upcard:set_texture_rect(unpack(rect))
	end

	self._peer_data[peer_id].chosen_card_id = nil
end