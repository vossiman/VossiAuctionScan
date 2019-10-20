# VossiAuctionScan

WoW Classic addon

## Description

bulk scan the AH to file (for later use)

This addon dumps all results of https://wowwiki.fandom.com/wiki/API_GetAuctionItemInfo into a LUA table, that is stored to SavedVariables.
It scans the auction house based on your filter settings, if you put in no filter the whole AH is scanned.
Results are stored in a nicely readable way into SavedVariables

Location on Windows:
> C:\Blizzard\World of Warcraft\_classic_\WTF\Account\ACCOUNTNAME\SavedVariables\VossiAuctionScan.lua

##How to use
    1. Open AH
    2. (optional: set filters)
    3. push "start scan" button
    4. wait for it to finish
    5. store scan (10 slots available)
    6. log out/reload ui (so data is written to disk)
    7. check data in file

 
if you have auctioneer installed, it automatically scans all items in the background additionally, if you use vossi auction scanner 

