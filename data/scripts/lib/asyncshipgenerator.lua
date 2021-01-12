local Log = include("SDKDebugLogging")
local Rand = include("SDKUtilityRandom")
local ShipClass_Default = include("ship_classes/default")
local ShipClass_Carrier = include("ship_classes/carrier")

local _ModName = "Async Ship Generator"

-- Fucntion to build Methodname
function GetName(n)
    return _ModName .. " - " .. n
end

local _Debug = 0

----------------------------------------------------------------------------------------------------------
----------------------------------------- Added Funcitons ------------------------------------------------
----------------------------------------------------------------------------------------------------------

AsyncShipGenerator.ShipClasses = {}

AsyncShipGenerator.VolumeShips = {}
AsyncShipGenerator.VolumeShips[1]  = 1       -- Slot 1
AsyncShipGenerator.VolumeShips[2]  = 51      -- Slot 2: 51660m3
AsyncShipGenerator.VolumeShips[3]  = 128     -- Slot 3: 131000m3
AsyncShipGenerator.VolumeShips[4]  = 320     -- Slot 4
AsyncShipGenerator.VolumeShips[5]  = 800     -- Slot 5
AsyncShipGenerator.VolumeShips[6]  = 2000    -- Slot 6
AsyncShipGenerator.VolumeShips[7]  = 5000    -- Slot 7
AsyncShipGenerator.VolumeShips[8]  = 12500   -- Slot 8
AsyncShipGenerator.VolumeShips[9]  = 19764   -- Slot 9
AsyncShipGenerator.VolumeShips[10] = 31250   -- Slot 10
AsyncShipGenerator.VolumeShips[11] = 43065   -- Slot 11
AsyncShipGenerator.VolumeShips[12] = 59348   -- Slot 12
AsyncShipGenerator.VolumeShips[13] = 78125   -- Slot 13
AsyncShipGenerator.VolumeShips[14] = 107554  -- Slot 14
AsyncShipGenerator.VolumeShips[15] = 148371  -- Slot 15
AsyncShipGenerator.VolumeShips[16] = 250000  -- Titan Scale / Max Size Limit For Slot 15 
AsyncShipGenerator.VolumeShips[17] = 500000  -- Max Size Limit for AI Titan Class

