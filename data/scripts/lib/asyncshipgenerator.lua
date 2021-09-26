--[[
    Developer Notes:
    - Rebuild this entirely...
]]

local Log = include("SDKDebugLogging")
local Rand = include("SDKUtilityRandom")
local Volume = include("SDKGlobalDesigns - Volumes")

-- Logging Setup
    local Log = include("SDKDebugLogging")
    local _ModName = "Async Ship Generator"
    local _Debug = 0
-- End Logging

-- Custom Functions



--



-- New function
function AsyncShipGenerator:createCustomMilitaryShip(faction, position, volume)
    position = position or Matrix()
    volume = volume or Volume.Ship()
    
    PlanGenerator.makeAsyncShipPlan("_ship_generator_on_military_plan_generated", {self.generatorId, position, faction.index}, faction, volume)
    self:shipCreationStarted()
end

----------------------------------------------------------------------------------------------------------
------------------------------------- Modified Vanilla Funcitons -----------------------------------------
----------------------------------------------------------------------------------------------------------

-- Saved Vanilla Function
AsyncShipGenerator.old_createShip = AsyncShipGenerator.createShip 
function AsyncShipGenerator:createShip(_Faction, _Position, _Volume, _AutoOverride)
    position = position or Matrix()
    _Volume = _Volume or Volume.Ship()

    PlanGenerator.makeAsyncShipPlan("_ship_generator_on_ship_plan_generated", {self.generatorId, _Position, _Faction.index}, _Faction, _Volume, _AutoOverride)
    self:shipCreationStarted()
end

--[[
local function onShipPlanFinished(plan, generatorId, position, factionIndex)
    local self = generators[generatorId] or {}

    local faction = Faction(factionIndex)
    local ship = Sector():createShip(faction, "", plan, position, self.arrivalType)

    finalizeShip(ship)
    onShipCreated(generatorId, ship)
end
]]

-- Saved Vanilla Function
AsyncShipGenerator.old_createDefender = AsyncShipGenerator.createDefender 
function AsyncShipGenerator:createDefender(faction, position)
    position = position or Matrix()

    -- defenders should be a lot beefier than the normal ships
    -- Override Chance in GetShipVolume
    local Chance = {}
    Chance[1]   = 0    Chance[2]   = 0
    Chance[3]   = 0    Chance[4]   = 0 
    Chance[5]   = 0    Chance[6]   = 0 

    Chance[7]   = 100   -- 100 Ships
    Chance[8]   = 200   -- 100 Ships
    Chance[9]   = 300   -- 100 Ships
    Chance[10]  = 500   -- 200 Ships
    Chance[11]  = 600   -- 100 Ships
    Chance[12]  = 700   -- 100 Ships
    Chance[13]  = 800   -- 100 Ships
    Chance[14]  = 870   -- 70 Ships
    Chance[15]  = 997   -- 57 Ships
    Chance[16]  = 1000  -- 3 Ship / 1000 Ships

    local volume = Volume.Ship(Chance)

    PlanGenerator.makeAsyncShipPlan("_ship_generator_on_defender_plan_generated", {self.generatorId, position, faction.index}, faction, volume)
    self:shipCreationStarted()
end

--[[
local function onDefenderPlanFinished(plan, generatorId, position, factionIndex)
    local self = generators[generatorId] or {}

    local faction = Faction(factionIndex)
    local ship = Sector():createShip(faction, "", plan, position, self.arrivalType)

    local turrets = Balancing_GetEnemySectorTurrets(Sector():getCoordinates()) * 2 + 3
    turrets = turrets + turrets * math.max(0, faction:getTrait("careful") or 0) * 0.5

    ShipUtility.addArmedTurretsToCraft(ship, turrets)
    ship.title = ShipUtility.getMilitaryNameByVolume(ship.volume)
    ship.damageMultiplier = ship.damageMultiplier * 4

    ship:addScript("ai/patrol.lua")
    ship:addScript("antismuggle.lua")
    ship:setValue("is_armed", 1)
    ship:setValue("is_defender", 1)
    ship:setValue("npc_chatter", true)

    ship:addScript("icon.lua", "data/textures/icons/pixel/defender.png")

    finalizeShip(ship)
    onShipCreated(generatorId, ship)
end
]]

