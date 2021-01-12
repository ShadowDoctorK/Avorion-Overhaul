package.path = package.path .. ";data/scripts/lib/?.lua"
package.path = package.path .. ";data/scripts/?.lua"

include ("galaxy")
include ("utility")
include ("defaultscripts")
include ("goods")
local PlanGenerator = include ("plangenerator")
local ShipUtility = include ("shiputility")
local SectorFighterGenerator = include("sectorfightergenerator")

local ShipClass_Default = {}
local ClassName = "Default" --this should match the line above

-- How I want it to work:
-- Setup these event functions for each Ship Class
--  1. start()
--  2. addTurretsAndEquipment()
--  3. addScripts()
--  4. setValues()
--  5. finalize()

-- The params argument can be used to pass key/values through to the various functions.
-- For the default ship, no params are needed. However other ship types may expect params so check each ship class to see what it needs

local function start(generatorId, faction, position, volume, params)
    position = position or Matrix()
    volume = volume or Balancing_GetSectorShipVolume(Sector():getCoordinates()) * Balancing_GetShipVolumeDeviation()
    
    -- Keep the function name the same -- Defined in asynshipgenerator.lua
    PlanGenerator.makeAsyncShipPlan("_ship_generator_on_ship_by_class_plan_generated", {generatorId, position, faction.index, ClassName, params}, faction, volume)
end

local function addTurretsAndEquipment(ship, params)
    local faction = Faction(ship.factionIndex)
    local turrets = Balancing_GetEnemySectorTurrets(Sector():getCoordinates()) * 2 + 3
    turrets = turrets + turrets * math.max(0, faction:getTrait("careful") or 0) * 0.5
    ShipUtility.addArmedTurretsToCraft(ship, turrets)
end

local function addScripts(ship, params)
    AddDefaultShipScripts(ship)
end

local function setValues(ship, params)

end

local function finalize(ship, params)
    ship.crew = ship.minCrew
    ship.shieldDurability = ship.shieldMaxDurability

    SetBoardingDefenseLevel(ship)
end


-- Add the Ship Class to a list on the asynshipgenerator  script so the classes can be called dynamically
function ShipClass_Default:init(ShipClasses)
    ShipClasses[ClassName] = {
        start = start,
        addTurretsAndEquipment = addTurretsAndEquipment,
        addScripts = addScripts,
        setValues = setValues,
        finalize = finalize
    }
end

return ShipClass_Default