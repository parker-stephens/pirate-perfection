--Purpose: disables drop-in pause in game.
--Author: ThisJazzman

local session = GetNetSession()
if ( session ) then
	local backuper = backuper
	local hijack = backuper.hijack
	local backup = backuper.backup

	local Application = Application
	local set_pause = Application.set_pause
	local is_paused = Application.paused
	local SoundDevice = SoundDevice
	local set_rtpc = SoundDevice.set_rtpc

	--Just unpause, if pause occured
	local function unpause(o, ...)
		local already_paused = is_paused(Application)
		local r = o(...)
		if (not already_paused) then
			set_pause(Application, false)
			set_rtpc(SoundDevice, "ingame_sound", 1)
		end
		return r
	end

	hijack(backuper, 'BaseNetworkSession.load', unpause)
	hijack(backuper, 'BaseNetworkSession.on_drop_in_pause_request_received', unpause)

	--Lobotomy/modify menu stuff
	local system_message = system_message
	local tr = Localization.translate
	local join_progress_text = tr.dropin_join_progress
	local joined_text = tr.dropin_joined

	--TO DO: Put it on HUD nicely somehow
	local MenuManager = MenuManager
	backup(backuper, 'MenuManager.show_person_joining')
	MenuManager.show_person_joining=void
	backup(backuper, 'MenuManager.update_person_joining')
	MenuManager.update_person_joining=function( self, id, progress )
		local peer = session._peers[id]
		local name = peer._name
		local high_progress = peer._high_progress or 0
		if ( progress > high_progress ) then
			system_message(name..join_progress_text..progress.."%")
			peer._high_progress = high_progress + 15
		end
	end
	backup(backuper, 'MenuManager.close_person_joining')
	MenuManager.close_person_joining=function(self, id)
		local peer = session._peers[id]
		if ( peer ) then
			peer._high_progress = nil
			system_message(peer._name..joined_text)
		end
	end
end