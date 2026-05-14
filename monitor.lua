-- Configuration
local SERVER_ID = 5  -- Your Server ID
local UPDATE_INTERVAL = 3 
local MODEM_SIDE = "top" -- Your modem is on top

-- Your trash chests go here
local TRASH_CHESTS = {
    "metalbarrels:crystal_1"
}

rednet.open(MODEM_SIDE)

local display = peripheral.find("monitor") or term
if display == peripheral.find("monitor") then
    display.setTextScale(1)
end

-- Upgraded Progress Bar
local function drawProgressBar(used, total, y, barColor)
    local width, _ = display.getSize()
    local barWidth = width - 4
    
    local fillRatio = 0
    if total > 0 then
        fillRatio = math.min(1, used / total)
    end
    
    local fillWidth = math.floor(fillRatio * barWidth)
    
    display.setCursorPos(2, y)
    display.setBackgroundColor(colors.gray)
    display.write(string.rep(" ", barWidth))
    
    display.setCursorPos(2, y)
    display.setBackgroundColor(barColor)
    display.write(string.rep(" ", fillWidth))
    
    display.setBackgroundColor(colors.black)
end

-- Checks the physical barrel directly
local function getTrashUsage()
    local totalUsed = 0
    local totalCap = 0
    local foundAny = false

    for _, name in ipairs(TRASH_CHESTS) do
        if peripheral.isPresent(name) then
            foundAny = true
            totalCap = totalCap + peripheral.call(name, "size")
            
            local items = peripheral.call(name, "list")
            if items then
                for k, v in pairs(items) do
                    totalUsed = totalUsed + 1
                end
            end
        end
    end

    if foundAny then
        return totalUsed, totalCap
    else
        return nil, nil
    end
end

-- Asks the server for the main storage
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
        -- 1. FETCH ALL DATA FIRST (This prevents the screen from blinking while waiting)
        local data = fetchStorageData()
        local tUsed, tCap = getTrashUsage()
        
        -- 2. NOW CLEAR AND DRAW INSTANTLY
        display.setBackgroundColor(colors.black)
        display.clear()
        
        -- =====================================
        --      SECTION 1: MAIN STORAGE
        -- =====================================
        display.setCursorPos(1, 1)
        display.setTextColor(colors.yellow)
        display.write(" --- Main Storage --- ")
        display.setTextColor(colors.white)
        
        if type(data) == "table" and data.total_slots then
            -- Fixing the mod author's typo again
            local total = data.used_slots
            local used = data.total_slots
            local percent = 0
            if total > 0 then percent = math.floor((used / total) * 100) end
            
            display.setCursorPos(2, 3)
            display.write("Slots: " .. used .. " / " .. total .. "  (" .. percent .. "%)")
            
            -- Draw a green progress bar on row 5
            drawProgressBar(used, total, 5, colors.green)
            
        else
            display.setTextColor(colors.red)
            display.setCursorPos(2, 3)
            display.write("Status: SERVER DISCONNECTED / ERROR")
        end
        
        -- =====================================
        --      SECTION 2: BORDELCESTKA
        -- =====================================
        display.setCursorPos(1, 8)
        display.setTextColor(colors.orange)
        display.write(" --- Bordelcestka --- ")
        display.setTextColor(colors.white)
        
        if tCap then
            local tPercent = 0
            if tCap > 0 then tPercent = math.floor((tUsed / tCap) * 100) end
            
            display.setCursorPos(2, 10)
            display.write("Slots: " .. tUsed .. " / " .. tCap .. "  (" .. tPercent .. "%)")
            
            -- Draw an orange progress bar on row 12
            drawProgressBar(tUsed, tCap, 12, colors.orange)
        else
            display.setTextColor(colors.gray)
            display.setCursorPos(2, 10)
            display.write("Status: BARREL DISCONNECTED")
        end
        
        -- =====================================
        --               FOOTER
        -- =====================================
        display.setTextColor(colors.gray)
        local _, height = display.getSize()
        display.setCursorPos(2, height)
        display.write("Refreshing in " .. UPDATE_INTERVAL .. "s...")
        
        sleep(UPDATE_INTERVAL)
    end
end

updateScreen()
