-- Configuration
local SERVER_ID = 5  -- Make sure this matches your main Stockpile server
local MODEM_SIDE = "top" -- Change if the modem on this new PC is on the back/side

rednet.open(MODEM_SIDE)

-- 1. Get all known items from Stockpile
local function getStockpileItems()
    local uuid = math.random(1, 2^31)
    
    -- We use get_content() to pull the entire storage database
    rednet.send(SERVER_ID, {"get_content()", uuid}, "stockpile")
    local id, msg = rednet.receive(3)
    
    local knownItems = {}
    
    if id == SERVER_ID and type(msg) == "table" and msg[2] == uuid then
        local content = msg[1]
        if type(content) == "table" then
            -- Build a lookup table so we can instantly check if an item exists
            for key, value in pairs(content) do
                if type(key) == "string" then
                    -- If the return is a dictionary [id] = count
                    knownItems[key] = true
                elseif type(value) == "table" and value.name then
                    -- If the return is an array of item tables
                    knownItems[value.name] = true
                end
            end
        end
    else
        print("Error: Could not connect to Stockpile server.")
        return nil
    end
    
    return knownItems
end

-- 2. Scan the trash barrels and count ONLY new items
local function analyzeTrash(knownItems)
    local tally = {}
    local barrelCount = 0

    for _, pName in ipairs(peripheral.getNames()) do
        if string.find(pName, "metalbarrels:crystal") then
            barrelCount = barrelCount + 1
            local items = peripheral.call(pName, "list")
            
            if items then
                for slot, item in pairs(items) do
                    -- ONLY add it to our math if Stockpile doesn't know about it!
                    if not knownItems[item.name] then
                        tally[item.name] = (tally[item.name] or 0) + item.count
                    end
                end
            end
        end
    end
    
    return tally, barrelCount
end

-- 3. The Main Program
local function run()
    term.clear()
    term.setCursorPos(1, 1)
    print("Fetching data from Stockpile...")
    
    local knownItems = getStockpileItems()
    if not knownItems then return end
    
    print("Scanning Bordelčestka...")
    local trashTally, barrelCount = analyzeTrash(knownItems)
    
    -- Convert our tally into a list so we can sort it
    local sortedList = {}
    for name, count in pairs(trashTally) do
        table.insert(sortedList, {name = name, count = count})
    end
    
    -- Sort the list from highest count to lowest count
    table.sort(sortedList, function(a, b) return a.count > b.count end)
    
    -- Display the results
    term.clear()
    term.setCursorPos(1, 1)
    term.setTextColor(colors.yellow)
    print("--- Top Unassigned Items (" .. barrelCount .. " Barrels) ---")
    term.setTextColor(colors.white)
    
    if #sortedList == 0 then
        term.setTextColor(colors.green)
        print("\nGood job! Everything in the trash already has a slot in your main storage.")
    else
        -- Print up to the top 15 items so it fits on a normal computer screen
        local maxItems = math.min(#sortedList, 15)
        for i = 1, maxItems do
            local item = sortedList[i]
            
            -- Clean up the name by removing "minecraft:" or the mod name prefix
            local cleanName = item.name:gsub("^.-:", "")
            
            -- Format it into
