--[[
    Example Code for creating a ship...

    local Faction = include("SDKUtilityFaction")
    local Class = include("SDKGlobalDesigns - Classes")
    local Ships = include("SDKGlobalDesigns - Generator Ships Async")       -- When you are using all the defaults

    function ExampleShip(fac, pos)
        local Call = Ships.Callbacks() 
        local Ships = SDKAsyncShipGenerator(Namespace, ExampleCallback)     -- When you are passing Namespace and Callbacks

        local Settings = Ships.Settings(
            Class.Carrier,          -- Style
            nil,                    -- Volume (Will Randomize if nil)
            nil,                    -- Material (Will select based on region if nil)
            "Example Ship",         -- Will override the ship title if set
            nil,                    -- Defaults to "Jump" arrival unless set to "EntityArrivalType.Gate"
            Call.Carrier            -- Callback function to use the defaults.
        )

        Ships.Generate(
            Faction.Civilian(),     -- Faction
            pos or Matrix(),        -- Position
            Settings                -- Pass Settings
        )

    end

    function ExampleCallback(ship)
        -- Code will execute after the generator is finished
    end
]]

package.path = package.path .. ";data/scripts/lib/?.lua"
package.path = package.path .. ";data/scripts/?.lua"

include ("defaultscripts")
local Rand = include("SDKUtilityRandom")
local Plan = include("plangenerator")
local Equip = include("SDKGlobalDesigns - Equipment")
local Volume = include("SDKGlobalDesigns - Volumes")

-- Logging Setup
    local Log = include("SDKDebugLogging")
    local _ModName = "Async Ship Generator"
    local _Debug = 0

    local function LogName(n)
        return _ModName .. " - " .. n
    end
-- End Logging

local SDKShipGenerator = {}

-- SDKGlobalDesigns - Generator Ships Async Utilitiy.lua 
    -- Inlucde these in other scripts by using the above lua

    local CB = {}   
    CB.Ship          = "SDKAsyncGeneratedShip"
    CB.Defender      = "SDKAsyncGeneratedDefender"
    CB.Carrier       = "SDKAsyncGeneratedCarrier"
    CB.Military      = "SDKAsyncGeneratedMilitary"
    CB.Trader        = "SDKAsyncGeneratedTrader"
    CB.Miner         = "SDKAsyncGeneratedMiner"
    CB.Salvager      = "SDKAsyncGeneratedSalvager"
    CB.Civilian      = "SDKAsyncGeneratedCivilian"
    CB.Drone         = "SDKAsyncGeneratedDrone"
    CB.CrewTransport = "SDKAsyncGeneratedCrewTransport"

    local function Settings(sn, vl, mt, ti, at, cb)
        local o = {}
        o.style = sn
        o.volume = vl
        o.material = mt
        o.title = ti
        o.arrival = at
        o.callback = cb     
        return o
    end
--

-- since this local variable can be used in multiple scripts in the same lua_State, a single callback function isn't enough
-- we use a table that has a unique id per generator
local G = {} -- G
local SDKAsyncShipGenerator = {}
SDKAsyncShipGenerator.__index = SDKAsyncShipGenerator

-- Common / Support Functions

    local function Created(generatorId, ship) local Method = LogName("Created")
        Log.Debug(Method, "Begining Post Creation...", _Debug)
        local self = G[generatorId] if not self then return end
        
        Log.Debug(Method, "Generator: " .. Log.S(self.generatorId), _Debug)

        if self.expected > 0 then
            table.insert(self.generated, ship) 
            self:TryBatchCallback()
            
        elseif not self.batching then                                       -- No Callback for Single Creation
            if self.callback then self.callback(ship) end
            G[generatorId] = nil                                            -- Clean Up

        end
    end

    local function Finalize(ship)
        ship.crew = ship.idealCrew
        ship.shieldDurability = ship.shieldMaxDurability
        AddDefaultShipScripts(ship)
        SetBoardingDefenseLevel(ship)
    end