-- Saved Vanilla Function
AsyncShipGenerator.old_createCarrier = AsyncShipGenerator.createCarrier 
function AsyncShipGenerator:createCarrier(faction, position, fighters)
    
    -- Check if Carriers are Valid
    if not carriersPossible() then
        self:createMilitaryShip(faction, position)
        return
    end

    position = position or Matrix()
    fighters = fighters or 10

    -- carriers should be even beefier than the defenders
    -- Override Chance in GetShipVolume
    local Chance = {}
    Chance[1]   = 0    Chance[2]   = 0
    Chance[3]   = 0    Chance[4]   = 0 
    Chance[5]   = 0    Chance[6]   = 0 
    Chance[7]   = 0    Chance[8]   = 0   
    Chance[9]   = 0

    Chance[10]  = 200   -- 200 Ships
    Chance[11]  = 400   -- 200 Ships
    Chance[12]  = 600   -- 200 Ships
    Chance[13]  = 750   -- 150 Ships
    Chance[14]  = 820   -- 120 Ships
    Chance[15]  = 993   -- 173 Ships
    Chance[16]  = 1000  -- 7 Ship / 1000 Ships

    local volume = Volume.Ship(Chance)
    
    PlanGenerator.makeAsyncCarrierPlan("_ship_generator_on_carrier_plan_generated", {self.generatorId, position, faction.index, fighters}, faction, volume)
    self:shipCreationStarted()
end

--[[
local function onCarrierPlanFinished(plan, generatorId, position, factionIndex, fighters)
    local self = generators[generatorId] or {}

    local faction = Faction(factionIndex)
    local ship = Sector():createShip(faction, "", plan, position, self.arrivalType)

    ShipUtility.addCarrierEquipment(ship, fighters)
    ship:addScript("ai/patrol.lua")

    finalizeShip(ship)
    onShipCreated(generatorId, ship)
end
]]

-- Saved Vanilla Function
AsyncShipGenerator.old_createMilitaryShip = AsyncShipGenerator.createMilitaryShip 
function AsyncShipGenerator:createMilitaryShip(faction, position, volume)
    position = position or Matrix()
    volume = Volume.Ship() -- Ignores volume arg

    PlanGenerator.makeAsyncShipPlan("_ship_generator_on_military_plan_generated", {self.generatorId, position, faction.index}, faction, volume)
    self:shipCreationStarted()
end

--[[
local function onMilitaryPlanFinished(plan, generatorId, position, factionIndex)
    local self = generators[generatorId] or {}

    local faction = Faction(factionIndex)
    local ship = Sector():createShip(faction, "", plan, position, self.arrivalType)

    ShipUtility.addMilitaryEquipment(ship, 1, 0)

    finalizeShip(ship)
    onShipCreated(generatorId, ship)
end
]]

-- Saved Vanilla Function
AsyncShipGenerator.old_createTorpedoShip =    AsyncShipGenerator.createTorpedoShip
function AsyncShipGenerator:createTorpedoShip(faction, position, volume)
    position = position or Matrix()
    volume = Volume.Ship() -- Ignores volume arg

    PlanGenerator.makeAsyncShipPlan("_ship_generator_on_torpedo_plan_generated", {self.generatorId, position, faction.index}, faction, volume)
    self:shipCreationStarted()
end

--[[
local function onTorpedoShipPlanFinished(plan, generatorId, position, factionIndex)
    local self = generators[generatorId] or {}

    local faction = Faction(factionIndex)
    local ship = Sector():createShip(faction, "", plan, position, self.arrivalType)

    ShipUtility.addTorpedoBoatEquipment(ship)

    finalizeShip(ship)
    onShipCreated(generatorId, ship)
end
]]

