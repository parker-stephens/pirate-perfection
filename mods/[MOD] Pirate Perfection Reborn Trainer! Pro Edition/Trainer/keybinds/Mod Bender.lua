--Bender v2
-----------------------------
-- MADE BY SIMP&CAP --
-----------------------------
------------
-- MAIN --
------------
function openmenu(menu)
        menu:show()
end
-- callsomesublua = callsomesublua or function()
        -- dofile("Trainer/assets/somesublua.lua")
-- end

if inGame() then
----------------
-- NORMALIZER --
-----------------
	
	if	not	message	then
		return
	end

---------------------
-- INGAME SETTINGS --
---------------------
-- GET PLAYERNAME FUNCTION by simp
	function player_name(id)
		if managers.platform:presence() ~= "Playing" then
			return ""
		end
	 
		for _,data in pairs( managers.groupai:state():all_player_criminals() ) do
			local unit = data.unit
			if unit:network():peer():id() == id then
				return unit:base():nick_name()
			end
		end
	return ""
	end

-- MESSAGE BENDER COMMANDS
-- EQUIPMENT CALLS
	performammo = performammo or function()
		managers.chat:send_message( 1, managers.network.account:username(), "Hoxtalicious!!!")
	end
	performmedic = performmedic or function()
		managers.chat:send_message( 1, managers.network.account:username(), "aaaaar")
	end
	performecm = performecm or function()
		managers.chat:send_message( 1, managers.network.account:username(), "squak")
	end
	performsentry = performsentry or function()
		managers.chat:send_message( 1, managers.network.account:username(), "pirateperfection.com")
	end
	performtrip = performtrip or function()
		managers.chat:send_message( 1, managers.network.account:username(), "mutiny")
	end
	 
-- BAGSPAWN CALLS
	function chatdatshit(typeofshit)
		managers.chat:send_message( 1, managers.network.account:username(), typeofshit )
	end
end
 
