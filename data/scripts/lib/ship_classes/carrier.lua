package.path = package.path .. ";data/scripts/lib/?.lua"
package.path = package.path .. ";data/scripts/?.lua"

include ("galaxy")
include ("utility")
include ("defaultscripts")
include ("goods")
local PlanGenerator = include ("plangenerator")
local ShipUtility = include ("shiputility")
local SectorFighterGenerator = include("sectorfightergenerator")

local ShipClass_Carrier = {}
local ClassName = "Carrier" --this should match the line above

-- See ship_classes/default.lua for more details

--Expected Params
--[[

    {
        fighters = int
    }

]] 

local function start(generatorId, faction, position, volume, params)
    position = position or Matrix()
    volume = volume or Balancing_GetSectorShipVolume(Sector():getCoordinates()) * 15.0
    
    -- Keep the function name the same -- Defined in asynshipgenerator.lua
    PlanGenerator.makeAsyncCarrierPlan("_ship_generator_on_ship_by_class_plan_generated", {generatorId, position, faction.index, ClassName, params}, faction, volume)
end

local function addTurretsAndEquipment(ship, params)
    fighters = params.fighters or 10
    ShipUtility.addCarrierEquipment(ship, fighters)
end

local function addScripts(ship, params)
    AddDefaultShipScripts(ship)
    ship:addScript("ai/patrol.lua")
end

local function setValues(ship, params)

end

local function finalize(ship, params)
    ship.crew = ship.minCrew
    ship.shieldDurability = ship.shieldMaxDurability

    SetBoardingDefenseLevel(ship)
end


-- Add the Ship Class to a list on the asynshipgenerator  script so the classes can be called dynamically
function ShipClass_Carrier:init(ShipClasses)
    ShipClasses[ClassName] = {
        start = start,
        addTurretsAndEquipment = addTurretsAndEquipment,
        addScripts = addScripts,
        setValues = setValues,
        finalize = finalize
    }
end

return ShipClass_Carrier