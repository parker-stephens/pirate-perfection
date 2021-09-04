-- ArmorTweaks v2 by Baddog-11
-- Every Value In-Game should be 1.000 with this setting. Edit them to your likings.

plugins:new_plugin('armor_tweaks')

VERSION = '2.0'

CATEGORY = 'main'

--[[function MAIN()
local backuper = backuper
	backuper:backup('UpgradesTweakData._init_pd2_values()')]]
	if not armor_tweaks then armor_tweaks = true
-- Main Stats.
	tweak_data.upgrades.values.player.body_armor.armor										=	{ 77, 14, 14, 14, 77, 77, 77 }						-- Default = { 0, 3, 4, 5, 7, 9, 15 }
	tweak_data.upgrades.values.player.body_armor.concealment								=	{ 30, 26, 23, 21, 18, 12, 1 }						-- Default = { 30, 26, 23, 21, 18, 12, 1 }
	tweak_data.upgrades.values.player.ballistic_vest_concealment							=	{ 3 }												-- Default = { 4 }
	tweak_data.upgrades.values.player.body_armor.movement									=	{ 1.33, 1.33, 1.33, 1.33, 1.33, 1.33,1.33 }			-- Default = { 1.05, 1.025, 1, 0.95, 0.75, 0.65, 0.575 }
	tweak_data.upgrades.values.player.body_armor.dodge										=	{ 49.30, 49.05, 49.05, 49.05, 49.30, 49.30, 49.30 }	-- Default = { 0.05, -0.05, -0.1, -0.15, -0.2, -0.25, -0.55 }
	tweak_data.upgrades.values.player.armor_dodge_penalty									=	{ 0, 0, 0, 0, 0, 0, 0 }								-- Default = { 1, 1, 0.8, 0.5, 0.25, 0 }
	tweak_data.upgrades.values.player.body_armor.damage_shake								=	{ 0, 0, 0, 0, 0, 0, 0 }								-- Default = { 1, 0.96, 0.92, 0.85, 0.8, 0.7, 0.5 }
	tweak_data.upgrades.values.player.body_armor.stamina									=	{ 67, 67, 67, 67, 67, 67, 67}						-- Default = { 1.025, 1, 0.95, 0.9, 0.85, 0.8, 0.7 }
-- Skills Stats.
	tweak_data.upgrades.values.player.headshot_regen_armor_bonus							=	{ 2 }												-- Default = { 0.5, 2.5 }
	tweak_data.upgrades.values.player.add_armor_stat_skill_ammo_mul							=	{ true }											-- Default = { true }
	tweak_data.upgrades.values.player.body_armor.skill_ammo_mul                 			=	{ 2, 2, 2, 2, 2, 2, 2 }								-- Default = { 1, 1.02, 1.04, 1.06, 1.8, 1.1, 1.12 }
	tweak_data.upgrades.values.player.body_armor.skill_max_health_store						=	{ 25, 25, 25, 25, 25, 25, 25 }						-- Default = { 14, 13.5, 12.5, 12, 10.5, 9.5, 4 }
	tweak_data.upgrades.values.player.body_armor.skill_kill_change_regenerate_speed			=	{ 25, 25, 25, 25, 25, 25, 25 }						-- Default = { 14, 13.5, 12.5, 12, 10.5, 9.5, 4 }
-- Regeneration Stats.
	tweak_data.upgrades.values.player.armor_regen_timer_multiplier_passive					=	{ 0.9 } 											-- Default = { 0.9 }
	tweak_data.upgrades.values.player.armor_regen_timer_multiplier_tier						=	{ 0.9 }												-- Default = { 0.9 }
	tweak_data.upgrades.values.player.armor_regen_time_mul									=	{ 0.85 } 											-- Default = { 0.85 }
	tweak_data.upgrades.values.player.armor_regen_damage_health_ratio_multiplier			=	{ 0.2, 0.4, 0.6 } 									-- Default = { 0.2, 0.4, 0.6 }
	tweak_data.upgrades.values.player.armor_regen_damage_health_ratio_threshold_multiplier	=	{ 2 } 												-- Default = { 2 }
	tweak_data.upgrades.values.player.passive_always_regen_armor							=	{ 1.5 } 											-- Default = { 1.5 }
