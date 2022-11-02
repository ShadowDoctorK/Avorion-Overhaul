package.path = package.path .. ";data/scripts/lib/?.lua"

include ("randomext")
include ("stringutility")
include ("callable")
local FactionEradicationUtility = include("factioneradicationutility")
local Xsotan = include ("story/xsotan")
local Placer = include ("placer");
local AsyncShipGenerator = include("asyncshipgenerator")

-- Don't remove or alter the following comment, it tells the game the namespace this script lives in. If you remove it, the script will break.
-- namespace WormholeGuardian
WormholeGuardian = {}


-- variables are all non-local so the tests have access
WormholeGuardian.shieldDurability = 0

WormholeGuardian.spawningStateDuration = 60 -- seconds that the wormhole will be open
WormholeGuardian.spawningStateTime = 0
WormholeGuardian.shieldLoss = 0.1
WormholeGuardian.spawnAllyFrequency = 7.5
WormholeGuardian.spawnAllyTime = 0
WormholeGuardian.spawnPlayerAllyFrequency = 15.0
WormholeGuardian.spawnPlayerAllyTime = 0

WormholeGuardian.channelStateTime = 0
WormholeGuardian.channelDuration = 15
WormholeGuardian.channelingPlayers = {}

WormholeGuardian.playerWormholes = {}
WormholeGuardian.xsotanWormholes = {}

WormholeGuardian.playerAlliesSpawned = {}

WormholeGuardian.channelLaser = nil
WormholeGuardian.lasers = {}
WormholeGuardian.playerChannelLasers = {}

local State =
{
    Fighting = 0,
    Channeling = 1,
    Spawning = 2,
}

WormholeGuardian.state = State.Fighting

function WormholeGuardian.initialize()
    WormholeGuardian.shieldDurability = Entity().shieldMaxDurability

    if onClient() then
        registerBoss(Entity().index, nil, nil, "data/music/special/guardian.ogg")
    end

    if onServer() then
        Entity():registerCallback("onDestroyed", "onDestroyed")
    end
end

function WormholeGuardian.interactionPossible()
    return true
end

if onServer() then
function WormholeGuardian.getUpdateInterval()
    return 0.25
end
end

if onClient() then
function WormholeGuardian.getUpdateInterval()
    return 0.033
end
end

function WormholeGuardian.onDestroyed()
    Server():setValue("xsotan_swarm_time", 30 * 60)

    -- add script that allows players to spawn laser boss
    -- drop corrupted AI map on destruction
    local players = {Sector():getPlayers()}
    for _, player in pairs(players) do
        player:addScriptOnce("data/scripts/player/events/spawnlaserboss.lua")
        player:getInventory():addOrDrop(UsableInventoryItem("corruptedaimap.lua", Rarity(RarityType.Legendary)))
        player:setValue("wormhole_guardian_destroyed", true)
    end
end

function WormholeGuardian.hasAllies()
    local allies = {Sector():getEntitiesByFaction(Entity().factionIndex)}

    local self = Entity()
    for _, ally in pairs(allies) do
        if ally.index ~= self.index and ally:hasComponent(ComponentType.Plan) and ally:hasComponent(ComponentType.ShipAI) then
            return true
        end
    end

    return false
end

function WormholeGuardian.aggroAllies()
    local ownIndex = Entity().factionIndex

    local sector = Sector()
    local allies = {sector:getEntitiesByFaction(Entity().factionIndex)}
    local factions = {sector:getPresentFactions()}

    for _, ally in pairs(allies) do
        if ally:hasComponent(ComponentType.Plan) and ally:hasComponent(ComponentType.ShipAI) then

            local ai = ShipAI(ally.index)
            for _, factionIndex in pairs(factions) do
                if factionIndex ~= ownIndex then
                    ai:registerEnemyFaction(factionIndex)
                end
            end
        end
    end

    return false
end

function WormholeGuardian.setFighting()
    WormholeGuardian.shieldDurability = Entity().shieldDurability
    ShipAI():setAggressive()

    for player, _ in pairs(WormholeGuardian.channelingPlayers) do
        WormholeGuardian.playerAlliesSpawned[player] = true
    end

    WormholeGuardian.channelingPlayers = {}
    WormholeGuardian.xsotanWormholes = {}
    WormholeGuardian.playerWormholes = {}

    WormholeGuardian.state = State.Fighting