function AsyncShipGenerator:GetShipVolume(override)
    local _MethodName = GetName("Get Ship Volume")

    if not override then
        Chance = override
    end

    -- Chance Number Must be Matched with AsyncShipGenerator.VolumeShips 
    -- Leave out the last item in AsyncShipGenerator.VolumeShips because
    -- it will act as the upper limit for plan volume
    local Chance = {}
    Chance[1]   = 0
    Chance[2]   = 0
    Chance[3]   = 0
    Chance[4]   = 40    -- 40 Ships
    Chance[5]   = 80    -- 40 Ships
    Chance[6]   = 150   -- 70 Ships
    Chance[7]   = 300   -- 150 Ships
    Chance[8]   = 450   -- 110 Ships
    Chance[9]   = 560   -- 100 Ships
    Chance[10]  = 660   -- 100 Ships
    Chance[11]  = 740   -- 80 Ships
    Chance[12]  = 800   -- 60 Ships
    Chance[13]  = 870   -- 70 Ships
    Chance[14]  = 940   -- 70 Ships
    Chance[15]  = 999   -- 59 Ships
    Chance[16]  = 1000  -- 1 Ship / 1000 Ships

    local Roll = Rand.Int(1, 1000)
    local Volume = 1

    Log.Debug(_MethodName, "Rolled Dice: " .. tostring(Roll), _Debug)

    if Roll < Chance[1] then            
        Volume = Rand.Int(AsyncShipGenerator.VolumeShips[1], AsyncShipGenerator.VolumeShips[2] -1)
        Log.Debug(_MethodName, "Slot 1 Volume: " .. tostring(Volume), _Debug)
    elseif Roll < Chance[2] then        
        Volume = Rand.Int(AsyncShipGenerator.VolumeShips[2], AsyncShipGenerator.VolumeShips[3] -1)
        Log.Debug(_MethodName, "Slot 1 Volume: " .. tostring(Volume), _Debug)
    elseif Roll < Chance[3] then       
        Volume = Rand.Int(AsyncShipGenerator.VolumeShips[3], AsyncShipGenerator.VolumeShips[4] -1)
        Log.Debug(_MethodName, "Slot 2 Volume: " .. tostring(Volume), _Debug)
    elseif Roll < Chance[4] then        
        Volume = Rand.Int(AsyncShipGenerator.VolumeShips[4], AsyncShipGenerator.VolumeShips[5] -1)
        Log.Debug(_MethodName, "Slot 3 Volume: " .. tostring(Volume), _Debug)
    elseif Roll < Chance[5] then        
        Volume = Rand.Int(AsyncShipGenerator.VolumeShips[5], AsyncShipGenerator.VolumeShips[6] -1)
        Log.Debug(_MethodName, "Slot 4 Volume: " .. tostring(Volume), _Debug)
    elseif Roll < Chance[6] then        
        Volume = Rand.Int(AsyncShipGenerator.VolumeShips[6], AsyncShipGenerator.VolumeShips[7] -1)        
        Log.Debug(_MethodName, "Slot 5 Volume: " .. tostring(Volume), _Debug)
    elseif Roll < Chance[7] then        
        Volume = Rand.Int(AsyncShipGenerator.VolumeShips[7], AsyncShipGenerator.VolumeShips[8] -1)
        Log.Debug(_MethodName, "Slot 6 Volume: " .. tostring(Volume), _Debug)
    elseif Roll < Chance[8] then        
        Volume = Rand.Int(AsyncShipGenerator.VolumeShips[8], AsyncShipGenerator.VolumeShips[9] -1)
        Log.Debug(_MethodName, "Slot 7 Volume: " .. tostring(Volume), _Debug)
    elseif Roll < Chance[9] then        
        Volume = Rand.Int(AsyncShipGenerator.VolumeShips[9], AsyncShipGenerator.VolumeShips[10] -1)
        Log.Debug(_MethodName, "Slot 8 Volume: " .. tostring(Volume), _Debug)
    elseif Roll < Chance[10] then       
        Volume = Rand.Int(AsyncShipGenerator.VolumeShips[10], AsyncShipGenerator.VolumeShips[11] -1)
        Log.Debug(_MethodName, "Slot 9 Volume: " .. tostring(Volume), _Debug)
    elseif Roll < Chance[11] then       
        Volume = Rand.Int(AsyncShipGenerator.VolumeShips[11], AsyncShipGenerator.VolumeShips[12] -1)
        Log.Debug(_MethodName, "Slot 10 Volume: " .. tostring(Volume), _Debug)
    elseif Roll < Chance[12] then       
        Volume = Rand.Int(AsyncShipGenerator.VolumeShips[12], AsyncShipGenerator.VolumeShips[13] -1)
        Log.Debug(_MethodName, "Slot 12 Volume: " .. tostring(Volume), _Debug)
    elseif Roll < Chance[13] then       
        Volume = Rand.Int(AsyncShipGenerator.VolumeShips[13], AsyncShipGenerator.VolumeShips[14] -1)
        Log.Debug(_MethodName, "Slot 13 Volume: " .. tostring(Volume), _Debug)
    elseif Roll < Chance[14] then       
        Volume = Rand.Int(AsyncShipGenerator.VolumeShips[14], AsyncShipGenerator.VolumeShips[15] -1)
        Log.Debug(_MethodName, "Slot 14 Volume: " .. tostring(Volume), _Debug)
    elseif Roll < Chance[15] then       
        Volume = Rand.Int(AsyncShipGenerator.VolumeShips[15], AsyncShipGenerator.VolumeShips[16] -1)
        Log.Debug(_MethodName, "Slot 15 Volume: " .. tostring(Volume), _Debug)
    elseif Roll <= Chance[16] then       
        Volume = Rand.Int(AsyncShipGenerator.VolumeShips[16], AsyncShipGenerator.VolumeShips[17])   
        Log.Debug(_MethodName, "Slot 15 ++ Volume: " .. tostring(Volume), _Debug) 
    else                                
        Volume = Rand.Int(AsyncShipGenerator.VolumeShips[1], AsyncShipGenerator.VolumeShips[15])
        Log.Debug(_MethodName, "Something Went Wrong, Selecting Random Slot Volume: " .. tostring(Volume), _Debug)
    end

    Log.Debug(_MethodName, "Selected Volume: " .. tostring(Volume), _Debug)

    return Volume / 2

