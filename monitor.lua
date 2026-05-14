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
    local fillWidth = math.floor((used / total) * barWidth)
    
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
    
    -- ADDED "stockpile" PROTOCOL HERE
    rednet.send(SERVER_ID, {"usage()", requestUUID}, "stockpile")
    
    -- LISTENING FOR "stockpile" PROTOCOL HERE
    local id, message = rednet.receive("stockpile", 3)
    
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
        
        if data and data.total_slots then
            local used = data.used_slots
            local total = data.total_slots
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
        else
            display.setTextColor(colors.red)
            display.setCursorPos(2, 3)
            display.write("Error: Timeout or invalid data.")
            display.setCursorPos(2, 4)
            display.write("Waiting for Server ID: " .. SERVER_ID)
        end
        
        display.setTextColor(colors.gray)
        display.setCursorPos(1, 12)
        display.write("Refreshing in " .. UPDATE_INTERVAL .. "s...")
        
        sleep(UPDATE_INTERVAL)
    end
end

-- Make sure you type 'exit()' in the server's lua prompt and 
-- reboot the server so Stockpile is running normally again!
updateScreen()