-- Saved Vanilla Function
AsyncShipGenerator.old_createDisruptorShip =  AsyncShipGenerator.createDisruptorShip
function AsyncShipGenerator:createDisruptorShip(faction, position, volume)
    if not disruptorsPossible() then
        self:createMilitaryShip(faction, position)
        return
    end

    position = position or Matrix()
    volume = Volume.Ship() -- Ignores volume arg

    PlanGenerator.makeAsyncShipPlan("_ship_generator_on_disruptor_plan_generated", {self.generatorId, position, faction.index}, faction, volume)
    self:shipCreationStarted()
end

--[[
local function onDisruptorShipPlanFinished(plan, generatorId, position, factionIndex)
    local self = generators[generatorId] or {}

    local faction = Faction(factionIndex)
    local ship = Sector():createShip(faction, "", plan, position, self.arrivalType)

    ShipUtility.addDisruptorEquipment(ship)

    finalizeShip(ship)
    onShipCreated(generatorId, ship)
end
]]

-- Saved Vanilla Function
AsyncShipGenerator.old_createCIWSShip =       AsyncShipGenerator.createCIWSShip
function AsyncShipGenerator:createCIWSShip(faction, position, volume)
    if not carriersPossible() then
        self:createMilitaryShip(faction, position)
        return
    end

    position = position or Matrix()
    volume = Volume.Ship() -- Ignores volume arg

    PlanGenerator.makeAsyncShipPlan("_ship_generator_on_ciws_plan_generated", {self.generatorId, position, faction.index}, faction, volume)
    self:shipCreationStarted()
end

--[[
local function onCIWSShipPlanFinished(plan, generatorId, position, factionIndex)
    local self = generators[generatorId] or {}

    local faction = Faction(factionIndex)
    local ship = Sector():createShip(faction, "", plan, position, self.arrivalType)

    ShipUtility.addCIWSEquipment(ship)

    finalizeShip(ship)
    onShipCreated(generatorId, ship)
end
]]

-- Saved Vanilla Function
AsyncShipGenerator.old_createPersecutorShip = AsyncShipGenerator.createPersecutorShip
function AsyncShipGenerator:createPersecutorShip(faction, position, volume)
    position = position or Matrix()
    volume = Volume.Ship() -- Ignores volume arg

    PlanGenerator.makeAsyncShipPlan("_ship_generator_on_persecutor_plan_generated", {self.generatorId, position, faction.index}, faction, volume)
    self:shipCreationStarted()
end

--[[
local function onPersecutorShipPlanFinished(plan, generatorId, position, factionIndex)
    local self = generators[generatorId] or {}

    local faction = Faction(factionIndex)
    local ship = Sector():createShip(faction, "", plan, position, self.arrivalType)

    ShipUtility.addPersecutorEquipment(ship)

    finalizeShip(ship)
    onShipCreated(generatorId, ship)
end
]]

-- Saved Vanilla Function
AsyncShipGenerator.old_createBlockerShip =    AsyncShipGenerator.createBlockerShip
function AsyncShipGenerator:createBlockerShip(faction, position, volume)
    position = position or Matrix()
    volume = Volume.Ship() -- Ignores volume arg

    PlanGenerator.makeAsyncShipPlan("_ship_generator_on_blocker_plan_generated", {self.generatorId, position, faction.index}, faction, volume)
    self:shipCreationStarted()
end

--[[
local function onBlockerShipPlanFinished(plan, generatorId, position, factionIndex)
    local self = generators[generatorId] or {}

    local faction = Faction(factionIndex)
    local ship = Sector():createShip(faction, "", plan, position, self.arrivalType)

    ShipUtility.addBlockerEquipment(ship)

    finalizeShip(ship)
    onShipCreated(generatorId, ship)
end
]]