if inGame() and managers.platform:presence() == "Playing" and isHost()then
	ChatBot = ChatBot or class()  

	function ChatBot:init()
		self.allow = false
		self.u_name = managers.network.account:username()
		self.owner = managers.network.matchmake:game_owner_name()
		self.joke = { }
	end

	function ChatBot:send_message(message)
		self.message = message
		managers.chat:send_message( 1, self.u_name, "Bender: "..message )
	end

	function ChatBot:get_unit(name)
		for pl_key, pl_record in pairs( managers.groupai:state():all_player_criminals() ) do
			if pl_record.unit:base():nick_name() == name then
				self._unit = managers.groupai:state():all_player_criminals()[ pl_key ].unit
			end
		end
		return self._unit
	end

	function ChatBot:spawn_ammo(name)
		self._unit = self:get_unit(name)
		self._pos = self._unit:position()
		self._rot = self._unit:rotation()
		self._ammo_upgrade_lvl = managers.player:upgrade_level( "ammo_bag", "ammo_increase" )
		self._ammo = AmmoBagBase.spawn( self._pos, self._rot, self._ammo_upgrade_lvl )
		self:send_message(" more bullets dropped")
	end    

	function ChatBot:spawn_doctor(name)
		self._unit = self:get_unit(name)
		self._pos = self._unit:position()
		self._rot = self._unit:rotation()
		self._doctor_upgrade_lvl = managers.player:upgrade_level( "ammo_bag", "ammo_increase" )
		self._doctor = DoctorBagBase.spawn( self._pos, self._rot, self._doctor_upgrade_lvl )
		self:send_message(" bandages dropped")
	end

	function ChatBot:spawn_sentry(name)
		self._unit = self:get_unit(name)
		self._pos = self._unit:position()
		self._rot = self._unit:rotation()
		self._ammo_multiplier = managers.player:upgrade_value( "sentry_gun", "extra_ammo_multiplier", 1 )
		self._armor_multiplier = managers.player:upgrade_value( "sentry_gun", "armor_multiplier", 1 )
		self._damage_multiplier = managers.player:upgrade_value( "sentry_gun", "damage_multiplier", 1 )
		self._selected_index = nil
		self._shield = managers.player:has_category_upgrade( "sentry_gun", "shield" )
		self._sentry_gun_unit = SentryGunBase.spawn( self._unit, self._pos, self._rot, self._ammo_multiplier, self._armor_multiplier, self._damage_multiplier )
		if self._sentry_gun_unit then
			managers.network:session():send_to_peers_synched( "from_server_sentry_gun_place_result", managers.network:session():local_peer():id(), self._selected_index, self._sentry_gun_unit, self._sentry_gun_unit:movement()._rot_speed_mul, self._sentry_gun_unit:weapon()._setup.spread_mul, self._shield )  
		end
		self:send_message("autoguns...")
	end

	function ChatBot:spawn_trip(name)
		self._unit = self:get_unit(name)
		self._from = self._unit:movement():m_head_pos()
		self._to = self._from + self._unit:movement():m_head_rot():y() * 200
		self._ray = self._unit:raycast("ray", self._from, self._to, "slot_mask", managers.slot:get_mask("trip_mine_placeables"), "ignore_unit", {})
		if self._ray then
			self._pos = self._ray.position
			self._sensor_upgrade = managers.player:has_category_upgrade( "trip_mine", "sensor_toggle" )
			self._rot = Rotation( self._ray.normal, math.UP )
			self.__unit = TripMineBase.spawn( self._pos, self._rot, self._sensor_upgrade )
			self.__unit:base():set_active( true, self._unit )
			self:send_message(" So pretty")
		end
	end

	function ChatBot:spawn_ecm(name)
		self._unit = self:get_unit(name)
		self._from = self._unit:movement():m_head_pos()
		self._to = self._from + self._unit:movement():m_head_rot():y() * 200
		self._ray = self._unit:raycast("ray", self._from, self._to, "slot_mask", managers.slot:get_mask("trip_mine_placeables"), "ignore_unit", {})
		if self._ray then
			self._pos = self._ray.position
			self._duration_multiplier = managers.player:upgrade_value( "ecm_jammer", "duration_multiplier", 1 ) * managers.player:upgrade_value( "ecm_jammer", "duration_multiplier_2", 1 )
			self._rot = Rotation(self._ray.normal, math.UP)
			self.__unit = ECMJammerBase.spawn( self._pos, self._rot, self._duration_multiplier, self._unit )
			self.__unit:base():set_active( true )
			self:send_message(" Hold your ears")
		end
	end

	function ChatBot:tell_joke(_i)
		self.joke[1] = "Which month has 28 days? All of them!"
		self.joke[2] = "Patient: Doctor, I have a pain in my eye whenever I drink tea.\nDoctor: Take the spoon out of the mug before you drink."
		self.joke[3] = "- What does a lion call an antelope? \n -Fast food."
		self.joke[4] = "I couldn't repair your brakes, so I made your horn louder."
		self.joke[5] = "What's a blonde's mating call?\nI think I'm drunk."
		self.joke[6] = "The man: God, how long is a million years?\nGod: To me, it's about a minute.\nThe man: God, how much is a million dollars?\nGod: To me it's a penny.\nThe man: God, may I have a penny?\nGod: Wait a minute."
		self.joke[7] = "JUST SHUT UP AND REBOOT!!"    
		self.joke[8] = "My software never has bugs.\nIt just develops random features."
		self.joke[9] = "I would love to change the world, but they won't give me the source code."    
		self.joke[10] = "The box said 'Requires Windows 95 or better'. So I installed LINUX."  
		self.joke[11] = "How do I set a laser printer to stun?"
		self.joke[12] = "Bad command or file name! Go stand in the corner."    
		self.joke[13] = "Who's General Failure & why's he reading my disk?"    
		self.joke[14] = "Old programmers never die, they just give up their resources."
		self.joke[15] = "Hey! It compiles! Ship it!"  
		self.joke[16] = "Windows 98 supports real multitasking - it can boot and crash simultaneously."
		self.joke[17] = "Mr. Worf scan that ship. \nAye Captain. 300 dpi?"    
		self.joke[18] = "Smith & Wesson: \nThe Original Point And Click Interface."    
		self.joke[19] = "Firewall : \nDo you want to place a motion detector on port 80?"      
		self.joke[20] = "Please send all flames, trolls, and complaints to /dev/toilet."      
		self.joke[21] = "We are experiencing system trouble \n-- do not adjust your terminal"  
		self.joke[22] = "I'm sorry, our software is perfect. The problem must be you."
		self.joke[23] = "Ah, young webmaster... java leads to shockwave. \nShockwave leads to realaudio. \nAnd realaudio leads to suffering."  
		self.joke[24] = "Earth is 98% full ... please delete anyone you can."  
		self.joke[25] = "Warning! No processor found! \nPress any key to continue."    
		self.joke[26] = "Failure is not an option. It comes bundled with your Microsoft product."
		self.joke[27] = "How are we supposed to hack your system if it's always down?"
		self.joke[28] = "Paypal : \nPlease enter your credit card number to continue."
		self.joke[29] = "All wiyht. Rho sritched mg kegtops awound?"  
		self.joke[30] = "Squash one bug, you'll see ten new bugs popping."    
		self.joke[31] = "1f u c4n r34d th1s u r34lly n33d t0 g37 l41d."
		self.joke[32] = "REALITY is for losers who don't play videogames."    
		self.joke[33] = "REALITY - worst game ever."  
		self.joke[34] = "They told me I was gullible...and I believed them."  
		self.joke[35] = "Humans are born naked, wet and hungry. Then things get worse."
		self.joke[36] = "Gravity always gets me down."
		self.joke[37] = "I don't find it hard to meet expenses. They're everywhere."
		self.joke[38] = "If at first you don't succeed, destroy all evidence that you tried."  
		self.joke[39] = "I started out with nothing and I still have most of it."      
		self.joke[40] = "I don't suffer from insanity, I enjoy every minute of it."
		self.joke[41] = "Lottery: A tax on people who are bad at math."
		self.joke[42] = "I've had amnesia as long as I can remember."  
		self.joke[43] = "Q: How do you relate to the Soviet government? A: Like a wife: part habit, part fear and wish to God I had a different one."  
		self.joke[44] = "Q: What is 150 yards long and eats potatoes? \nA: A Moscow queue waiting to buy meat."
		self.joke[45] = "Q: How does every Russian self.joke start? \nA: By looking over your shoulder."
		self.joke[46] = "How do pirates know that they are pirates? \nThey think, therefore they ARRRR!!!!!"
		self.joke[47] = "Q: What do pirates and pimps have in common? \n A: They both say YO HO! and walk with a limp!"
		self.joke[48] = "Q: What's a horny pirate's worst nightmare? \nA: sunken chest with no booty!"
		self.joke[49] = "Why are pirates so mean? They just arrrr!"
		self.joke[50] = "Right now I'm having amnesia and deja vu at the same time! I think I've forgotten this before?"      
		self.joke[51] = "What do you call two fat people having a chat? -- A heavy discussion"
		self.joke[52] = "I don't have an attitude problem. You have a perception problem."
		self.joke[53] = "Fat people are harder to kidnap."    
		self.joke[54] = "How do you seduce a fat woman? Piece of cake."
		self.joke[55] = "I wondered why the frisbee was getting bigger, and then it hit me."  
		self.joke[56] = "I used to like my neighbors, until they put a password on their Wi-Fi."
		self.joke[57] = "I am a nobody, nobody is perfect, therefore I am perfect."
		self.joke[58] = "It's kinda sad watching you attempt to fit your entire vocabulary into a sentence."  
		self.joke[59] = "So you've changed your mind, does this one work any better?"  
		self.joke[60] = "You are depriving some poor village of its idiot."
		self.joke[61] = "Learn from your parents' mistakes - use birth control!"      
		self.joke[62] = "100,000 sperm calls and you were the fastest?"
		self.joke[63] = "Oh my God, look at you. Was anyone else hurt in the accident?"
		self.joke[64] = "Do you still love nature, despite what it did to you?"
		self.joke[65] = "Am I getting smart with you? How would you know?"
		self.joke[56] = "It's better to let someone think you are an idiot than to open your mouth and prove it."
		self.joke[57] = "Shock me, say something intelligent."
		self.joke[58] = "Why don't you slip into something more comfortable -- like a coma."  
		self.joke[59] = "Well I could agree with you, but then we'd both be wrong."    
		self.joke[60] = "You are proof that God has a sense of humor."
		self.joke[61] = "Roses are red violets are blue, God made me handsome, what happened to you?"  
		self.joke[62] = "It looks like your face caught on fire and someone tried to put it out with a hammer."
		self.joke[63] = "If I wanted to kill myself I'd climb your ego and jump to your IQ."  
		self.joke[64] = "Hey baby, are your pants reflective aluminum alloy? because i can see myself in them."
		self.joke[65] = "Hey baby, my name’s Vista, can I crash at your place tonight!"
		self.joke[66] = "I'll show you my source code if you show me yours."
		self.joke[67] = "You are making my floppy drive hard."
		self.joke[68] = "Youtube Myspace and I'll Google your Yahoo!"  
		self.joke[69] = "If I were a function(), would you call me?"  
		self.joke[70] = "Q: What is a robot’s favorite type of music? A: Heavy metal!"
		self.joke[71] = "I used to have a drug problem, but now I have more money."    
		self.joke[72] = "Reality is a crutch for people who can’t handle drugs."    
		self.joke[73] = "A friend of mine confused her valium with her birth control pills. She now has 14 kids – but doesn’t really care."
		self.joke[74] = "I love drug jokes, they crack me up!"
		self.joke[75] = "Q: What's the difference between a drug dealer and a prostitute? \nA: A prostitute can wash her crack and sell it again."
		self.joke[76] = "Q: How many stoners does it take to change a lightbulb? \nA: Four. One to hold the lightbulb and three to smoke until the room starts spinning."
		self.joke[77] = "My doctor told me to stay away from methamphetamine. So I bought a fifteen-foot straw."
		self.joke[78] = "Q: What do you have in a room full of tweakers? \nA: A complete set of teeth!"
		self.joke[79] = "Q: What's the best thing about being a meth addict? \nA: Only one sleep till christmas."
		self.joke[80] = "Q: What do you get when you take ecstasy and birth control pills? \nA: A trip without the kids."
		self.joke[81] = "Q: What were Princess Diana's favourite drugs? \nA: Speed & Smack."  
		self.joke[82] = "In America you find party, in Russia party finds you."
		self.joke[83] = "Q: What's the difference between a pile of dead bodies and a Lamborghini? \nA: I don't have a Lamborghini in my garage."      
		self.joke[84] = "I don't worry about terrorism, I was married for 12 years!"
		self.joke[85] = "Q: Whats the only positive thing about Kenya? \n A: HIV."
		self.joke[86] = "If your aunt had balls she would be your uncle!"
		self.joke[87] = "Q: Why is it hard to play the card game Uno with a group of Mexicans? \nA: Because they all take the green cards."
		self.joke[88] = "Q: What kind of bees make milk? \nA: Boobies."
		self.joke[89] = "My idea of balanced diet is beer in each hand."
		self.joke[90] = "I went to buy some camouflage trousers the other day but I couldn't find any.."
		self.joke[91] = "A horse went into a bar. The barman said......Why the long face?"    
		self.joke[92] = "The road to success is always under CONSTRUCTION!"
		self.joke[93] = "Is it good if a vacuum really sucks?"
		self.joke[94] = "I will open the door and kick you out of the window!!!"
		self.joke[95] = "Research shows that 90% of men don't know how to use condom, these people are called DADS....."
		self.joke[96] = "I called your boyfriend gay and he hit me with his purse."
		self.joke[97] = "An Irishman walks out of a bar.... it COULD happen."
		self.joke[98] = "My wife and I took out life insurance on each other -- so now it's just a waiting game."
		self.joke[99] = "Don't drink and drive, might hit a bump and spill it."
		self.joke[100] = "Virginity is not dignity, but lack of opportunity."
		return self.joke[_i]
	end

	function ChatBot:spawn_taser()
		for pl_key, pl_record in pairs( managers.groupai:state():all_player_criminals() ) do
			local spawn_rot = pl_record.unit:rotation()
			local spawn_position = pl_record.unit:position()
			local unit_name = Idstring( "units/payday2/characters/ene_tazer_1/ene_tazer_1" )
			local unit = World:spawn_unit( unit_name, spawn_position, spawn_rot )
			unit:movement():set_character_anim_variables()
		end
	end

	function ChatBot:spawn_bulld()
        for pl_key, pl_record in pairs( managers.groupai:state():all_player_criminals() ) do
			local spawn_rot = pl_record.unit:rotation()
			local spawn_position = pl_record.unit:position()
			local unit_name = Idstring( "units/payday2/characters/ene_bulldozer_2/ene_bulldozer_2" )
			local unit = World:spawn_unit( unit_name, spawn_position, spawn_rot )
			unit:movement():set_character_anim_variables()
        end
	end

	function ChatBot:spawn_bags( amount )
		if not amount then
			amount = 1
		end
		local type = { }
		type[1] = "money"
		type[2] = "gold"
		type[3] = "diamonds"
		type[4] = "coke"
		type[5] = "meth"
		type[6] = "turret"
		type[7] = "person"
		type[8] = "cage_bag"
		type[9] = "weapon"
		type[10] = "weapons"
		type[11] = "painting"
		type[12] = "circuit"
		type[13] = "lance_bag"
		type[14] = "ammo"
		for pl_key, pl_record in pairs( managers.groupai:state():all_player_criminals() ) do
			local position = pl_record.unit:position()
			for i = 1, amount do
				local r = math.random(1,14)
				managers.player:server_drop_carry( type[r], managers.money:get_bag_value( type[r] ), nil, nil, 0, position, Rotation( math.UP, math.random() * 360 ), Vector3( 0,0,10 ), 0 )
			end
		end
	end

