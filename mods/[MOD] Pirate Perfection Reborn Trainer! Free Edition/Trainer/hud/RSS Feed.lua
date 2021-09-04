NewsFeedGui = NewsFeedGui or class(TextBoxGui)

NewsFeedGui.URLS = {"https://www.pirateperfection.com/discover/all.xml","http://pp4pd2.tumblr.com/rss"}
NewsFeedGui.fixNumbers = { }
NewsFeedGui.PRESENT_TIME = 0.5
NewsFeedGui.SUSTAIN_TIME = 6
NewsFeedGui.REMOVE_TIME = 0.5
NewsFeedGui.MAX_NEWS = 40 -- max news to load from every source
NewsFeedGui.MAX_NEWS_SHOW = 20 -- sources get equal number of news in show list
NewsFeedGui.MIX = false -- if not mixed, news will be shown in the order of their URLs

local cp1251=	{	[128]='\208\130',
					[129]='\208\131',
					[130]='\226\128\154',
					[131]='\209\147',
					[132]='\226\128\158',
					[133]='\226\128\166',
					[134]='\226\128\160',
					[135]='\226\128\161',
					[136]='\226\130\172',
					[137]='\226\128\176',
					[138]='\208\137',
					[139]='\226\128\185',
					[140]='\208\138',
					[141]='\208\140',
					[142]='\208\139',
					[143]='\208\143',
					[144]='\209\146',
					[145]='\226\128\152',
					[146]='\226\128\153',
					[147]='\226\128\156',
					[148]='\226\128\157',
					[149]='\226\128\162',
					[150]='\226\128\147',
					[151]='\226\128\148',
					[152]='\194\152',
					[153]='\226\132\162',
					[154]='\209\153',
					[155]='\226\128\186',
					[156]='\209\154',
					[157]='\209\156',
					[158]='\209\155',
					[159]='\209\159',
					[160]='\194\160',
					[161]='\209\142',
					[162]='\209\158',
					[163]='\208\136',
					[164]='\194\164',
					[165]='\210\144',
					[166]='\194\166',
					[167]='\194\167',
					[168]='\208\129',
					[169]='\194\169',
					[170]='\208\132',
					[171]='\194\171',
					[172]='\194\172',
					[173]='\194\173',
					[174]='\194\174',
					[175]='\208\135',
					[176]='\194\176',
					[177]='\194\177',
					[178]='\208\134',
					[179]='\209\150',
					[180]='\210\145',
					[181]='\194\181',
					[182]='\194\182',
					[183]='\194\183',
					[184]='\209\145',
					[185]='\226\132\150',
					[186]='\209\148',
					[187]='\194\187',
					[188]='\209\152',
					[189]='\208\133',
					[190]='\209\149',
					[191]='\209\151'
				}

cp1251_utf8 = function(s)
	local r, b = ''
	for i = 1, s and s:len() or 0 do b = s:byte(i)
		if b < 128 then r = r..string.char(b)
			else
			if b > 239 then
				r = r..'\209'..string.char(b-112)
				elseif b > 191 then
					r = r..'\208'..string.char(b-48)
				elseif cp1251[b] then
					r = r..cp1251[b]
				else r = r..'_'
			end
		end
	end
	return r
end

function NewsFeedGui:init(ws)
	self._ws = ws
	self:_create_gui()
	self:make_news_request()
end

