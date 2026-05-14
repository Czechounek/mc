local SERVER_ID = 5
rednet.open("top")

print("Reorganizing Stockpile units...")

-- 1. Redefine 'storage' to REMOVE the metal barrel
local updateStorage = [[unit.set("storage", {"functionalstorage:storage_controller_1", "jumbofurnace:jumbo_furnace_exterior_0"})]]
rednet.send(SERVER_ID, {updateStorage, 1}, "stockpile")
sleep(0.5)

-- 2. Create the new 'bordelchest' unit and ADD the metal barrel to it
local createBordel = [[unit.set("bordelchest", {"metalbarrels:crystal_1"})]]
rednet.send(SERVER_ID, {createBordel, 2}, "stockpile")
sleep(0.5)

-- 3. (Optional but recommended) Tell Stockpile to ignore the trash chest in searches
local ignoreBordel = [[unit.is_io("bordelchest", false)]]
rednet.send(SERVER_ID, {ignoreBordel, 3}, "stockpile")
sleep(0.5)

-- 4. Rescan everything so the server remembers the new slot counts
local scanAll = [[scan({"functionalstorage:storage_controller_1", "jumbofurnace:jumbo_furnace_exterior_0", "metalbarrels:crystal_1"})]]
rednet.send(SERVER_ID, {scanAll, 4}, "stockpile")

print("Done! Your units are now separated.")
