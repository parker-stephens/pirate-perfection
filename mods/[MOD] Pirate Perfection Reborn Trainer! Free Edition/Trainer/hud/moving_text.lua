--Purpose: testing with moving text
--Idea: moving text synced from net

--[[local rand_text = {
	'Moving text, announcements and etc.',
	'Pirate Perfection Reborn will be released soon!',
	'Pirate Perfection: feel the power',
	'Cats were here ...',
	'I don\'t know what to type, captain will probably add his own stuff here',
	'Moving text, developed by baldwin',
	'Baldwin was here ...',
	'Come to chat with devs and people here: http://steamcommunity.com/groups/pp4pd2', --TO DO: Clicky announcements, I'm trying to implement this into workspace.lua
	'Don\'t forget to report bugs.',
	'Thank you for using our Trainer :)',
}]]

local rand_text = {  }

local speed = 100

local dist_mul = GameSetup and 2 or 1 --Rare text for in-game and more frequent for menu

local Global = Global
local ppr_obj = ppr_obj
local math_rand = math.random
local string = string
local str_find = string.find
local str_split = string.split
local Color = Color
local Steam = Steam
local http_request = Steam.http_request
local executewithdelay = executewithdelay
local RenderSettings = RenderSettings
local resolution = RenderSettings.resolution
local max_x = resolution.x

local tobj = ppr_obj:text('moving_text',rand_text[math_rand(1,#rand_text)],max_x,0,nil,Color(math_rand(),math_rand(),math_rand()),nil,0)

ppr_obj.__elements.moving_text = tobj

local main_timer = TimerManager:main()
local get_delta_time = main_timer.delta_time

local function update()
	tobj:set_x(tobj:x()-(get_delta_time(main_timer)*speed))
	if tobj:x() < -max_x*dist_mul then
		tobj:hide()
		tobj:set_text(rand_text[math_rand(1,#rand_text)])
		do
			local x,y,w,h = tobj:text_rect()
			tobj:set_size( w, h )
		end
		tobj:set_x(max_x+tobj:w()*dist_mul)
		tobj:set_color(Color(math_rand(),math_rand(),math_rand()))
		tobj:show()
	end
end

local retry_myid
local function ___(b,dat)
	m_log_vs('moving_text.lua report. Is success ?', b, 'Data received:\n================\n', dat,'\n================')
	StopLoopIdent(retry_myid)
	if (b and dat and dat ~= '' and not str_find(dat,'<.-html.->.*<.-/html.->')) then
		rand_text = str_split(dat,'\n')
		Global.moving_text_cache = rand_text
		Global.moving_text_cache_t = main_timer:time()
		RunNewLoopIdent('moving_text',update)
	end
end

local request
request = function()
	http_request(Steam, 'https://bitbucket.org/SoulHipHop/pirate-perfection/downloads/moving_text.txt', ___)
	retry_myid = executewithdelay( request, 3.5 )
end

--Don't annoy host with requests
rand_text = Global.moving_text_cache
if ( rand_text and ( main_timer:time() - Global.moving_text_cache_t < 180 ) ) then
	RunNewLoopIdent('moving_text', update)
else
	request()
end