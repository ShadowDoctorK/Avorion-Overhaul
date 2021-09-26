package.path = package.path .. ";data/scripts/lib/?.lua"
package.path = package.path .. ";data/scripts/?.lua"

include ("galaxy")
include ("stringutility")
include("randomext")
local PlanGenerator = include ("plangenerator")
local ShipUtility = include ("shiputility")
local PirateGenerator = include("pirategenerator")
local Rand = include("SDKUtilityRandom")
local Volume = include("SDKGlobalDesigns - Volumes")

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
    local vl = Rand.Int(Volume.Ships[5], Volume.Ships[6]) * volumeFactor
    --Multiply Pirates by three till we make a clean generator. I reduce them to 1/3 the volume in the plan generator.
    vl = vl * 3

    -- Temp solution for pirate generation till a full overhaul is done
    if title == "Pirate Mothership" then 

        PlanGenerator.makeAsyncCarrierPlan("_pirate_generator_on_plan_generated", 
        {self.generatorId, position, faction.index, title}, 
        faction, vl, 
        "Carrier",
        nil,    -- Material: Use Fallback
        false,  -- Sync: False means Async
        PlanGenerator.GetOverride(nil, vl))  -- Override Volume

    else

        PlanGenerator.makeAsyncShipPlan("_pirate_generator_on_plan_generated", 
        {self.generatorId, position, faction.index, title}, 
        faction, vl, 
        title,
        nil,    -- Material: Use Fallback
        false,  -- Sync: False means Async
        PlanGenerator.GetOverride(nil, vl))  -- Override Volume

    end    
end