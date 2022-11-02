package.path = package.path .. ";data/scripts/lib/?.lua"

local Xsotan = include ("story/xsotan")
include ("randomext")
local Log = include("SDKDebugLogging")

local _Debug = 0
local _ModName = "Reclaimer Logic" function GetName(n)
    return _ModName .. " - " .. n
end

-- Don't remove or alter the following comment, it tells the game the namespace this script lives in. If you remove it, the script will break.
-- namespace Reclaimer
Reclaimer = {}
local self = Reclaimer

function Reclaimer.getAllowedSpawns()
    local _Base = 25
    -- Adjust based on Difficulty
    local _Settings = GameSettings()
    if _Settings.difficulty == Difficulty.Insane then 
        return _Base + 18
    elseif _Settings.difficulty == Difficulty.Hardcore then 
        return _Base + 15
    elseif _Settings.difficulty == Difficulty.Expert then 
        return _Base + 12
    elseif _Settings.difficulty == Difficulty.Veteran then 
        return _Base + 9
    elseif _Settings.difficulty == Difficulty.Normal then 
        return _Base + 6
    elseif _Settings.difficulty == Difficulty.Easy then 
        return _Base
    end
    return _Base -- failsafe    
end

self.timeStep = 5
self.data = {}
self.lasers = {}
self.Spawns = self.getAllowedSpawns()

local lasers = self.lasers

function Reclaimer.getTimeStep()
    local _Base = 5
    -- Adjust based on Difficulty
    local _Settings = GameSettings()
    if _Settings.difficulty == Difficulty.Insane then 
        return _Base
    elseif _Settings.difficulty == Difficulty.Hardcore then 
        return _Base + 2
    elseif _Settings.difficulty == Difficulty.Expert then 
        return _Base + 3
    elseif _Settings.difficulty == Difficulty.Veteran then 
        return _Base + 4
    elseif _Settings.difficulty == Difficulty.Normal then 
        return _Base + 5
    elseif _Settings.difficulty == Difficulty.Easy then 
        return _Base + 7
    end
    return 10 -- failsafe    
end

function Reclaimer.initialize()
    local entity = Entity()
    entity:setValue("xsotan_reclaimer", true)
end

if onServer() then
    function Reclaimer.getUpdateInterval()
        return self.timeStep
    end
else
    function Reclaimer.getUpdateInterval()
        return 0.25
    end
end

function Reclaimer.updateServer(timeStep)

    if self.Spawns <= 0 then return end

    self.timeStep = self.getTimeStep()

    local entity = Entity()

    if ShipAI(entity).isAttackingSomething then
        if self.getSpawnableMinions() > 0 and self.Spawns > 0 then
            self.spawnMinion()
            --self.timeStep = random():getFloat(2, 3)
            self.Spawns = self.Spawns - 1
        end
    end
end

function Reclaimer.updateClient(timeStep)
    local entity = Entity()
    for k, l in pairs(lasers) do

        if valid(l.laser) then
            l.laser.from = entity.translationf
            l.laser.to = l.to
        else
            lasers[k] = nil
        end
    end
end

function Reclaimer.spawnMinion()
    local direction = random():getDirection()

    local master = Entity()
    local pos = master.translationf
    local radius = master.radius
    local minionPosition = pos + direction * radius * random():getFloat(5, 10)

    broadcastInvokeClientFunction("animation", direction, minionPosition)
    self.createWormhole(minionPosition)

    local matrix = MatrixLookUpPosition(master.look, master.up, minionPosition)
    local minion = Xsotan.createReclaimerMinion(matrix, 0.5)
    minion:setValue("xsotan_reclaimer_minion", true)
    --minion:setTitle("Xsotan Minion"%_T, {})

    local attackedId = ShipAI(master).attackedEntity
    minion:invokeFunction("xsotanbehaviour.lua", "onSetToAggressive", attackedId)
end

function Reclaimer.createWormhole(position)
    -- spawn a wormhole
    local desc = WormholeDescriptor()
    desc:removeComponent(ComponentType.EntityTransferrer)
    desc:addComponents(ComponentType.DeletionTimer)
    desc.position = MatrixLookUpPosition(vec3(0, 1, 0), vec3(1, 0, 0), position)

    local size = random():getFloat(15, 25)
    local wormhole = desc:getComponent(ComponentType.WormHole)
    wormhole:setTargetCoordinates(random():getInt(-50, 50), random():getInt(-50, 50))
    wormhole.visible = true
    wormhole.visualSize = size
    wormhole.passageSize = size
    wormhole.oneWay = true
    wormhole.simplifiedVisuals = true

    desc:addScriptOnce("data/scripts/entity/wormhole.lua")

    local wormhole = Sector():createEntity(desc)

    local timer = DeletionTimer(wormhole.index)
    timer.timeLeft = 3
end

function Reclaimer.animation(direction, minionPosition)
    local sector = Sector()

    local entity = Entity()
    local pos = entity.translationf

    local laser = sector:createLaser(entity.translationf, minionPosition, ColorRGB(0.8, 0.6, 0.1), 1.5)
    laser.maxAliveTime = 1.5
    laser.collision = false
    laser.animationSpeed = -500

    table.insert(lasers, {laser = laser, to = minionPosition})
end

function Reclaimer.getSpawnableMinions(amount) local _MethodName = GetName("Spawnable Minions")
    local minions = Sector():getNumEntitiesByScriptValue("xsotan_reclaimer_minion")

    Log.Debug(_MethodName, "Spawned Latchers: " .. tostring(minions), _Debug)

    local Allowed = 6 + GameSettings().difficulty
    local open = Allowed - minions

    -- spawn at max 8 minions to avoid infinite spawning
    local maxSpawnable = 15
    open = math.min(open, maxSpawnable)
    open = math.max(0, open)

    return open
end

function Reclaimer.secure()
    return self.data
end

function Reclaimer.restore(data)
    self.data = data or {}
end
