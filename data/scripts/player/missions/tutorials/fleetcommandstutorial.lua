--[[ 
Changes: 
 - Lady will spawn as a slot 4 ship.
 - Lady can be a Military Ship, Cargo Ship or Miner.
]]

-- Saved Vanilla Function
old_createShip = createShip
function createShip()
    if onClient() then invokeServerFunction("createShip") return end
    if mission.data.custom.shipId and Player():ownsShip(mission.data.custom.shipId.name) then return end

    local faction = Player()

    local translation = random():getDirection() * 1000
    local position = MatrixLookUpPosition(-translation, vec3(0, 1, 0), translation)

    local volume = random():getInt(320, 750)

    -- Get a random volume limiting the ship to Slot 4 Ranges using the default volumes.
    -- Also selects a random type between Military, Cargo and Miner ships.
    local Dice = random():getInt(0, 999)     
    local Type
    local ship if Dice <= 333 then
        Type = "Military" ship = ShipGenerator.createShip(faction, position, volume, true)    
    elseif Dice <= 666 then
        Type = "Freighter" ship = ShipGenerator.createFreighterShip(faction, position, volume, true, true)
    else
        Type = "Miner" ship = ShipGenerator.createMiningShip(faction, position, volume, true, true)
    end

    mission.data.custom.shipId = ship.id.string

    if Type == "Military" then
        ship.title = "Lady Destruction"%_T
    elseif Type == "Freighter" then
        ship.title = "Lady Logistics"%_T
    elseif Type == "Miner" then
        ship.title = "Lady Industrious"%_T
    end

    ship:addCrew(1, CrewMan(CrewProfessionType.Captain))
    ship:registerCallback("onBlockPlanChanged", "onBlockPlanChanged")

    ship.name = "Lady"%_T
    mission.data.custom.shipName = ship.name
end
callable(nil, "createShip")