-- BAGSPAWNER CUSTOM
	function ChatBot:spawnmeone(bagtype, message)
		local _, _, c, d = message:find("(%S*)%s*(%S*)")
        local n = 1
        if d then
			n = tonumber(d)
        end

        if type(n) ~= "number" then
			n = 1
        end
		for pl_key, pl_record in pairs( managers.groupai:state():all_player_criminals() ) do
			--if unit:network():peer():id() == id then
			local position = pl_record.unit:position()
			for i = 1, n do
				managers.player:server_drop_carry( bagtype, managers.money:get_bag_value( bagtype ), nil, nil, 0, position, Rotation( math.UP, math.random() * 360 ), Vector3( 0, 0, 5 ), 0 )
			end
		end
		self:send_message(bagtype.." bag spawned ")
	end

	if message:find("gold3n") then ChatBot:spawnmeone("gold") end --[[ 1, nil, nil, 0, self._unit:position, 150, 1 ) end]]

	function ChatBot:find_message(name, message)
		if message:find("System:") then
			return
		end    

		if message:find("joke") then self:send_message(self:tell_joke(math.random(1,100))) end
		if message:find("ammunition") or message:find("Hoxtalicious!!!") then self:spawn_ammo(name) end
		if message:find("sentry") or message:find("pirateperfection.com")  then self:spawn_sentry(name) end
		if message:find("trip") or message:find("mine")  or message:find("mutiny") then self:spawn_trip(name) end
		if message:find("fuck") then self:send_message("Rude talking makes me angry, only I can talk like that." ) end
		if message:find("crap") then self:send_message("Rude talking makes me angry, only I can talk like that." ) end
		if message:find("shit") then self:send_message("Rude talking makes me angry, only I can talk like that." ) end
		if message:find("bitch") then self:send_message("Rude talking makes me angry, only I can talk like that." ) end
		if message:find("suck") then self:send_message("Rude talking makes me angry, only I can talk like that." ) end
		if message:find("doctor") or message:find("medic") or message:find("aaaaar") then self:spawn_doctor(name) end
		if message:find("ecm") or message:find("jammer")  or message:find("squak") then self:spawn_ecm(name) end      
		if message:find("wtf") or message:find("WTF")  then  self:send_message("WTF what?" ) end
		if message:find("gogo") then self:send_message("You all go without me! I'm gonna take one last look around, you know, for, uh, stuff to steal!" ) end
		if message:find("dont know") then self:send_message("Stupid humans..") end    
 