-- Multiplier Stats.
	tweak_data.upgrades.values.player.armor_regen_timer_stand_still_multiplier				=	{ 1 }												-- Default = { 0.8 }
	tweak_data.upgrades.values.player.armor_regen_timer_multiplier							=	{ 1 }												-- Default = { 0.85 }
	tweak_data.upgrades.values.player.armor_multiplier										=	{ 1 }												-- Default = { 1.3 }
	tweak_data.upgrades.values.player.passive_armor_multiplier								=	{ 1, 1 }											-- Default = { 1.1, 1.25 }
	tweak_data.upgrades.values.player.passive_armor_movement_penalty_multiplier				=	{ 1 }												-- Default = { 0.75 }
	tweak_data.upgrades.values.player.tier_armor_multiplier									=	{ 1, 1, 1 }											-- Default = { 1.05, 1.1, 1.2, 1.3, 1.15, 1.35 }
-- Team Stats.
	tweak_data.upgrades.values.team.armor.regen_time_multiplier								=	{ 2 }												-- Default = { 0.75 }
	tweak_data.upgrades.values.team.armor.passive_regen_time_multiplier						=	{ 2 }												-- Default = { 0.9 }
	tweak_data.upgrades.values.team.armor.multiplier										=	{ 2 }												-- Default = { 1.05 }
-- Perks Stats.
	tweak_data.upgrades.values.player.perk_armor_loss_multiplier							=	{ 0.95, 0.9, 0.85, 0.8 }							-- Default = { 0.95, 0.9, 0.85, 0.8 }
	tweak_data.upgrades.values.player.perk_armor_regen_timer_multiplier						=	{ 0.95, 0.85, 0.75, 0.65, 0.55 }					-- Default = { 0.95, 0.85, 0.75, 0.65, 0.55 }
	tweak_data.upgrades.values.player.killshot_regen_armor_bonus							=	{ 3 }												-- Default = { 3 }
	tweak_data.upgrades.values.player.killshot_close_regen_armor_bonus						=	{ 3 }												-- Default = { 3 }
-- Stats.
	tweak_data.upgrades.values.player.armor_increase										=	{ 1, 1.1, 1.2 }										-- Default = { 1, 1.1, 1.2 }
	tweak_data.upgrades.values.player.armor_carry_bonus										= 	{ 1.01 }											-- Default = { 1.01 }
	tweak_data.upgrades.values.player.armor_depleted_stagger_shot							= 	{ 0, 6 }											-- Default = { 0, 6 }
	tweak_data.upgrades.values.player.armor_piercing_chance									=	{ 0.1, 0.3 }										-- Default = { 0.1, 0.3 }
	tweak_data.upgrades.values.temporary.armor_break_invulnerable							=	{ { 2, 15 } }										-- Default = { { 2, 15 } }
	tweak_data.upgrades.values.player.armor_grinding										=	{ { { 1, 2 }, { 1.5, 3 }, { 2, 4 }, { 2.5, 5 }, { 3.5, 6 }, { 4.5, 7 }, { 8.5, 10 } } }		-- Default = { { { 1, 2 }, { 1.5, 3 }, { 2, 4 }, { 2.5, 5 }, { 3.5, 6 }, { 4.5, 7 }, { 8.5, 10 } } }
	tweak_data.upgrades.values.player.damage_to_armor										=	{ { { 3, 1.5 }, { 3, 1.5 }, { 3, 1.5 }, { 3, 1.5 }, { 3, 1.5 }, { 3, 1.5 }, { 3, 1.5 } } }	-- Default = { { { 3, 1.5 }, { 3, 1.5 }, { 3, 1.5 }, { 3, 1.5 }, { 3, 1.5 }, { 3, 1.5 }, { 3, 1.5 } } }
	tweak_data.upgrades.armor_health_store_kill_amount										=	1 													-- Default = 1
	tweak_data.upgrades.values.player.armor_health_store_amount								=	{ 0.4, 0.8, 1.2 } 									-- Default = { 0.4, 0.8, 1.2 }
	tweak_data.upgrades.values.player.armor_max_health_store_multiplier						=	{ 1.5 } 											-- Default = { 1.5 }
	end
--[[end

function UNLOAD()
	local backuper = backuper
	backuper:restore('UpgradesTweakData._init_pd2_values()')
end

FINALIZE()]]