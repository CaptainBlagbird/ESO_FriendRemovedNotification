
--Register LAM with LibStub
local MAJOR, MINOR = "LibNotifications", 1
local libNotes, oldminor = LibStub:NewLibrary(MAJOR, MINOR)
if not libNotes then return end	--the same or newer version of this lib is already loaded into memory 


local libNotesProvider = ZO_NotificationProvider:Subclass()

LIBNOTIFICATIONS_ROWTYPEID = 347 -- random unique number for rowTypeId
	
local function SetupRowControl(control, data)
    ZO_SortFilterList.SetupRow(NOTIFICATIONS.sortFilterList, control, data)
    local notificationType = data.notificationType

    control.notificationType = notificationType
    control.index = data.index

	local noteBtn 		= GetControl(control, "Note")
	local acceptBtn 	= GetControl(control, "Accept")
	local declineBtn 	= GetControl(control, "Decline")
	
	local hideNote 			= (type(data.note) ~= "string")
	local hideAcceptBtn 	= (type(data.acceptCallback) ~= "function")
	local hideDeclineBtn 	= (type(data.declineCallback) ~= "function")
	
	noteBtn:SetHidden(showNote)
	acceptBtn:SetHidden(hideAcceptBtn)
	declineBtn:SetHidden(hideDeclineBtn)
	
    GetControl(control, "Icon"):SetTexture(data.texture)
    GetControl(control, "Type"):SetText(data.heading)
end

local function SetupNotification(control, data)
    SetupRowControl(control, data)
    NOTIFICATIONS:SetupMessage(control:GetNamedChild("Message"), data)
    NOTIFICATIONS:SetupNote(control, data)
end


--=============================================================--
--=== LOCAL PROVIDER FUNCTIONS ===--
--=============================================================--
function libNotesProvider:BuildNotificationList()
    ZO_ClearNumericallyIndexedTable(self.list)
	
	-- Use a copy so it wont delete/alter the addons original msg list/table.
	self.list = ZO_ShallowTableCopy(self.notifications)
end

function libNotesProvider:UpdateNotifications()
	self:BuildNotificationList()
	self:pushUpdateCallback()
end


function libNotesProvider:New(notificationManager)
	if not self.dataRowTypeId then
		self.dataRowTypeId = ZO_ScrollList_AddDataType(NOTIFICATIONS.sortFilterList.list, LIBNOTIFICATIONS_ROWTYPEID, "ZO_NotificationsRequestRow", 50, function(control, data) SetupNotification(control, data) end)
	end
	self.dataRowTypeId = LIBNOTIFICATIONS_ROWTYPEID

    local provider = ZO_NotificationProvider.New(self, notificationManager)
	
	table.insert(NOTIFICATIONS.providers, provider)
	provider.notifications = {}
	provider.self = self
	
    return provider
end

function libNotesProvider:Accept(data)
	if data.acceptCallback then
		data.acceptCallback(data)
	end
end

function libNotesProvider:Decline(data, button, openedFromKeybind)
	if data.declineCallback then
		data.declineCallback(data)
	end
end



--=============================================================--
--=== LIBRARY FUNCTIONS ===--
--=============================================================--
function libNotes:CreateProvider()
    local provider = libNotesProvider:New(NOTIFICATIONS)
	
	return provider
end