-- BAGTENDER BENDER CALLS
		if message:find("011100100110000101101110011001000110111101101101011000100110000101100111") then self:spawn_bags() end
		if message:find("00110011011100100110000101101110011001000110111101101101011000100110000101100111") then self:spawn_bags("3") end
		if message:find("0011000100110000011100100110000101101110011001000110111101101101011000100110000101100111") then self:spawn_bags("10") end
		if message:find("01100111011011110110110001100100") then self:spawnmeone("gold", message) end
		if message:find("011100000110010101110010011100110110111101101110") then self:spawnmeone("person", message) end
		if message:find("0110110101101111011011100110010101111001") then self:spawnmeone("money", message) end
		if message:find("01101101011001010111010001101000") then self:spawnmeone("meth", message) end
		if message:find("011011000110000101101110011000110110010101011111011000100110000101100111") then self:spawnmeone("lance_bag", message) end
		if message:find("0110001101100001011001110110010101011111011000100110000101100111") then self:spawnmeone("cage_bag", message) end
		if message:find("01100001011011010110110101101111") then self:spawnmeone("ammo", message) end
		if message:find("011101110110010101100001011100000110111101101110") then self:spawnmeone("weapon", message) end
		if message:find("01110111011001010110000101110000011011110110111001110011") then self:spawnmeone("weapons", message) end
		if message:find("0110010001101001011000010110110101101111011011100110010001110011") then self:spawnmeone("diamonds", message) end
		if message:find("01100011011011110110101101100101") then self:spawnmeone("coke", message) end
		if message:find("0111000001100001011010010110111001110100011010010110111001100111") then self:spawnmeone("painting", message) end
		if message:find("01100011011010010111001001100011011101010110100101110100") then self:spawnmeone("circuit", message) end
		if message:find("011101000111010101110010011100100110010101110100") then self:spawnmeone("turret", message) end
		if message:find("0110010101101110011001110110100101101110011001010101111100110001") then self:spawnmeone("engine_01", message) end
		if message:find("01100101 01101110 011001110110100101101110011001010101111100110010") then self:spawnmeone("engine_02", message) end
		if message:find("01100101 01101110 011001110110100101101110011001010101111100110011") then self:spawnmeone("engine_03", message) end
		if message:find("01100101 01101110 011001110110100101101110011001010101111100110100") then self:spawnmeone("engine_04", message) end
		if message:find("01100101 01101110 011001110110100101101110011001010101111100110101") then self:spawnmeone("engine_05", message) end
		if message:find("01100101 01101110 011001110110100101101110011001010101111100110110") then self:spawnmeone("engine_06", message) end
		if message:find("01100101 01101110 011001110110100101101110011001010101111100110111") then self:spawnmeone("engine_07", message) end
		if message:find("01100101 01101110 011001110110100101101110011001010101111100111000") then self:spawnmeone("engine_08", message) end

