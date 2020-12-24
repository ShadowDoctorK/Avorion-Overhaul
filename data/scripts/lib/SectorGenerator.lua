
--[[
package.path = package.path .. ";data/scripts/lib/?.lua"
package.path = package.path .. ";data/scripts/?.lua"

include ("randomext")
include ("galaxy")
include ("utility")
include ("stringutility")
include ("defaultscripts")
include ("goods")
include ("merchantutility")
local ShipGenerator = include ("shipgenerator")
local StyleGenerator = include ("internal/stylegenerator.lua")
local PlanGenerator = include ("plangenerator")
local ShipUtility = include ("shiputility")
local GatesMap = include ("gatesmap")
local AncientGatesMap = include ("ancientgatesmap")
local ConsumerGoods = include ("consumergoods")
local SectorFighterGenerator = include("sectorfightergenerator")

local AsteroidFieldGenerator = include ("asteroidfieldgenerator")

local assert = assert
local SectorGenerator = {}
SectorGenerator.__index = SectorGenerator

local function new(x, y)
    assert(type(x) == "number" and type(y) == "number", "New SectorGenerator expects 2 numbers")

    return setmetatable({coordX = x, coordY = y}, SectorGenerator)
end

function SectorGenerator:getPositioningDistance()
    local x, y = Sector():getCoordinates()

    local d = length(vec2(x, y))

    return lerp(d, 450, 380, 5000, 8000)
end

function SectorGenerator:getPositionInSector(maxDist)
    maxDist = maxDist or self:getPositioningDistance()

    -- deliberately not [-1;1] to avoid round sectors
    -- see getUniformPositionInSector(maxDist) below
    local position = vec3(math.random(), math.random(), math.random());
    local dist = getFloat(-maxDist, maxDist)
    position = position * dist

    -- create a random up vector
    local up = vec3(math.random(), math.random(), math.random())

    -- create a random look vector
    local look = vec3(math.random(), math.random(), math.random())

    -- create the look vector from them
    local mat = MatrixLookUp(look, up)
    mat.pos = position

    return mat
end

function SectorGenerator:getUniformPositionInSector(maxDist)
    maxDist = maxDist or self:getPositioningDistance()

    -- uniform version of getPositionInSector
    local position = random():getDirection()
    local dist = getFloat(-maxDist, maxDist)
    position = position * dist

    local up = random():getDirection()
    local look = random():getDirection()

    local mat = MatrixLookUp(look, up)
    mat.pos = position
    return mat
end

function SectorGenerator:findStationPositionInSector(stationRadius)

    local stations = {Sector():getEntitiesByType(EntityType.Station)}
    local maxDist = self:getPositioningDistance()

    -- radius
    local radius = stationRadius * 1.75 -- keep some distance to other stations, otherwise the stations will be moved away from each other, which is not pretty

    while true do
        -- get a random position in the sector
        local mat = self:getPositionInSector(maxDist)
        local position = mat.pos

        -- check if it would intersect with another station
        local intersects = 0
        for i, station in pairs(stations) do

            -- get bounding sphere of station
            local sphere = station:getBoundingSphere();
            sphere.radius = sphere.radius * 1.75

            -- check if they intersect
            local distance = distance(position, sphere.center)
            if distance < radius + sphere.radius then
                intersects = 1;
                break;
            end

--          print("tested for intersection with " .. otherIndex .. " at position " .. tostring(otherPosition) .. ", distance: " .. distance .. ", intersecting: " .. intersects)

        end

        if intersects == 0 then
            -- doesn't intersect, great!
            local look = vec3(math.random(), 0, math.random())
            local up = vec3(0, 1, 0) + vec3(math.random(), math.random(), math.random()) * 0.05

            return MatrixLookUpPosition(look, up, mat.translation)
        end

        -- increase distance so the search will eventually come to an end
        maxDist = maxDist + 50
    end
end

function SectorGenerator:createStash(worldMatrix, title)
    local plan = PlanGenerator.makeContainerPlan()

    local container = self:createContainer(plan, worldMatrix, 0)

    container.title = ""
    container:addScript("stash.lua")
    container.title = title or "Secret Stash"%_t

    if random():test(0.2) then
        if not container:hasScript("data/scripts/entity/story/historybook.lua") then
            container:addScript("data/scripts/entity/story/historybook.lua")
        end
    end

    return container
end

function SectorGenerator:createContainer(plan, worldMatrix, factionIndex)
    local desc = EntityDescriptor()
    desc:addComponents(
       ComponentType.Plan,
       ComponentType.BspTree,
       ComponentType.Intersection,
       ComponentType.Asleep,
       ComponentType.DamageContributors,
       ComponentType.BoundingSphere,
       ComponentType.BoundingBox,
       ComponentType.Velocity,
       ComponentType.Physics,
       ComponentType.Scripts,
       ComponentType.ScriptCallback,
       ComponentType.Title,
       ComponentType.Owner,
       ComponentType.FactionNotifier,
       ComponentType.WreckageCreator,
       ComponentType.InteractionText,
       ComponentType.Loot
       )

    desc.position = worldMatrix or self:getPositionInSector()
    desc:setPlan(plan)
    desc.title = "Container"%_t
    if factionIndex then desc.factionIndex = factionIndex end

    return Sector():createEntity(desc)
end

function SectorGenerator:createContainerField(sizeX, sizeY, circular, position, factionIndex, hackables)

    sizeX = sizeX or math.random(10, 30)
    sizeY = sizeY or math.random(10, 30)

    if circular == nil then
        circular = 0

        if math.random() < 0.2 then
            circular = 1
        end
    end

    position = position or self:getPositionInSector()

    local space = 40.0

    local plan = PlanGenerator.makeContainerPlan()
    local basePosition = position.pos
    local up = position.up
    local look = position.look
    local right = position.right

    --local basePosition = vec3(15, 15, 15)

    local containers = {}
    for y = 1, sizeY do

        for x = 1, sizeX do

            local create = 1

            if circular == 1 then
                local radius

                if sizeX > sizeY then
                    radius = sizeY / 2
                else
                    radius = sizeX / 2
                end

                if distance(vec2(x, y), vec2(sizeX / 2, sizeY / 2)) > radius then
                    create = 0
                end
            end

            if create == 1 then
                local pos = basePosition + right * space * (x - sizeX / 2) + look * space * (y - sizeY / 2)


                local worldMatrix = Matrix();
                worldMatrix.pos = pos
                worldMatrix.up = up
                worldMatrix.look = look
                worldMatrix.right = right

                local container = self:createContainer(plan, worldMatrix, factionIndex)
                table.insert(containers, container)
            end
        end
    end

    hackables = hackables or math.random(0, 2)
    for i = 1, hackables do
        local container = containers[math.random(1, #containers)]

        container.title = ""
        container:addScriptOnce("internal/dlc/blackmarket/entity/hackablecontainer.lua")
    end

    return containers
end

function SectorGenerator:generateStationContainers(station, sizeX, sizeY, circular)

    sizeX = sizeX or math.random(8, 15)
    sizeY = sizeY or math.random(8, 15)

    if circular == nil then
        if math.random() < 0.5 then
            circular = 1
        else
            circular = 0
        end
    end

    local stationMatrix = station.position

    local box = station:getBoundingBox()

    local pos = stationMatrix:transformCoord(box.center)

    pos = pos + stationMatrix.right * (box.size.x * 0.5 + 600.0 + math.random() * 100.0)

    stationMatrix.pos = pos

    self:createContainerField(sizeX, sizeY, circular, stationMatrix, station.factionIndex, 0)

end

function SectorGenerator:createDenseAsteroidField(probability)
    local size = getFloat(0.8, 1.25)

    return AsteroidFieldGenerator.createAsteroidFieldEx(500 * size, 1800 * size, 5.0, 25.0, true, probability);
end

-- returns an asteroid type, based on the sector's position in the galaxy
function SectorGenerator:getAsteroidType()
    local generator = AsteroidFieldGenerator(self.coordX, self.coordY)
    return generator:getAsteroidType()
end

function SectorGenerator:createClaimableAsteroid(position)
    local generator = AsteroidFieldGenerator(self.coordX, self.coordY)
    return generator:createClaimableAsteroid()
end

-- creates an asteroid
function SectorGenerator:createSmallAsteroid(translation, size, resources, material)
    local generator = AsteroidFieldGenerator(self.coordX, self.coordY)
    return generator:createSmallAsteroid(translation, size, resources, material)
end

function SectorGenerator:createHiddenTreasureAsteroid(translation, size, material)
    local generator = AsteroidFieldGenerator(self.coordX, self.coordY)
    return generator:createHiddenTreasureAsteroid(translation, size, material)
end

-- returns an asteroid type, based on the sector's position in the galaxy
function SectorGenerator:getAsteroidType()
   local generator = AsteroidFieldGenerator(self.coordX, self.coordY)
   return generator:getAsteroidType()
end

function SectorGenerator:createClaimableAsteroid(position)
    local generator = AsteroidFieldGenerator(self.coordX, self.coordY)
    return generator:createClaimableAsteroid(position)
end

-- creates an asteroid
function SectorGenerator:createSmallAsteroid(translation, size, resources, material)
    local generator = AsteroidFieldGenerator(self.coordX, self.coordY)
    return generator:createSmallAsteroid(translation, size, resources, material)
end

function SectorGenerator:createHiddenTreasureAsteroid(translation, size, material)
    local generator = AsteroidFieldGenerator(self.coordX, self.coordY)
    return generator:createHiddenTreasureAsteroid(translation, size, material)
end

-- create asteroid fields
function SectorGenerator:createDenseAsteroidField(probability)
    local size = getFloat(0.8, 1.25)
    local generator = AsteroidFieldGenerator(self.coordX, self.coordY)
    return generator:createAsteroidFieldEx(500 * size, 1800 * size, 5.0, 25.0, true, probability);
end

function SectorGenerator:createAsteroidField(probability)
    local size = getFloat(0.5, 1.0)
    local generator = AsteroidFieldGenerator(self.coordX, self.coordY)
    return generator:createAsteroidFieldEx(300 * size, 1800 * size, 5.0, 25.0, true, probability);
end

function SectorGenerator:createSmallAsteroidField(probability)
    local size = getFloat(0.2, 0.4)
    local generator = AsteroidFieldGenerator(self.coordX, self.coordY)
    return generator:createAsteroidFieldEx(200 * size, 1800 * size, 5.0, 25.0, true, probability);
end

function SectorGenerator:createEmptyAsteroidField()
    local size = getFloat(0.8, 1.0)
    local generator = AsteroidFieldGenerator(self.coordX, self.coordY)
    return generator:createAsteroidFieldEx(400 * size, 1800 * size, 5.0, 25.0, false);
end

function SectorGenerator:createEmptySmallAsteroidField()
    local size = getFloat(0.2, 0.4)
    local generator = AsteroidFieldGenerator(self.coordX, self.coordY)
    return generator:createAsteroidFieldEx(200 * size, 1800 * size, 5.0, 25.0, false);
end

-- create an asteroid
function SectorGenerator:createBigAsteroid(position)
    position = position or self:getPositionInSector()
    return self:createBigAsteroidEx(position, getFloat(40, 60), true)
end

-- create an empty asteroid
function SectorGenerator:createEmptyBigAsteroid()
    local position = self:getPositionInSector()
    return self:createBigAsteroidEx(position, getFloat(40, 60), false)
end

function SectorGenerator:createBigAsteroidEx(position, size, resources)

    local material = self:getAsteroidType()

    --acquire a random seed for the asteroid
    local plan = PlanGenerator.makeBigAsteroidPlan(size, resources, material)
    plan.accumulatingHealth = false

    local asteroid = Sector():createAsteroid(plan, resources, position)

    if resources then
        asteroid.isObviouslyMineable = true
    end

    return asteroid
end


-- Saved Vanilla Function
SectorGenerator.old_createStation = SectorGenerator.createStation
function SectorGenerator:createStation(faction, scriptPath, ...)

    --print("Script Path: " .. tostring(scriptPath))

    local styleName = PlanGenerator.determineStationStyleFromScriptArguments(scriptPath, ...)

    local plan = PlanGenerator.makeStationPlan(faction, styleName)
    if plan == nil then
        printlog("Error while generating a station plan for faction ".. faction .. ".")
        return
    end

    local position = self:findStationPositionInSector(plan.radius);
    local station
    -- has to be done like this, passing nil for a string doesn't work
    if scriptPath then
        station = Sector():createStation(faction, plan, position, scriptPath, ...)
    else
        station = Sector():createStation(faction, plan, position)
    end

    self:postStationCreation(station)

    return station
end
]]

-- Saved Vanilla Function
SectorGenerator.old_postStationCreation = SectorGenerator.postStationCreation
function SectorGenerator:postStationCreation(station)
    AddDefaultStationScripts(station)

    SetBoardingDefenseLevel(station)

    -- Give all stations a chance to be armed.
    if random():test(0.40) then ShipUtility.addArmedTurretsToCraft(station) end
    if random():test(0.25)  then ShipUtility.addArmedTurretsToCraft(station) end    

    station.crew = station.minCrew
    station.shieldDurability = station.shieldMaxDurability

    -- Add Patrol Script So Station Will Use Fighters and Turrets
    station:addScriptOnce("ai/patrol.lua")

    Physics(station).driftDecrease = 0.2
end

--[[
function SectorGenerator:createStationConstructionSite(faction, scripts)
    local scriptPath = nil
    for _, script in pairs(scripts) do
        scriptPath = script.script
        break
    end

    local plan, seed, volume, material = PlanGenerator.makeStationPlan(faction, scriptPath)
    if plan == nil then
        printlog("Error while generating a station plan for faction ".. faction .. ".")
        return
    end

--    local profiler = Profiler("Construction")
--    profiler:section("setup")

    local planSize = plan:getBoundingBox().size * 0.25
    local color = ColorRGB(0.4, 0.4, 0.4)
    local indices = {plan:getBlockIndices()}

--    profiler:done()
--    profiler:section("transform")

    for i, index in pairs(indices) do
        local blockPosition = plan:getBlock(index).box.position
        if math.abs(blockPosition.x) > planSize.x or math.abs(blockPosition.y) > planSize.y or math.abs(blockPosition.z) > planSize.z then
            if i % 5 == 0 then
                plan:setBlockType(index, BlockType.Framework)
                plan:setBlockColor(index, color)
            end
        else
            if i % 14 == 0 then
                plan:setBlockType(index, BlockType.Framework)
                plan:setBlockColor(index, color)
            end
        end
    end

--    profiler:done()
--    profiler:section("framework")

    for i, index in pairs(indices) do
        if i % 3 == 0 then
            local box = plan:getBlock(index).box
            local size = box.size
            local minAxis = 0
            if size.y < size.x then minAxis = 1 end
            if size.z < size.y then minAxis = 2 end

            local thickness = 3
            local offset = vec3()

            if minAxis == 0 then
                offset.x = (size.x + thickness) * 0.5
                size.x = thickness
            else
                offset.x = random():getFloat(size.x * 0.1, size.x * 0.3)
                size.x = random():getFloat(size.x * 0.5, size.x)
            end

            if minAxis == 1 then
                offset.y = (size.y + thickness) * 0.5
                size.y = thickness
            else
                offset.y = random():getFloat(size.y * 0.1, size.y * 0.3)
                size.y = random():getFloat(size.y * 0.5, size.y)
            end

            if minAxis == 2 then
                offset.z = (size.z + thickness) * 0.5
                size.z = thickness
            else
                offset.z = random():getFloat(size.z * 0.1, size.z * 0.3)
                size.z = random():getFloat(size.z * 0.5, size.z)
            end

            plan:addBlock(box.position + offset, size, index, -1, color, material, Matrix(), BlockType.Framework)
            plan:addBlock(box.position - offset, size, index, -1, color, material, Matrix(), BlockType.Framework)
        end
    end

--    profiler:done()
--    profiler:print()

    local desc = EntityDescriptor()
    desc:addComponent(ComponentType.BoundingBox)
    desc:addComponent(ComponentType.BoundingSphere)
    desc:addComponent(ComponentType.Durability)
    desc:addComponent(ComponentType.PlanMaxDurability)
    desc:addComponent(ComponentType.Plan)
    desc:addComponent(ComponentType.BspTree)
    desc:addComponent(ComponentType.Intersection)
    desc:addComponent(ComponentType.Asleep)
    desc:addComponent(ComponentType.Velocity)
    desc:addComponent(ComponentType.Physics)
    desc:addComponent(ComponentType.Scripts)
    desc:addComponent(ComponentType.ScriptCallback)
    desc:addComponent(ComponentType.Title)
    desc:addComponent(ComponentType.Owner)
    desc:addComponent(ComponentType.FactionNotifier)
    desc:addComponent(ComponentType.WreckageCreator)
    desc:addComponent(ComponentType.Loot)
    desc:addComponent(ComponentType.DamageContributors)
    desc:addComponent(ComponentType.Position)

    desc.title = "Construction Site"%_t
    desc.factionIndex = faction.index
    desc:setPlan(plan)
    desc.position = self:findStationPositionInSector(plan.radius)

    local station = Sector():createEntity(desc)

    station:addScript("data/scripts/entity/constructionsite.lua", seed, volume, material, scripts)

    Physics(station).driftDecrease = 0.2

    return station
end

function SectorGenerator:createWreckage(faction, plan, breaks)
    local wreckages = {SectorGenerator:createUnstrippedWreckage(faction, plan, breaks)}

    for _, wreckage in pairs(wreckages) do
        if random():test(0.2) then
            wreckage:addScriptOnce("data/scripts/entity/story/captainslogs.lua")
        end
        if random():test(0.9) then
            ShipUtility.stripWreckage(wreckage)
        end
    end

    return unpack(wreckages)
end
]]

function SectorGenerator:createUnstrippedWreckage(faction, plan, breaks)

    breaks = 0 -- Removed Breaks. This causes alot of lag.

    if not plan then
        if math.random() < 0.5 then
            plan = PlanGenerator.makeShipPlan(faction)
        else
            plan = PlanGenerator.makeFreighterPlan(faction)
        end
    end

    local plans = {}
    if breaks > 0 then
        local tries = 0

        while tries < breaks do
            tries = tries + 1

            -- find a random index and break at that point
            local index = math.random(0, plan.numBlocks - 1)
            index = plan:getNthIndex(index)

            local newPlans = {plan:divide(index)}
            for _, p in pairs(newPlans) do
                table.insert(plans, p)
            end
        end
    end

    table.insert(plans, plan)

    local wreckages = {}

    for _, plan in pairs(plans) do
        -- create the wreckage from the plan
        plan.accumulatingHealth = false
        local wreckage = Sector():createWreckage(plan, self:getPositionInSector())

        table.insert(wreckages, wreckage)

        if math.random(1, 5) == 1 then
            -- add cargo
            local index = math.random(1, #spawnableGoods)
            local g = spawnableGoods[index]
            local good = g:good()

            local maxValue = math.random(500, 3000) * Balancing_GetSectorRichnessFactor();
            local maxVolume = 100

            local amount = math.floor(math.min(maxValue / good.price, maxVolume / good.size))

            wreckage:addCargo(good, amount);
        end
    end

    return unpack(wreckages)
end

--[[
function SectorGenerator:createShipyard(faction)
    local station = self:createStation(faction, "data/scripts/entity/merchants/shipyard.lua");
    station:addScript("data/scripts/entity/merchants/repairdock.lua")

    station:addScript("data/scripts/entity/merchants/consumer.lua", "Shipyard"%_t, unpack(ConsumerGoods.Shipyard()))

    return station
end

function SectorGenerator:createEquipmentDock(faction)
    local station = self:createStation(faction, "data/scripts/entity/merchants/equipmentdock.lua");

    station:addScript("data/scripts/entity/merchants/turretmerchant.lua")
    station:addScript("data/scripts/entity/merchants/fightermerchant.lua")
    station:addScript("data/scripts/entity/merchants/utilitymerchant.lua")
    station:addScript("data/scripts/entity/merchants/consumer.lua", "Equipment Dock"%_t, unpack(ConsumerGoods.EquipmentDock()))

    local x, y = Sector():getCoordinates()
    local dist2 = x * x + y * y
    if dist2 < 380 * 380 then
        station:addScript("data/scripts/entity/merchants/torpedomerchant.lua")
    end

    ShipUtility.addArmedTurretsToCraft(station)

    return station
end

function SectorGenerator:createRepairDock(faction)
    local station = self:createStation(faction, "data/scripts/entity/merchants/repairdock.lua");

    station:addScript("data/scripts/entity/merchants/consumer.lua", "Repair Dock"%_t, unpack(ConsumerGoods.RepairDock()))

    return station
end

function SectorGenerator:createMilitaryBase(faction)
    local station = self:createStation(faction, "data/scripts/entity/merchants/militaryoutpost.lua");

    station:addScript("data/scripts/entity/merchants/consumer.lua", "Military Outpost"%_t, unpack(ConsumerGoods.MilitaryOutpost()))

    ShipUtility.addArmedTurretsToCraft(station)

    -- add fighters
    local hangar = Hangar(station)
    hangar:addSquad("Alpha")
    hangar:addSquad("Beta")
    hangar:addSquad("Gamma")
    hangar:addSquad("Delta")

    local generator = SectorFighterGenerator()
    generator.factionIndex = faction.index

    local numFighters = 0
    for squad = 0, 3 do
        local fighter = generator:generateArmed(faction:getHomeSectorCoordinates())
        for i = 1, 12 do
            hangar:addFighter(squad, fighter)
        end
    end

    return station
end

function SectorGenerator:createResearchStation(faction)
    local station = self:createStation(faction, "data/scripts/entity/merchants/researchstation.lua");

    station:addScript("data/scripts/entity/merchants/consumer.lua", "Research Station"%_t, unpack(ConsumerGoods.ResearchStation()))

    return station
end

function SectorGenerator:createTurretFactory(faction)
    local station = self:createStation(faction, "data/scripts/entity/merchants/turretfactory.lua");

    station:addScript("data/scripts/entity/merchants/turretfactoryseller.lua", "Turret Factory"%_t, unpack(ConsumerGoods.TurretFactory()))

    return station
end

function SectorGenerator:createFighterFactory(faction)
    local station = self:createStation(faction, "data/scripts/entity/merchants/fighterfactory.lua")
    station:addScript("data/scripts/entity/merchants/fightermerchant.lua")

    return station
end

function SectorGenerator:createBeacon(position, faction, text, args)
    local desc = EntityDescriptor()
    desc:addComponents(
       ComponentType.Plan,
       ComponentType.BspTree,
       ComponentType.Intersection,
       ComponentType.Asleep,
       ComponentType.DamageContributors,
       ComponentType.BoundingSphere,
       ComponentType.BoundingBox,
       ComponentType.Velocity,
       ComponentType.Physics,
       ComponentType.Scripts,
       ComponentType.ScriptCallback,
       ComponentType.Title,
       ComponentType.Owner,
       ComponentType.InteractionText,
       ComponentType.FactionNotifier
       )

    local plan = PlanGenerator.makeBeaconPlan()

    desc.position = position or self:getPositionInSector()
    desc:setMovePlan(plan)
    desc.title = "Beacon"%_t
    if faction then desc.factionIndex = faction.index end

    local beacon = Sector():createEntity(desc)
    beacon:addScript("beacon", text, args)
    beacon.dockable = false
    return beacon
end

function SectorGenerator:createGates(distanceFromSectorCenter)
    distanceFromSectorCenter = distanceFromSectorCenter or 3000

    local map = GatesMap(Server().seed)
    local targets = map:getConnectedSectors({x = self.coordX, y = self.coordY})

    for _, target in pairs(targets) do
        -- get start sector
        local firstPlayer = Player(1)
        local startSectorX, startSectorY
        if firstPlayer then
            startSectorX, startSectorY = firstPlayer:getHomeSectorCoordinates()
        end

        local faction
        if startSectorX and startSectorX == target.x and startSectorY == target.y then
            -- use nearest faction for the start sector
            faction = Galaxy():getNearestFaction(target.x, target.y)
        else
            faction = Galaxy():getLocalFaction(target.x, target.y)
        end

        if faction ~= nil then

            local desc = EntityDescriptor()
            desc:addComponents(
               ComponentType.Plan,
               ComponentType.BspTree,
               ComponentType.Intersection,
               ComponentType.Asleep,
               ComponentType.DamageContributors,
               ComponentType.BoundingSphere,
               ComponentType.PlanMaxDurability,
               ComponentType.Durability,
               ComponentType.BoundingBox,
               ComponentType.Velocity,
               ComponentType.Physics,
               ComponentType.Scripts,
               ComponentType.ScriptCallback,
               ComponentType.Title,
               ComponentType.Owner,
               ComponentType.FactionNotifier,
               ComponentType.WormHole,
               ComponentType.EnergySystem,
               ComponentType.EntityTransferrer
            )

            local styleGenerator = StyleGenerator(faction.index)
            local c1 = styleGenerator.factionDetails.baseColor
            local c2 = ColorRGB(0.25, 0.25, 0.25)
            local c3 = styleGenerator.factionDetails.paintColor
            c1 = ColorRGB(c1.r, c1.g, c1.b)
            c3 = ColorRGB(c3.r, c3.g, c3.b)

            local plan = PlanGenerator.makeGatePlan(Seed(faction.index) + Server().seed, c1, c2, c3)

            local dir = vec3(target.x - self.coordX, 0, target.y - self.coordY)
            normalize_ip(dir)

            local position = MatrixLookUp(dir, vec3(0, 1, 0))
            position.pos = dir * distanceFromSectorCenter

            desc:setMovePlan(plan)
            desc.position = position
            desc.factionIndex = faction.index
            desc.invincible = true
            desc:addScript("data/scripts/entity/gate.lua")

            local wormhole = desc:getComponent(ComponentType.WormHole)
            wormhole:setTargetCoordinates(target.x, target.y)
            wormhole.visible = false
            wormhole.visualSize = 50
            wormhole.passageSize = 50
            wormhole.oneWay = true

            Sector():createEntity(desc)
        end
    end


end

function SectorGenerator:createAncientGates()

    local map = AncientGatesMap(Server().seed)
    local targets = map:getConnectedSectors({x = self.coordX, y = self.coordY})

    for _, target in pairs(targets) do

        -- print ("%i %i", target.x, target.y)

        local desc = EntityDescriptor()
        desc:addComponents(
           ComponentType.Plan,
           ComponentType.BspTree,
           ComponentType.Intersection,
           ComponentType.Asleep,
           ComponentType.DamageContributors,
           ComponentType.BoundingSphere,
           ComponentType.PlanMaxDurability,
           ComponentType.Durability,
           ComponentType.BoundingBox,
           ComponentType.Velocity,
           ComponentType.Physics,
           ComponentType.Scripts,
           ComponentType.ScriptCallback,
           ComponentType.Title,
           ComponentType.Owner,
           ComponentType.FactionNotifier,
           ComponentType.WormHole,
           ComponentType.EnergySystem,
           ComponentType.EntityTransferrer
           )

        local plan = PlanGenerator.makeGatePlan(Seed(156684531) + Server().seed, ColorRGB(1, 1, 1), ColorRGB(0.5, 0.5, 0.5), ColorRGB(1.0, 0.25, 0.25))
        plan:scale(vec3(10, 10, 10))

        local dir = vec3(target.x - self.coordX, 0, target.y - self.coordY)
        normalize_ip(dir)

        local position = MatrixLookUp(dir, vec3(0, 1, 0))
        position.pos = dir * 6000.0

        desc:setMovePlan(plan)
        desc.position = position
        desc.invincible = true
        desc:addScript("data/scripts/entity/ancientgate.lua")

        local wormhole = desc:getComponent(ComponentType.WormHole)
        wormhole:setTargetCoordinates(target.x, target.y)
        wormhole.visible = false
        wormhole.visualSize = 250
        wormhole.passageSize = 250
        wormhole.oneWay = true

        Sector():createEntity(desc)
    end


end

function SectorGenerator:createRandomWormHole()

    local value = math.random()

    if value < 0.1 then
        return self:createRandomizedWormHole()
    elseif value < 0.55 then
        return self:createRingWormHole()
    else
        return self:createDeepWormHole()
    end
end

function SectorGenerator:wormHoleAllowed(from, to)

    self.passageMap = self.passageMap or PassageMap(Server().seed)

    -- a wormhole can't be inside an unpassable sector
    if not self.passageMap:passable(from.x, from.y) or not self.passageMap:passable(to.x, to.y) then
        return false
    end

    -- if they're not either both inside or both outside, then the wormhole crosses the ring -> illegal
    if self.passageMap:insideRing(from.x, from.y) ~= self.passageMap:insideRing(to.x, to.y) then
        return false
    end

    return true
end

function SectorGenerator:createRingWormHole(angle)

    -- this type of wormhole goes around in a ring
    local distfactor = (500 - math.sqrt(self.coordX * self.coordX + self.coordY * self.coordY)) / 500 -- factor from 0 to 1
    if distfactor > 1.0 then dist = 1.0 end -- clamp at 1 max

    angle = angle or 4.0 + 40.0 * math.random() ^ 5.0 * distfactor

    if math.random() < 0.5 then angle = -angle end

    local x = math.cos(angle) * self.coordX - math.sin(angle) * self.coordY
    local y = math.sin(angle) * self.coordX + math.cos(angle) * self.coordY

    x = x + math.random(-20, 20)
    y = y + math.random(-20, 20)

    x = round(x)
    y = round(y)

    local from = {x = self.coordX, y = self.coordY}
    local to = {x = x, y = y}

    if not self:wormHoleAllowed(from, to) then return end

    return self:createWormHole(x, y, ColorRGB(1, 1, 0))

end

function SectorGenerator:createDeepWormHole(wormHoleDistance)

    local dist = math.sqrt(self.coordX * self.coordX + self.coordY * self.coordY)

    local x = self.coordX / dist
    local y = self.coordY / dist

    wormHoleDistance = wormHoleDistance or math.random(30, 100)

    -- towards center
    x = self.coordX - x * wormHoleDistance
    y = self.coordY - y * wormHoleDistance

    -- plus a little randomness
    x = x + math.random(-wormHoleDistance / 5, wormHoleDistance / 5);
    y = y + math.random(-wormHoleDistance / 5, wormHoleDistance / 5);

    x = round(x)
    y = round(y)

    local from = {x = self.coordX, y = self.coordY}
    local to = {x = x, y = y}

    if not self:wormHoleAllowed(from, to) then return end

    return self:createWormHole(x, y, ColorRGB(0, 1, 1))

end

function SectorGenerator:createRandomizedWormHole()

    -- completely random
    local x = math.random(self.coordX - 200, self.coordX + 200)
    local y = math.random(self.coordY - 200, self.coordY + 200)

    x = round(x)
    y = round(y)

    local from = {x = self.coordX, y = self.coordY}
    local to = {x = x, y = y}

    if not self:wormHoleAllowed(from, to) then return end

    return self:createWormHole(x, y, ColorRGB(0, 1, 0))
end

function SectorGenerator:createWormHole(x, y, color, size)
    local from = {x = self.coordX, y = self.coordY}
    local to = {x = x, y = y}
    if not self:wormHoleAllowed(from, to) then
        print (string.format("Wormhole from %i:%i to %i:%i is not allowed", from.x, from.y, to.x, to.y))
        return
    end

    -- position it
    local d = vec2(x - self.coordX, y - self.coordY)
    local dist = length(d)
    d = d / dist

    color = color or ColorRGB(0, 1, 1)
    size = size or math.random(30, 100) + dist / 4 -- the further it goes, the bigger it is

    local wormHole = Sector():createWormHole(x, y, color, size)

    -- wormholes are placed at 20 km outside the sector, up to 70 km outside the sector (if it were going from top to bottom of the galaxy)
    wormHole.translation = dvec3(d.x * 2000 + dist * 5, math.random(-500, 500), d.y * 2000 + dist * 5)

    -- look in the direction where it's going
    wormHole.orientation = MatrixLookUp(vec3(d.x, 0, d.y), vec3(0, 1, 0))

    wormHole:addScriptOnce("data/scripts/entity/wormhole.lua")

    return wormHole;
end

function SectorGenerator:addAmbientEvents()
    Sector():addScriptOnce("sector/passingships.lua")
    Sector():addScriptOnce("sector/traders.lua")
    Sector():addScriptOnce("sector/factionwar/initfactionwar.lua")
end

function SectorGenerator:addOffgridAmbientEvents()
end

function SectorGenerator:getWormHoleProbability()
    return 1 / 30
end

function SectorGenerator:deleteObjectsFromDockingPositions()
    local stations = {Sector():getEntitiesByComponent(ComponentType.DockingPositions)}

    for _, station in pairs(stations) do
        DockingPositions(station):deleteRemovableObstacles()
    end
end

return setmetatable({new = new}, {__call = function(_, ...) return new(...) end})
]]