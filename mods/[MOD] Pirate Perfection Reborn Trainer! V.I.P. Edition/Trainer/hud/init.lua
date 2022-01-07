--HUD stuff here

--TO DO: Remake it from whitelist

ppr_require('Trainer/tools/workspace')

local ppr_dofile = ppr_dofile
local ppr_config = ppr_config
local ExGUIObject = ExGUIObject

local managers = managers
local M_gui = managers.gui_data

--Init object
--Confused about choose of workspace, seems 16_9 like a correct one since menu uses cutted workspace size
local ppr_obj = ExGUIObject:new( GameSetup and M_gui:create_fullscreen_workspace() or M_gui:create_fullscreen_16_9_workspace() )

local G = getfenv(0)
G.ppr_obj = ppr_obj

ppr_obj.__elements = {}

--ppr_obj:setup_mouse() --Temporary debug

--Wrapped requires into separate function for update_object()
local function exec()
	--Version text
	if ppr_config.HUD_VersionText and MenuSetup then
		ppr_dofile('Trainer/hud/version_text')
	end
	--Moving text
	if ppr_config.HUD_MovingText then
		ppr_dofile('Trainer/hud/moving_text')
	end
end

--Called when resolution changed
function ppr_obj:update_object()
	StopLoopIdent('moving_text')
	ppr_obj:destroy()
	ppr_obj = ExGUIObject:new( GameSetup and M_gui:create_fullscreen_workspace() or M_gui:create_fullscreen_16_9_workspace() )
	G.ppr_obj = ppr_obj
	ppr_obj.__elements = {}
	--ppr_obj:setup_mouse() --Temporary debug
	exec()
end

exec()