end

function WormholeGuardian.setChanneling()
    WormholeGuardian.channelStateTime = 0
    WormholeGuardian.state = State.Channeling
    WormholeGuardian.createChannelBeam()

    Sector():broadcastChatMessage("", 2, "The guardian is starting to channel the black hole's energy!"%_t)
end

function WormholeGuardian.setSpawning()
    WormholeGuardian.spawningStateTime  = 0
    WormholeGuardian.spawnAllyTime = 0
    WormholeGuardian.spawnPlayerAllyTime = 0

    WormholeGuardian.state = State.Spawning
end

function WormholeGuardian.channel(timePassed)
    ShipAI():setPassive()
    Entity():damageShield(timePassed / (WormholeGuardian.spawningStateDuration + WormholeGuardian.channelDuration) * WormholeGuardian.shieldLoss * Entity().shieldMaxDurability, vec3(), Uuid())
end

function WormholeGuardian.morePlayerWormholes()
    if tablelength(WormholeGuardian.playerWormholes) < tablelength(WormholeGuardian.channelingPlayers) then
        return true
    end

    -- as long as not every channeling player has at least 10 wormholes, continue creating them
    for _, wormholes in pairs(WormholeGuardian.playerWormholes) do
        if #wormholes < 10 then return true end
    end

    return false
end

function WormholeGuardian.updateServer(timePassed)

    if WormholeGuardian.state == State.Fighting then
        -- while he's fighting, his shield is invulnerable
        Entity().shieldDurability = WormholeGuardian.shieldDurability

        -- once he has no more allies, he will go into the channeling state
        if not WormholeGuardian.hasAllies() then
            WormholeGuardian.setChanneling()
        end

    elseif WormholeGuardian.state == State.Channeling then
        WormholeGuardian.channel(timePassed)

        WormholeGuardian.channelStateTime = WormholeGuardian.channelStateTime + timePassed

        if WormholeGuardian.channelStateTime > WormholeGuardian.channelDuration then
            WormholeGuardian.setSpawning()
        end

    elseif WormholeGuardian.state == State.Spawning then

        WormholeGuardian.spawnAllyTime = WormholeGuardian.spawnAllyTime + timePassed
        WormholeGuardian.spawnPlayerAllyTime = WormholeGuardian.spawnPlayerAllyTime + timePassed
        WormholeGuardian.spawningStateTime  = WormholeGuardian.spawningStateTime  + timePassed

        WormholeGuardian.channel(timePassed)

        if WormholeGuardian.morePlayerWormholes() then
            WormholeGuardian.createPlayerWormhole()
        end

        if #WormholeGuardian.xsotanWormholes < 15 then
            WormholeGuardian.createXsotanWormhole()
        end

        local usedFrequency = WormholeGuardian.spawnAllyFrequency
        if Sector().numPlayers > 1 then
            usedFrequency = usedFrequency / (Sector().numPlayers * 1.25)
        end

        while WormholeGuardian.spawnAllyTime > usedFrequency do
            WormholeGuardian.createXsotan()
            WormholeGuardian.spawnAllyTime = WormholeGuardian.spawnAllyTime - usedFrequency
        end

        if WormholeGuardian.spawnPlayerAllyTime > WormholeGuardian.spawnPlayerAllyFrequency then
            WormholeGuardian.createPlayerAllies()
            WormholeGuardian.spawnPlayerAllyTime = WormholeGuardian.spawnPlayerAllyTime - WormholeGuardian.spawnPlayerAllyFrequency
        end

        if WormholeGuardian.spawningStateTime > WormholeGuardian.spawningStateDuration then
            WormholeGuardian.setFighting()
        end

    end

    WormholeGuardian.aggroAllies()
end

