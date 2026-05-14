local SERVER_ID = 5
rednet.open("top")

print("Sending updated unit configuration to server...")

-- Updated Command 1: Now using "storage_controller_1"
local setCommand = [[unit.set("storage", {"functionalstorage:storage_controller_1", "jumbofurnace:jumbo_furnace_exterior_0", "metalbarrels:crystal_1"})]]
rednet.send(SERVER_ID, {setCommand, 1}, "stockpile")

sleep(1)

-- Updated Command 2: Scan the inventories again
print("Sending scan command...")
local scanCommand = [[scan({"functionalstorage:storage_controller_1", "jumbofurnace:jumbo_furnace_exterior_0", "metalbarrels:crystal_1"})]]
rednet.send(SERVER_ID, {scanCommand, 2}, "stockpile")

print("Done! The server now knows the new ID.")
