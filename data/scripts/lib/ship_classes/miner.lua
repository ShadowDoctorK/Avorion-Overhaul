package.path = package.path .. ";data/scripts/lib/?.lua"
package.path = package.path .. ";data/scripts/?.lua"

include ("galaxy")
include ("utility")
include ("defaultscripts")
include ("goods")
local PlanGenerator = include ("plangenerator")
local ShipUtility = include ("shiputility")
local SectorFighterGenerator = include("sectorfightergenerator")

local ShipClass_Miner = {}
local ClassName = "Miner" --this should match the line above

-- See ship_classes/default.lua for more details

--Expected Params
--[[

    {
        volumeAmp = int
    }

]] 

local function start(generatorId, faction, position, volume, params)
    position = position or Matrix()
    volume = volume or Balancing_GetSectorShipVolume(Sector():getCoordinates()) * (params.volumeAmp or 1)
    
    -- Keep the function name the same -- Defined in asynshipgenerator.lua
    PlanGenerator.makeAsyncShipPlan("_ship_generator_on_ship_by_class_plan_generated", {generatorId, position, faction.index, ClassName, params}, faction, volume)
end

local function addTurretsAndEquipment(ship, params)
    local turrets = Balancing_GetEnemySectorTurrets(Sector():getCoordinates())

    ShipUtility.addUnarmedTurretsToCraft(ship, turrets)
end

local function addScripts(ship, params)
    AddDefaultShipScripts(ship)
    ship:addScript("civilship.lua")
    ship:addScript("dialogs/storyhints.lua")
    ship:addScript("icon.lua", "data/textures/icons/pixel/civil-ship.png")
end

local function setValues(ship, params)
    ship:setValue("is_civil", true)
    ship:setValue("is_miner", true)
    ship:setValue("npc_chatter", true)
end

local function finalize(ship, params)
    ship.crew = ship.minCrew
    ship.shieldDurability = ship.shieldMaxDurability
    
    ship.title = ShipUtility.getMinerNameByVolume(ship.volume)
    SetBoardingDefenseLevel(ship)
end


-- Add the Ship Class to a list on the asynshipgenerator  script so the classes can be called dynamically
function ShipClass_Miner:init(ShipClasses)
    ShipClasses[ClassName] = {
        start = start,
        addTurretsAndEquipment = addTurretsAndEquipment,
        addScripts = addScripts,
        setValues = setValues,
        finalize = finalize
    }
end

return ShipClass_Miner