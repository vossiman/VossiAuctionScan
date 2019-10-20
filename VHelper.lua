
debugging = false

local waitTable = {};
local waitFrame = nil;

-- async wait function
function vossi__wait(delay, func, ...)
  if (not scanInProgress) then return false end
  if(type(delay)~="number" or type(func)~="function") then
    return false;
  end
  if(waitFrame == nil) then
    waitFrame = CreateFrame("Frame","WaitFrame", UIParent);
    waitFrame:SetScript("onUpdate",function (self,elapse)
      local count = #waitTable;
      local i = 1;
      while(i<=count) do
        local waitRecord = tremove(waitTable,i);
        local d = tremove(waitRecord,1);
        local f = tremove(waitRecord,1);
        local p = tremove(waitRecord,1);
        if(d>elapse) then
          tinsert(waitTable,i,{d-elapse,f,p});
          i = i + 1;
        else
          count = count - 1;
          f(unpack(p));
        end
      end
    end);
  end
  tinsert(waitTable,{delay,func,{...}});
  return tr
end

function truncate(number, decimals)
    return number - (number % (0.1 ^ decimals))
end

function pprint(input)
    print("|cFF00FF00vossi auction scanner|r: "..input)
end

function dprint(input)
    if (debugging) then 
        print("|cFF00FF00vossi auction scanner|r [|cFFFF0000debug|r] "..input)
    end
end

function table.removekey(table, key)
    local element = table[key]
    table[key] = nil
    return element
end