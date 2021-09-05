package.path = package.path .. ";data/scripts/lib/?.lua"

local Faction = include("SDKUtilityFaction")
local Deisgns = include("SDKGlobalDesigns")
local Plan = include("SDKUtilityBlockPlan")
local Posit = include("SDKUtilityPosition")
local AI = include("SDKUtilityEntityAI")
local Logging = include("SDKDebugLogging")
Logging.Debugging = 1
Logging.ModName = "SDK Background Sector Manager"

SDKBackgroundSectorManager = {} 
local self = SDKBackgroundSectorManager

self.Log = Logging

-- Sector Settings
self._Initialized = false
self._CoreRadius = 7500     -- 75km
self._MaxRadius = 15000     -- 150km

self._WreckageLimit = 30    -- Default Wreckage Limit (No Scrapyard)
self._WreckageLife = 180    -- 3 Mins, Then Tugs Clear Populated Space Randomly

self._NextBadcheck = 15     -- 15 Sec, The Interval the Sector will check for Pirates/Xsotan
self._NextClean = 60        -- 1 Min, The Interval the Sector Will Delete Small Particle Wreckage.
self._NextControl = 0       -- 5 Min, The Interval the Controlling Faction will be Checked.

-- Sector Status Tracking
self._MainFaction = Faction
self._Populated = false
self._NumStations = 0
self._Pirates = false
self._Xsotan = false
self._DeployedScrapTugs = {}

-- Wreckage Status Tracking
self._WrecksForPickup = {}

function SDKBackgroundSectorManager.initialize() local _Method = "Initialize"
    print("Init Background Manager...")
    self.Log.Debug(_MethodName, tostring(Sector().name) .. ": Sector Manager Initialized")
    self._MainFaction = Faction.New()
    self._MainFaction.Controlling()
    self._Initialized = true
end

function SDKBackgroundSectorManager.getUpdateInterval()
    print("Update Interval...")
    return 1
end