--

function SDKAsyncShipGenerator:Generate(fac, pos, o) local Method = LogName("Generate")
    pos = pos or Matrix()
    o = o or Settings()
    
    -- Validate Callback
    if not o.callback then 
        o.callback = "SDKAsyncGeneratedShip"
        Log.Warning(Method, "No Callback Passed, Using Default Ship Callback...", 1)
    end
    
    -- Validate Style
    if not o.style then 
        o.style = "Military"
        Log.Warning(Method, "No Style Passed, Using Default Military Style...", 1)
    end
    
    -- Validate Volume
    if not o.volume then
        o.volume = Plan.Volume.Ship()
    end

    Log.Debug(Method, "Target Internal Callback: " .. Log.S(o.callback))

    Plan.ShipAsync(o.callback, {self.generatorId, pos, fac.index, o}, fac, o.style, false, o)
    self:Started()
end

-- Callback Functions

    local function FinishedShip(plan, generatorId, pos, fi, o)
        local self = G[generatorId] or {} o = o or {}
        local fac = Faction(self.factionIndex or fi)
        local ship = Sector():createShip(fac, "", plan, pos, o.arrival or self.arrivalType)
        ship.title = o.title or Volume.MilitaryName(ship.volume)
        Finalize(ship) Created(generatorId, ship)
    end

    local function FinishedDefender(plan, generatorId, pos, fi, o)
        local self = G[generatorId] or {} o = o or {}
        local fac = Faction(self.factionIndex or fi)
        local ship = Sector():createShip(fac, "", plan, pos, o.arrival or self.arrivalType)
        ship:setValue("SDKShipType", "Defender")
        
        local Armed, Defense = Equip.GetTurrets(ship, fac)
        Equip.FactionTurret(ship, fac, Equip._Armed, Armed)        -- Armed Faction Turrets
        Equip.FactionTurret(ship, fac, Equip._Defense, Defense)    -- Defense Faction Turrets
    
        ship.title = o.title or Volume.MilitaryName(ship.volume)
        ship.shieldDurability = ship.shieldMaxDurability
        ship.crew = ship.idealCrew   
        -- ship.damageMultiplier = ship.damageMultiplier * 4
    
        ship:addScript("ai/patrol.lua")
        ship:addScript("antismuggle.lua")
        ship:setValue("is_armed", true)
        ship:setValue("is_defender", true)
        ship:setValue("npc_chatter", true)
        ship:addScript("icon.lua", "data/textures/icons/pixel/defender.png")
    
        Finalize(ship) Created(generatorId, ship)
    end 

    local function FinishedCarrier(plan, generatorId, pos, fi, o)
        local self = G[generatorId] or {} o = o or {}
        local fac = Faction(self.factionIndex or fi)
        local ship = Sector():createShip(fac, "", plan, pos, o.arrival or self.arrivalType)
        ship:setValue("SDKShipType", "Carrier")

        local Armed, Defense = Equip.GetTurrets(ship, fac)
        Equip.FactionTurret(ship, fac, Equip._Armed, Armed)        -- Armed Faction Turrets
        Equip.FactionTurret(ship, fac, Equip._Defense, Defense)    -- Defense Faction Turrets
        Equip.CombatHanger(ship)                                   -- Add Fighters Wings

        ship.shieldDurability = ship.shieldMaxDurability
        ship.title = o.title or Volume.CarrierName(ship.volume)
        ship.crew = ship.idealCrew

        ship:addScript("ai/patrol.lua")
        ship:setValue("is_armed", true)      -- Vanilla Variable
        ship:addScript("icon.lua", "data/textures/icons/pixel/carrier.png")

        Finalize(ship) Created(generatorId, ship)
    end

    local function FinishedMilitary(plan, generatorId, pos, fi, o)
        local self = G[generatorId] or {} o = o or {}
        local fac = Faction(self.factionIndex or fi)
        local ship = Sector():createShip(fac, "", plan, pos, o.arrival or self.arrivalType)
        ship:setValue("SDKShipType", "Military")

        local Armed, Defense = Equip.GetTurrets(ship, fac)
        Equip.FactionTurret(ship, fac, Equip._Armed, Armed)        -- Armed Faction Turrets
        Equip.FactionTurret(ship, fac, Equip._Defense, Defense)    -- Defense Faction Turrets
    
        ship.crew = ship.idealCrew
        ship.title = o.title or Volume.MilitaryName(ship.volume)
        ship.shieldDurability = ship.shieldMaxDurability
    
        ship:setValue("is_armed", true)      -- Vanilla Variable
        ship:addScript("icon.lua", "data/textures/icons/pixel/military-ship.png")

        Finalize(ship) Created(generatorId, ship)
    end

    local function FinishedTrader(plan, generatorId, pos, fi, o)
        local self = G[generatorId] or {} o = o or {}
        local fac = Faction(self.factionIndex or fi)
        local ship = Sector():createShip(fac, "", plan, pos, o.arrival or self.arrivalType)
        ship:setValue("SDKShipType", "Trader")
    
        local Armed, Defense = Equip.GetTurrets(ship, fac)
        if Rand.Truth(0.75) then
            Equip.FactionTurret(ship, fac, Equip._Armed, Armed)    -- Armed Faction Turrets
            ship:setValue("is_armed", true)      -- Vanilla Variable
        end
        Equip.FactionTurret(ship, fac, Equip._Defense, Defense)    -- Defense Faction Turrets
    
        ship.crew = ship.idealCrew
        ship.title = o.title or Volume.TraderName(ship.volume)
        ship.shieldDurability = ship.shieldMaxDurability
    
        ship:addScript("civilship.lua")
        ship:addScript("dialogs/storyhints.lua")
        ship:setValue("is_civil", true)         -- Vanilla Variable
        ship:setValue("is_trader", true)        -- Vanilla Variable
        ship:setValue("npc_chatter", true)      -- Vanilla Variable
        ship:addScript("icon.lua", "data/textures/icons/pixel/civil-ship.png")
        
        Finalize(ship) Created(generatorId, ship)
    end

    local function FinishedFreighter(plan, generatorId, pos, fi, o)
        local self = G[generatorId] or {} o = o or {}
        local fac = Faction(self.factionIndex or fi)
        local ship = Sector():createShip(fac, "", plan, pos, o.arrival or self.arrivalType)
        ship:setValue("SDKShipType", "Freighter")

        ship.shieldDurability = ship.shieldMaxDurability
    
        local Armed, Defense = Equip.GetTurrets(ship, fac)
        if Rand.Truth() then
            Equip.FactionTurret(ship, fac, Equip._Armed, Armed)    -- Armed Faction Turrets
            ship:setValue("is_armed", true)      -- Vanilla Variable
        end
        Equip.FactionTurret(ship, fac, Equip._Defense, Defense)    -- Defense Faction Turrets
        
        ship.crew = ship.idealCrew
        ship.title = Volume.FreighterName(ship.volume)
    
        ship:addScript("civilship.lua")
        ship:addScript("dialogs/storyhints.lua")
        ship:setValue("is_civil", true)         -- Vanilla Variable
        ship:setValue("is_freighter", true)     -- Vanilla Variable
        ship:setValue("npc_chatter", true)      -- Vanilla Variable
        ship:addScript("icon.lua", "data/textures/icons/pixel/civil-ship.png")
        
        Finalize(ship) Created(generatorId, ship)
    end

    local function FinishedMiner(plan, generatorId, pos, fi, o)
        local self = G[generatorId] or {} o = o or {}
        local fac = Faction(self.factionIndex or fi)
        local ship = Sector():createShip(fac, "", plan, pos, o.arrival or self.arrivalType)
        ship:setValue("SDKShipType", "Miner")

        ship.shieldDurability = ship.shieldMaxDurability
    
        local Armed, Defense = Equip.GetTurrets(ship, fac)
        Equip.FactionTurret(ship, fac, Equip._Miner, Armed)        -- Miner Faction Turrets
        Equip.FactionTurret(ship, fac, Equip._Defense, Defense)    -- Defense Faction Turrets
        if Rand.Truth(0.25) then
            Equip.FactionTurret(ship, fac, Equip._Armed, Armed)    -- Armed Faction Turrets
            ship:setValue("is_armed", true)      -- Vanilla Variable
        end
        
        ship.crew = ship.idealCrew
        ship.title = Volume.MinerName(ship.volume)
    
        ship:addScript("civilship.lua")
        ship:addScript("dialogs/storyhints.lua")
        ship:setValue("is_civil", true)             -- Vanilla Variable
        ship:setValue("is_miner", true)             -- Vanilla Variable
        ship:setValue("npc_chatter", true)          -- Vanilla Variable
        ship:addScript("icon.lua", "data/textures/icons/pixel/civil-ship.png")
        
        Finalize(ship) Created(generatorId, ship)
    end

    local function FinishedSalvager(plan, generatorId, pos, fi, o)
        local self = G[generatorId] or {} o = o or {}
        local fac = Faction(self.factionIndex or fi)
        local ship = Sector():createShip(fac, "", plan, pos, o.arrival or self.arrivalType)
        ship:setValue("SDKShipType", "Salvager")

        ship.shieldDurability = ship.shieldMaxDurability
    
        local Armed, Defense = Equip.GetTurrets(ship, fac)
        Equip.FactionTurret(ship, fac, Equip._Salvager, Armed)     -- Salvager Faction Turrets
        Equip.FactionTurret(ship, fac, Equip._Defense, Defense)    -- Defense Faction Turrets
        if Rand.Truth(0.25) then
            Equip.FactionTurret(ship, fac, Equip._Armed, Armed)    -- Armed Faction Turrets
            ship:setValue("is_armed", true)      -- Vanilla Variable
        end
        
        ship.crew = ship.idealCrew
        ship.title = Volume.SalvagerName(ship.volume)
    
        ship:addScript("civilship.lua")
        ship:addScript("dialogs/storyhints.lua")
        ship:setValue("is_civil", true)             -- Vanilla Variable
        ship:setValue("npc_chatter", true)          -- Vanilla Variable
        ship:addScript("icon.lua", "data/textures/icons/pixel/civil-ship.png")
        
        Finalize(ship) Created(generatorId, ship)
    end

    local function FinishedCrewTransport(plan, generatorId, pos, fi, o)
        local self = G[generatorId] or {} o = o or {}
        local fac = Faction(self.factionIndex or fi)
        local ship = Sector():createShip(fac, "", plan, pos, o.arrival or self.arrivalType)
        ship:setValue("SDKShipType", "Crew Transport")

        ship.shieldDurability = ship.shieldMaxDurability
    
        local Armed, Defense = Equip.GetTurrets(ship, fac)
        Equip.FactionTurret(ship, fac, Equip._Defense, Defense)    -- Defense Faction Turrets
        if Rand.Truth(0.25) then
            Equip.FactionTurret(ship, fac, Equip._Armed, Armed)    -- Armed Faction Turrets
            ship:setValue("is_armed", true)      -- Vanilla Variable
        end
        
        ship.crew = ship.idealCrew
        ship.title = "Crew Transport"
    
        ship:addScript("civilship.lua")
        ship:addScript("dialogs/storyhints.lua")
        ship:setValue("is_civil", true)             -- Vanilla Variable
        ship:setValue("npc_chatter", true)          -- Vanilla Variable
        ship:addScript("icon.lua", "data/textures/icons/pixel/groupmember.png")
        
        Finalize(ship) Created(generatorId, ship)
    end

