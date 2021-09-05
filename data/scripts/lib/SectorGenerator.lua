
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
]]

-- Saved Vanilla Function
SectorGenerator.old_postStationCreation = SectorGenerator.postStationCreation
function SectorGenerator:postStationCreation(station)
    AddDefaultStationScripts(station)

    SetBoardingDefenseLevel(station)

    -- Give all stations a chance to be armed.
    if random():test(0.40) then ShipUtility.addArmedTurretsToCraft(station) end
    if random():test(0.25)  then ShipUtility.addArmedTurretsToCraft(station) end    

    station.crew = station.idealCrew
    station.shieldDurability = station.shieldMaxDurability

    -- Add Patrol Script So Station Will Use Fighters and Turrets
    station:addScriptOnce("ai/patrol.lua")

    Physics(station).driftDecrease = 0.2
end


-- Removed the plan breaking, this reduced the number of entities in a sector
-- Overall this was done to improve performance.
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

function SectorGenerator:createGates(distanceFromSectorCenter)
    distanceFromSectorCenter = distanceFromSectorCenter or 3000

    local sector = Sector()
    sector:setValue("gates2.0", true)

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

            sector:createEntity(desc)
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
]]