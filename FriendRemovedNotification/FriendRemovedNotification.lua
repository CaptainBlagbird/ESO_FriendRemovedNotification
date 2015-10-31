--[[

Friend Removed Notification
by CaptainBlagbird
https://github.com/CaptainBlagbird

--]]

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

-- Event handler function for EVENT_FRIEND_ADDED or EVENT_FRIEND_REMOVED
local function OnFriendAddedOrRemoved(eventCode, DisplayName)
	local action = ""
	if eventCode == EVENT_FRIEND_ADDED then
		SavedVars.friends[DisplayName] = GetTimeStamp()
		action = "added"
	elseif eventCode == EVENT_FRIEND_REMOVED then
		SavedVars.friends[DisplayName] = nil
		action = "removed"
	else
		return
	end
	
	d("Friend "..action..": \""..ZO_LinkHandler_CreatePlayerLink(DisplayName).."\"")
end
EVENT_MANAGER:RegisterForEvent(AddonName, EVENT_FRIEND_REMOVED, OnFriendAddedOrRemoved)
EVENT_MANAGER:RegisterForEvent(AddonName, EVENT_FRIEND_ADDED, OnFriendAddedOrRemoved)

-- Event handler function for EVENT_PLAYER_ACTIVATED
local function OnPlayerActivated(eventCode)
	-- Set up SavedVariables table
	SavedVars = ZO_SavedVars:New(AddonName.."_SavedVariables", 1)
	if SavedVars.friends == nil then InitSavedVarsFriends() end
	
	-- Compare friends list with list in SavedVars
	for DisplayName, _ in pairs(SavedVars.friends) do
		if not IsFriend(DisplayName) then
			-- Call event handler function directly
			OnFriendAddedOrRemoved(EVENT_FRIEND_REMOVED, DisplayName)
		end
	end
	
	EVENT_MANAGER:UnregisterForEvent(AddonName, EVENT_PLAYER_ACTIVATED)
end
EVENT_MANAGER:RegisterForEvent(AddonName, EVENT_PLAYER_ACTIVATED, OnPlayerActivated)