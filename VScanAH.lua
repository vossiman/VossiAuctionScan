scanInProgress = false
scanStepInProgress = false


nextButton=nil
statusbar = nil

local waitCount=0
 
VCurrentScan = {}
scanTimestamp = ""

local timeAuctionStarted = nil

VAuction_EventFrame:Hide()


function ScanAuctionHouse(...)
    timeAuctionStarted = time()
    VCurrentScan = {}
    updateCount=0
    
    dprint("[u"..updateCount.."] Auction list update started")
    scanInProgress = true
    scanStepInProgress = true

    scanTimestamp = date("%m/%d/%y %H:%M:%S")
    pprint("Starting auction house scan for snapshot: "..scanTimestamp)
    -- clicking the search button
    local Button=_G["BrowseSearchButton"]
    Button:Click("LeftButton", true)
    
end

function waitForScanFinish()    
    if (scanInProgress) then 
        waitCount = waitCount + 1
        if (nextButton:IsEnabled()) then
            dprint("  [w"..waitCount.."] Auction list update finished!!!!")
            waitCount = 0
            readCurrentAuctionPage()
        else 
            -- exit condition if we are at the last page            
            if (IsAuctionOnLastPage()) then
                dprint("  [w"..waitCount.."] Auction last page detected")
                waitCount = 0
                readCurrentAuctionPage()
            else
                dprint("  [w"..waitCount.."] Auction list update not finished - waiting")
                vossi__wait(0.5, waitForScanFinish)
            end
        end    
    end
end

function readCurrentAuctionPage() 
    local numBatchAuctions, totalAuctions = GetNumAuctionItems("list");
    updateScanStats()
    dprint(numBatchAuctions.." Auctions to process")
    for i=1,numBatchAuctions do 
        local values = { GetAuctionItemInfo("list", i); }

        hasAllInfo = values[18]
        itemId = values[17]
        name = values[1]
        auctionTimeleft = GetAuctionItemTimeLeft("list", i);
        values[19] = auctionTimeleft

        if (not hasAllInfo or itemId <=0 or not name) then
            dprint('['..i..'] name is null or hasAllInfo = FALSE or itemId <= 0')
            break
        end

        local currentItemcount = table.getn(VCurrentScan)
        VCurrentScan [currentItemcount+1] = values
    end   
    local currentItemcount = table.getn(VCurrentScan)
    dprint(currentItemcount.." in total now stored to VCurrentScan")
    scanStepInProgress = false   
    readNextAuctionPage()
end

function CancelScan(...)
    scanInProgress = false
    scanStepInProgress = false
    pprint("Scan canceled")
    finishAuctionScan(true) 
end

function finishAuctionScan(scanCanceled)
    scanStepInProgress = false
    scanInProgress = false    
    updateScanStats(scanCanceled, true)
    local currentItemcount=table.getn(VCurrentScan)
    pprint("Finished Scan, "..currentItemcount.." items ready to store!")
    StoreScan()
    scanBtn:SetText("Start scan")
    enableStartScan(true)    
    ListScans()
end

function updateScanStats(scanCanceled,scanFinished)
    local numBatchAuctions, totalAuctions = GetNumAuctionItems("list");
    local readAuctions = table.getn(VCurrentScan)
    local percent = 0
    if (readAuctions>0) then
        percent = readAuctions/totalAuctions*100
    end

    if (not scanCanceled and scanFinished) then
        percent = 100.0
        totalAuctions = readAuctions
    end

    timeNow = time()
    timeSpent = timeNow - timeAuctionStarted

    minutesSpent = truncate(timeSpent/60,0)
    secondsSpent = truncate(timeSpent - (minutesSpent * 60),0)

    VAuction_ScanName:SetText("Scan Snapshot Name: "..scanTimestamp)
    if (scanFinished) then
        VAuction_TimePredictText:SetText("Scan finished")
    else
        -- first page can't calculate time left yet
        if (timeSpent > 0 and readAuctions>0) then
            timeLeft = (timeSpent/readAuctions*totalAuctions)-timeSpent
            minutesLeft = truncate(timeLeft/60,0)
            secondsLeft = truncate(timeLeft - (minutesLeft * 60),0)
            VAuction_TimePredictText:SetText("Time left: "..minutesLeft.." min "..secondsLeft.." sec")
        else
            VAuction_TimePredictText:SetText("Time left: calculating")
        end        
    end
    VAuction_TimeSpentText:SetText("Time spent: "..minutesSpent.." min "..secondsSpent.." sec")
    VAuction_ScanText:SetText("Scanned "..readAuctions.." of "..totalAuctions.." items")

    statusbar:SetValue(percent)
    statusbar.value:SetText(string.format("%.1f",percent)..'%')
    --dprint(readAuctions..'/'..totalAuctions..' --> '..string.format("%.3f",percent)..'%')
end

function IsAuctionOnLastPage(offsetValue)
    offsetVal = 1
    if (offsetValue) then
        offsetVal=offsetValue
    end
    local scansPerPage = 50
    local numBatchAuctions, totalAuctions = GetNumAuctionItems("list");
    local currentItemcount=table.getn(VCurrentScan)
    local currentPage = ceil(currentItemcount/scansPerPage)+offsetVal
    if (currentPage <= 1) then
        currentPage = 1
    end
    local maxPages = ceil(totalAuctions/scansPerPage) 
    dprint("IsAuctionOnLastPage - now on page: "..currentPage.."/"..maxPages)
    if (currentPage==maxPages) then
        return true
    else
        return false
    end
end

function readNextAuctionPage() 
    dprint("readNextAuctionPage")
    if (scanInProgress) then
        -- exit condition - we've scanned a total amount of more items than there is listed                
        if (IsAuctionOnLastPage(0)) then
            finishAuctionScan()
        else 
            updateScanStats()
            -- go to next page
            scanStepInProgress = true
            nextButton:Click("LeftButton", true)
        end        
    end
end

function StoreScan(...) 
    scanCount = table.getn(VossiScanTable)
    VossiScanTable [scanTimestamp] = {}
    VCopy_Table(VCurrentScan, VossiScanTable [scanTimestamp])
end