-- Saved Vanilla Function
AsyncShipGenerator.old_createFlagShip =       AsyncShipGenerator.createFlagShip
function AsyncShipGenerator:createFlagShip(faction, position, volume)
    position = position or Matrix()

    -- Override Chance in GetShipVolume
    local Chance = {}
    Chance[1]   = 0    Chance[2]   = 0
    Chance[3]   = 0    Chance[4]   = 0 
    Chance[5]   = 0    Chance[6]   = 0 
    Chance[7]   = 0    Chance[8]   = 0   
    Chance[9]   = 0    Chance[10]  = 0   
    Chance[11]  = 0    Chance[12]  = 0   

    Chance[13]  = 300   -- 300 Ships
    Chance[14]  = 650   -- 350 Ships
    Chance[15]  = 950   -- 300 Ships
    Chance[16]  = 50    -- 50 Ships / 1000 Ships

    volume = Volume.Ship(Chance) -- Ignores volume arg

    PlanGenerator.makeAsyncShipPlan("_ship_generator_on_flagship_plan_generated", {self.generatorId, position, faction.index}, faction, volume)
    self:shipCreationStarted()
end

--[[
local function onFlagShipPlanFinished(plan, generatorId, position, factionIndex)
    local self = generators[generatorId] or {}

    local faction = Faction(factionIndex)
    local ship = Sector():createShip(faction, "", plan, position, self.arrivalType)

    ShipUtility.addFlagShipEquipment(ship)

    finalizeShip(ship)
    onShipCreated(generatorId, ship)
end
]]

-- Saved Vanilla Function
AsyncShipGenerator.old_createTradingShip =    AsyncShipGenerator.createTradingShip
function AsyncShipGenerator:createTradingShip(faction, position, volume)
    position = position or Matrix()

    -- Override Chance in GetShipVolume
    local Chance = {}
    Chance[1]   = 0    Chance[2]   = 0
    Chance[3]   = 0    Chance[4]   = 0 
    Chance[5]   = 0    
    
    Chance[6]   = 50 
    Chance[7]   = 150    
    Chance[8]   = 250       
    Chance[9]   = 350
    Chance[10]  = 500   
    Chance[11]  = 650   
    Chance[12]  = 800   
    Chance[13]  = 1000  
    Chance[14]  = 1000  -- 0 Ships
    Chance[15]  = 1000  -- 0 Ships
    Chance[16]  = 1000  -- 0 Ship / 1000 Ships

    local volume = Volume.Ship(Chance)

    PlanGenerator.makeAsyncShipPlan("_ship_generator_on_trader_plan_generated", {self.generatorId, position, faction.index}, faction, volume)
    self:shipCreationStarted()
end

--[[
local function onTraderPlanFinished(plan, generatorId, position, factionIndex)
    local self = generators[generatorId] or {}

    local faction = Faction(factionIndex)
    local ship = Sector():createShip(faction, "", plan, position, self.arrivalType)

    if math.random() < 0.5 then
        local turrets = Balancing_GetEnemySectorTurrets(Sector():getCoordinates())
        ShipUtility.addArmedTurretsToCraft(ship, turrets)
    end

    ship.title = ShipUtility.getTraderNameByVolume(ship.volume)

    ship:addScript("civilship.lua")
    ship:addScript("dialogs/storyhints.lua")
    ship:setValue("is_civil", 1)
    ship:setValue("is_trader", 1)
    ship:setValue("npc_chatter", true)

    ship:addScript("icon.lua", "data/textures/icons/pixel/civil-ship.png")

    finalizeShip(ship)
    onShipCreated(generatorId, ship)
end
]]

-- Saved Vanilla Function
AsyncShipGenerator.old_createFreighterShip =  AsyncShipGenerator.createFreighterShip
function AsyncShipGenerator:createFreighterShip(_Faction, _Position, _Volume, _AutoOverride)
    position = position or Matrix()

    -- Override Chance in GetShipVolume
    local Chance = {}
    Chance[1]   = 0    Chance[2]   = 0
    Chance[3]   = 0    Chance[4]   = 0 

    Chance[5]   = 50     
    Chance[6]   = 100 
    Chance[7]   = 150    
    Chance[8]   = 400   
    Chance[9]   = 500
    Chance[10]  = 600   
    Chance[11]  = 700   
    Chance[12]  = 800   
    Chance[13]  = 900  
    Chance[14]  = 950 
    Chance[15]  = 1000
    Chance[16]  = 1000 -- 0 Ship / 1000 Ships

    _Volume = _Volume or Volume.Ship(Chance)

    PlanGenerator.makeAsyncFreighterPlan("_ship_generator_on_freighter_plan_generated", {self.generatorId, _Position, _Faction.index}, _Faction, _Volume, _AutoOverride)
    self:shipCreationStarted()
