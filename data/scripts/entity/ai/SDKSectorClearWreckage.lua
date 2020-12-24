--[[
    To Do List:
    1. Add a function to the SDLUtilityShipAI.lua that will generate and check a clear path to a
       target point and return the waypoints.
    2. Add stuck detection system so we can readjust the route by chaning waypoints if we need to.
]]

package.path = package.path .. ";data/scripts/lib/?.lua"
include ("stringutility")
include ("randomext")

local Logging = include("SDKDebugLogging")
local AI = include("SDKUtilityEntityAI")

SDKSectorClearWreckage = {}
local self = SDKSectorClearWreckage

self.Log = Logging

self.Data = {}
self.Data.TargetID = -1
self.Data.TargetPos = { x = 0, y = 0, z = 0 }
self.Data.WorkingRadius = 0
self.Data.Stage = 0
self.Data.TetheredWrecks = {}

self.TargetChanged = true
self.DangerRange = 1000 -- 10km
self.WreckeRange = 500  -- 5km
self._Jump = false

-- Shared Server/Client Items
function SDKSectorClearWreckage.initialize(_TargetID, _Range)

    self.Data.TargetID = _TargetID
    self.WreckeRange = _Range or 500
    self.SetApproach()

    if onServer() then
        AI.Load(Entity())
        AI.Aggressive(false)        
    end

    if onClient() then

    end

end

-- Server Side Only Items
if onServer() then

    function SDKSectorClearWreckage.getUpdateInterval()
        return math.random() + 5.0 -- Prevents stacking AI Orders during the load of the server.
    end  

    -- this function will be executed every frame on the server only
    function SDKSectorClearWreckage.updateServer(_TimeStep)
        
        self.CheckDangerous()

        -- Check if we should jump
        if self._Jump then self.Jump() end

        if self.Data.Stage < 2 then     self.UpdateFlying()
        elseif self.Data.Stage = 2 then self.UpdateTether() end

    end

    function SDKSectorClearWreckage.UpdateFlying()

        -- Add Stuck Detection & Actions to Fix Here
        
        self.CheckTarget() 

        -- In Range of Wreck
        if AI.DistanceTo(Entity().translationf, self.Data.TargetPos) < self.WreckeRange then
            self.Data.Stage = 2

        -- If Target Changed Update Fly Command
        elseif self.TargetChanged or self.Data.Stage == 0 then
            AI.Fly(self.Data.TargetPos, self.Data.WorkingRadius)
            self.Data.Stage = 1
        end

    end

    function SDKSectorClearWreckage.UpdateTether()
        
    end

    function SDKSectorClearWreckage.Jump()

    end

end -- End onServer()

-- Client Side Only Items
if onClient() then

    function SDKSectorClearWreckage.getUpdateInterval()
        return math.random() + 1.0
    end

end

-- Support Function
function SDKSectorClearWreckage.SetApproach()
    local Target = Entity(self.Data.TargetID)
    local Ship = Entity()

    -- Leave if the target is no longer valid.
    if not Target then self._Jump = true return end

    self.Data.TargetPos = Target.translationf
    self.Data.WorkingRadius = Target::getBoundingSphere().radius + Ship:getBoundingSphere().radius
end

function SDKSectorClearWreckage.CheckDangerous()

    for _, _Ship in pairs({Sector():getEntitiesByType(EntityType.Ship)}) do

        local _Faction = Faction(_Ship.factionIndex)

        if _Faction then

            self.Log.Debug(_Method, "Faction: " .. tostring(_Faction.name))

            -- Check for Pirates & Xsotan
            if string.match(_Faction.name, "Pirate") or string.match(_Faction.name, "Xsotan") 
               and AI.DistanceTo(_Ship.translationf) < self.DangerRange then

                -- Check for the string description for default factions. Exclude these fake Xostan triggers.
                if not string.match(_Faction.name, "This refers to factions, such as") then
                    self._Jump = true
                end  

            end
            
            -- Check for Ships At War With Faction
            if _Faction:getRelationStatus(_Ship.factionIndex) == RelationStatus.War 
               and AI.DistanceTo(_Ship.translationf) < self.DangerRange then
                self._Jump = true
            end  
        end
    end

end

function SDKSectorClearWreckage.CheckTarget()

    local Target = Entity(self.Data.TargetID)

    if Target then -- Check the target hasn't moved
        
        if AI.PositionChanged(Target.translationf, self.Data.TargetPos) then
            self.Data.TargetPos = Target.translationf
            self.TargetChanged = true
        end

    else -- Find a new wreck within the range of the last one or leave.

        for _, _Wreck in pairs({Sector():getEntitiesByType(EntityType.Wreckage)}) do
            if AI.DistanceTo(_Wreck.translationf, self.Data.TargetPos) < self.WreckeRange then
                self.Data.TargetPos = _Wreck.translationf
                self.TargetChanged = true
                return
            end
        end

        -- Didn't find a wreck so leave.
        self._Jump = true

    end
   
end