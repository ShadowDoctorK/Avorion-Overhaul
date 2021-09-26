--[[
    Developer Notes:
    !! This script has to be Namespaced or it will not function !!

    - Spawn Civilian Gate Traffic
    - Spawn Savlagers to clear Core Wrecks

    - Detect Damaged Alliance/Faction Ship & Stations --> Send Repair Ships
    - Detect Wreckage In Populated Sectors --> Send Scrap Tugs In To Clear/Harvest It
    - Add Roving Sector Patrols To Lightly Guarded Sectors --> Scan for Smugglers, 
      Clear out Strong Hostiles, etc... then move to next area
]]

package.path = package.path .. ";data/scripts/lib/?.lua"

--local Deisgns = include("SDKGlobalDesigns")
--local Plan = include("SDKUtilityBlockPlan")
--local AI = include("SDKUtilityEntityAI")
--local Posit = include("SDKUtilityPosition")

local Rand = include("SDKUtilityRandom")
local Plan = include("SDKUtilityBlockPlan")
local Position = include("SDKUtilityPosition")
local Faction = include("SDKUtilityFaction")                    -- Control Loaded Faction
local Ships = include("SDKGlobalDesigns - Generator Ships")     -- Spawn Ships for Script Logic
local Volume = include("SDKGlobalDesigns - Volumes")
local Class = include("SDKGlobalDesigns - Classes")

local AsyncShips = include("SDKGlobalDesigns - Generator Ships Async")
local Call = include("SDKGlobalDesigns - Generator Ships Async Utility")

-- Logging Setup
    local Log = include("SDKDebugLogging")
    local _ModName = "Background Sector Manager"
    local _Debug = 0
-- End Logging

-- Don't remove or alter the following comment, it tells the game the namespace this script lives in. If you remove it, the script will break.
-- namespace SDKBackgroundSectorManager

SDKBackgroundSectorManager = {} 
local self = SDKBackgroundSectorManager

-- Sector Settings
self._Initialized = false
self._CoreRadius = 7500 / 2 -- 75km
self._MaxRadius = 15000 / 2 -- 150km
self._WreckageSize = 130    -- Volume Threshold for despawn/marking

-- Update Timers 
self._TStatus = 0           -- 5 Min Updates    
self._TWreckage = 0         -- 1 Min Updates
self._TControl = 0          -- 5 Min Updates
self._TThreats = 15         -- 15 Sec Updates

-- Sector Status Tracking
self._MainFaction = nil     -- Set on Initialize
self._Populated = false
self._NumStations = 0
self._Scrapyard = false     -- If true will modify Wreckage stuff.
self._RepairDock = false
self._Shipyard = false
self._Pirates = false
self._Xsotan = false
self._Hostile = false

-- Sector Limits
self._LimitWreckage = 30    -- Default for No Scrapyard

-- Scrapyard Tracking
self._TScrapyardUpdate = 5
self._TWreckSpawn = 0

-- Fucntion to build Method
function SDKBackgroundSectorManager.LogName(n)
    return _ModName .. " - " .. n
end

function SDKBackgroundSectorManager.initialize() local Method = self.LogName("Initialize")
    Log.Debug(Method, tostring(Sector().name) .. ": Sector Manager Initialized", _Debug)
    --print(tostring(Sector().name) .. ": Sector Manager Initialized")
end

function SDKBackgroundSectorManager.getUpdateInterval()    
    return 1
end

-- Both Client/Server Updates
function SDKBackgroundSectorManager.updateServer(Tick) local Method = self.LogName("Update")
    
    -- Load the Main Faction
    if not self._Initialized then 
        self._MainFaction = Faction.New()
        self._MainFaction.Controlling()
        self._Initialized = true
    end

    self.UpdateMainFaction(Tick)    -- (5 Min)  Purpose: Updates the Controlling Faction for the Scripts Logic
    self.UpdateThreats(Tick)        -- (15 Sec) Purpose: Updates the Pirate and Xostan values for this Scripts Logic
    self.UpdateLifeTime(Tick)       -- (1 Sec)  Purpose: Controls Despawn of Entities Marked with "SDKLifeTime" Value
    self.UpdateStatus(Tick)         -- (5 Min)  Purpose: Updates Sector related Logic (Populated, Scrapyard etc...)
    self.UpdateWreckage(Tick)       -- (1 Min)  Purpose: Sector Performace / Tag Wrecks for Script Logic

    --[[ 
    .    Have Local Faction Do Its Peacetime Jobs. In the event the Local faction is the 
    .    Player, Independent Civilians or Neighboring factions will do the tasks. 
    .    Some events will be skipped or adjusted based on the Player being responsible
    .    for their own sectors.
    ]]

    if not self.IsDangerous() then

        self.UpdateScrapyard(Tick)
       
    end

    if self.IsDangerous() then
       -- Logic to move ships to safety.
       -- Defenders if required.
    end

