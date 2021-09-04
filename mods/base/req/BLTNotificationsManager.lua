
BLTNotificationsManager = BLTNotificationsManager or blt_class()

function BLTNotificationsManager:init()

	self._notifications = {}
	self._uid = 1000

end

function BLTNotificationsManager:_get_uid()
	local uid = self._uid
	self._uid = uid + 1
	return uid
end

function BLTNotificationsManager:_get_notification( uid )
	for i, data in ipairs( self._notifications ) do
		if data.id == uid then
			return self._notifications[i], i
		end
	end
	return nil, -1
end

function BLTNotificationsManager:get_notifications()
	return self._notifications
end

function BLTNotificationsManager:add_notification( parameters )

	-- Create and store the notification
	local data = {
		id = self:_get_uid(),
		title = parameters.title or "No Title",
		text = parameters.text or "",
		icon = parameters.icon,
		icon_texture_rect = parameters.icon_texture_rect,
		color = parameters.color,
		priority = parameters.priority or (id * -1),
	}
	table.insert( self._notifications, data )

	-- Add the notification immediately if the gui is visible
	local notifications = managers.menu_component:blt_notifications_gui()
	if notifications then
		notifications:add_notification( data )
	end

	return data.id

end

function BLTNotificationsManager:remove_notification( uid )

	-- Remove the notification
	local _, idx = self:_get_notification( uid )
	if idx > 0 then

		table.remove( self._notifications, idx )

		-- Update the ui
		local notifications = managers.menu_component:blt_notifications_gui()
		if notifications then
			notifications:remove_notification( uid )
		end

	end

end

--------------------------------------------------------------------------------
-- BLT legacy support
-- Not complete support, replace if you use this in a mod

NotificationsManager = NotificationsManager or {}

function NotificationsManager:GetNotifications()
	return BLT.Notifications:get_notifications()
end

function NotificationsManager:GetCurrentNotification()
	return BLT.Notifications:get_notifications()[1]
end

function NotificationsManager:GetCurrentNotificationIndex()
	return 1
end

function NotificationsManager:AddNotification( id, title, message, priority, callback )
	self._legacy_ids = self._legacy_ids or {}
	local new_id = BLT.Notifications:add_notification( {
		title = title,
		text = message,
		priority = priority
	} )
	self._legacy_ids[id] = new_id
end

function NotificationsManager:UpdateNotification( id, new_title, new_message, new_priority, new_callback )
	self._legacy_ids = self._legacy_ids or {}
	self:RemoveNotification( id )
	self:AddNotification( id, new_title, new_message, new_priority, new_callback )
end

function NotificationsManager:RemoveNotification( id )
	self._legacy_ids = self._legacy_ids or {}
	if self._legacy_ids[id] then
		BLT.Notifications:remove_notification( self._legacy_ids[id] )
		self._legacy_ids[id] = nil
	end
end

function NotificationsManager:ClearNotifications()
	self._legacy_ids = self._legacy_ids or {}
	for id, new_id in pairs( self._legacy_ids ) do
		BLT.Notifications:remove_notification( new_id )
	end
end

function NotificationsManager:NotificationExists( id )
	self._legacy_ids = self._legacy_ids or {}
	return self._legacy_ids[id] ~= nil
end

function NotificationsManager:ShowNextNotification( suppress_sound )
	log("[Error] NotificationsManager.ShowNextNotification is no longer supported.")
end

function NotificationsManager:ShowPreviousNotification( suppress_sound )
	log("[Error] NotificationsManager.ShowPreviousNotification is no longer supported.")
end

function NotificationsManager:ClickNotification( suppress_sound )
	log("[Error] NotificationsManager.ClickNotification is no longer supported.")
end

function NotificationsManager:MarkNotificationAsRead( id )
	log("[Error] NotificationsManager.MarkNotificationAsRead is no longer supported.")
end
