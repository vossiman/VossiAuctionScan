
VAuction_EventFrame = _G["VossiAuctionScanFrame"]

VAuction_ScanName = _G["VScanName"]
VAuction_TimePredictText = _G["VTimePredictText"]
VAuction_TimeSpentText = _G["VTimeSpentText"]
VAuction_ScanText = _G["VScanText"]
VAuction_VScansCount = _G["VScansCount"]

VStoredScansCount=0

function createStatusbar()
    statusbar = CreateFrame("StatusBar", nil, VAuction_EventFrame)
    statusbar:SetPoint("TOP", VAuction_EventFrame, "TOP", 0, -70)
    statusbar:SetWidth(280)
    statusbar:SetHeight(20)
    statusbar:SetStatusBarTexture("Interface\\TARGETINGFRAME\\UI-StatusBar")
    statusbar:GetStatusBarTexture():SetHorizTile(false)
    statusbar:GetStatusBarTexture():SetVertTile(false)
    statusbar:SetMinMaxValues(0, 100.0)
    statusbar:SetStatusBarColor(0, 0.65, 0)
    statusbar:SetValue(0)

    statusbar.bg = statusbar:CreateTexture(nil, "BACKGROUND")
    statusbar.bg:SetTexture("Interface\\TARGETINGFRAME\\UI-StatusBar")
    statusbar.bg:SetAllPoints(true)
    statusbar.bg:SetVertexColor(0, 0.35, 0)

    statusbar.value = statusbar:CreateFontString(nil, "OVERLAY")
    statusbar.value:SetPoint("CENTER", statusbar, "CENTER", 4, 0)
    statusbar.value:SetFont("Fonts\\FRIZQT__.TTF", 16, "OUTLINE")
    statusbar.value:SetJustifyH("CENTER")
    statusbar.value:SetShadowOffset(1, -1)
    statusbar.value:SetTextColor(0, 1, 0)
    statusbar.value:SetText("0%")
end

function initializeStatus() 
    VAuction_ScanName:SetText("Scan Snapshot Name: -")
    VAuction_TimePredictText:SetText("")
    VAuction_TimeSpentText:SetText("")
    VAuction_ScanText:SetText("scan not started yet")
    statusbar:SetValue(0)
    statusbar.value:SetText("0%")

    storeBtn = _G["VStoreButton"]
    storeBtn:SetEnabled(false)

    scanBtn = _G["VScanButton"]
    scanBtn:SetEnabled(true)
end

function ScanButtonClick()
    scanBtn = _G["VScanButton"]
    storeBtn = _G["VStoreButton"]

    if (scanInProgress) then
        -- scan running, cancel it and reset button text
        CancelScan()
        scanBtn:SetText("Start scan")        
    else
        ScanAuctionHouse()
        scanBtn:SetText("Cancel Scan")   
        storeBtn:SetEnabled(false)     
    end
end

function StoreButtonClick()
    storeBtn = _G["VStoreButton"]
    storeBtn:SetEnabled(false)
    local itemCount = table.getn(VCurrentScan)
    if (itemCount>0) then
        StoreScan()

        pprint('Stored Snapshot: '..scanTimestamp.." with "..itemCount.." items")
        ListScans()
    end
end

function ListScans()
    scanFrame = _G["VScansFrame"]
    scanFrameHeight = scanFrame:GetHeight()
    scanFrameWidth = scanFrame:GetWidth()
    dprint("Scan List Frame Height/Width: "..scanFrameHeight.."/"..scanFrameWidth)

    -- clean up UI Elements not used anymore
    for i=1,10 do
        scanFrameName = "ScansListItem"..i
        if (scanFrame[scanFrameName]) then
            scanFrame[scanFrameName]:Hide()
        end
        
        scanFrameButton = "ScansListButton"..i
        if (scanFrame[scanFrameButton]) then
            scanFrame[scanFrameButton]:Hide()
        end
    end

    i=0
    lineHeight=20
    marginOffset=15    
    deleteButtonSize=30
    deleteButtonWidth=50
    topOffset = 5

    -- create a table sorted by date - key of they array
    local tkeys = {}
    for k in pairs(VossiScanTable) do table.insert(tkeys, k) end

    table.sort(tkeys)

    -- loop over sorted keys
    for _,sortedKey in pairs(tkeys) do 
        -- assign values as if looping normally over pairs to k,v
        k=sortedKey
        v=VossiScanTable[sortedKey]

        i=i+1
        scanCount = table.getn(v)
        --dprint(k)
        scanFrameName = "ScansListItem"..i
        if (not scanFrame[scanFrameName]) then
            scanFrame[scanFrameName] = scanFrame:CreateFontString(scanFrameName, "OVERLAY", "GameFontWhite")
        end
        
        scanFrame[scanFrameName]:SetPoint("TOPLEFT", scanFrame, "TOPLEFT", marginOffset+0, 0+(-lineHeight*i)+topOffset) 
        scanFrame[scanFrameName]:SetJustifyH("LEFT")
        scanFrame[scanFrameName]:SetShadowOffset(1, -1)
        --scanFrame[scanFrameName]:SetTextColor(0, 1, 0)
        scanFrame[scanFrameName]:SetText("["..i .. "] "..k.." - "..scanCount.." items")
        scanFrame[scanFrameName]:SetWidth(scanFrameWidth-deleteButtonWidth)
        scanFrame[scanFrameName]:SetHeight(lineHeight)
        scanFrame[scanFrameName]:Show()

        
        scanFrameButton = "ScansListButton"..i
        if (not scanFrame[scanFrameButton]) then
            scanFrame[scanFrameButton] = CreateFrame("Button", scanFrameButton, scanFrame)
        end

        deleteButtonOffset = deleteButtonSize-lineHeight
        deleteTopOffset = -5
        scanFrame[scanFrameButton]:SetPoint("TOPRIGHT", scanFrame, "TOPRIGHT", -marginOffset+0, 0+(-lineHeight*i)+deleteButtonOffset+deleteTopOffset+topOffset) 
        scanFrame[scanFrameButton]:SetSize(deleteButtonSize,deleteButtonSize)
        scanFrame[scanFrameButton]:SetNormalTexture("Interface\\Buttons\\CancelButton-Up")
        scanFrame[scanFrameButton]:SetPushedTexture("Interface\\Buttons\\CancelButton-Down")
        scanFrame[scanFrameButton]:SetHighlightTexture("Interface\\Buttons\\CancelButton-Down")
        scanFrame[scanFrameButton]:SetScript("OnClick", ScanMouseClickHandle)
        scanFrame[scanFrameButton].scanId = i
        scanFrame[scanFrameButton].scanTimestamp = k
        scanFrame[scanFrameButton]:Show()
    end    

    VStoredScansCount = i
    VAuction_VScansCount:SetText("Scans stored: "..VStoredScansCount.."/10")

end

function ScanMouseClickHandle(s,ev)    
    DeleteScan(s.scanTimestamp)
end 

function DeleteScan(scanTimestamp)
    pprint("Removing scan: "..scanTimestamp)
    table.removekey(VossiScanTable, scanTimestamp)
    ListScans()
    if (VStoredScansCount<10) then
        storeBtn = _G["VStoreButton"]
        storeBtn:SetEnabled(true)
    end
end