function NewsFeedGui:update(t, dt)
	--log("[Pirate Perfection Reborn RSS Feed] UPDATING")
	if not self._titles then
		return
	end
	if self._news and #self._titles > 0 then
		local color = math.lerp(tweak_data.screen_colors.button_stage_2, tweak_data.screen_colors.button_stage_3, (1 + math.sin(t * 360)) / 2)
		self._title_panel:child("title"):set_color(self._mouse_over and tweak_data.screen_colors.button_stage_2 or color)
		if self._next then
			self._next = nil
			self._news.i = self._news.i + 1
			if self._news.i > #self._titles then
				self._news.i = 1
			end
			self._title_panel:child("title"):set_text(utf8.to_upper("(" .. self._news.i .. "/" .. #self._titles .. ") " .. self._titles[self._news.i]))
			local _, _, w, h = self._title_panel:child("title"):text_rect()
			self._title_panel:child("title"):set_h(h)
			self._title_panel:set_w(w + 10)
			self._title_panel:set_h(h)
			self._title_panel:set_left(self._panel:w())
			self._title_panel:set_bottom(self._panel:h())
			self._present_t = t + self.PRESENT_TIME
		end
		if self._present_t then
			self._title_panel:set_left(0 - (managers.gui_data:safe_scaled_size().x + self._title_panel:w()) * ((self._present_t - t) / self.PRESENT_TIME))
			if t > self._present_t then
				self._title_panel:set_left(0)
				self._present_t = nil
				self._sustain_t = t + self.SUSTAIN_TIME
			end
		end
		if self._sustain_t and t > self._sustain_t then
			self._sustain_t = nil
			self._remove_t = t + self.REMOVE_TIME
		end
		if self._remove_t then
			self._title_panel:set_left(0 - (managers.gui_data:safe_scaled_size().x + self._title_panel:w()) * (1 - (self._remove_t - t) / self.REMOVE_TIME))
			if t > self._remove_t then
				self._title_panel:set_left(0 - (managers.gui_data:safe_scaled_size().x + self._title_panel:w()))
				self._remove_t = nil
				self._next = true
			end
		end
	end
	--log("[Pirate Perfection Reborn RSS Feed] UPDATED")
end

NewsFeedGui.busy = false

function NewsFeedGui:make_news_request()
	print("make_news_request()")
	if self.urlNumber == nil then
		self.urlNumber = 1
		if self.MAX_NEWS_SHOW < #self.URLS then
			self.MAX_NEWS_SHOW = #self.URLS
		end
	end
	for i = 1, #self.URLS do
			Steam:http_request(self.URLS[i], callback(self, self, "news_result"))
			
	end
	Steam:http_request( "http://pp4pd2.tumblr.com/rss", callback( self, self, "news_result" ) )
end

function NewsFeedGui:news_result(success, body)
	for i = 1, 1000000 do
		if not self.busy then break end
	end
	self.busy = true
	print("news_result()", success)
	if not alive(self._panel) then
		return
	end
	if success then
		self._titles = self:_get_text_block(body, "<title>", "</title>", self.MAX_NEWS)
		self._links = self:_get_text_block(body, "<link>", "</link>", self.MAX_NEWS)
		local titles = {}
		local links = {}
		--log("[Pirate Perfection Reborn RSS FEED] parsing a source")
		if string.match(body, "</link>") then
			--log("[Pirate Perfection Reborn RSS FEED] </link>")
			titles = self:_get_text_block(body, "<title>", "</title>", self.MAX_NEWS, true)
			links = self:_get_text_block(body, "<link>", "</link>", self.MAX_NEWS, true)
		elseif string.match(body, "<link href=\"") then
			titles = self:_get_text_block(body, "</updated><title>", "</title></entry>", self.MAX_NEWS, false)
			links = self:_get_text_block(body, "<link href=\"", "\" /><updated>", self.MAX_NEWS, false)
		elseif string.match(body, "<link rel=\"alternate\" href=\"") then
			titles = self:_get_text_block(body, "<title>", "</title>", self.MAX_NEWS, true, "entry")
			links = self:_get_text_block(body, "<link rel=\"alternate\" href=\"", "\"/>", self.MAX_NEWS, true, "entry")
		else
			return
		end
		--log("[Pirate Perfection Reborn RSS FEED] parsed")
		if titles == nil or #titles == 0 then
			return
		end
		local nums = {}
		for i = 1, self.MAX_NEWS do
			nums[i] = false
		end
		--log("[Pirate Perfection Reborn RSS FEED] choosing (" .. #titles .. " titles, " .. #links .. " links)")
		for i = 1, self.MAX_NEWS_SHOW/#self.URLS do
			local num = math.random(#titles)
			while nums[num] ~= false do
				num = num + 1
				if num > #titles then
					num = 1
				end
			end

			nums[num] = true
		end
		--log("[Pirate Perfection Reborn RSS FEED] chosen")
		if self.urlNumber == 1 then
			self._titles = {}
			self._links = {}
			--local counter = 1
			for i = 1, self.MAX_NEWS do
				if nums[i] ~= false and titles[i] ~= nil then
					titles[i] = "1 &quot 2 &#039; 3 &#8217; 4 &amp;"
					self._titles[#self._titles+1] = titles[i]:gsub("&#%d+;", "'")
												:gsub("&quot;", "'")
												:gsub("&amp;", "&")
												:gsub("<!%[CDATA%[", "")
												:gsub("]]>", "")
												:gsub("&apos;", "'")
												:gsub("_", "'")
												
					for j=1, #self.fixNumbers do
						if self.fixNumbers[j] == self.urlNumber then
							self._titles[#self._titles] = cp1251_utf8(self._titles[#self._titles]);
						end
					end
					
					self._links[#self._links+1] = links[i]
					--log("[Pirate Perfection Reborn RSS FEED] " .. links[i])
					--counter = counter + 1
				end
			end
		else
			for i = 1, self.MAX_NEWS do
				if nums[i] ~= false and titles[i] ~= nil then
					self._titles[#self._titles+1] = titles[i]:gsub("&#%d+;", "'")
												:gsub("&quot;", "'")
												:gsub("&amp;", "&")
												:gsub("<!%[CDATA%[", "")
												:gsub("]]>", "")
												:gsub("&apos;", "'")
												:gsub("_", "'")
												
					for j=1, #self.fixNumbers do
						if self.fixNumbers[j] == self.urlNumber then
							self._titles[#self._titles] = cp1251_utf8(self._titles[#self._titles]);
						end
					end
					
					self._links[#self._links+1] = links[i]
				end
			end
		end
		
		if self.urlNumber == #self.URLS then

			if self.MIX then
			--log("[Pirate Perfection Reborn RSS FEED] mixing starts")
				for i = 1, #self._titles, 2 do
					local num = math.random(#self._titles)
					local temp_title = self._titles[num]
					local temp_link = self._links[num]
					self._titles[num] = self._titles[i]
					self._links[num] = self._links[i]
					self._titles[i] = temp_title
					self._links[i] = temp_link
				end
				--log("[Pirate Perfection Reborn RSS FEED] mixing ends")
			end

			self._news = {i = 0}
			self._next = true
			--log("[Pirate Perfection Reborn RSS FEED] announcement starts")
			self._panel:child("title_announcement"):set_visible(#self._titles > 0)
		end
		self.urlNumber = self.urlNumber + 1
	end
	self.busy = false
	--log("[Pirate Perfection Reborn RSS FEED] parse func ended")
end
function NewsFeedGui:_create_gui()
	local size = managers.gui_data:scaled_size()
	self._panel = self._ws:panel():panel({
		name = "main",
		w = size.width / 2,
		h = 44,
		layer = 500
	})
	self._panel:bitmap({
		visible = false,
		name = "bg_bitmap",
		texture = "guis/textures/textboxbg",
		layer = 500,
		color = Color.Free,
		w = self._panel:w(),
		h = self._panel:h()
	})
	self._panel:text({
		visible = false,
		rotation = 360,
		name = "title_announcement",
		text = " ",
		font = tweak_data.menu.pd2_small_font,
		font_size = tweak_data.menu.pd2_small_font_size,
		align = "left",
		halign = "left",
		vertical = "top",
		hvertical = "top",
		color = Color.Free,
		layer = 500
	})
	self._title_panel = self._panel:panel({
		name = "title_panel",
		layer = 500
	})
	self._title_panel:text({
		rotation = 360,
		name = "title",
		text = "",
		font = tweak_data.menu.pd2_medium_font,
		font_size = tweak_data.menu.pd2_medium_font_size,
		align = "left",
		halign = "left",
		vertical = "bottom",
		hvertical = "bottom",
		color = Color.Free,
		layer = 500
	})
	self._title_panel:set_right(-10)
	self._panel:set_bottom(self._panel:parent():h())
end
function NewsFeedGui:_get_text_block(s, sp, ep, max_results, itemOnly, itemText)
	if itemOnly == nil then
		itemOnly = true
	end
	if itemText == nil then
		itemText = "item"
	end
	local result = {}
	local len = string.len(s)
	local i = 1
	local function f(s, sp, ep, max_results)
		if not string.match(s, ep) then
			i = len
			return
		end
		local s1, e1 = string.find(s, sp, 1, true)
		if not e1 then
			return
		end
		local s2, e2 = string.find(s, ep, e1, true)
		--log("[Pirate Perfection Reborn RSS FEED] insert result e1, s2 " .. e1 .. ", " .. s2)
		table.insert(result, string.sub(s, e1 + 1, s2 - 1))
		if not itemOnly then
			i = i + s2
		end
	end
	while len > i and max_results > #result do
		--log("[Pirate Perfection Reborn RSS FEED] get_text_block i=" .. i)
		if itemOnly then
			local s1, e1 = string.find(s, "<" .. itemText .. ">", i, true)
			if not e1 then
				break
			end
			local s2, e2 = string.find(s, "</" .. itemText .. ">", e1, true)
			local item_s = string.sub(s, e1 + 1, s2 - 1)
			f(item_s, sp, ep, max_results)
			i = e1
		else
			--log("[Pirate Perfection Reborn RSS FEED] item_s " .. item_s)
			f(string.sub(s, i), sp, ep, max_results)
		end
		--f(item_s, sp, ep, max_results)
		--i = e1
	end
	return result
end
function NewsFeedGui:mouse_moved(x, y)
	local inside = self._panel:inside(x, y)
	self._mouse_over = inside
	return inside, inside and "link"
end
function NewsFeedGui:mouse_pressed(button, x, y)
	if not self._news then
		return
	end
	if button == Idstring("0") and self._panel:inside(x, y) then
		if MenuCallbackHandler:is_overlay_enabled() then
			Steam:overlay_activate("url", self._links[self._news.i])
		else
			managers.menu:show_enable_steam_overlay()
		end
		return true
	end
end
function NewsFeedGui:close()
	if alive(self._panel) then
		self._ws:panel():remove(self._panel)
	end
end

-- Option to Remove New Heists GUI

local removeNewHeistsGui = false  -- remove the box on the right side of the main menu (true/false)

local original_update = NewHeistsGui.update

function NewHeistsGui:update(...)
	if not removeNewHeistsGui then
		original_update(self, ...)
	end

	if self._newsfeed_gui then
		self._newsfeed_gui:update(...)
	else
		self._newsfeed_gui = NewsFeedGui:new(managers.menu_component._ws)
	end
end

local original_createcontractbox = NewHeistsGui.init

function NewHeistsGui:init(...)
	if not removeNewHeistsGui then
		original_createcontractbox(self, ...)
	end

	if self._newsfeed_gui then
		--self._newsfeed_gui:close()
		--self._newsfeed_gui = nil
	else
		self._newsfeed_gui = NewsFeedGui:new(managers.menu_component._ws)
	end
end

local original_mouse_pressed = NewHeistsGui.mouse_pressed

function NewHeistsGui:mouse_pressed(...)
	if not removeNewHeistsGui then
		original_mouse_pressed(self, ...)
	end

	if self._newsfeed_gui and self._newsfeed_gui:mouse_pressed(...) then
		return
	end
end

local original_close = NewHeistsGui.close

function NewHeistsGui:close()
	if not removeNewHeistsGui then
		original_close(self)
	end

	if self._newsfeed_gui then
		self._newsfeed_gui:close()
		self._newsfeed_gui = nil
	end
end