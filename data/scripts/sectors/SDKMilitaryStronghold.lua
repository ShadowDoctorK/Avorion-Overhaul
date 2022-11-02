package.path = package.path .. ";data/scripts/lib/?.lua"
package.path = package.path .. ";data/scripts/?.lua"

local ShipGenerator = include("shipgenerator")
local SectorGenerator = include ("SectorGenerator")
local ShipUtility = include("shiputility")
local Placer = include("placer")
include("music")

local SectorTemplate = {}

-- must be defined, will be used to get the probability of this sector
function SectorTemplate.getProbabilityWeight(x, y)
    return 300
end

function SectorTemplate.offgrid(x, y)
    return false
end

-- this function returns whether or not a sector should have space gates
function SectorTemplate.gates(x, y)
    return true
end

-- this function returns what relevant contents there will be in the sector (exact)
function SectorTemplate.contents(x, y)
    local seed = Seed(string.join({GameSeed(), x, y, "SDKMilitaryStronghold"}, "-"))
    math.randomseed(seed);

    local random = random()

    local contents = 
    {
        ships = 0, 
        stations = 0, 
        seed = tostring(seed)
    }

    contents.headquarters = 1
    contents.militaryOutposts = random:getInt(1, 4)
    contents.repairDocks = random:getInt(2, 3)
    contents.shipyards = random:getInt(2, 3)
    contents.equipmentDocks = random:getInt(1, 2)

    if random:test(0.33) then
        contents.turretFactories = 1
        contents.turretFactorySuppliers = 1
    end

    if random:test(0.33) then
        contents.fighterFactories = 1
    end

    -- create defenders
    contents.defenders = random:getInt(8, 15)

    contents.ships = contents.defenders
    contents.stations = contents.headquarters
                        + contents.militaryOutposts
                        + contents.repairDocks
                        + contents.shipyards
                        + contents.equipmentDocks
                        + (contents.turretFactories or 0)
                        + (contents.turretFactorySuppliers or 0)
                        + (contents.fighterFactories or 0)

    local faction = Galaxy():getLocalFaction(x, y) or Galaxy():getNearestFaction(x, y)

    if onServer() then
        contents.faction = faction.index
    end

    return contents, random, faction
end

function SectorTemplate.musicTracks()
    local good = {
        primary = TrackCollection.HappyNoParticle(),
        secondary = TrackCollection.HappyNeutral(),
    }

    local neutral = {
        primary = TrackCollection.Neutral(),
        secondary = TrackCollection.HappyNeutral(),
    }

    local bad = {
        primary = TrackCollection.Middle(),
        secondary = TrackCollection.Neutral(),
    }

    return good, neutral, bad
end

-- player is the player who triggered the creation of the sector (only set in start sector, otherwise nil)
function SectorTemplate.generate(player, seed, x, y)
    local contents, random, faction = SectorTemplate.contents(x, y)

    local generator = SectorGenerator(x, y)

    local stations = {}

    -- Headquarters
    local station = generator:createStation(faction, "data/scripts/entity/merchants/headquarters.lua")
    ShipUtility.addArmedTurretsToCraft(station)
    ShipUtility.addArmedTurretsToCraft(station)
    ShipUtility.addArmedTurretsToCraft(station)
    ShipUtility.addArmedTurretsToCraft(station)

    --[[
    print("Outposts: " .. tostring(contents.militaryOutposts))
    print("Repair Docks: " .. tostring(contents.repairDocks))
    print("Shipyards: " .. tostring(contents.shipyards))
    print("Equip Docks: " .. tostring(contents.equipmentDocks))
    ]]

    -- Other Various Military and Fleet Production Stations
    for i = 1, contents.militaryOutposts do
        local station = generator:createMilitaryBase(faction)
        ShipUtility.addArmedTurretsToCraft(station)
    end

    for i = 1, contents.repairDocks do
        local station = generator:createRepairDock(faction);  
    end
    
    for i = 1, contents.shipyards do
        local station = generator:createShipyard(faction);  
    end

    for i = 1, contents.equipmentDocks do
        local station = generator:createEquipmentDock(faction) 
    end

    -- create a turret factory
    if contents.turretFactories then
        local station = generator:createTurretFactory(faction)
    end

    if contents.turretFactorySuppliers then
        local station = generator:createStation(faction, "data/scripts/entity/merchants/turretfactorysupplier.lua");
    end

    if contents.fighterFactories then
        local station = generator:createFighterFactory(faction)
    end


    -- create defenders
    for i = 1, contents.defenders do
        ShipGenerator.createDefender(faction, generator:getPositionInSector())
    end

    -- maybe create some asteroids
    local numFields = random:getInt(0, 2)
    for i = 1, numFields do
        generator:createEmptyAsteroidField();
    end

    numFields = random:getInt(0, 2)
    for i = 1, numFields do
        generator:createAsteroidField();
    end

    local numSmallFields = random:getInt(0, 5)
    for i = 1, numSmallFields do
        generator:createSmallAsteroidField()
    end

    if SectorTemplate.gates(x, y) then generator:createGates() end

    if random:test(generator:getWormHoleProbability()) then generator:createRandomWormHole() end

    generator:addAmbientEvents()
    Placer.resolveIntersections()
end

-- called by respawndefenders.lua
function SectorTemplate.getDefenders(contents, seed, x, y)
    return contents.faction, contents.defenders
end

return SectorTemplate
