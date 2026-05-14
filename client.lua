local SERVER_ID = 5
rednet.open("top")

print("Sending unit configuration to server...")

-- Command 1: Create the storage unit
local setCommand = [[unit.set("storage", {"functionalstorage:storage_controller_0", "jumbofurnace:jumbo_furnace_exterior_0", "metalbarrels:crystal_1"})]]
rednet.send(SERVER_ID, {setCommand, 1}, "stockpile")

sleep(1) -- Wait 1 second to let the server process

-- Command 2: Scan the inventories
print("Sending scan command...")
local scanCommand = [[scan({"functionalstorage:storage_controller_0", "jumbofurnace:jumbo_furnace_exterior_0", "metalbarrels:crystal_1"})]]
rednet.send(SERVER_ID, {scanCommand, 2}, "stockpile")

print("Done! You can now run your monitor program.")
