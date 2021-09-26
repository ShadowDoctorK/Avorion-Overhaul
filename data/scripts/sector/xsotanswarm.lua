package.path = package.path .. ";data/scripts/lib/?.lua"
package.path = package.path .. ";data/scripts/?.lua"
package.path = package.path .. ";?"

include("randomext")
include("galaxy")
local Xsotan = include("story/xsotan")
local SpawnUtility = include("spawnutility")
local ShipUtility = include("shiputility")
local SectorGenerator = include ("SectorGenerator")
local SectorTurretGenerator = include ("sectorturretgenerator")
local Log = include("SDKDebugLogging")

local _Debug = 0
local _ModName = "Xsotan Swarm" function GetName(n)
    return _ModName .. " - " .. n
end

--[[
function XsotanSwarm.spawnBackgroundXsotan()
    if XsotanSwarm.countAliveXsotan() > 15 then return end

    local generator = SectorGenerator(Sector():getCoordinates())

    local xsotan = Xsotan.createShip(generator:getPositionInSector(), 1.0)
    if not valid(xsotan) then return end

    xsotan:setValue("xsotan_spawn_limit", 1)
    xsotan:setValue("xsotan_destruction_limit", 1)
    for _, p in pairs({Sector():getPlayers()}) do
        ShipAI(xsotan.id):registerEnemyFaction(p.index)
    end
    ShipAI(xsotan.id):setAggressive()
end

function XsotanSwarm.spawnHenchmenXsotan(num)

    local generator = SectorGenerator(Sector():getCoordinates())

    local ships = {}
    local i
    for i = 0, num do
        local xsotan = Xsotan.createShip(generator:getPositionInSector(), 1.0)
        if not valid(xsotan) then return end

        table.insert(ships, xsotan)
        xsotan:setValue("xsotan_destruction_limit", 1)
        for _, p in pairs({Sector():getPlayers()}) do
            ShipAI(xsotan.id):registerEnemyFaction(p.index)
        end
        ShipAI(xsotan.id):setAggressive()
    end

    SpawnUtility.addEnemyBuffs(ships)
end

function XsotanSwarm.spawnLevel2()
    data.level2Spawned = true

    local generator = SectorGenerator(Sector():getCoordinates())
    local xsotan = Xsotan.createShip(generator:getPositionInSector(), 10.0)
    if not valid(xsotan) then return end

    xsotan:setValue("xsotan_swarm_boss", 1)
    xsotan.title = "Xsotan Emissary"%_T
    for _, p in pairs({Sector():getPlayers()}) do
        ShipAI(xsotan.id):registerEnemyFaction(p.index)
    end
    ShipAI(xsotan.id):setAggressive()

    -- spawn henchmen
    XsotanSwarm.spawnHenchmenXsotan(3)
end

function XsotanSwarm.spawnLevel3()
    data.level3Spawned = true

    local generator = SectorGenerator(Sector():getCoordinates())
    local xsotan = Xsotan.createQuantum(generator:getPositionInSector(), 15.0)
    if not valid(xsotan) then return end

    Loot(xsotan.index):insert(XsotanSwarm.generateUpgrade())
    Loot(xsotan.index):insert(XsotanSwarm.generateUpgrade())
    WreckageCreator(xsotan.index).active = false

    xsotan:setValue("xsotan_swarm_boss", 1)
    for _, p in pairs({Sector():getPlayers()}) do
        ShipAI(xsotan.id):registerEnemyFaction(p.index)
    end
    ShipAI(xsotan.id):setAggressive()

    -- spawn henchmen
    XsotanSwarm.spawnHenchmenXsotan(3)
end

function XsotanSwarm.spawnLevel4()
    data.level4Spawned = true

    local generator = SectorGenerator(Sector():getCoordinates())
    local xsotan = Xsotan.createSummoner(generator:getPositionInSector(), 15.0)
    if not valid(xsotan) then return end
    WreckageCreator(xsotan.index).active = false

    local x, y = Sector():getCoordinates()
    Loot(xsotan.index):insert(InventoryTurret(SectorTurretGenerator():generate(x, y, 0, Rarity(RarityType.Exotic))))
    Loot(xsotan.index):insert(InventoryTurret(SectorTurretGenerator():generate(x, y, 0, Rarity(RarityType.Exotic))))

    xsotan:setValue("xsotan_swarm_boss", 1)
    for _, p in pairs({Sector():getPlayers()}) do
        ShipAI(xsotan.id):registerEnemyFaction(p.index)
    end
    ShipAI(xsotan.id):setAggressive()

    -- spawn henchmen
    XsotanSwarm.spawnHenchmenXsotan(3)
end

function XsotanSwarm.spawnLevel5()
    data.level5Spawned = true
    Server():setValue("xsotan_swarm_precursor_fight", true)

    -- spawn guardian precursor
    local generator = SectorGenerator(Sector():getCoordinates())
    local precursor = XsotanSwarm.spawnPrecursor(generator:getPositionInSector(), 0.8)
    if not valid(precursor) then return end
    Sector():addScriptOnce("story/guardianprecursorbar.lua")

    -- set enemy factions
    for _, p in pairs({Sector():getPlayers()}) do
        ShipAI(precursor.id):registerEnemyFaction(p.index)
    end
    ShipAI(precursor.id):setAggressive()

    -- add loot
    Loot(precursor.index):insert(XsotanSwarm.generateUpgrade())
    Loot(precursor.index):insert(XsotanSwarm.generateUpgrade())
    Loot(precursor.index):insert(XsotanSwarm.generateUpgrade())
    Loot(precursor.index):insert(XsotanSwarm.generateUpgrade())

    -- extend global event time limit
    local server = Server()
    local timer = server:getValue("xsotan_swarm_duration")
    if timer == (30 * 60) then
        server:setValue("xsotan_swarm_duration", timer + (10 * 60))
    end

end
]]

-- Saved Vanilla Function
XsotanSwarm.old_spawnPrecursor =  XsotanSwarm.spawnPrecursor
function XsotanSwarm.spawnPrecursor(position, scale) local _MethodName = GetName("Spwan Precursor")
    -- Use the loaded Designs or Generate if no Designs Exist
    local boss = Xsotan.createProtoGuardian(nil, true) 
    boss:addScript("icon.lua", "data/textures/icons/pixel/enemy-strength-indicators/skull.png")
    return boss
end