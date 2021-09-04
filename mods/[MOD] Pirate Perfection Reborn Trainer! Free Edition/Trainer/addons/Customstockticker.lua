-- Custom stock ticker...  now with Donations by Davy Jones
if TextTemplateBase then
	local ipairs = ipairs
	local pcall = pcall
	local tonumber = tonumber
	local tostring = tostring
	local type = type

	local rand = math.rand

	local s_find = string.find
	local s_format = string.format
	local s_gsub = string.gsub
	local s_reverse = string.reverse
	local s_split = string.split
	local s_sub = string.sub

	local t_insert = table.insert

	local Steam = Steam

	local function format_dec(input)
		if input == "--" then
			return input
		end
		local _, _, minus, int, dec = s_find(tostring(input), '([-]?)(%d+)([.]?%d*)')
		int = s_gsub(s_reverse(int), "(%d%d%d)", "%1,")
		return minus..s_gsub(s_reverse(int), "^,", "")..dec
	end

	function TextTemplateBase:_stock_ticker()
		for i = 1, self._unit:text_gui().ROWS do
			self._unit:text_gui():set_row_gap(i, 20)
			self._unit:text_gui():clear_row_and_guis(i)
			self._unit:text_gui():set_row_speed(i, i * 100)
		end
		local companies = {
			{"[TEC] E-peen", true},
			{"247 Kick You One Time", true},
			{"A-Fancy-Domain-Of-My-Choice.com", true},
			{"Analtech", true},
			{"Assmans Barber", true},
			{"B.J. Cummings Co.", true},
			{"Bass Drop Movers", true},
			{"Beaver Cleaners", true},
			{"Beaver Research", true},
			{"Bimbo Bakeries", true},
			{"Blaxican Fried Burritos Inc.", true},
			{"Blood-Island.com", true},
			{"Butamax", true},
			{"Camel Towing", true},
			{"Cash 22 Pawnbroker", true},
			{"Choosespain", true},
			{"Come On Baby", true},
			{"CopyCat Coders Co.", true},
			{"Couche Tard", true},
			{"Curl Up and Dye", true},
			{"Cyberdyne Systems", true},
			{"Deja Brew", true},
			{"Dingleberrys", true},
			{"Doge Style Pedigree", true},
			{"Donations Director", true},
			{"Dongs", true},
			{"Florist Gump", true},
			{"Fuk Mi Sushi Bar", true},
			{"Get Serious", true},
			{"Hand Jobs, Nails and Spa", true},
			{"Harfatus Engineering Ltd.", true},
			{"Harry Butz Day Spa", true},
			{"Hash House A Go Go", true},
			{"Hooker Cockram Inc.", true},
			{"Hooker Furniture", true},
			{"Houdini Hats", true},
			{"HoxHUD.com", true},
			{"I.C. Wiener Enterprises", true},
			{"Infamy Lingeri", true},
			{"iPoo", true},
			{"Juan In A Million", true},
			{"Kidsexchange", true},
			{"Kum and Go", true},
			{"Kuntz Insurance Group", true},
			{"Last Bullet Gaming", true},
			{"Lawn And Order", true},
			{"Lewd Leather", true},
			{"Lick-a-Chick", true},
			{"Lord Of The Fries", true},
			{"Master Bait and Tackle", true},
			{"Masters Brawlers", true},
			{"Masters Virtual Wonders", true},
			{"Merry Widow Life Insurance", true},
			{"Our Motherboard of Mercy", true},
			{"Over9000 Hypetrains", true},
			{"Parrotspeak.com", true},
			{"Pen Island", true},
			{"PHO Shizzle", true},
			{"PirateBiz", true},
			{"PirateNexus.com", true},
			{"PiratePerfection.com", true},
			{"Planet Of The Grapes", true},
			{"PocoCurante Infosystems", true},
			{"Poo Ping Palace", true},
			{"Pump 'n Munch", true},
			{"Queef Perfumes", true},
			{"RedNeck Perimeter Defence Corp.", true},
			{"Sandy Balls Country Club", true},
			{"Simplity Mods", true},
			{"Som Tang Wong Industries", true},
			{"South Andros", true},
			{"Speedofart", true},
			{"Spick and Span Window Cleaning", true},
			{"Stiff Nipples Air Conditioning", true},
			{"Stinky Stork Diaper Service", true},
			{"Surelock Holmes", true},
			{"TCN E-peen", true},
			{"Tequila Mockingbird", true},
			{"Thai Me Up", true},
			{"The Daily Grind", true},
			{"The Fryin Dutchman", true},
			{"The Glory Hole", true},
			{"TheBloodyFAQ.com", true},
			{"ThePirateBay.org", true},
			{"Threeway Express", true},
			{"Transcend Ltd.", true},
			{"unknownShits.me", true},
			{"Unlimited Erections LLC.", true},
			{"WE LOVE OVERKILL", true},
			{"WhoRepresents.com", true},
			{"Wok Around the Clock", true},
			{"Wok This Way", true},
			{"Wong, Doody, Crandall and Wiener", true},
			{"Yahpoo Plumbing", true},
			{"You Bed Your Life", true}
		}
		if not TextTemplateBase.STOCK_PERCENT then
			TextTemplateBase.STOCK_PERCENT = {}
			local bankruptcy_chance = rand(0.01)
			local bad_chance = rand(0.1)
			local good_chance = rand(0.1)
			local joker_chance = rand(0.01)
			local srand
			for i, company in ipairs(companies) do
				srand = 0
				if type(company) == "table" then
					if company[2] then
						srand = rand(100, 1000)
					else
						srand = rand(-1000, -500)
					end
				elseif bankruptcy_chance > rand(1) then
					srand = rand(-99, -45)
				elseif bad_chance > rand(1) then
					srand = rand(-55, -5)
				elseif good_chance > rand(1) then
					srand = rand(0, 40)
				elseif joker_chance > rand(1) then
					srand = rand(-100, 250)
				else
					srand = rand(-10, 10)
				end
				TextTemplateBase.STOCK_PERCENT[i] = srand
			end
		end
		for i, company in ipairs(companies) do
			local j = TextTemplateBase.STOCK_PERCENT[i]
			local row = math.mod(i, self._unit:text_gui().ROWS) + 1
			self._unit:text_gui():add_text(row, type(company) == "table" and company[1] or company, "white")
			self._unit:text_gui():add_text(row, "" .. (j < 0 and "" or "+") .. format_dec(s_format("%.2f", j)) .. "%", j < 0 and "light_red" or "light_green", self._unit:text_gui().FONT_SIZE / 1.5, "bottom", nil)
			self._unit:text_gui():add_text(row, "  ", "white")
		end
	end

	function TextTemplateBase:_big_bank_welcome()
		for i = 1, self._unit:text_gui().ROWS do
			self._unit:text_gui():clear_row_and_guis(i)
			self._unit:text_gui():set_row_gap(i, 50)
			self._unit:text_gui():set_row_speed(i, i * 200)
		end
		local function set_text(success, page)
			local texts = {}
			local texts2 = {}
			local function donation_display()
				page = s_split(s_gsub(s_gsub(s_gsub(s_gsub(s_gsub(page, "<.->", ""), "(.-)All Goals", "", 4), "Latest Goals(.*)", ""), "%$", ""), ",", ""), "\n")
				local sec_1 = "Latest Donations"
				local sec_2 = "Donations Director"
				local sec_3 = "Top Donors"
				local sec_4 = "View Top Donors"
				local sec_5 = "Donation Stats"
				local line = 1
				while page[line] ~= sec_1 do
					local title = page[line]
					while not s_find(page[line], " worth of booty collected") do
						line = line + 1
					end
					t_insert(texts, {title, s_gsub(page[line], " of(.*)", "")})
					line = line + 3
					if s_sub(page[line], 1, 8) == "IP.Board" then
						line = line + 1
					end
				end
				t_insert(texts2, sec_1)
				local function sec_2_check()
					while true do
						local text = page[line]
						if text == sec_2 then
							return false
						elseif s_sub(text, 1, 1) == " " and s_sub(text, -3, -3) == "." then
							return true
						else
							line = line + 1
						end
					end
				end
				while sec_2_check() do
					t_insert(texts2, {page[line - 1], s_gsub(page[line], " ", "")})
					line = line + 1
				end
				t_insert(texts2, sec_3)
				while page[line] ~= sec_3 do
					line = line + 1
				end
				line = line + 1
				while page[line] ~= sec_4 do
					t_insert(texts2, {page[line + 1], page[line]})
					line = line + 2
				end
				while page[line] ~= sec_5 do
					line = line + 1
				end
				t_insert(texts, {page[line + 1], page[line + 2]})
				t_insert(texts, {page[line + 5], page[line + 6]})
			end
			local use_default = true
			if success and s_find(s_sub(page, 0, 80), "All Goals") and pcall(donation_display) then
				use_default = false
			end
			if use_default then
				texts = {"We know how to hide your money", "Your money is our money", "Your money stays with us", "Give us your money right now", "Time to cash in?", "We love your money", "We suck for a buck", "Why so hilarious?", "A penny saved is still just a penny", "Robbing Joe Average since 1872", "Donate and get perks", "Why are you still reading this?", "Nothing to see here!", "Go on, rob the fuckers", "Dafuq did I just say, rob them already", "I give up, your too stubborn for me", "Now go rob the bank, ok?", "Thank you for your patience, We'll take your money now"}
				texts2 = {"Fencing", "Money Laundering", "Betting", "Pyramid Schemes", "Gold Bars", "No Questions Asked Deposits", "No Withdrawals", "Prostitution", "Scams", "VAT Carousels", "Creative Bookkeeping", "OCCUPY WALLSTREET"}
			end
			for _, text in ipairs(texts) do
				self._unit:text_gui():add_text(1, "    -    ", "green")
				self._unit:text_gui():add_text(1, "Welcome to the Blood Island Bank", "green")
				self._unit:text_gui():add_text(1, "    -    ", "green")
				self._unit:text_gui():add_text(1, use_default and text or text[1]..":", use_default and "green" or "orange")
				self._unit:text_gui():add_text(1, use_default and "" or "$"..format_dec(text[2]), "white")
			end
			for _, text in ipairs(texts2) do
				local t_type = type(text) == "table"
				if not t_type then
					self._unit:text_gui():add_text(2, "  -  ", "light_green")
				else
					self._unit:text_gui():add_text(2, "  ", "white")
				end
				self._unit:text_gui():add_text(2, (t_type and text[1] or text)..(use_default and "" or ":"), t_type and (text[2] == "--" and "white" or tonumber(text[2]) >= 25 and "yellow" or tonumber(text[2]) >= 5 and "red" or "light_blue") or "light_green")
				self._unit:text_gui():add_text(2, t_type and "$"..format_dec(text[2]) or "", "white")
			end
		end
		Steam:http_request("https://www.pirateperfection.com/donate/view-goals/", set_text)
	end
end