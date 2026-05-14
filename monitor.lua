-- Configuration
local SERVER_ID = 5  -- Your Server ID
local UPDATE_INTERVAL = 3 
local MODEM_SIDE = "top" -- Your modem is on top

rednet.open(MODEM_SIDE)

local display = peripheral.find("monitor") or term
if display == peripheral.find("monitor") then
    display.setTextScale(1)
end

local function drawProgressBar(used, total, y)
    local width, _ = display.getSize()
    local barWidth = width - 4
    
    -- SAFETY CLAMP: math.min ensures the ratio never goes above 1 (100%)
    -- even if the data gets weird again.
    local fillRatio = math.min(1, used / total)
    local fillWidth = math.floor(fillRatio * barWidth)
    
    display.setCursorPos(2, y)
    display.setBackgroundColor(colors.gray)
    display.write(string.rep(" ", barWidth))
    
    display.setCursorPos(2, y)
    display.setBackgroundColor(colors.green)
    display.write(string.rep(" ", fillWidth))
    
    display.setBackgroundColor(colors.black)
end

local function fetchStorageData()
    local requestUUID = math.random(1, 2^31)
    
    rednet.send(SERVER_ID, {"usage()", requestUUID}, "stockpile")
    local id, message = rednet.receive(3)
    
    if id == SERVER_ID and type(message) == "table" and message[2] == requestUUID then
        return message[1]
    end
    
    return nil
end

local function updateScreen()
    while true do
        display.clear()
        display.setCursorPos(1, 1)
        display.setTextColor(colors.yellow)
        display.write(" --- Stockpile Storage Monitor --- ")
        display.setTextColor(colors.white)
        
        local data = fetchStorageData()
        
        if type(data) == "table" and data.total_slots then
            -- THE FIX: We swapped 'used' and 'total' here to fix the mod author's typo!
            local total = data.used_slots
            local used = data.total_slots
            local percent = math.floor((used / total) * 100)
            
            display.setCursorPos(2, 3)
            display.write("Status: ONLINE")
            
            display.setCursorPos(2, 5)
            display.write("Used Slots:  " .. used)
            
            display.setCursorPos(2, 6)
            display.write("Total Cap:   " .. total)
            
            display.setCursorPos(2, 8)
            display.write("Fullness:    " .. percent .. "%")
            
            drawProgressBar(used, total, 10)
            
        elseif type(data) == "string" then
            display.setTextColor(colors.red)
            display.setCursorPos(2, 3)
            display.write("Server API Error:")
            
            display.setTextColor(colors.white)
            display.setCursorPos(2, 5)
            local shortError = string.sub(data, 1, 35) .. "..."
            display.write(shortError)
            
        else
            display.setTextColor(colors.red)
            display.setCursorPos(2, 3)
            display.write("Error: Timeout.")
            display.setCursorPos(2, 4)
            display.write("Waiting for Server ID: " .. SERVER_ID)
        end
        
        display.setTextColor(colors.gray)
        display.setCursorPos(1, 12)
        display.write("Refreshing in " .. UPDATE_INTERVAL .. "s...")
        
        sleep(UPDATE_INTERVAL)
    end
end

updateScreen()
