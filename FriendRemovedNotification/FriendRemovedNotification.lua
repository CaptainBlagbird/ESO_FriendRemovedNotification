--[[

Friend Removed Notification
by CaptainBlagbird
https://github.com/CaptainBlagbird

--]]

-- Libraries
local LN = LibStub:GetLibrary("LibNotifications")
LN_provider = LN:CreateProvider()

-- Addon info
local AddonName = "FriendRemovedNotification"
-- Local variables
local SavedVars = {}


-- Function to set up the friends list in the SavedVars
local function InitSavedVarsFriends()
	SavedVars.friends = {}
	for i=1, GetNumFriends() do
		local DisplayName = GetFriendInfo(i)
		SavedVars.friends[DisplayName] = 0
	end
	d(AddonName.." initialized.")
end

-- Event handler function for EVENT_FRIEND_REMOVED
local function OnFriendRemoved(eventCode, DisplayName)
	-- Remove from SavedVars friends list
	SavedVars.friends[DisplayName] = nil
	
	-- Function to remove custom notification
	local function removeNotification(provider, data)
		t = provider.notifications
		j = data.notificationId
		-- Loop through table starting at index
		for i=j, #t do
			-- Replace current element with next element
			t[i] = t[i+1]
			-- Update index in data
			if i<#t then
				t[i].notificationId = i
				t[i].message = tostring(i)
			end
		end
		provider:UpdateNotifications()
	end
	-- Custom notification info
	local msg = {
			dataType        = LIBNOTIFICATIONS_ROWTYPEID,
			notificationId  = #LN_provider.notifications + 1,
			note            = "Notification by add-on \""..AddonName.."\"",
			message         = "|cFFFFFF"..ZO_LinkHandler_CreatePlayerLink(DisplayName).."|r was removed from your friends list. Send whisper?",
			heading         = "Friend removed",
			texture         = "EsoUI/Art/Notifications/notificationIcon_friend.dds",
			declineCallback = function(data) removeNotification(LN_provider, data) end,
			acceptCallback  = function(data)
					StartChatInput("", CHAT_CHANNEL_WHISPER, DisplayName)
					removeNotification(LN_provider, data)
				end,
		}
	-- Add custom notification
	table.insert(LN_provider.notifications, msg)
	LN_provider:UpdateNotifications()
end
EVENT_MANAGER:RegisterForEvent(AddonName, EVENT_FRIEND_REMOVED, OnFriendRemoved)

-- Event handler function for EVENT_PLAYER_ACTIVATED
local function OnPlayerActivated(eventCode)
	-- Set up SavedVariables table
	SavedVars = ZO_SavedVars:NewAccountWide(AddonName.."_SavedVariables", 1)
	if SavedVars.friends == nil then InitSavedVarsFriends() end
	
	-- Compare friends list with list in SavedVars
	for DisplayName, _ in pairs(SavedVars.friends) do
		if not IsFriend(DisplayName) then
			-- Call event handler function directly
			OnFriendRemoved(EVENT_FRIEND_REMOVED, DisplayName)
		end
	end
	
	EVENT_MANAGER:UnregisterForEvent(AddonName, EVENT_PLAYER_ACTIVATED)
end
EVENT_MANAGER:RegisterForEvent(AddonName, EVENT_PLAYER_ACTIVATED, OnPlayerActivated)