function SDKBackgroundSectorManager.updateServer(_TimeStep) local _Method = "Update"
    
    print("Time Step: " .. tostring(_TimeStep))

    -- Both Client/Server Updates
    self.Despawn(_TimeStep)         -- (1 Sec)  Purpose: Controls Despawn of Entities Marked with "SDKLifeTime" Value
    self.CheckController(_TimeStep) -- (5 Min)  Purpose: Updates the Controlling Faction for the Scripts Logic and Checks for Populated Sectors
    self.CheckBaddies(_TimeStep)    -- (15 Sec) Purpose: Updates the Pirate and Xostan values for this Scripts Logic
    self.WreckageCleanUp(_TimeStep) -- (1 Min)  Purpose: Sector Performace / Cleanup

    --[[ Have Local Faction Do Its Peacetime Jobs. In the event the Local faction is the 
    .    Player, Independent Civilians will do the tasks. Some events will be skipped or adjusted
    .    based on the Player being responsible for their own sectors.]]

    if not self.IsDangerous() then

        local MainType = self._MainFaction.Type()

        -- Detect and Transport Wreckages. Linked to WreckageCleanUp() Settings.
        local Wreckages = self.Wrecks() if Wreckages then

            -- AI Controlling Faction
            if MainType == 2 then
                -- Set Tug Faction to Main Faction
                local TugFaction = Faction.New() TugFaction.Load(self._MainFaction.Get())

                local Tug = self.Salvager(TugFaction)   -- Create A Salvage Tug

                local Wrecks = AI.Entities(             
                    EntityType.Wreckage,                -- Get a list of Wrecks
                    Wreckages[1].translationf,          -- From the Target Wreck
                    500                                 -- Within 5km
                )

                -- Task the Tug with his job. Then record it.
                Tug:addScriptOnce("data/scripts/entity/ai/SDKSectorClearWreckage.lua", Wrecakges[1], 500)
                self._DeployedScrapTugs[#self._DeployedScrapTugs + 1] = self.DeployedTug(Tug.id, Wrecks)

            end
                
        end

    end

end

-- Detect Damaged Alliance/Faction Ship & Stations --> Send Repair Ships

-- Detect Wreckage In Populated Sectors --> Send Scrap Tugs In To Clear/Harvest It

-- Add Roving Sector Patrols To Lightly Guarded Sectors --> Scan for Smugglers, 
-- Clear out Strong Hostiles, etc... then move to next area

---------------------------------------------------------------------------------------
------------------------------- Support Functions -------------------------------------
---------------------------------------------------------------------------------------

-- Update these with custom value trackers once the Ship generator is cleaned up.
function SDKBackgroundSectorManager.CheckBaddies(_TimeStep)

    -- Timer Checks
    self._NextBadcheck = self._NextBadcheck - _TimeStep
    if self._NextBadcheck > 0 then return end

    for _, _Ship in pairs({Sector():getEntitiesByType(EntityType.Ship)}) do

        local _Faction = Faction(_Ship.factionIndex)

        -- Check Pirates
        if string.match(_Faction.name, "Pirate") then            
            if not string.match(_Faction.name, "This refers to factions, such as") then
                self._Pirates = true                
            end self._Pirates = false
        end
        
        -- Check Xsotan
        if string.match(_Faction.name, "Xsotan") then
            if not string.match(_Faction.name, "This refers to factions, such as") then
                self._Xsotan = true                
            end self._Xsotan = false
        end
        
    end 

    -- Reset Timer
    self._NextBadcheck = 60 -- Clean Up Sector every 60 seconds

end

function SDKBackgroundSectorManager.WreckageCleanUp(_TimeStep) local _Method = "Wreckage Clean Up"
            
    -- Timer Checks
    self._NextClean = self._NextClean - _TimeStep
    if self._NextClean > 0 then return end
    
    -- Clean up small particle wreckages
    local _Sector = Sector() for k, v in pairs({_Sector:getEntitiesByType(EntityType.Wreckage)}) do
        if v.volume <= 100 then _Sector:deleteEntity(v) end
    end 

    -- Reset Timer
    self._NextClean = 60 -- Clean Up Sector every 60 seconds

end

function SDKBackgroundSectorManager.Despawn(_TimeStep) local _Method = "Despawn"
    for _, _Entity in pairs({Sector():getEntitiesByScriptValue("SDKLifeTime")}) do

        local _Time = tonumber(_Entity:getValue("SDKLifeTime")) if _Time then

            -- Test Life Time / Delete Entity
            _Time = _Time - _TimeStep  if _Time <= 0 then 
                
                self.Log.Debug(_Method, "Despawn: " .. tostring(_Entity.type) .. " - " .. tostring(_Entity.name))  
                Sector():deleteEntityJumped(_Entity)
            
            else -- Update LifeTime
                _Entity:setValue("SDKLifeTime", _Time)
            end

        end

    end 
end

function SDKBackgroundSectorManager.CheckController(_TimeStep) local _Method = "Check Controller"

    -- Timer Checks
    self._NextControl = self._NextControl - _TimeStep
    if self._NextControl > 0 then return end

    self._Populated = false                         -- Reset Populated Variable
    self._NumStations = 0
    local Temp = self._MainFaction.Get()            -- Store Old Faction
    self._MainFaction.Controlling()                 -- Test The Controlling Faction
    if self._MainFaction.Type() ~= -1 then          -- See if a Faction Exists
        
        if not self._MainFaction.IsSelf(Temp) then  -- Controlling Faction Changed
            local name = "None" if Temp.name then name = Temp.name end
            local x, y = Sector():getCoordinates()
            self.Log.Debug(_Method, "(" .. tostring(x) .. ", " .. tostring(y) .. ") Controlling Faction Changed From " .. tostring(name) .. " To " .. tostring(self._MainFaction.Name()))

            -- Add Broadcast to Controlling Faction Space and Losing Faction Space

        end

        -- Check if Sector is Populated.
        for _, _Station in pairs({Sector():getEntitiesByType(EntityType.Station)}) do
            if not _Station.dockable then 
                self._Populated = true 
                self._NumStations = self._NumStations + 1
            end
        end 

    end
    
    -- Reset Timer
    self._NextControl = 300 -- 5 Min

end

function SDKBackgroundSectorManager.HasEnemies(_Faction)
    _Faction = _Faction or self.Locals()

    -- Check for Ships At War With Faction
    for _, _Ship in pairs({Sector():getEntitiesByType(EntityType.Ship)}) do
        if _Faction:getRelationStatus(_Ship.factionIndex) == RelationStatus.War then
            return true
        end  
    end 

end

function SDKBackgroundSectorManager.IsDangerous(_Faction)
    _Faction = _Faction or self.Locals()

    if self._Pirates then return true end
    if self._Xsotan then return true end
    if self.HasEnemies(_Faction) then return true end
    
    return false

end

function SDKBackgroundSectorManager.Wrecks() local _Method = "Wrecks"

    -- Processs Wrecks After Clean Up's Only.
    if self._NextClean == 60 then return nil end

    local _Sector = Sector() 
    local _Wrecks = {}
    for k, v in pairs({_Sector:getEntitiesByType(EntityType.Wreckage)}) do
        if v.volume > 100 then table.insert(_Wrecks, v) end
    end

    -- Check if we have deployed tugs...
    if #_Wrecks ~= 0 and #self._DeployedScrapTugs ~= 0 then

        -- Check if tugs are still alive and remove their targets from the list.
        for k, v in pairs(self._DeployedScrapTugs) do
            
            -- Remove Wrecks From List...
            if Entity(v.Index) then

                local Temp = {} local Targets = {}

                -- Record Wreck IDs
                for i = 1, #v.Wrecks do Targets[v.Wrecks[i]] = 1 end
                
                -- Remove Targeted Wrecks
                for k2, v2 in pairs(_Wrecks) do
                    if not Targets[v2.index] then table.insert(Temp, v2) end
                end

                _Wrecks = Temp

            -- Remove Tug From List...
            else
                self._DeployedScrapTugs[k] = nil
            end
            
        end

    end

    return _Wrecks

end

--[[
    Creates a Info Container for a List of Wreck IDs a Deployed Tug is targeting.
]]
function SDKBackgroundSectorManager.DeployedTug(TugID, Wrecks)
    local Temp = {}
    Temp.Index = TugID
    Temp.Wrecks = Wrecks
    return Temp
end

---------------------------------------------------------------------------------------
--------------------------------- Ship Functions --------------------------------------
---------------------------------------------------------------------------------------

-- Note: This will be removed when this class of ship is added to the PlanGenerator


-- ADD THE INCLUDE STATEMENTS FOR THIS FUNCTION

function SDKBackgroundSectorManager.Salvager(_Faction, _Position)
    
    local _Table = Designs.Get("MediumSalvagers")
    local _TargetDesign = _Table[Rand.Int(1, #_Table)]
    
    self.Log.Debug(_Method, "Total Designs: " .. tostring(#_Table))
    self.Log.Debug(_Method, "Target Design: " .. tostring(_TargetDesign))
    
    if Plan.Load(_TargetDesign) then
        Plan.Material()
    else Log.Warning(_Method, "No Salvager Plan Was Loaded, Returning nil...") return end        
    
    _Position = _Position or Posit.PositionInSector(nil, 100, Plan.Radius()) or Matrix()

    local _Ship = Sector():createShip(_Faction, "", Plan.Get(), _Position, EntityArrivalType.Jump)

    _Ship.shieldDurability = _Ship.shieldMaxDurability
    _Ship.crew = _Ship.idealCrew

    AddDefaultShipScripts(_Ship)
    
    local _Turrets = Balancing_GetEnemySectorTurrets(Sector():getCoordinates())
    ShipUtility.addArmedTurretsToCraft(_Ship, _Turrets)

    _Ship.crew = _Ship.idealCrew
    _Ship.title = "Scrapyard Tug"
       
    _Ship:addScriptOnce("ai/patrol.lua")

    _Ship:addScriptOnce("civilship.lua")
    _Ship:setValue("is_civil", 1)
    _Ship:setValue("npc_chatter", true)
    _Ship:addScriptOnce("icon.lua", "data/textures/icons/pixel/civil-ship.png")

    return _Ship
end