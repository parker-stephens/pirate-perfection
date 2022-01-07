--Disable anticheat by baldwin, keeping up to date by Jazzman
--Purpose: lobotomises several functions, responsible for checking for some cheats.

local PlayerManager = PlayerManager
local NetworkMember = NetworkMember
local NetworkPeer = NetworkPeer

function PlayerManager.verify_carry()return true end --Sometimes it blocks host from spawning bag, so it lobotomied
function PlayerManager.verify_equipment()return true end
function PlayerManager.verify_grenade()return true end
	
if NetworkMember then
	function NetworkMember.place_bag()return true end
end

local GrenadeBase = GrenadeBase
if ( GrenadeBase ) then
	function GrenadeBase.check_time_cheat()return true end --Removes grenade's launcher silly delay. Crazy firerate enabled again (though it will work only on host side)
end
if ( ProjectileBase ) then
	function ProjectileBase.check_time_cheat()return true end
end

--Here was create_ticket lobotomy, but it was removed due OVERKILL nerfed it
function NetworkPeer.begin_ticket_session()return true end
function NetworkPeer.on_verify_ticket()end
function NetworkPeer.end_ticket_session()end
function NetworkPeer.change_ticket_callback()end

function NetworkPeer.verify_job()end --Who cares own peer dlc heist or no
function NetworkPeer.verify_character()end --Doesn't forces people to pay for Female character
function NetworkPeer.verify_bag()return true end

function NetworkPeer.verify_outfit()end --Who cares own peer some outfit or no, saves a little of cpu aswell
function NetworkPeer._verify_outfit_data()end
function NetworkPeer._verify_cheated_outfit()end
function NetworkPeer._verify_content()return true end

function NetworkPeer.tradable_verify_outfit() end
function NetworkPeer.on_verify_tradable_outfit() end

-- Disable skills/perks/infamy check
ppr_dofile "Trainer/addons/disable_skills_check"
function InfamyManager._verify_loaded_data() end

-- Remove loot cap
tweak_data.money_manager.max_small_loot_value = math.huge

-- Slow-mo Protection by Davy Jones
local ppr_config = ppr_config

if ppr_config.slowmo_protect then
	local current_level = Global.game_settings.level_id
	local M_chat = managers.chat

	local backuper = backuper
	local executewithdelay = executewithdelay
	local slowmo_reverse = ppr_config.slowmo_reverse
	local tr = Localization.translate

	local heist_lock = true
	local bounce_lock = {0, 0, 0, 0}

	local reset_bounce = function(id)
		bounce_lock[id] = 1
	end

	backuper:hijack('UnitNetworkHandler.start_timespeed_effect', function(o, s, effect_id, timer_name, affect_timer_names_str, speed, fade_in, sustain, fade_out, sender)
		if heist_lock and sustain <= 5 and current_level == 'mia_2' and (affect_timer_names_str == nil or affect_timer_names_str == "player;") then
			o(s, effect_id, timer_name, affect_timer_names_str, speed, fade_in, sustain, fade_out, sender)
			heist_lock = false
		else
			local peer = s._verify_sender(sender)
			if not peer then
				M_chat:_receive_message(1, tr.troll_time_control, tr.troll_time_mess_block, Color.red)
				return
			end
			local id = peer:id()
			local cur_bounce = bounce_lock[id]
			if slowmo_reverse then
				if cur_bounce < 4 then
					bounce_lock[id] = cur_bounce + 1
					peer:send('start_timespeed_effect', effect_id, timer_name, affect_timer_names_str, speed, fade_in, sustain, fade_out)
					executewithdelay({func = reset_bounce, params = {id}}, 10, 'bounce_lock_reset_'..id)
				else
					reset_bounce(id)
				end
			end
			if cur_bounce == 0 then
				M_chat:_receive_message(1, tr.troll_time_control, peer:name()..tr.troll_time_mess_block..(slowmo_reverse and tr.troll_time_mess_reverse or ""), Color.red)
			end
		end
	end)
end