end

-- Update Fucntions

    function SDKBackgroundSectorManager.UpdateThreats(Tick) local Method = self.LogName("Update Threats")

        self._TThreats = self._TThreats - Tick if self._TThreats <= 0 then
            self._TThreats = 15 -- Reset Timer

            local Pirate = false
            local Xsotan = false

            for _, _Ship in pairs({Sector():getEntitiesByType(EntityType.Ship)}) do

                local F = Faction.New() F.Load(_Ship.factionIndex)
                if F.IsPirate() then Pirate = true end
                if F.IsXsotan() then Xsotan = true end
                
            end 

            self._Pirates = Pirate
            self._Xsotan = Xsotan

        end

    end

    function SDKBackgroundSectorManager.UpdateLifeTime(Tick) local Method = self.LogName("Update Life Time")

        for _, E in pairs({Sector():getEntitiesByScriptValue("SDKLifeTime")}) do
            local Life = tonumber(E:getValue("SDKLifeTime")) if Life then

                -- Test Life Time / Delete Entity
                Life = Life - Tick  if Life <= 0 then 
                    
                    Log.Debug(Method, "Despawn: " .. tostring(E.type) .. " - " .. tostring(E.name), _Debug)  
                    Sector():deleteEntityJumped(E)
                
                else -- Update LifeTime
                    E:setValue("SDKLifeTime", Life)
                end

            end
        end

    end

    function SDKBackgroundSectorManager.UpdateMainFaction(Tick) local Method = self.LogName("Update Main Faction")

        self._TControl = self._TControl - Tick if self._TControl <= 0 then
            self._TControl = 300 -- Reset Timer

            -- Check/Change Controlling Faction
            local F = Faction.New() F.Controlling() if not F.IsSelf(self._MainFaction) then

                self._MainFaction = F   -- Update Contolliing Faction

                -- [News Broadcast] Sector Change to all Players in Lossing Factions Sectors and Gaining Factions Sectors

            end

        end
        
    end

    function SDKBackgroundSectorManager.UpdateStatus(Tick) local Method = self.LogName("Update Status")
        
        self._TStatus = self._TStatus - Tick if self._TStatus <= 0 then
            self._TStatus = 300 -- Reset Timer

            local Populated = false
            local NumStation = 0
            local Scrapyards = false
            local Shipyards = false
            local RepairDocks = false

            -- Check Stations.
            for _, S in pairs({Sector():getEntitiesByType(EntityType.Station)}) do
                if not S.dockable then      -- Not in Transport Mode
                    
                    Populated = true NumStation = NumStation + 1
                    if     S:hasScript("data/scripts/entity/merchants/scrapyard.lua") then  Scrapyards = true
                    elseif S:hasScript("data/scripts/entity/merchants/shipyard.lua") then   Shipyards = true
                    elseif S:hasScript("data/scripts/entity/merchants/repairdock.lua") then RepairDocks = true end

                end
            end 

            self._Populated = Populated
            self._Scrapyard = Scrapyards
            self._Shipyard = Shipyards
            self._RepairDock = RepairDocks
            self._NumStations = NumStation

            if Scrapyards then
                self._LimitWreckage = 120   -- Upper Limit - Will Spawn Mega Salvager Until Under Threshold
                self._LifeWreckage = -1     -- Don't Despawn Large Wrecks
            else
                self._LimitWreckage = 30    -- Upper Limit - Will Spawn Mega Salvager Until 0
                self._LifeWreckage = 180    -- Despawn Small Wreckage / Process Large Wreckage
            end

            Log.Debug(Method, "Populated: " .. tostring(self._Populated), _Debug)
            Log.Debug(Method, "Detected Stations: " .. tostring(self._NumStations), _Debug)
            Log.Debug(Method, "Scrapyard: " .. tostring(self._Scrapyard), _Debug)
            Log.Debug(Method, "Shipyard: " .. tostring(self._Shipyard), _Debug)
            Log.Debug(Method, "Repair Dock: " .. tostring(self._RepairDock), _Debug)

        end

    end

    function SDKBackgroundSectorManager.UpdateWreckage(Tick) local Method = self.LogName("Update Wreckage")
                    
        self._TWreckage = self._TWreckage - Tick if self._TWreckage <= 0 then 
            self._TWreckage = 60 -- Reset Timer

            Log.Debug(Method, "Scrapyard: " .. tostring(self._Scrapyard), _Debug)

            -- Scrub Particle Wreckage / Mark New Wreckages
            local c2 = 0 local S = Sector() for k, v in pairs({S:getEntitiesByType(EntityType.Wreckage)}) do
                if v.volume <= self._WreckageSize then S:deleteEntity(v)   -- Delete Small Wreckage
                else v:setValue("SDKWreckage", v.volume) end c2 = c2 + 1   -- Set Wreckage to Volume
            end

            Log.Debug(Method, "Processed Wrecks: " .. tostring(c2), _Debug)

            -- Update Wreckage Timers
            local c = 0 if self._Scrapyard == false then
                for _, E in pairs({Sector():getEntitiesByScriptValue("SDKWreckage")}) do

                    local T = tonumber(E:getValue("SDKWreckageTime")) or 0
                    E:setValue("SDKWreckageTime", T + Tick) c = c + 1
        
                end
            end

            Log.Debug(Method, "Detected Wrecks: " .. tostring(c), _Debug)

            -- Add Control Logic to remove excessive wreckage

        end

    end

    function SDKBackgroundSectorManager.UpdateScrapyard(Tick) local Method = self.LogName("Update Scrapyard")
        
        if not self._Scrapyard then return end  -- No Scrapyard = No Work
        
        self._TScrapyardUpdate = self._TScrapyardUpdate - Tick if self._TScrapyardUpdate <= 0 then 
            self._TWreckage = 5 -- Reset Timer

            -- Wreckage Threshold
            -- more populated sectors get less Wreckage for Load Management.
            local Wrecks = self.WrecksCount()       -- Get Number of Wrecks
            local Allowed = self.WrecksAllowed()    -- Get Number Allowed
            if Wrecks > Allowed then return end     -- Threshold Check

            -- Track Wreckage Spawn Countdown
            self._TWreckSpawn = self._TWreckSpawn - Tick if self._TWreckSpawn > 0 then return end

            -- Set Spawn Timer: Increase Speed if Wreckage is in Demand
            if Wrecks > Allowed * 0.2 then
                 self._TWreckSpawn = Rand.Int(10, 120)
            else self._TWreckSpawn = Rand.Int(10, 45) end

            self.SpawnScrapyardWreck()

        end

    end