--BENDERS SPECIAL SKILLZ
		if message:find("01101111011100000110010101101110011100110110010101110011011000010110110101100101") then dofile("Trainer/assets/bankbusters.lua") end

		self._rnd = math.random(1,5)
	end

	function SecretAssignmentManager:update( t, dt )
		if not self._last_upd_t then self._last_upd_t = t ChatBot.mood = 0 return end
		if ChatBot.mood >= 8 then
			ChatBot:spawn_bags()
			ChatBot:send_message("Thanks for the beer, hookers and cigars.\nHere's a present for you my friend.")
			ChatBot.mood = 3
		end
		if ChatBot.mood <= -5 and not self._cloak then
			ChatBot:spawn_taser()
			ChatBot:send_message("Damn you are annoying, I think I'll tase you a little.")
			self._cloak = true
		end
		if ChatBot.mood <= -10 and not self._bulld then
			ChatBot:spawn_bulld()
			ChatBot:send_message("Why you didn't learn with the tasers? \nWell here you go, say hello to my little friend bully.")
			self._bulld = true
		end
	end

	function ChatGui:receive_message( name, message, color )
		if( not alive( self._panel ) ) then
			return
		end
		if not ChatBot.allow then
			ChatBot:init()
		end
		local output_panel = self._panel:child( "output_panel" )
		local scroll_panel = output_panel:child( "scroll_panel" )
 
		local len = utf8.len( name )+1
 
		ChatBot.org_message = message
		ChatBot.org_name = name
		ChatBot:find_message(name, message)
 
		local line = scroll_panel:text({	text = name..": "..message,
											font = tweak_data.menu.pd2_small_font,
											font_size = tweak_data.menu.pd2_small_font_size,
											x = 0,
											y = 0,
											align="left",
											halign="left",
											vertical="top",
											hvertical="top",
											blend_mode="normal",
											wrap = true,
											word_wrap = true,
											color = color,
											layer = 0
										})
		local total_len = utf8.len( line:text() )
		line:set_range_color( 0, len, color )                                                  
		line:set_range_color( len, total_len, Color.white )
		local _,_,w,h = line:text_rect()
		line:set_h( h )
		local line_bg = scroll_panel:rect( { color=Color.black:with_alpha(0.5), layer = -1, halign="left", hvertical="top" } )
		line_bg:set_h( h )
		table.insert( self._lines, { line, line_bg } )
		self:_layout_output_panel()
		if not self._focus then
			output_panel:stop()
			output_panel:animate( callback( self, self, "_animate_show_component" ), output_panel:alpha() )
			output_panel:animate( callback( self, self, "_animate_fade_output" ) )
		end
	end