--

-- Batching & Setup Functions

    function SDKAsyncShipGenerator:startBatch()
        self.batching = true
        self.generated = {}
        self.expected = 0
    end

    function SDKAsyncShipGenerator:endBatch()
        self.batching = false

        -- it's possible all callbacks happened already before endBatch() is called
        self:TryBatchCallback()
    end

    function SDKAsyncShipGenerator:Started() local Method = LogName("New")
        if self.batching then
            self.expected = self.expected + 1
        end

        G[self.generatorId] = self
    end

    function SDKAsyncShipGenerator:tryBatchCallback() local Method = LogName("Batch Callback")

        -- don't callback while batching or when no ships were generated (yet)
        if not self.batching and self.expected > 0 and #self.generated == self.expected then

            if self.callback then

                -- find all valid ships and only pass those on
                local validGenerated = {}
                for _, entity in pairs(self.generated) do
                    if valid(entity) then
                        table.insert(validGenerated, entity)
                    end
                end

                Log.Debug(Method, "Sending Ships to the Callback...", _Debug)
                self.callback(validGenerated)
            end

            G[self.generatorId] = nil -- clean up
        end

    end

    local function new(namespace, cb) local Method = LogName("New")
        Log.Debug(Method, "Creating New Instance...", _Debug)
        Log.Debug(Method, "Name Space: " .. Log.S(namespace), _Debug)
        Log.Debug(Method, "Callback: " .. Log.S(cb), _Debug)

        local i = {}    -- Instance
        i.generatorId = random():getInt()
        i.expected = 0
        i.batching = false
        i.generated = {}
        i.callback = cb
        i.arrivalType = EntityArrivalType.Jump
        i.scaling = 1.0
        i.factionIndex = nil

        while G[i.generatorId] do
            i.generatorId = random():getInt()
        end

        Log.Debug(Method, "Generator: " .. Log.S(i.generatorId), _Debug)
        G[i.generatorId] = i

        if namespace then
            assert(type(namespace) == "table")
        end

        if cb then
            assert(type(cb) == "function")
        end

        if namespace then
            namespace.SDKAsyncGeneratedShip = FinishedShip
            namespace.SDKAsyncGeneratedDefender = FinishedDefender
            namespace.SDKAsyncGeneratedCarrier = FinishedCarrier
            namespace.SDKAsyncGeneratedFreighter = FinishedFreighter
            namespace.SDKAsyncGeneratedMilitary = FinishedMilitary
            namespace.SDKAsyncGeneratedTrader = FinishedTrader
            namespace.SDKAsyncGeneratedMiner = FinishedMiner
            namespace.SDKAsyncGeneratedSalvager = FinishedSalvager
            namespace.SDKAsyncGeneratedCivilian = FinishedCivilian
            namespace.SDKAsyncGeneratedDrone = FinishedDrone
            namespace.SDKAsyncGeneratedCrewTransport = FinishedCrewTransport
        else -- Global Callbacks
            SDKAsyncGeneratedShip = FinishedShip
            SDKAsyncGeneratedDefender = FinishedDefender
            SDKAsyncGeneratedCarrier = FinishedCarrier
            SDKAsyncGeneratedFreighter = FinishedFreighter
            SDKAsyncGeneratedMilitary = FinishedMilitary
            SDKAsyncGeneratedTrader = FinishedTrader
            SDKAsyncGeneratedMiner = FinishedMiner
            SDKAsyncGeneratedSalvager = FinishedSalvager
            SDKAsyncGeneratedCivilian = FinishedCivilian
            SDKAsyncGeneratedDrone = FinishedDrone
            SDKAsyncGeneratedCrewTransport = FinishedCrewTransport
        end

        return setmetatable(i, SDKAsyncShipGenerator)
    end

--

return setmetatable({new = new}, {__call = function(_, ...) return new(...) end})