end

-- New function
function AsyncShipGenerator:createCustomMilitaryShip(faction, position, volume)
    position = position or Matrix()
    volume = volume or self:GetShipVolume(Chance)
    
    PlanGenerator.makeAsyncShipPlan("_ship_generator_on_military_plan_generated", {self.generatorId, position, faction.index}, faction, volume)
    self:shipCreationStarted()
end

function AsyncShipGenerator:createShipByClass(shipClass, faction, position, volume, params)
    local _MethodName = GetName("createShipByClass")
    Log.Debug(_MethodName, "Creating Ship Of Class: " .. tostring(shipClass), _Debug)

    -- Grab the set if functions dynamically from our list
    local shipClass = AsyncShipGenerator.ShipClasses[shipClass] or nil
    
    --If that ship class was not in the list then create a default ship
    if shipClass == nil then 
        Log.Debug(_MethodName, "Ship Class Not Found: " .. tostring(shipClass), _Debug)
        AsyncShipGenerator:createShip(faction, position, volume)
        return
    end

    Log.Debug(_MethodName, "Ship Class Found: " .. tostring(shipClass), _Debug)
    --If we do have our ShipClass functions then use it
    shipClass.start(self.generatorId,faction,position,volume, params or {})

    self:shipCreationStarted()
end

local function onShipByClassPlanFinished(plan, generatorId, position, factionIndex, shipClass, params)
    local self = generators[generatorId] or {}

    local _MethodName = GetName("onShipByClassPlanFinished")
    Log.Debug(_MethodName, "Plan Finished For Ship Of Class: " .. tostring(shipClass), _Debug)
    
    -- If we are in the callback and then the ship class must exist -- or else we wouldn't have gotten here
    local shipClass = AsyncShipGenerator.ShipClasses[shipClass]

    if self.scaling then
        plan:scale(vec3(self.scaling))
    end

    local faction = Faction(self.factionIndex or factionIndex)
    local ship = Sector():createShip(faction, "", plan, position, self.arrivalType)

    shipClass.addTurretsAndEquipment(ship, params)
    shipClass.addScripts(ship, params)
    shipClass.setValues(ship, params)
    shipClass.finalize(ship, params)

    Log.Debug(_MethodName, "Ship Of Class: " .. tostring(shipClass) .. "Completed", _Debug)

    onShipCreated(generatorId, ship)
end

----------------------------------------------------------------------------------------------------------
------------------------------------- Modified Vanilla Funcitons -----------------------------------------
----------------------------------------------------------------------------------------------------------

-- Saved Vanilla Function
AsyncShipGenerator.old_createShip = AsyncShipGenerator.createShip 
function AsyncShipGenerator:createShip(_Faction, _Position, _Volume, _AutoOverride)
    position = position or Matrix()
    _Volume = _Volume or self:GetShipVolume()

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

    local volume = self:GetShipVolume(Chance)

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

    local volume = self:GetShipVolume(Chance)
    
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
    volume = self:GetShipVolume(Chance) -- Ignores volume arg

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
    volume = self:GetShipVolume(Chance) -- Ignores volume arg

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
    volume = self:GetShipVolume(Chance) -- Ignores volume arg

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
    volume = self:GetShipVolume(Chance) -- Ignores volume arg

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
    volume = self:GetShipVolume(Chance) -- Ignores volume arg

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
    volume = self:GetShipVolume(Chance) -- Ignores volume arg

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

    volume = self:GetShipVolume(Chance) -- Ignores volume arg

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

    local volume = self:GetShipVolume(Chance)

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

    _Volume = _Volume or self:GetShipVolume()

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

    _Volume = _Volume or self:GetShipVolume()

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
]]

local old_new = new
local function new(namespace, onGeneratedCallback)
    local rtn = old_new(namespace, onGeneratedCallback)

    ShipClass_Default:init(AsyncShipGenerator.ShipClasses)
    ShipClass_Carrier:init(AsyncShipGenerator.ShipClasses)
    
    if namespace then
        namespace._ship_generator_on_ship_by_class_plan_generated = onShipByClassPlanFinished
    else
        _ship_generator_on_ship_by_class_plan_generated = onShipByClassPlanFinished
    end

    return rtn
end
--[[


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