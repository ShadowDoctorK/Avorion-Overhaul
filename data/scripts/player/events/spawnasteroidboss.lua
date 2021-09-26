--[[
package.path = package.path .. ";data/scripts/lib/?.lua"
package.path = package.path .. ";data/scripts/?.lua"
include ("randomext")
include ("utility")

local shipGenerator = include("shipgenerator")
local SectorGenerator = include("SectorGenerator")
local AsteroidFieldGenerator = include("asteroidfieldgenerator")
local PlanGenerator = include ("plangenerator")
local ShipUtility = include ("shiputility")
local SectorSpecifics = include ("sectorspecifics")
local SectorTurretGenerator = include ("sectorturretgenerator")

-- Don't remove or alter the following comment, it tells the game the namespace this script lives in. If you remove it, the script will break.
-- namespace SpawnAsteroidBoss
SpawnAsteroidBoss = {}
local boss = nil
local data = {}
data.num = 0
data.done = false
data.visited = {}
data.countVisited = 0
]]

if onServer() then

    --[[
    function SpawnAsteroidBoss.initialize()
        Player():registerCallback("onSectorEntered", "onSectorEntered")
    end

    function SpawnAsteroidBoss.onSectorEntered(player, x, y, changeType)
        if changeType ~= SectorChangeType.Jump then return end

        local specs = SectorSpecifics()
        local serverSeed = Server().seed
        local regular, offgrid, blocked, home = specs:determineContent(x, y, serverSeed)

        if not regular and offgrid and not blocked and not home then
            specs:initialize(x, y, serverSeed)

            if specs.generationTemplate.path == "sectors/asteroidshieldboss" then
                if onServer() then
                    -- only spawn him once
                    local sector = Sector()
                    if sector:getEntitiesByScript("data/scripts/entity/events/asteroidshieldboss.lua") then return end

                    local visited = false
                    for _, p in pairs(data.visited) do
                        if p.x == x and p.y == y then
                            visited = true
                        end
                    end

                    if not visited then
                        local coords = {x, y}
                        table.insert(data.visited, coords)
                        data.countVisited = data.countVisited + 1

                        -- delete everything not player owned
                        local entities = {sector:getEntities()}
                        for _, entity in pairs(entities) do
                            if not entity.allianceOwned and not entity.playerOwned then
                                sector:deleteEntity(entity)
                            end
                        end

                        local value = data.countVisited
                        if value == 4 then
                            data.num = 4
                            SpawnAsteroidBoss.createBoss()
                            data.visited = {}
                            data.countVisited = 0

                        elseif value == 3 then
                            data.num = 3
                            SpawnAsteroidBoss.createShieldAsteroids()

                        elseif value == 2 then
                            data.num = 2
                            SpawnAsteroidBoss.createShieldAsteroids()

                        else
                            data.num = 1
                            SpawnAsteroidBoss.createShieldAsteroids()
                        end
                    end
                end
            end
        end
    end
    ]]

    local Volume = include("SDKGlobalDesigns - Volumes")
    local Equip = include("SDKGlobalDesigns - Equipment")

    -- Saved Vanilla Function
    SpawnAsteroidBoss.old_createBoss = SpawnAsteroidBoss.createBoss
    function SpawnAsteroidBoss.createBoss()
        -- no double spawning
        if Sector():getEntitiesByScript("entity/events/asteroidshieldboss.lua") then return end

        local faction = SpawnAsteroidBoss.getFaction()
        --local volume = Balancing_GetSectorShipVolume(Sector():getCoordinates()) * 30

        ----------------- Create Aseroid Boss ----------------
        -- Slot 9 to 12
        local Chances = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 250, 500, 550, 1000, 1000, 1000}
        -- Get Volume Ranges
        local volume = Volume.Ship(Chances)
        -- Override the Volume Passing Custom Volume
        local o = PlanGenerator.GetOverride("Military", volume, nil, "Boss 8055")
        local plan = PlanGenerator.Ship(faction, "Boss 8055", o)

        local boss = Sector():createShip(faction, "", plan, Matrix(), EntityArrivalType.Jump)
        boss:addScript("icon.lua", "data/textures/icons/pixel/enemy-strength-indicators/skull.png")
        boss.crew = boss.minCrew
        boss.shieldDurability = boss.shieldMaxDurability
        AddDefaultShipScripts(boss)
        SetBoardingDefenseLevel(boss)
        -------------------------------------------------------

        -- add turrets
        local x, y = Sector():getCoordinates()
        local generator = SectorTurretGenerator()

        local railGunLow = generator:generate(x, y, 0, Rarity(RarityType.Exceptional), WeaponType.RailGun)
        local railGunHigh = generator:generate(x, y, 0, Rarity(RarityType.Exotic), WeaponType.RailGun)
        ShipUtility.addTurretsToCraft(boss, railGunLow, 3)
        ShipUtility.addTurretsToCraft(boss, railGunHigh, 2)

        local cannonLow = generator:generate(x, y, 0, Rarity(RarityType.Exceptional), WeaponType.Cannon)
        local cannonHigh = generator:generate(x, y, 0, Rarity(RarityType.Exotic), WeaponType.Cannon)
        ShipUtility.addTurretsToCraft(boss, cannonLow, 3)
        ShipUtility.addTurretsToCraft(boss, cannonHigh, 2)

        local pdc = generator:generate(x, y, 0, Rarity(RarityType.Exceptional), WeaponType.PointDefenseChainGun)
        ShipUtility.addTurretsToCraft(boss, pdc, 4)

        -- add shield generator to ship plan
        local plan = Plan(boss.id)
        plan:setBlockType(plan.rootIndex, BlockType.ShieldGenerator)

        -- set boss idle
        ShipAI(boss.id):setAggressive()

        -- set boss properties
        boss.name = ""
        boss.title = "Specimen 8055"%_T
        boss.invincible = true
        Boarding(boss).boardable = false
        boss.dockable = false
        boss.shieldDurability = boss.shieldMaxDurability
        local shield = Shield(boss.id)
        shield.invincible = true

        -- asteroids
        SpawnAsteroidBoss.createShieldAsteroids(boss.translation)

        -- set boss scripts
        boss:addScriptOnce("data/scripts/entity/events/asteroidshieldboss.lua")
        boss:addScript("deleteonplayersleft.lua")

        -- add drops
        local randomRarityType = function()
            local rand = random():getInt(1, 10)
            if rand <= 2 then
                return RarityType.Legendary
            else
                return RarityType.Exotic
            end
        end
        Loot(boss.index):insert(SystemUpgradeTemplate("data/scripts/systems/shieldbooster.lua", Rarity(randomRarityType()), random():createSeed()))
        Loot(boss.index):insert(SystemUpgradeTemplate("data/scripts/systems/shieldbooster.lua", Rarity(randomRarityType()), random():createSeed()))

        local rand = random():getInt(0, 1)

        if rand == 0 then
            Loot(boss.index):insert(InventoryTurret(generator:generate(x, y, 0, Rarity(randomRarityType), WeaponType.Cannon)))
        else
            Loot(boss.index):insert(InventoryTurret(generator:generate(x, y, 0, Rarity(randomRarityType), WeaponType.RailGun)))
        end

        -- adds legendary turret drop
        boss:addScriptOnce("internal/common/entity/background/legendaryloot.lua")
    end

    --[[
    function SpawnAsteroidBoss.createShieldAsteroids()
        --print("Creating Sheild Asteroids: Executing Function...")

        -- we don't need to actually spawn new asteroids, if there still are some
        if Sector():getEntitiesByScript("data/scripts/entity/events/shieldasteroid.lua") then return end
        --print("Creating Sheild Asteroids: Begin...")

        maxAsteroids = 4
        local dimChanges =
        {
            vec3(1500 + math.random(1, 1500), math.random(1, 10), math.random(1, 10)),
            vec3(-1500 - math.random(1, 1500), math.random(1, 10), math.random(1, 10)),
            vec3(math.random(1, 10), math.random(1, 10), 1500 + math.random(1, 1500)),
            vec3(math.random(1, 10), math.random(1, 10), -1500 - math.random(1, 1500)),
        }

        local sectorCoords = {}
        sectorCoords.x, sectorCoords.y = Sector():getCoordinates()
        local generator = SectorGenerator(sectorCoords.x, sectorCoords.y)
        local tx, ty = SpawnAsteroidBoss.calculateNextLocation()
        
        for i = 1, data.num do
            local translation = vec3(0 + (dimChanges[i].x), 0 + (dimChanges[i].y), 0 + (dimChanges[i].z))

            local asteroid = generator:createSmallAsteroid(translation, 60, false, Material(1))
            
            --print("Creating Asteroid #" .. tostring(data.num))

            asteroid:setValue("shield_asteroid", true)

            if data.num < 4 then
                asteroid:addScriptOnce("player/events/shieldasteroid.lua", tx, ty)
            end

            local asteroidfieldgenerator = AsteroidFieldGenerator(sectorCoords.x, sectorCoords.y)

            -- spawns the "explosion shaped" asteroid balls around the shield asteroids
            ballAsteroidPosition = translation
            local asteroid = asteroidfieldgenerator:createBallAsteroidField(0.1, ballAsteroidPosition)
        end
    end

    function SpawnAsteroidBoss.getFaction()
        local name = "The Pariah"%_T
        local faction = Galaxy():findFaction(name)
        if faction == nil then
            faction = Galaxy():createFaction(name, 0, 0)
            faction.initialRelations = 0
            faction.initialRelationsToPlayer = 0
            faction.staticRelationsToPlayers = true
        end

        faction.initialRelationsToPlayer = 0
        --    setRelationStatus(faction, Player(callingPlayer), RelationStatus.Neutral, false, false)
        faction.staticRelationsToPlayers = true
        faction.homeSectorUnknown = true

        return faction
    end

    function SpawnAsteroidBoss.getNumAsteroids()
        return data.num
    end

    function SpawnAsteroidBoss.calculateNextLocation(range_in)

        if data.num >= 4 then return end

        local specs = SectorSpecifics()
        local centerX, centerY = Sector():getCoordinates()
        local range = range_in or 20
        local coords = specs.getShuffledCoordinates(random(), centerX, centerY, 1, range)
        local x, y
        local serverSeed = Server().seed

        for _, coord in pairs(coords) do

            local regular, offgrid, blocked, home = specs:determineContent(coord.x, coord.y, serverSeed)

            if not regular and offgrid and not blocked and not home then
                specs:initialize(coord.x, coord.y, serverSeed)

                if specs.generationTemplate.path == "sectors/asteroidshieldboss" then
                    x = coord.x
                    y = coord.y
                    break
                end
            end
        end

        return x, y
    end

    function SpawnAsteroidBoss.secure()
        return data
    end

    function SpawnAsteroidBoss.restore(data_in)
        data = data_in
    end
    ]]

end


--[[
return SpawnAsteroidBoss
]]