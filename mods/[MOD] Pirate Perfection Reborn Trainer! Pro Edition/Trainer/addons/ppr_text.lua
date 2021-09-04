-- Adds PPR watermark on map

local level = managers.job:current_level_id()
local newgui = World:newgui()
local Vector3 = Vector3
local Color = Color

if level == "firestarter_3" or level == "branchbank" then
	local vec1 = Vector3(-2600,1280,1375)
	local vec2 = Vector3(4000,600,0)
	local vec3 = Vector3(0,0,-2800)
	
	newgui:create_world_workspace( 9100, 2050, vec1, vec2, vec3 ):panel():text({ font = "core/fonts/diesel",font_size = 190, color = Color.bluegreen,text = "PIRATEPERFECTION" })
	newgui:create_world_workspace( 9100, 2050, vec1, vec2, vec3 ):panel():text({ font = "core/fonts/diesel",font_size = 190,color = Color.gold,text = "PIRATEPERFECTION" })
end