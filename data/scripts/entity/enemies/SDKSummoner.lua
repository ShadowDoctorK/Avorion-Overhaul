package.path = package.path .. ";data/scripts/lib/?.lua"

local Xsotan = include ("story/xsotan")
include ("randomext")
local Log = include("SDKDebugLogging")

local _Debug = 0
local _ModName = "Summoner Logic" 
local function GetName(n)
    return _ModName .. " - " .. n
end

-- Don't remove or alter the following comment, it tells the game the namespace this script lives in. If you remove it, the script will break.
-- namespace Summoner
Summoner = {}
local self = Summoner

function Summoner.getAllowedSpawns()
    local _Base = 8
    -- Adjust based on Difficulty
    local _Settings = GameSettings()
    if _Settings.difficulty == Difficulty.Insane then 
        return _Base + 6
    elseif _Settings.difficulty == Difficulty.Hardcore then 
        return _Base + 4
    elseif _Settings.difficulty == Difficulty.Expert then 
        return _Base + 3
    elseif _Settings.difficulty == Difficulty.Veteran then 
        return _Base + 2
    elseif _Settings.difficulty == Difficulty.Normal then 
        return _Base + 1
    elseif _Settings.difficulty == Difficulty.Easy then 
        return _Base
    end
    return _Base -- failsafe    
end

self.timeStep = 3
self.data = {}
self.lasers = {}
self.Spawns = self.getAllowedSpawns()
self.Reclaimers = 4
self.ChargeUP = 0

self.Glow = false
self.GlowStatus = false

local lasers = self.lasers


function Summoner.getTimeStep()
    local _Base = 5
    -- Adjust based on Difficulty
    local _Settings = GameSettings()
    if _Settings.difficulty == Difficulty.Insane then 
        return _Base
    elseif _Settings.difficulty == Difficulty.Hardcore then 
        return _Base + 1
    elseif _Settings.difficulty == Difficulty.Expert then 
        return _Base + 2
    elseif _Settings.difficulty == Difficulty.Veteran then 
        return _Base + 3
    elseif _Settings.difficulty == Difficulty.Normal then 
        return _Base + 4
    elseif _Settings.difficulty == Difficulty.Easy then 
        return _Base + 5
    end
    return 10 -- failsafe    
end

function Summoner.initialize()
    local entity = Entity()
    entity:setValue("xsotan_summoner", true)
end

if onServer() then
function Summoner.getUpdateInterval()
    return self.timeStep
end
else
function Summoner.getUpdateInterval()
    return 0
end
end

function Summoner.updateServer(timeStep) local Method = GetName("Update Server")
    self.timeStep = self.getTimeStep()

    local entity = Entity()

    if ShipAI(entity).isAttackingSomething then

        --Log.Warning(Method, "Charge Up: " .. Log.S(self.ChargeUP), _Debug)
        --Log.Warning(Method, "Spawns: " .. Log.S(self.Spawns), _Debug)
        --Log.Warning(Method, "Reclaimers: " .. Log.S(self.Reclaimers), _Debug)
        --Log.Warning(Method, "Glow: " .. Log.S(self.Glow), _Debug)
        --Log.Warning(Method, "Glow Status: " .. Log.S(self.GlowStatus), _Debug)

        -- Wait for the Summoner to Charge before deploying...
        if self.ChargeUP < 30 then self.ChargeUP = self.ChargeUP + timeStep self.SetCharge(true) return end

        -- Set the Glow
        if self.Spawns + self.Reclaimers > 0 and not self.Glow then
            self.Glow = true self.SetGlow(true)
        -- Remove the Glow
        elseif self.Spawns + self.Reclaimers == 0 and self.Glow then
            self.Glow = false self.SetGlow(false)
            self.SetCharge(false)
        end

        if not self.Glow then return end

        if self.getSpawnableMinions() > 0 and self.Spawns > 0 then
            self.spawnMinion()
            self.Spawns = self.Spawns - 1
        end

        if self.getSpawnableReclaimers() > 0 and self.Reclaimers > 0 then
            self.spawnReclaimer()
            self.Reclaimers = self.Reclaimers - 1
        end
    end
end