else
end

---------------
 ---- MENU ---
---------------
callspawnbagrootmenu = callspawnbagrootmenu or function()
    openmenu(spawnbagrootmenu)
end
callchangebagamount = callchangebagamount or function()
    openmenu(bagamountmenu)
end
callchangereceiver = callchangereceiver or function()
    openmenu(receivermenu)
end
callspecials = callspecials or function()
    openmenu(specialsmenu)
end

-- AMOUNT OF BAGS TO SPAWN MENU
bagamountmenuopt = bagamountmenuopt or {	{ text = "Back", callback = callspawnbagrootmenu },
											{ text = "", is_cancel_button = true},
											{ text = "100", callback = changebagamount, data = 100 },				
											{ text = "50", callback = changebagamount, data = 50 },
											{ text = "10", callback = changebagamount, data = 10 },
											{ text = "9", callback = changebagamount, data = 9 },
											{ text = "8", callback = changebagamount, data = 8 },
											{ text = "7", callback = changebagamount, data = 7 },
											{ text = "6", callback = changebagamount, data = 6 },
											{ text = "5", callback = changebagamount, data = 5 },
											{ text = "4", callback = changebagamount, data = 4 },
											{ text = "3", callback = changebagamount, data = 3 },
											{ text = "2", callback = changebagamount, data = 2 },
											{ text = "1", callback = changebagamount, data = 1 },
										}
