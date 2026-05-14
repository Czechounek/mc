-- Configuration
local SERVER_ID = 123  -- CHANGE THIS to your Stockpile Server's Computer ID!
local UPDATE_INTERVAL = 3 
local MODEM_SIDE = "back" -- Change to the side your modem is on

-- Initialize Rednet
if not rednet.isOpen(MODEM_SIDE) then
    rednet.open(MODEM_SIDE)
end

-- Setup displays
local monitor = peripheral.find("monitor")
local display = monitor or term

if monitor then
    monitor.setTextScale(1)
end

-- Logging function (Forces output to the computer's main screen, not the monitor)
local function logData(msg)
    local oldTerm = term.redirect(term.native())
    print("[LOG] " .. msg)
    term.redirect(oldTerm)
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
    
    logData("--------------------------------")
    logData("Sending 'usage()' to Server ID: " .. SERVER_ID)
    logData("UUID: " .. requestUUID)
    
    rednet.send(SERVER_ID, {"usage()", requestUUID})
    
    logData("Waiting 3s for response...")
    local senderId, message = rednet.receive(3)
    
    -- Check for timeout
    if not senderId then
        logData("ERROR: Timeout. No response from server.")
        return nil
    end
    
    logData("Received response from ID: " .. tostring(senderId))
    logData("Message type: " .. type(message))
    
    -- If it's not from our server, ignore it but log it
    if senderId ~= SERVER_ID then
        logData("WARNING: Ignored message from wrong ID.")
        return nil
    end
    
    -- Check data formatting
    if type(message) == "table" then
        logData("Data[1] type: " .. type(message[1]))
        logData("Data[2] UUID: " .. tostring(message[2]))
        
        if message[2] == requestUUID then
            logData("SUCCESS: Valid data verified.")
            return message[1]
        else
            logData("ERROR: UUID mismatch.")
        end
    else
        logData("ERROR: Response was not a table. Raw content: " .. tostring(message))
    end
    
    return nil
end

local function updateScreen()
    term.native().clear()
    term.native().setCursorPos(1,1)
    logData("Starting Stockpile Diagnostic Monitor...")

    while true do
        display.clear()
        display.setCursorPos(1, 1)
        display.setTextColor(colors.yellow)
        display.write(" --- Stockpile Storage Monitor --- ")
        display.setTextColor(colors.white)
        
        local data = fetchStorageData()
        
        if type(data) == "table" and data.total_slots then
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
            display.write("Error: Could not connect to server.")
            display.setCursorPos(2, 4)
            display.write("Check logs on computer terminal.")
        end
        
        display.setTextColor(colors.gray)
        display.setCursorPos(1, 12)
        display.write("Refreshing in " .. UPDATE_INTERVAL .. "s...")
        
        sleep(UPDATE_INTERVAL)
    end
end

-- Start the loop
updateScreen()
