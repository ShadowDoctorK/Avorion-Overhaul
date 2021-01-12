package.path = package.path .. ";data/scripts/lib/?.lua"
package.path = package.path .. ";data/scripts/?.lua"

include ("galaxy")
include ("utility")
include ("defaultscripts")
include ("goods")
include("randomext")
local PlanGenerator = include ("plangenerator")
local FighterGenerator = include ("fightergenerator")
local ShipUtility = include ("shiputility")

local Log = include("SDKDebugLogging")

local generators = {}
local AsyncFleetGenerator = {}
AsyncFleetGenerator.__index = AsyncFleetGenerator

local _ModName = "Async Fleet Generator"

-- Fucntion to build Methodname
function GetName(n)
    return _ModName .. " - " .. n
end

local _Debug = 0

----------------------------------------------------------------------------------------------------------
----------------------------------------- WARNING - PLEASE READ ------------------------------------------
----------------------------------------------------------------------------------------------------------
--[[
    This Script Is Using Parts of the AsyncShipGenerator. Which means if you include both this script and that one, issues will arise

    Really I wanted to see if i could simplify the AsyncShipGenerator script and thus needed a new clean script to mess with.
]]




----------------------------------------------------------------------------------------------------------
----------------------------------------- Ship Builder Funcitons -----------------------------------------
----------------------------------------------------------------------------------------------------------
function AsyncFleetGenerator:Build() 
    for index, queueObject in pairs(self.shipQueue) do
        -- print("queueObject: " .. tostring(index))
        -- printTable(queueObject)
        self:createShipByClass(index,queueObject)
    end
end

function AsyncFleetGenerator:createShipByClass(index,queueObject)
    -- print("createShipByClass - GeneratorId: " .. tostring(queueObject.generatorId))
    
    local self = generators[queueObject.generatorId] or {}
    
    -- Grab the set if functions dynamically from our list
    local shipClass = self.shipClasses[queueObject.shipClass] or nil
    
    --If that ship class was not in the list then create a default ship
    if shipClass == nil then 
        return
    end

    local params = queueObject.params or {}
    params.index = index

    --If we do have our ShipClass functions then use it
    shipClass.start(queueObject.generatorId,queueObject.faction,queueObject.position, queueObject.volume, queueObject.params or {})
end

local function onShipByClassPlanFinished(plan, generatorId, position, factionIndex, shipClass, params)
    -- print("onShipByClassPlanFinished - GeneratorId: " .. tostring(generatorId))
    
    local self = generators[generatorId] or {}

    if self.scaling then
        plan:scale(vec3(self.scaling))
    end

    --Basically setting the plan to the queueObject will tell the update timer to build it
    queueObject = self.shipQueue[params.index]

    local shipClass = self.shipClasses[queueObject.shipClass]
    local ship = Sector():createShip(queueObject.faction, "", plan, position, self.arrivalType)

    queueObject.ship = ship

    shipClass.addTurretsAndEquipment(ship, queueObject.params)
    shipClass.addScripts(ship, queueObject.params)
    shipClass.setValues(ship, queueObject.params)
    shipClass.finalize(ship, queueObject.params)

    if queueObject.onCompleteCallback then
        queueObject.onCompleteCallback(ship)
    end

    queueObject.done = true

    --one of these will be the last one, so if it is, send the final callback
    local allDone = true
    for index, check in pairs(self.shipQueue) do
        if check.done == false then
            allDone = false
        end
    end


    if allDone and self.callback then
        local validGenerated = {}
        for _, entity in pairs(self.shipQueue) do
            if valid(entity.ship) then
                table.insert(validGenerated, entity.ship)
            end
        end
        self.callback(validGenerated)
        self.shipQueue = {}
    end

end

----------------------------------------------------------------------------------------------------------
----------------------------------------- Fleet Setup Funcitons ------------------------------------------
----------------------------------------------------------------------------------------------------------

--Adds a set number of ships, the classes are randomly selected form the loaded ship classes
--I don't exaclty know how the params will work for this, could get messy, but i'll leave this here for ease of testing later
function AsyncFleetGenerator:queueRandomShips(count, faction, position, volume, params, onCompleteCallback)    
    local countShipClases = getTableSize(self.shipClasses)

    for i = 1, count do
        local class = getElementKeyAtPosition(self.shipClasses, math.random(1,countShipClases))
        self:queueShip(class, faction, position, volume, params, onCompleteCallback)
    end
end


function AsyncFleetGenerator:queueShip(shipClass, faction, position, volume, params, onCompleteCallback)
    local queueObject = {
        generatorId = self.generatorId,
        shipClass = shipClass,
        faction = faction,
        position = position,
        volume = volume,
        params = params,
        onCompleteCallback = onCompleteCallback,
        done = false
    }

    table.insert(self.shipQueue, queueObject)
end


----------------------------------------------------------------------------------------------------------
----------------------------------------- Helper Funcitons -----------------------------------------------
----------------------------------------------------------------------------------------------------------

function getTableSize(t)
    local count = 0
    for _, __ in pairs(t) do
        count = count + 1
    end
    return count
end

function getElementKeyAtPosition(t,i)
    if i > getTableSize(t) or i < 0 then
        return nil
    end

    local count = 0
    for _, __ in pairs(t) do
        count = count + 1
        if count == i then
            return _
        end
    end
    
    return nil
end


----------------------------------------------------------------------------------------------------------
----------------------------------------- Init Funciton --------------------------------------------------
----------------------------------------------------------------------------------------------------------

--When instantiating this script,  pass in a list of ship classes that will be loaded dynamically -- ship classes must be in the lib/ship_classes folder
-- example: local generator = AsyncFleetGenerator(namespace, {"Carrier","Disrupter"})
local function new(namespace, onGeneratedCallback, shipClasses)
    local instance = {}
    instance.generatorId = random():getInt()

    instance.shipClasses = {}
    instance.shipQueue = {}

    instance.callback = onGeneratedCallback

    instance.arrivalType = EntityArrivalType.Jump
    instance.scaling = 1.0
    instance.factionIndex = nil

    while generators[instance.generatorId] do
        instance.generatorId = random():getInt()
    end

    generators[instance.generatorId] = instance

    if namespace then
        assert(type(namespace) == "table")
    end

    for index, value in pairs(shipClasses) do
        local shipClass = include("ship_classes/" .. string.lower(value) ) or nil
        if shipClass then
            shipClass:init(instance.shipClasses)
        end
    end

    --make sure we have at least one ship class -- even if it's default
    if getTableSize(instance.shipClasses) == 0 then
        local ShipClass_Default = include("ship_classes/default")
        ShipClass_Default:init(instance.shipClasses)
    end

    -- print("AsyncFleetGenerator: New()")
    -- printTable(instance.shipClasses)
    
    if namespace then
        namespace._ship_generator_on_ship_by_class_plan_generated = onShipByClassPlanFinished
    else
        _ship_generator_on_ship_by_class_plan_generated = onShipByClassPlanFinished
    end

    return setmetatable(instance, AsyncFleetGenerator)
end

return setmetatable({new = new}, {__call = function(_, ...) return new(...) end})