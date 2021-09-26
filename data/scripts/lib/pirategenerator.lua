package.path = package.path .. ";data/scripts/lib/?.lua"
package.path = package.path .. ";data/scripts/?.lua"

include ("galaxy")
include ("stringutility")
include ("randomext")
local PlanGenerator = include ("plangenerator")
local ShipUtility = include ("shiputility")
local SectorTurretGenerator = include ("sectorturretgenerator")
local Rand = include("SDKUtilityRandom")

----------------------------------------------------------------------------------------------------------
------------------------------------- Modified Vanilla Funcitons -----------------------------------------
----------------------------------------------------------------------------------------------------------

-- Saved Vanilla Function
PirateGenerator.old_getScaling = PirateGenerator.getScaling
function PirateGenerator.getScaling()
    local scaling = 1 + (Sector().numPlayers/10)
    
    if scaling == 0 then scaling = 1 end
    return scaling
end

-- Saved Vanilla Function
PirateGenerator.old_create = PirateGenerator.create
function PirateGenerator.create(position, volumeFactor, title)
    
    local Volume = PlanGenerator.GetVolume()

    position = position or Matrix()
    local x, y = Sector():getCoordinates()
    PirateGenerator.pirateLevel = PirateGenerator.pirateLevel or Balancing_GetPirateLevel(x, y)

    local faction = Galaxy():getPirateFaction(PirateGenerator.pirateLevel)

    volume = Volume.Get(5, 6) * volumeFactor

    --Multiply Pirates by three till we make a clean generator. I reduce them to 1/3 the volume in the plan generator.
    volume = volume * 3

    local o = PlanGenerator.GetOverride("Military", volume, nil, title)

    local plan = PlanGenerator.Ship(faction, "Military", o)
    local ship = Sector():createShip(faction, "", plan, position)

    PirateGenerator.addPirateEquipment(ship, title)

    ship.crew = ship.idealCrew
    ship.shieldDurability = ship.shieldMaxDurability

    return ship
end