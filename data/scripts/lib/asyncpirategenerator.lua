package.path = package.path .. ";data/scripts/lib/?.lua"
package.path = package.path .. ";data/scripts/?.lua"

include ("galaxy")
include ("stringutility")
include("randomext")
local PlanGenerator = include ("plangenerator")
local ShipUtility = include ("shiputility")
local PirateGenerator = include("pirategenerator")
local Rand = include("SDKUtilityRandom")

-- Saved Vanilla Function
AsyncPirateGenerator.old_create = AsyncPirateGenerator.create 
function AsyncPirateGenerator:create(position, volumeFactor, title)

    if self.batching then
        self.expected = self.expected + 1
    end

    position = position or Matrix()
    local x, y = Sector():getCoordinates()
    self.pirateLevel = self.pirateLevel or Balancing_GetPirateLevel(x, y)

    local faction = Galaxy():getPirateFaction(self.pirateLevel)
    local volume = Rand.Int(PlanGenerator.VolumeShips[5], PlanGenerator.VolumeShips[6]) * volumeFactor
    --Multiply Pirates by three till we make a clean generator. I reduce them to 1/3 the volume in the plan generator.
    volume = volume * 3

    -- Temp solution for pirate generation till a full overhaul is done
    if title == "Pirate Mothership" then 

        PlanGenerator.makeAsyncCarrierPlan("_pirate_generator_on_plan_generated", 
        {self.generatorId, position, faction.index, title}, 
        faction, volume, 
        "Carrier",
        nil,    -- Material: Use Fallback
        false,  -- Sync: False means Async
        true)   -- Volume Override: true means used passed volume        

    else

        PlanGenerator.makeAsyncShipPlan("_pirate_generator_on_plan_generated", 
        {self.generatorId, position, faction.index, title}, 
        faction, volume, 
        title,
        nil,    -- Material: Use Fallback
        false,  -- Sync: False means Async
        true)   -- Volume Override: true means used passed volume        

    end    
end