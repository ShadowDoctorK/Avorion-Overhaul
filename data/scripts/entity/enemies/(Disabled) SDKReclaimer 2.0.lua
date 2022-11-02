package.path = package.path .. ";data/scripts/lib/?.lua"

local Xsotan = include ("story/xsotan")
include ("randomext")

-- Logging Setup
local Log = include("SDKDebugLogging")
local _ModName = "Reclaimer Logic" 
local _Debug = 0
local function LogName(n) return _ModName .. " - " .. n end
-- End Logging

-- Don't remove or alter the following comment, it tells the game the namespace this script lives in. If you remove it, the script will break.
-- namespace SDK_Reclaimer
-- Fixe the above line removing the _
SDKReclaimer = {}
local self = SDKReclaimer

self.Step = 5
self.lasers = {}
self.MaxSpawns = nil

-- Latcher Types
self.Attackers = nil
self.Bombers = nil
self.Controllers = nil

function Reclaimer.initialize()
    local e = Entity() 
    e:setValue("xsotan_reclaimer", true)        -- Is this a Default Game marker?
    e:setValue("SDKXstoan", "Reclaimer")        -- My Custom Marker

    self.Step, self.MaxSpawns, self.Attackers, self.Bombers, self.Controllers = self.DifficultySettings()
end

if onServer() then
    function Reclaimer.getUpdateInterval() return self.Step end
else -- onClient()
    function Reclaimer.getUpdateInterval() return 0 end
end

function Reclaimer.Spawnable()
    return self.Attackers + self.Bombers + self.Controllers
end

function Reclaimer.OpenSpawn()

end

function Reclaimer.updateServer(Tick)

    if self.Spawnable() <= 0 then return end     -- No Spawns no Work

    local e = Entity() if ShipAI(e).isAttackingSomething then
        if self.Spawnable() > 0 and self.Spawns > 0 then
            self.spawnMinion()
            --self.timeStep = random():getFloat(2, 3)
            self.Spawns = self.Spawns - 1
        end
    end

end

function Reclaimer.updateClient(Tick)
    local e = Entity()
    for k, l in pairs(lasers) do

        if valid(l.laser) then
            l.laser.from = e.translationf
            l.laser.to = l.to
        else
            lasers[k] = nil
        end
    end
end

function Reclaimer.DifficultySettings()

    -- Easy Settings (Default)
    local T = 13        -- Server Tick Speed
    local M = 6         -- Max Spawns at One Time
    local A = 4         -- Attackers
    local B = 2         -- Bombers
    local C = 2         -- Controllers

    --[[
        Test using "GameSettings().difficulty" to make a 
        cleaner version of this function
    ]]

    -- Adjust based on Difficulty
    local S = GameSettings()
    if S.difficulty == Difficulty.Insane then 
        T = 5   M = 12   A = A*6   B = B*6   C = C*6          
    elseif S.difficulty == Difficulty.Hardcore then 
        T = 7   M = 10   A = A*5   B = B*5   C = C*5
    elseif S.difficulty == Difficulty.Expert then 
        T = 8   M = 9    A = A*4   B = B*4   C = C*4
    elseif S.difficulty == Difficulty.Veteran then 
        T = 9   M = 8    A = A*3   B = B*3   C = C*3
    elseif S.difficulty == Difficulty.Normal then 
        T = 10  M = 7    A = A*2   B = B*2   C = C*2
    --elseif S.difficulty == Difficulty.Easy then 
    end

    return T, M, A, B, C

end

function Reclaimer.spawnMinion()
    local dir = random():getDirection()

    local Reclaimer = Entity()
    local pos = Reclaimer.translationf
    local rad = Reclaimer.radius
    local MP = pos + dir * rad * random():getFloat(5, 10)

    broadcastInvokeClientFunction("animation", dir, MP)
    self.MakeWormhole(MP)

    local matrix = MatrixLookUpPosition(Reclaimer.look, Reclaimer.up, MP)
    local Minion = Xsotan.createReclaimerMinion(matrix, 0.5)
    Minion:setValue("SDKXstoan", "Latcher A")

    local Attack = ShipAI(Reclaimer).attackedEntity
    Minion:invokeFunction("xsotanbehaviour.lua", "onSetToAggressive", Attack)
end

function Reclaimer.MakeWormhole(position)
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

function Reclaimer.animation(dir, mp)
    local S = Sector()

    local e = Entity()
    local pos = entity.translationf

    local L = S:createLaser(e.translationf, mp, ColorRGB(0.8, 0.6, 0.1), 1.5)
    L.maxAliveTime = 1.5
    L.collision = false
    L.animationSpeed = -500

    table.insert(self.Lasers, {L = L, to = mp})
end

function Reclaimer.OpenSpawns(amount) local _MethodName = GetName("Spawnable Minions")
    
    local a = Sector():getNumEntitiesByScriptValue("Xsotan", "Latcher A")       -- Attackers
    local oa = self.Attackers - a

    local b = Sector():getNumEntitiesByScriptValue("Xsotan", "Latcher A")       -- Attackers
    local ob = self.Bombers - b

    local c = Sector():getNumEntitiesByScriptValue("Xsotan", "Latcher A")       -- Attackers
    local oc = self.Controllers - c

    -- spawn at max 8 minions to avoid infinite spawning
    local maxSpawnable = 15
    open = math.min(open, self.MaxSpawns)
    open = math.max(0, open)

    return open
end

function Reclaimer.secure()

    local Data = {}

    return Data
end

function Reclaimer.restore(Data)
    
end