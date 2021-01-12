package.path = package.path .. ";data/scripts/lib/?.lua"
package.path = package.path .. ";data/scripts/?.lua"

include ("galaxy")
include ("utility")
include ("defaultscripts")
include ("goods")
local PlanGenerator = include ("plangenerator")
local ShipUtility = include ("shiputility")
local SectorFighterGenerator = include("sectorfightergenerator")

local ShipClass_Defender = {}
local ClassName = "Defender" --this should match the line above

-- See ship_classes/default.lua for more details

--Expected Params
--[[

    {
        volumeAmp = int,
        damageAmp = int
    }

]] 

local function start(generatorId, faction, position, volume, params)
    position = position or Matrix()
    volume = volume or Balancing_GetSectorShipVolume(Sector():getCoordinates()) * (params.volumeAmp or 7.5)
    
    -- Keep the function name the same -- Defined in asynshipgenerator.lua
    PlanGenerator.makeAsyncShipPlan("_ship_generator_on_ship_by_class_plan_generated", {generatorId, position, faction.index, ClassName, params}, faction, volume)
end

local function addTurretsAndEquipment(ship, params)
    local faction = Faction(ship.factionIndex)
    local turrets = Balancing_GetEnemySectorTurrets(Sector():getCoordinates()) * 2 + 3
    turrets = turrets + turrets * math.max(0, faction:getTrait("careful") or 0) * 0.5

    ShipUtility.addArmedTurretsToCraft(ship, turrets)
    ship.damageMultiplier = ship.damageMultiplier * (params.damageAmp or 4)
end

local function addScripts(ship, params)
    AddDefaultShipScripts(ship)
    ship:addScriptOnce("ai/patrol.lua")
    ship:addScriptOnce("antismuggle.lua")
end

local function setValues(ship, params)
    ship:setValue("is_armed", true)
    ship:setValue("is_defender", true)
    ship:setValue("npc_chatter", true)
end

local function finalize(ship, params)
    ship:addMultiplyableBias(StatsBonuses.ArmedTurrets, 6)

    ship.crew = ship.minCrew
    ship.shieldDurability = ship.shieldMaxDurability
    
    ship.title = ShipUtility.getMilitaryNameByVolume(ship.volume)
    SetBoardingDefenseLevel(ship)
end


-- Add the Ship Class to a list on the asynshipgenerator  script so the classes can be called dynamically
function ShipClass_Defender:init(ShipClasses)
    ShipClasses[ClassName] = {
        start = start,
        addTurretsAndEquipment = addTurretsAndEquipment,
        addScripts = addScripts,
        setValues = setValues,
        finalize = finalize
    }
end

return ShipClass_Defender