function Summoner.updateClient(timeStep)
    local entity = Entity()

    local C = ColorRGB(1, 1, 0.878) 
    if self.GlowCharge == true and self.ChargeUP < 14 then
        self.ChargeUP = self.ChargeUP + timeStep
    elseif self.GlowCharge == false and self.ChargeUP ~= 0 then
        C = ColorRGB(0.816, 0.125, 0.565)
        self.ChargeUP = 12
    end

    --Log.Warning(Method, "Charge Up: " .. Log.S(self.ChargeUP), _Debug)

    for k, l in pairs(lasers) do

        if valid(l.laser) then
            l.laser.from = entity.translationf
            l.laser.to = l.to
        else
            lasers[k] = nil
        end
    end

    --Log.Warning(Method, "Client Glow: " .. Log.S(self.Glow), _Debug)
    --Log.Warning(Method, "Client Glow Status: " .. Log.S(self.GlowStatus), _Debug)

    if self.Glow and not self.GlowStatus then 
        self.GlowStatus = true
        Sector():addStaticHyperspaceGlow(entity.id)
    elseif not self.Glow and self.GlowStatus then
        self.GlowStatus = false
        Sector():removeStaticHyperspaceGlow(entity.id) 
    end

    if self.ChargeUP > 0 then
        Sector():createGlow(entity.translationf, self.ChargeUP * 2, C)
        Sector():createGlow(entity.translationf, self.ChargeUP * 4, C)
        Sector():createGlow(entity.translationf, self.ChargeUP * 6, C)
    end

end

function Summoner.Laser()

end

function Summoner.Glow()

end

function Summoner.SetCharge(v)
    if onServer() then 
        broadcastInvokeClientFunction("SetCharge", v)
    end

    self.GlowCharge = v
end

function Summoner.SetGlow(v)
    if onServer() then 
        broadcastInvokeClientFunction("SetGlow", v)
    end

    self.Glow = v
end

function Summoner.spawnMinion()
    local direction = random():getDirection()

    local master = Entity()
    local pos = master.translationf
    local radius = master.radius
    local minionPosition = pos + direction * radius * random():getFloat(5, 10)

    broadcastInvokeClientFunction("animation", direction, minionPosition)
    self.createWormhole(minionPosition)

    local matrix = MatrixLookUpPosition(master.look, master.up, minionPosition)
    local minion = Xsotan.createSummonerMinion(matrix, 0.5)
    minion:setValue("xsotan_summoner_minion", true)
    --minion:setTitle("Xsotan Minion"%_T, {})

    local attackedId = ShipAI(master).attackedEntity
    minion:invokeFunction("xsotanbehaviour.lua", "onSetToAggressive", attackedId)
end

function Summoner.spawnReclaimer()
    local direction = random():getDirection()

    local master = Entity()
    local pos = master.translationf
    local radius = master.radius
    local minionPosition = pos + direction * radius * random():getFloat(5, 10)

    broadcastInvokeClientFunction("animation", direction, minionPosition)
    self.createWormhole(minionPosition)

    local matrix = MatrixLookUpPosition(master.look, master.up, minionPosition)
    local minion = Xsotan.createReclaimer(matrix, 0.5)
    minion:setValue("xsotan_reclaimer", true)

    local attackedId = ShipAI(master).attackedEntity
    minion:invokeFunction("xsotanbehaviour.lua", "onSetToAggressive", attackedId)
end

function Summoner.createWormhole(position)
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

function Summoner.animation(direction, minionPosition)
    local sector = Sector()

    local entity = Entity()
    local pos = entity.translationf

    local laser = sector:createLaser(entity.translationf, minionPosition, ColorRGB(0.8, 0.6, 0.1), 1.5)
    laser.maxAliveTime = 1.5
    laser.collision = false
    laser.animationSpeed = -500

    table.insert(lasers, {laser = laser, to = minionPosition})
end

function Summoner.getSpawnableMinions(amount) local _MethodName = GetName("Spawnable Minions")
    local minions = Sector():getNumEntitiesByScriptValue("xsotan_summoner_minion")

    Log.Debug(_MethodName, "Spawned Minions: " .. tostring(minions), _Debug)

    local minionsPerSummoner = 6 + GameSettings().difficulty
    local open = minionsPerSummoner - minions

    -- spawn at max 8 minions to avoid infinite spawning
    local maxSpawnable = 8
    open = math.min(open, maxSpawnable)
    open = math.max(0, open)

    return open
end

function Summoner.getSpawnableReclaimers(amount) local _MethodName = GetName("Spawnable Reclaimers")
    local minions = Sector():getNumEntitiesByScriptValue("xsotan_reclaimer")

    Log.Debug(_MethodName, "Spawned Reclaimers: " .. tostring(minions), _Debug)

    local minionsPerSummoner = 2
    local open = minionsPerSummoner - minions
    
    local maxSpawnable = 2
    open = math.min(open, maxSpawnable)
    open = math.max(0, open)

    return open
end

function Summoner.secure()
    return self.data
end

function Summoner.restore(data)
    self.data = data or {}
end