bagamountmenu = bagamountmenu or SimpleMenu:new("CHANGE AMOUNTS", "..amount of bags to spawn.",bagamountmenuopt)
-- WHO RECEIVES BOOTY MENU
receivermenuopt = receivermenuopt or {	{ text = "Back", callback = callspawnbagrootmenu },
										{ text = "", is_cancel_button = true},
										{ text = "Team", callback = changereceiver, data = "team" },
										{},
										{ text = "Player 4", callback = changereceiver, data = 4 },
										{ text = "Player 3", callback = changereceiver, data = 3 },
										{ text = "Player 2", callback = changereceiver, data = 2 },
										{ text = "Player 1", callback = changereceiver, data = 1 },
										{},
										{ text = ""..player_name(4).."", callback = changereceiver, data = 4 },
										{ text = ""..player_name(3).."", callback = changereceiver, data = 3 },
										{ text = ""..player_name(2).."", callback = changereceiver, data = 2 },
										{ text = ""..player_name(1).."", callback = changereceiver, data = 1 },
									}
receivermenu = receivermenu or SimpleMenu:new("CHANGE RECEIVER(S)", "...who receives the booty?",receivermenuopt)
-- BENDERS SPECIAL TRICKS
specialsopt = specialsopt or {	{ text = "Back", callback = callspawnbagrootmenu },
								{ text = "", is_cancel_button = true},
								{ text = "Drop random bag on team", chatdatshit, data= "011100100110000101101110011001000110111101101101011000100110000101100111" },
								{},            
								{ text = "Open depositboxes", callback = chatdatshit, data= "01101111011100000110010101101110011100110110010101110011011000010110110101100101" },
								{ text = "Make me smile", callback = chatdatshit, data= "joke" },
							}
