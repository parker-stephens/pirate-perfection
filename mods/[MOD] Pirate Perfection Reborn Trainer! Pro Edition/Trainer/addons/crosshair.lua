-- Crosshair

local hud_panel = Overlay:newgui():create_screen_workspace():panel()
local hit_confirm = hud_panel:bitmap( { valign="center",
										halign="center",
										visible = true,
										texture = "units/pd2_dlc1/weapons/wpn_effects_textures/wpn_sight_reticle_m_1_il",
										w = 50,
										h = 50,
										color = Color.blue,
										layer = 0,
										name = PiratePerfectionReborn,
										rotation = rotation,
										blend_mode="add"
									} )
hit_confirm:set_center( hud_panel:w()/2, hud_panel:h()/2 )

--[[ List to Modify Crosshair
	textures :
-- Gage reticles
	dot1		= 	"units/pd2_dlc1/weapons/wpn_effects_textures/wpn_sight_reticle_s_1_il"
	dot2		= 	"units/pd2_dlc1/weapons/wpn_effects_textures/wpn_sight_reticle_m_1_il"
	dot3		= 	"units/pd2_dlc1/weapons/wpn_effects_textures/wpn_sight_reticle_l_1_il"
	cross1		= 	"units/pd2_dlc1/weapons/wpn_effects_textures/wpn_sight_reticle_2_il"
	cross2		= 	"units/pd2_dlc1/weapons/wpn_effects_textures/wpn_sight_reticle_3_il"
	cross3		= 	"units/pd2_dlc1/weapons/wpn_effects_textures/wpn_sight_reticle_4_il"
	circle1		= 	"units/pd2_dlc1/weapons/wpn_effects_textures/wpn_sight_reticle_5_il"
	circle2		= 	"units/pd2_dlc1/weapons/wpn_effects_textures/wpn_sight_reticle_6_il"
	circle3		= 	"units/pd2_dlc1/weapons/wpn_effects_textures/wpn_sight_reticle_7_il"
	circle4		= 	"units/pd2_dlc1/weapons/wpn_effects_textures/wpn_sight_reticle_8_il"
	angle1		= 	"units/pd2_dlc1/weapons/wpn_effects_textures/wpn_sight_reticle_9_il"
	angle2		= 	"units/pd2_dlc1/weapons/wpn_effects_textures/wpn_sight_reticle_10_il"
-- Butcher DLC reticles
	first circle	= 	"units/pd2_dlc_butcher_mods/weapons/wpn_effects_textures/wpn_sight_reticle_11_il"
	flat			= 	"units/pd2_dlc_butcher_mods/weapons/wpn_effects_textures/wpn_sight_reticle_12_il"
	sun				= 	"units/pd2_dlc_butcher_mods/weapons/wpn_effects_textures/wpn_sight_reticle_13_il"
	hunter			= 	"units/pd2_dlc_butcher_mods/weapons/wpn_effects_textures/wpn_sight_reticle_14_il"
	on/off			= 	"units/pd2_dlc_butcher_mods/weapons/wpn_effects_textures/wpn_sight_reticle_15_il"
	cross			= 	"units/pd2_dlc_butcher_mods/weapons/wpn_effects_textures/wpn_sight_reticle_16_il"
	insert here		= 	"units/pd2_dlc_butcher_mods/weapons/wpn_effects_textures/wpn_sight_reticle_17_il"
	hashtag			= 	"units/pd2_dlc_butcher_mods/weapons/wpn_effects_textures/wpn_sight_reticle_18_il"
	overkill		= 	"units/pd2_dlc_butcher_mods/weapons/wpn_effects_textures/wpn_sight_reticle_19_il"
	starbreeze		= 	"units/pd2_dlc_butcher_mods/weapons/wpn_effects_textures/wpn_sight_reticle_20_il"
	fuck you		= 	"units/pd2_dlc_butcher_mods/weapons/wpn_effects_textures/wpn_sight_reticle_21_il"
	rock on			= 	"units/pd2_dlc_butcher_mods/weapons/wpn_effects_textures/wpn_sight_reticle_22_il"
	lion game lion	= 	"units/pd2_dlc_butcher_mods/weapons/wpn_effects_textures/wpn_sight_reticle_23_il"
-- Standard hit confirm
	hit_x	=	"guis/textures/pd2/hitconfirm"
	hit_o	=	"guis/textures/pd2/hitconfirm_crit"
-- Colors NOT WORKING / WORK ONLY WITH SOME RETICLES
	Color.red
	Color.blue
	Color.green
	Color.yellow
	Color.white
]]