function WormholeGuardian.createXsotan()
    if #WormholeGuardian.xsotanWormholes == 0 then return end

    -- pick a random wormhole
    local wormhole = WormholeGuardian.xsotanWormholes[random():getInt(1, #WormholeGuardian.xsotanWormholes)]

    if not valid(wormhole) then return end

    local spawn = 1
    local spawned = {}
    for i = 1, spawn do
        local ally
        if Entity().durability < Entity().maxDurability * 0.75 and random():getInt(1, 2) == 1 then
            ally = Xsotan.createCarrier(wormhole.position, 2.0, 5)
        else
            ally = Xsotan.createShip(wormhole.position, 1.0)
        end

        table.insert(spawned, ally)
    end

    Placer.resolveIntersections(spawned)
    WormholeGuardian.aggroAllies()
end

function WormholeGuardian.createPlayerAllies()
    local spawned = {}

    local onFinished = function(ships)
        for _, ally in pairs(ships) do
            ally:addScript("entity/story/wormholeguardianally.lua")
            ally:removeScript("entity/antismuggle.lua")
        end

        Placer.resolveIntersections(spawned)
    end

    local generator = AsyncShipGenerator(WormholeGuardian, onFinished)
    generator:startBatch()

    for playerIndex, wormholes in pairs(WormholeGuardian.playerWormholes) do

        if WormholeGuardian.playerAlliesSpawned[playerIndex] then goto continue1 end
        WormholeGuardian.playerAlliesSpawned[playerIndex] = true

        local player = Player(playerIndex)

        -- spawn all allies of the player at once
        -- get all allies
        local ok, allies = player:invokeFunction("organizedallies.lua", "getAllies")
        if not allies then goto continue1 end

        for _, p in pairs(allies) do
            local factionIndex = p.factionIndex
            local amount = p.amount

            if FactionEradicationUtility.isFactionEradicated(factionIndex) then goto continue2 end

            local faction = Faction(factionIndex)
            if not faction then goto continue2 end

            -- pick a random wormhole
            local wormhole = wormholes[random():getInt(1, #wormholes)]

            for i = 1, amount do
                generator:createDefender(faction, wormhole.position)
            end

            ::continue2::
        end

        ::continue1::
    end

    generator:endBatch()
end

function WormholeGuardian.createXsotanWormhole()
    -- print ("create Xsotan Wormhole, time: " .. time)

    local wormhole = WormholeGuardian.createWormhole(Entity().translationf)

    table.insert(WormholeGuardian.xsotanWormholes, wormhole)

    WormholeGuardian.createBeam(Entity().index, wormhole.index, ColorRGB(1.0, 0.1, 0.1))
end

function WormholeGuardian.createPlayerWormhole()
    for playerIndex, _ in pairs(WormholeGuardian.channelingPlayers) do
        local player = Player(playerIndex)

        local ship = Sector():getEntity(player.craftIndex)
        if ship then
            local wormhole = WormholeGuardian.createWormhole(ship.translationf)

            WormholeGuardian.playerWormholes[playerIndex] = WormholeGuardian.playerWormholes[playerIndex] or {}
            table.insert(WormholeGuardian.playerWormholes[playerIndex], wormhole)

            WormholeGuardian.createBeam(ship.index, wormhole.index, ColorRGB(0.1, 0.1, 1.0))
        end
    end
end

function WormholeGuardian.createWormhole(center)
    center = center or vec3()

    -- spawn a wormhole
    local desc = WormholeDescriptor()
    desc:removeComponent(ComponentType.EntityTransferrer)
    desc:addComponents(ComponentType.DeletionTimer)
    desc.position = MatrixLookUpPosition(vec3(0, 1, 0), vec3(1, 0, 0), center + random():getDirection() * random():getFloat(500, 750))

    local size = random():getFloat(75, 150)

    local wormhole = desc:getComponent(ComponentType.WormHole)
    wormhole:setTargetCoordinates(random():getInt(-400, 400), random():getInt(-400, 400))
    wormhole.visible = true
    wormhole.visualSize = size
    wormhole.passageSize = size
    wormhole.oneWay = true
    wormhole.simplifiedVisuals = true

    desc:addScriptOnce("data/scripts/entity/wormhole.lua")

    local wormhole = Sector():createEntity(desc)

    local timer = DeletionTimer(wormhole.index)
    timer.timeLeft = WormholeGuardian.spawningStateDuration

    return wormhole
end

function WormholeGuardian.createBeam(fromIndex, toIndex, color)
    if onServer() then
        broadcastInvokeClientFunction("createBeam", fromIndex, toIndex, color)
        return
    end

    local sector = Sector()
    local a = sector:getEntity(fromIndex)
    local b = sector:getEntity(toIndex)

    if not a or not b then return end

    local laser = sector:createLaser(a.translationf, b.translationf, color, 5.0)

    local fromLocal = vec3()
    local toLocal = vec3()

    local planA = Plan(fromIndex)
    local planB = Plan(toIndex)
    if planA then fromLocal = planA.root.box.center end
    if planB then toLocal = planB.root.box.center end

    laser.maxAliveTime = 8.0
    laser.animationSpeed = -500
    laser.collision = false

    table.insert(WormholeGuardian.lasers, {laser = laser, fromIndex = fromIndex, toIndex = toIndex, fromLocal = fromLocal, toLocal = toLocal})
end

function WormholeGuardian.createChannelBeam()
    if onServer() then
        broadcastInvokeClientFunction("createChannelBeam")
        return
    end

    local dir = vec3(1, 0, 0)
    local planet = Planet(0)
    if valid(planet) then
        dir = normalize(planet.position.translation)
    end

    WormholeGuardian.channelLaser = Sector():createLaser(vec3(), dir * 500000, ColorRGB(0.9, 0.6, 0.2), 25.0)

    WormholeGuardian.channelLaser.maxAliveTime = WormholeGuardian.channelDuration
    WormholeGuardian.channelLaser.collision = false
end

function WormholeGuardian.createPlayerChannelBeam(craftIndex)
    if onServer() then
        broadcastInvokeClientFunction("createPlayerChannelBeam", craftIndex)
        return
    end

    local sector = Sector()
    local ship = sector:getEntity(craftIndex)
    if not ship then return end

    local laser = sector:createLaser(Entity().translationf, ship.translationf, ColorRGB(0.9, 0.6, 0.2), 25.0)

    laser.maxAliveTime = WormholeGuardian.channelDuration
    laser.collision = false

    table.insert(WormholeGuardian.playerChannelLasers, {laser = laser, index = craftIndex})
end

function WormholeGuardian.channelPlayer()
    if onClient() then
        invokeServerFunction("channelPlayer")
        return true
    end

    if WormholeGuardian.state == State.Channeling then
        local player = Player(callingPlayer)

        WormholeGuardian.createPlayerChannelBeam(player.craftIndex)
        WormholeGuardian.channelingPlayers[player.index] = true
    end
end
callable(WormholeGuardian, "channelPlayer")

function WormholeGuardian.updateClient(timeStep)

    local position = Entity().position
    local rootPosition = Plan().root.box.center
    local beamOrigin = position:transformCoord(rootPosition)

    registerBoss(Entity().index)

    -- update the positions of the guardian - black hole channeling laser
    if valid(WormholeGuardian.channelLaser) then
        local dir = vec3(1, 0, 0)
        local planet = Planet(0)
        if valid(planet) then
            dir = normalize(planet.position.translation)
        end

        WormholeGuardian.channelLaser.from = beamOrigin
        WormholeGuardian.channelLaser.to = dir * 500000
    end

    local sector = Sector()
    -- update the positions of the guardian - wormhole lasers
    for k, p in pairs(WormholeGuardian.lasers) do
        local laser = p.laser
        local a = sector:getEntity(p.fromIndex)
        local b = sector:getEntity(p.toIndex)

        if valid(laser) and a and b then
            local from = a.position:transformCoord(p.fromLocal)
            local to = b.position:transformCoord(p.toLocal)

            laser.from = from
            laser.to = to
        else
            WormholeGuardian.lasers[k] = nil
        end
    end

    -- update the positions of the guardian - player channeling lasers
    for k, p in pairs(WormholeGuardian.playerChannelLasers) do
        local laser = p.laser
        local ship = sector:getEntity(p.index)

        if valid(laser) and valid(ship) then
            laser.to = beamOrigin
            laser.from = ship.translationf
        else
            if valid(laser) then sector:removeLaser(laser) end
            WormholeGuardian.playerChannelLasers[k] = nil
        end
    end

end