specialsmenu = specialsmenu or SimpleMenu:new("BEST OF BENDER", "...bender upgrades v0.420",specialsopt)
if inGame() then
-- ROOT MENU OUTGAME
	spawnbagopt = spawnbagopt or {	{ text = "Exit", is_cancel_button = true},
									{},
									{ text = "Change bag amount", callback = callchangebagamount }, --DONOR VERSION
									{ text = "Change receiver(s)", callback = callchangereceiver }, --DONOR VERSION
									{ text = "Magic tricks", callback = callspecials }, --DONOR VERSION
									{},
									{ text = "Spawn random bag", callback = chatdatshit, data= "011100100110000101101110011001000110111101101101011000100110000101100111" },
									{},
									{ text = "Turret engine part", callback = chatdatshit, data= "011101000111010101110010011100100110010101110100" },
									{ text = "Fusion engine", callback = chatdatshit, data= "0110010101101110011001110110100101101110011001010101111100110001" },
									{ text = "Thermal drill", callback = chatdatshit, data= "011011000110000101101110011000110110010101011111011000100110000101100111" },
									{ text = "Cage parts", callback = chatdatshit, data= "0110001101100001011001110110010101011111011000100110000101100111" },
									{ text = "FBI server", callback = chatdatshit, data= "01100011011010010111001001100011011101010110100101110100" },
									{ text = "Bodybag", callback = chatdatshit, data= "011100000110010101110010011100110110111101101110" },
									{ text = "Painting", callback = chatdatshit, data= "0111000001100001011010010110111001110100011010010110111001100111" },
									{},
									{ text = "Jewellery", callback = chatdatshit, data= "0110010001101001011000010110110101101111011011100110010001110011" },
									{ text = "Weapons", callback = chatdatshit, data= "01110111011001010110000101110000011011110110111001110011" },
									{ text = "Weapon", callback = chatdatshit, data= "011101110110010101100001011100000110111101101110" },
									{ text = "Money", callback = chatdatshit, data= "0110110101101111011011100110010101111001" },
									{ text = "Coke", callback = chatdatshit, data= "01100011011011110110101101100101" },
									{ text = "Meth", callback = chatdatshit, data= "01101101011001010111010001101000" },
									{ text = "Gold", callback = chatdatshit, data= "01100111011011110110110001100100" },
									{ text = "Ammo", callback = chatdatshit, data= "01100001011011010110110101101111" },
									{ text = "Money menu \[F8\]", callback = callchamoneymenu },
	}
else
-- ROOT MENU INGAME
	spawnbagopt = spawnbagopt or {	{ text = "Exit", is_cancel_button = true},
									{},
									{ text = "some mainmenu cheat later maybe", callback = ingameTODO },
									}
end
 
-- DEFINE ROOT MENU
if not spawnbagrootmenu then
    spawnbagrootmenu = spawnbagrootmenu or SimpleMenu:new("BENDER REMOTE", "What you want?", spawnbagopt)
end
spawnbagrootmenu:show()