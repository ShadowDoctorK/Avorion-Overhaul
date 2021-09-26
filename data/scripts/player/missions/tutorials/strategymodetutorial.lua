--[[
    Developer Notes:
    - Rework this mission to allow the player to pick which type of ship they want.
]]

--[[ 
    Changes: 
    - Limited Volume to 4 slot ship
    - 3 Types can randomly spawn (Fighter, Miner, Hauler)
]]

function createLady()
    local sector = Sector()
    if sector:getEntitiesByScriptValue("strategy_command_lady") then return end
    if mission.data.custom.ladyGivenToPlayer then return end

    local adventShip = sector:getEntitiesByScript("story/missionadventurer.lua")
    if not adventShip then resetToPhase(2, true) return end

    local faction = Faction(adventShip.factionIndex)

    -- Replaced Volume (4 slot ship)
    local volume = random():getInt(320, 750)

    local adventurerPosition = adventShip.position
    local translation = random():getDirection() * 100
    local position = MatrixLookUpPosition(adventurerPosition.look, adventurerPosition.up, adventurerPosition.pos + translation)

    -- Get a random volume limiting the ship to Slot 4 Ranges using the default volumes.
    -- Also selects a random type between Military, Cargo and Miner ships.
    local Dice = random():getInt(0, 999)     
    local Type local ship if Dice <= 333 then
        Type = "Military" ship = ShipGenerator.createShip(faction, position, volume, true)    
    elseif Dice <= 666 then
        Type = "Freighter" ship = ShipGenerator.createFreighterShip(faction, position, volume, true, true)
    else
        Type = "Miner" ship = ShipGenerator.createMiningShip(faction, position, volume, true, true)
    end

    mission.data.custom.shipId = ship.id.string

    -- Customize the Ships title based on the type of ship
    if Type == "Military" then
        ship.title = "Lady Destruction"%_T
    elseif Type == "Freighter" then
        ship.title = "Lady Logistics"%_T
    elseif Type == "Miner" then
        ship.title = "Lady Industrious"%_T
    end

    ship.name = "Ol' Gal"%_T

    ship:setValue("strategy_command_lady", true)
    mission.data.custom.shipName = ship.name

    -- add deletion script in case something goes wrong, and we never give the ship to player => if given to player remove it!
    ship:addScriptOnce("data/scripts/entity/deleteonplayersleft.lua")
end