-- End Update Functions

-- Spawn Functions

    function SDKBackgroundSectorManager.SpawnScrapyardWreck() local Method = self.LogName("Spawn Scrapyard Wreckage")

        Log.Debug(Method, "Attempting To Spawn A New Wreck...", _Debug)
        local Generator = self.PlanGenerator()

        -- Scrapyard Information
            local SY, SYP, SYFI = self.Scrapyard()  -- Scrapyard, Posit, Faction Index

            Log.Debug(Method, "Scrapyard Positon: " .. tostring(SYP), _Debug)
            Log.Debug(Method, "Scrapyard Faction Index: " .. tostring(SYFI), _Debug)

            local Owner = Faction.New() if not Owner.Load(SYFI) then
            Log.Error(Method, "Failed to Get Scrapyard Info...", 1) return end
        --

        -- Wreckage Position
            local WP if self._NumStations > 1 then        -- Place outside Core Sector Area (Populated Sector)
                 WP = Position.Around(Position.RVec3(0,0,0), self._CoreRadius  * 0.75, self._MaxRadius * 0.75) 
            else WP = Position.Around(SYP, 500, 2500) end -- Place around the Scrapyard
            if not WP then Log.Error(Method, "Failed to Get Wreckage Spawn Position...", 1) return end
        --
        
        -- Get Valid Tug Faction
            local Facs = {} local NF = Owner.Neighbors() for i = 1, #NF do
                if not Owner.AtWar(NF[i]) then table.insert(Facs, NF[i]) end
            end table.insert(Facs, Owner.Civilian())
            local Fac = Facs[Rand.Int(1, #Facs)]
            if not Fac then Log.Error(Method, "Failed to Get Tug Faction...", 1) return end
        --          

        -- Load Wreckage Plan
            local Type local Roll = Rand.Int(1, 100)
            if     Roll <= 10 then      Type = Class.Military    
            elseif Roll <= 15 then      Type = Class.Carrier    
            elseif Roll <= 35 then      Type = Class.Miner    
            elseif Roll <= 70 then      Type = Class.Freighter    
            elseif Roll <= 100 then     Type = Class.Civilian end

            Log.Debug(Method, "Wreck Faction: " .. tostring(Fac.baseName), _Debug)
            Log.Debug(Method, "Wreck Style: " .. tostring(Type), _Debug)

            -- Get Wreckage based on the Tug Faction
            local Wreck = Generator.Wreckage(Fac, Type) if not Wreck then
            Log.Error(Method, "Failed to Load Wreckage Plan...", 1) return end 
            local WS = Volume.Slots(Wreck.volume)
        --

        -- Spawn Tug
            local P = Position.RMatrix(nil, nil, nil)    -- Common Positon Object to keep the same Look and Up Vecs.
            local Settings = Call.Settings(Class.Salvager, Volume.Get(5, 5), nil, nil, nil, Call.Salvager)
            local Build = AsyncShips(SDKBackgroundSectorManager, SDKBackgroundSectorManager.SpawnedScrapyardTug)

            -- Set Initial Tug Position / Evaluate Tug to Wreckage Match-Up
            P.position = Position.Around(WP, 25, 100) if WS < 7 then
                Build:Generate(Fac, P, Settings)        
            elseif WS < 11 then
                Settings.volume = Volume.Get(7, 7) 
                Build:Generate(Fac, P, Settings)
            else                                        
                Settings.volume = Volume.Get(10, 10)    
                P.position = Position.Around(WP, 50, 150) 
                Build:Generate(Fac, P, Settings)
            end 
        --

        -- Spawn Wreck
            P.position = WP
            Sector():createWreckage(Wreck, P, EntityArrivalType.Jump)
        --
    end

    function SDKBackgroundSectorManager.SpawnWreckageTug()
        
    end

    function SDKBackgroundSectorManager.SpawnWreckageSalvager()

    end

--

-- Callback Functions
    
    function SDKBackgroundSectorManager.SpawnedScrapyardTug(ship) local Method = self.LogName("Callback Scrapyard Tug")
        Log.Debug(Method, "Is Working", _Debug)
        ship:addScript("ai/patrol.lua")
        ship.title = "Scrapyard Tug" 
        ship:setValue("SDKLifeTime", Rand.Int(20, 45))
    end

    function SDKBackgroundSectorManager.SpawnedWreckageTug()

    end

    function SDKBackgroundSectorManager.SpawnedWreckageSalvager()

    end

--

-- Support Functions

    -- Pull nested Includes from a imported scripts
    function SDKBackgroundSectorManager.Designs()
        local Gen = self.PlanGenerator()
        return Gen.GetDeisgns()
    end

    -- Pull nested Includes from a imported scripts
    function SDKBackgroundSectorManager.PlanGenerator()
        return Ships.Generator()
    end

    -- Pull nested Includes from a imported scripts
    function SDKBackgroundSectorManager.Equip()
        return Ships.Equipment()
    end

    function SDKBackgroundSectorManager.IsCoreSector()
        return Galaxy():isCentralFactionArea(x, y, self._MainFaction.Obj.index)
    end

    function SDKBackgroundSectorManager.IsDangerous()
        if self._Pirates then return true end
        if self._Xsotan then return true end
        return false
    end

    function SDKBackgroundSectorManager.WrecksAllowed()
        local R = (self._NumStations * 9) or 0        -- Reduce Allowed Wrecks based on number of stations
        local W = self._LimitWreckage or 120          -- Wreckage Limit
        local A = W - R if A < 30 then return 30 end  -- Allowed Amount
        return A
    end

    function SDKBackgroundSectorManager.WrecksCount()
        local W = 0 for _, v in pairs({Sector():getEntitiesByScriptValue("SDKWreckage")}) do W = W + 1 end
        return W
    end

    function SDKBackgroundSectorManager.Scrapyard()
        for _, v in pairs({Sector():getEntitiesByScript("data/scripts/entity/merchants/scrapyard.lua")}) do            
            return v, v.translationf, v.factionIndex -- Return first one in the list.
        end return nil, nil, nil
    end

-- End Support Functions


function SDKBackgroundSectorManager.HasEnemies(_Faction)
    _Faction = _Faction or self.Locals()

    -- Check for Ships At War With Faction
    for _, _Ship in pairs({Sector():getEntitiesByType(EntityType.Ship)}) do
        if _Faction:getRelationStatus(_Ship.factionIndex) == RelationStatus.War then
            return true
        end  
    end 

end

function SDKBackgroundSectorManager.Wrecks() local _Method = "Wrecks"

    -- Processs Wrecks After Clean Up's Only.
    if self._NextClean == 60 then return nil end

    local _Sector = Sector() 
    local _Wrecks = {}

    -- Don't look for particle wreckage
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