end

-- Saved Vanilla Function
AsyncShipGenerator.old_createMiningShip =     AsyncShipGenerator.createMiningShip
function AsyncShipGenerator:createMiningShip(_Faction, _Position, _Volume, _AutoOverride)
    position = position or Matrix()

    -- Override Chance in GetShipVolume
    local Chance = {}
    Chance[1]   = 0    Chance[2]   = 0
    Chance[3]   = 0    Chance[4]   = 0 

    Chance[5]   = 50     
    Chance[6]   = 100 
    Chance[7]   = 150    
    Chance[8]   = 400   
    Chance[9]   = 500
    Chance[10]  = 600   
    Chance[11]  = 700   
    Chance[12]  = 800   
    Chance[13]  = 900  
    Chance[14]  = 950 
    Chance[15]  = 1000
    Chance[16]  = 1000 -- 0 Ship / 1000 Ships

    _Volume = _Volume or Volume.Ship(Chance)

    PlanGenerator.makeAsyncMinerPlan("_ship_generator_on_mining_plan_generated", {self.generatorId, _Position, _Faction.index}, _Faction, _Volume, _AutoOverride)
    self:shipCreationStarted()
end

--[[
local function onFreighterPlanFinished(plan, generatorId, position, factionIndex)
    local self = generators[generatorId] or {}

    local faction = Faction(factionIndex)
    local ship = Sector():createShip(faction, "", plan, position, self.arrivalType)

    if math.random() < 0.5 then
        local turrets = Balancing_GetEnemySectorTurrets(Sector():getCoordinates())

        ShipUtility.addArmedTurretsToCraft(ship, turrets)
    end

    ship.title = ShipUtility.getFreighterNameByVolume(ship.volume)

    ship:addScript("civilship.lua")
    ship:addScript("dialogs/storyhints.lua")
    ship:setValue("is_civil", 1)
    ship:setValue("is_freighter", 1)
    ship:setValue("npc_chatter", true)

    ship:addScript("icon.lua", "data/textures/icons/pixel/civil-ship.png")

    finalizeShip(ship)
    onShipCreated(generatorId, ship)
end

local function onMiningPlanFinished(plan, generatorId, position, factionIndex)
    local self = generators[generatorId] or {}

    local faction = Faction(factionIndex)
    local ship = Sector():createShip(faction, "", plan, position, self.arrivalType)

    local turrets = Balancing_GetEnemySectorTurrets(Sector():getCoordinates())

    ShipUtility.addUnarmedTurretsToCraft(ship, turrets)
    ship.title = ShipUtility.getMinerNameByVolume(ship.volume)

    ship:addScript("civilship.lua")
    ship:addScript("dialogs/storyhints.lua")
    ship:setValue("is_civil", 1)
    ship:setValue("is_miner", 1)
    ship:setValue("npc_chatter", true)

    ship:addScript("icon.lua", "data/textures/icons/pixel/civil-ship.png")

    finalizeShip(ship)
    onShipCreated(generatorId, ship)
end

function AsyncShipGenerator:startBatch()
    self.batching = true
    self.generated = {}
    self.expected = 0
end

function AsyncShipGenerator:endBatch()
    self.batching = false

    -- it's possible all callbacks happened already before endBatch() is called
    self:tryBatchCallback()
end

function AsyncShipGenerator:shipCreationStarted()
    if self.batching then
        self.expected = self.expected + 1
    end

    generators[self.generatorId] = self
end

function AsyncShipGenerator:tryBatchCallback()

    -- don't callback while batching or when no ships were generated (yet)
    if not self.batching and self.expected > 0 and #self.generated == self.expected then
        if self.callback then
            -- Problem: Since this is all asynchronous, a generated ship might have been destroyed when the callback is executed
            -- There are 2 options here:
            -- 1. pass on all generated entity references, some might be invalid
            -- 2. pass on only valid entity references, might be strange because user ordered eg. 4 ships but only gets 3
            -- BUT: in both cases the user has to do some kind of check in the callback
            -- in case #1 a valid() check HAS to be done for every ship
            -- in case #2 a check for the correct amount of ships MIGHT have to be done
            -- since case 2 is less common and will lead to less code written in general, I (koonschi) opted for case #2

            -- find all valid ships and only pass those on
            local validGenerated = {}
            for _, entity in pairs(self.generated) do
                if valid(entity) then
                    table.insert(validGenerated, entity)
                end
            end

            self.callback(validGenerated)
        end

        generators[self.generatorId] = nil -- clean up
    end

end

local function new(namespace, onGeneratedCallback)
    local instance = {}
    instance.generatorId = random():getInt()
    instance.expected = 0
    instance.batching = false
    instance.generated = {}
    instance.callback = onGeneratedCallback
    instance.arrivalType = EntityArrivalType.Jump

    while generators[instance.generatorId] do
        instance.generatorId = random():getInt()
    end

    generators[instance.generatorId] = instance

    if namespace then
        assert(type(namespace) == "table")
    end

    if onGeneratedCallback then
        assert(type(onGeneratedCallback) == "function")
    end

    -- use a completely different naming schedule with underscores to increase probability that this is never used by anything else
    if namespace then
        namespace._ship_generator_on_ship_plan_generated = onShipPlanFinished
        namespace._ship_generator_on_defender_plan_generated = onDefenderPlanFinished
        namespace._ship_generator_on_carrier_plan_generated = onCarrierPlanFinished
        namespace._ship_generator_on_freighter_plan_generated = onFreighterPlanFinished
        namespace._ship_generator_on_military_plan_generated = onMilitaryPlanFinished
        namespace._ship_generator_on_torpedo_plan_generated = onTorpedoShipPlanFinished
        namespace._ship_generator_on_disruptor_plan_generated = onDisruptorShipPlanFinished
        namespace._ship_generator_on_persecutor_plan_generated = onPersecutorShipPlanFinished
        namespace._ship_generator_on_blocker_plan_generated = onBlockerShipPlanFinished
        namespace._ship_generator_on_ciws_plan_generated = onCIWSShipPlanFinished
        namespace._ship_generator_on_flagship_plan_generated = onFlagShipPlanFinished
        namespace._ship_generator_on_trader_plan_generated = onTraderPlanFinished
        namespace._ship_generator_on_mining_plan_generated = onMiningPlanFinished
    else
        -- use global variables
        _ship_generator_on_ship_plan_generated = onShipPlanFinished
        _ship_generator_on_defender_plan_generated = onDefenderPlanFinished
        _ship_generator_on_carrier_plan_generated = onCarrierPlanFinished
        _ship_generator_on_freighter_plan_generated = onFreighterPlanFinished
        _ship_generator_on_military_plan_generated = onMilitaryPlanFinished
        _ship_generator_on_torpedo_plan_generated = onTorpedoShipPlanFinished
        _ship_generator_on_disruptor_plan_generated = onDisruptorShipPlanFinished
        _ship_generator_on_persecutor_plan_generated = onPersecutorShipPlanFinished
        _ship_generator_on_blocker_plan_generated = onBlockerShipPlanFinished
        _ship_generator_on_ciws_plan_generated = onCIWSShipPlanFinished
        _ship_generator_on_flagship_plan_generated = onFlagShipPlanFinished
        _ship_generator_on_trader_plan_generated = onTraderPlanFinished
        _ship_generator_on_mining_plan_generated = onMiningPlanFinished
    end

    return setmetatable(instance, AsyncShipGenerator)
end

return setmetatable({new = new}, {__call = function(_, ...) return new(...) end})
]]