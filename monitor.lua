local UPDATE_INTERVAL = 3 -- Refresh every 3 seconds

-- Auto-detect external monitor, or default to the computer terminal
local display = peripheral.find("monitor") or term
if display == peripheral.find("monitor") then
    display.setTextScale(1) -- Adjust this number if the text is too big/small on your monitor
end

local function drawProgressBar(used, total, y)
    local width, _ = display.getSize()
    local barWidth = width - 4
    local fillWidth = math.floor((used / total) * barWidth)
    
    -- Draw background
    display.setCursorPos(2, y)
    display.setBackgroundColor(colors.gray)
    display.write(string.rep(" ", barWidth))
    
    -- Draw fill
    display.setCursorPos(2, y)
    display.setBackgroundColor(colors.green)
    display.write(string.rep(" ", fillWidth))
    
    display.setBackgroundColor(colors.black)
end

local function fetchStorageData()
    -- Since we are running on the server itself, we try to call the API directly
    -- instead of using Rednet. 
    if type(usage) == "function" then
        return usage()
    elseif _G.stockpile and type(_G.stockpile.usage) == "function" then
        return _G.stockpile.usage()
    end
    return nil
end

local function updateScreen()
    while true do
        display.clear()
        display.setCursorPos(1, 1)
        display.setTextColor(colors.yellow)
        display.write(" --- Local Storage Monitor --- ")
        display.setTextColor(colors.white)
        
        -- Fetch local data directly
        local data = fetchStorageData()
        
        if data and data.total_slots then
            local used = data.used_slots
            local total = data.total_slots
            local percent = math.floor((used / total) * 100)
            
            display.setCursorPos(2, 3)
            display.write("Status: ONLINE (Local)")
            
            display.setCursorPos(2, 5)
            display.write("Used Slots:  " .. used)
            
            display.setCursorPos(2, 6)
            display.write("Total Cap:   " .. total)
            
            display.setCursorPos(2, 8)
            display.write("Fullness:    " .. percent .. "%")
            
            drawProgressBar(used, total, 10)
        else
            display.setTextColor(colors.red)
            display.setCursorPos(2, 3)
            display.write("Error: Could not read local data.")
            display.setCursorPos(2, 4)
            display.write("API function 'usage()' not found.")
        end
        
        display.setTextColor(colors.gray)
        display.setCursorPos(1, 12)
        display.write("Refreshing in " .. UPDATE_INTERVAL .. "s...")
        
        sleep(UPDATE_INTERVAL)
    end
end

-- Start the display loop
updateScreen()