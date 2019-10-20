events = {}

local updateCount=0

--VossiScanTable
function events:ADDON_LOADED(...)
    if (not VossiScanTable) then
        VossiScanTable = {}
    end
end

function events:PLAYER_LOGOUT(...)
    --StoreScan()
end


function events:AUCTION_ITEM_LIST_UPDATE(...)
    updateCount = updateCount + 1
    dprint("[u"..updateCount.."] Auction list updated")
    if (scanInProgress and scanStepInProgress) then
        scanStepInProgress = false
        waitForScanFinish()
    end    
end

function events:AUCTION_HOUSE_SHOW(...)
    VAuction_EventFrame:SetParent('AuctionFrame')
    VAuction_EventFrame:SetFrameStrata("TOOLTIP")
    VAuction_EventFrame:SetPoint("TOPLEFT", "AuctionFrame", "TOPRIGHT", 0)
    VAuction_EventFrame:Show()

    nextButton=_G["BrowseNextPageButton"]
    if (not statusbar) then
        createStatusbar()
    end
    ListScans()
    initializeStatus()    
end

function events:AUCTION_HOUSE_CLOSED(...)
    scanInProgress = false
    scanStepInProgress = false
    VAuction_EventFrame:Hide()
end

VAuction_EventFrame:SetScript("OnEvent", function(self, event, ...)
    events[event](self, ...); -- call one of the functions above
end);

for k, v in pairs(events) do
VAuction_EventFrame:RegisterEvent(k); -- Register all events for which handlers have been defined
end