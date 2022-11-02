--[[
    Developer Notes:
    !! This script has to be Namespaced or it will not function !!

    This script is added to both the Client and the Server via init.lua in the "Sector" folder

    - Spawn Civilian Gate Traffic
    - Spawn Savlagers to clear Core Wrecks

    - Detect Damaged Alliance/Faction Ship & Stations --> Send Repair Ships
    - Detect Wreckage In Populated Sectors --> Send Scrap Tugs In To Clear/Harvest It
    - Add Roving Sector Patrols To Lightly Guarded Sectors --> Scan for Smugglers, 
      Clear out Strong Hostiles, etc... then move to next area
]]

package.path = package.path .. ";data/scripts/lib/?.lua"
package.path = package.path .. ";data/scripts/?.lua"

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
self._WreckageSize = 150    -- Volume Threshold for instant delete
self._WreckageSize2 = 1000  -- Volume Threshold for despawn marking

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
self._RepairDock = false    -- Track Repair Docks
self._Shipyard = false      -- Track Shipyards
self._Pirates = false   
self._Xsotan = false
self._Hostile = false

self._TestWreck = nil

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
    --Log.Debug(Method, tostring(Sector().name) .. ": Sector Manager Initialized", _Debug)
    print(tostring(Sector().name) .. ": Sector Manager v1.0 Initialized")

    if onServer() then
        Sector():registerCallback("onDestroyed", "Destroyed")  -- Track New Wreckages
    end

end

function SDKBackgroundSectorManager.getUpdateInterval()    
    return 1
end

-- Both Client/Server Updates
function SDKBackgroundSectorManager.updateServer(Tick) local Method = self.LogName("Update")
    
    if onClient() then return end   -- Server Process Only.

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
    self.UpdateWreckage(Tick)       -- (30 Sec)  Purpose: Sector Performace / Tag Wrecks for Script Logic

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
        
        local S = Sector()

        -- New Wreckage Detection Every 15 Seconds
        self._TWreckage = self._TWreckage - Tick if self._TWreckage <= 0 then 
            self._TWreckage = 15 -- Reset Timer

            Log.Debug(Method, "Scrapyard: " .. tostring(self._Scrapyard), _Debug)

            self.WreckageHandshake()

            -- Scrub Particle Wreckage / Mark New Wreckages
            local c2 = 0 for k, v in pairs({S:getEntitiesByType(EntityType.Wreckage)}) do
                if v.volume <= self._WreckageSize then S:deleteEntity(v)                        -- Delete Small Wreckage
                elseif v.volume <= self._WreckageSize2 then v:setValue("SDKWreckageClear", 1)   -- Mark For Destruction
                end c2 = c2 + 1
            end

            Log.Debug(Method, "Processed Wrecks: " .. tostring(c2), _Debug)

        end

        -- Process New Wrecks Marked for Deletion (Stage 1)
        for _, E in pairs({Sector():getEntitiesByScriptValue("SDKWreckageClear", 1)}) do
            E:setValue("SDKWreckageClear", 2)
            E:setValue("SDKDustExplosion", Rand.Int(3,7))
            E:setValue("SDKExplosion", Rand.Int(6,11))
            E:setValue("SDKExplosion2", Rand.Int(4,12))
        end

        -- Process Timers / Effects / Deletion (Stage 2)
        for _, E in pairs({Sector():getEntitiesByScriptValue("SDKWreckageClear", 2)}) do   
            
            -- Process Dust Explosions / Timers
            local DX = tonumber(E:getValue("SDKDustExplosion")) or 0

            --print("Entity: " .. tostring(E.id) .. " | DX: " .. tostring(DX))

            DX = DX - Tick if DX < 0 and DX > -3 then
                self.WreckDustExplosion(E.translationf, E:getBoundingSphere().radius/3)
                E:setValue("SDKDustExplosion", DX)
            elseif DX > -3 then 
                E:setValue("SDKDustExplosion", DX) 
            end

            local X1 = tonumber(E:getValue("SDKExplosion")) or 0

            --print("Entity: " .. tostring(E.id) .. " | X1: " .. tostring(X1))

            X1 = X1 - Tick if X1 < 0 and X1 > -3 then
                self.WreckExplosion(E.translationf, E:getBoundingSphere().radius/3)
                E:setValue("SDKExplosion", X1)
            elseif X1 > -3 then 
                E:setValue("SDKExplosion", X1) 
            end

            local X2 = tonumber(E:getValue("SDKExplosion2")) or 0

            --print("Entity: " .. tostring(E.id) .. " | X2: " .. tostring(X2))

            X2 = X2 - Tick if X2 < 0 and X2 > -3 then
                self.WreckExplosion(E.translationf, E:getBoundingSphere().radius/3)
                E:setValue("SDKExplosion2", X2)
            elseif X2 > -3 then 
                E:setValue("SDKExplosion2", X2) 
            end

            if DX < 0 and X1 < 0 and X2 < 0 then
                S:deleteEntity(E)
            end
        end

        -- Process Critical Wrecks (Stage 1)
        for _, E in pairs({Sector():getEntitiesByScriptValue("SDKWreckCritical", 1)}) do
            --print("Critical Wreckage - Stage 1")
            E:setValue("SDKWreckCritical", 2)
            E:setValue("SDKCriticalLife", Rand.Int(10, 65))
        end

        -- Process Critical Wrecks (Stage 2)
        for _, E in pairs({Sector():getEntitiesByScriptValue("SDKCriticalLife")}) do   
            
            --print("Critical Wreckage - Stage 2")
            local L = tonumber(E:getValue("SDKCriticalLife")) 

            --print("Wreckage Life: " .. tostring(L))

            L = L - Tick
            local rad = E:getBoundingSphere().radius

            self.WreckDustExplosion(E.translationf, E:getBoundingSphere().radius)
            self.DeathDamage(E)
            
            if Rand.Truth() then
                self.WreckDustExplosion(E.translationf, rad)
            end
            
            if Rand.Truth() then
                self.WreckDustExplosion(E.translationf, rad)
            end
            
            if Rand.Truth() then
                self.WreckDustExplosion(E.translationf, rad)
            end
            
            if Rand.Truth() then
                self.WreckDustExplosion(E.translationf, rad)
                self.DeathDamage(E)
            end

            if L <= 0 then
                self.DeathExplosion(E)
                S:deleteEntity(E)
            else 
                --print("Update Wreckage Life: " .. tostring(L))
                E:setValue("SDKCriticalLife", L) 
            end
        end

        -- Update Large Wreckage Timers
        local c = 0 if self._Scrapyard == false then
            for _, E in pairs({Sector():getEntitiesByScriptValue("SDKWreckage")}) do

                local T = tonumber(E:getValue("SDKWreckageTime")) or 0
                E:setValue("SDKWreckageTime", T + Tick) c = c + 1
    
            end
        end

        --Log.Debug(Method, "Detected Wrecks: " .. tostring(c), _Debug)

        -- Add Control Logic to remove excessive wreckage

    end

    function SDKBackgroundSectorManager.UpdateScrapyard(Tick) local Method = self.LogName("Update Scrapyard")
        
        if not self._Scrapyard then return end  -- No Scrapyard = No Work
        
        -- Check Status every 5 seconds.
        self._TScrapyardUpdate = self._TScrapyardUpdate - Tick if self._TScrapyardUpdate <= 0 then 
            self._TWreckage = 5 -- Reset Timer

            local Total, Ships, Stations, Wrecks, Asteroids, Fighters = self.EntityLoad(true, true, true, true, true)

            -- Wreckage Threshold
            -- more populated sectors get less Wreckage for Load Management.

            local Limit = 200                                                                 -- Wreckage/Workload Limit
            local Value = Wrecks + (Stations * 10) + (Ships) + (Fighters) + (Asteroids/25)    -- Workload Value
            local Band = Limit - Rand.Round(Value, 0)                                         -- Do Math, Round to a whole number.
            local State = 0

            print("Workload Value: " .. tostring(Value))
            print("Spawn Band: " .. tostring(Band))
            
            if Band > 60 then       State = 0               -- Allow Quicker Spawns
                print("Allowing Faster Spawns")
            elseif Band > 0 then    State = 1               -- Disable Quicker Spawns     
                print("Disabled Faster Spawns")
            else                    State = 2               -- Disable Scrapyard Wrecks
                print("Disabled Scrapyard Spawns")
            end
               
            if State == 2 then return end               -- Threshold Check
            
            -- Track Wreckage Spawn Countdown
            self._TWreckSpawn = self._TWreckSpawn - Tick if self._TWreckSpawn > 0 then return end

            -- Set Spawn Timer: Increase Speed if Wreckage is in Demand
            if State == 0 then
                 self._TWreckSpawn = Rand.Int(10, 25)
            else self._TWreckSpawn = Rand.Int(10, 120) end

            self.SpawnScrapyardWreck()

        end

    end

-- End Update Functions

-- Processing Functions

    --[[
        This function attempts to match new wreckage with the old Entity() that was destroyed
        I'm mostly using this so I can track new ship/station destruction and roll a chance
        that the station/ship will go supercritical and completely explode.
    ]]
    function SDKBackgroundSectorManager.WreckageHandshake()

        --print("Checking Type " .. tostring(EntityType.Wreckage))

        local count = 0

        for k, v in pairs({Sector():getEntitiesByType(EntityType.Wreckage)}) do

            count = count +1
            --print("Checking Wreck " .. tostring(count) .. " | SDKWreckage = " .. tostring(v:getValue("SDKWreckage")) .. " | SDKWreckageClear = " .. tostring(v:getValue("SDKWreckageClear")))

            -- Delete small wreckage for performance
            if v.volume <= self._WreckageSize then Sector():deleteEntity(v) end

            -- Handle Areas with Scrapyards different
            if self._Scrapyard then
                v:setValue("SDKScrapyardWreckage", true)    -- Mark all wrecks in a scrapyard on generation/every 15 seconds
                v:setValue("SDKWreckageClear", nil)         -- Don't remove wreck from scrapyard
                v:setValue("SDKWreckage", v.volume)         
                
            -- Only check unprocessed Wrecks not in Scrapyard
            elseif not v:getValue("SDKWreckage") and not v:getValue("SDKWreckageClear") then local C = true 

                --[[
                if v.volume > self._WreckageSize then
                    print("Process: Target Wreck " .. tostring(count) .. " | " .. tostring(v.volume) .. "/" .. tostring(self._WreckageSize))
                else
                    print("Delete Target Wreck " .. tostring(count))
                end
                ]]

                --Randomly Make wreckage go boom...                  
                if Rand.Truth(.3) then                         
                    v.title = "Wreck (Supercritical)"
                    v:setValue("SDKWreckCritical", 1) 
                elseif Rand.Truth(.7) then                         
                    v.title = "Wreck (Critical)"
                else
                    -- Safely cooled down. Wont go boom.
                    print("Target Wreck - Cooled Down. Safe.")
                    v.title = "Wreck"
                    v:setValue("SDKWreckage", v.volume)
                end 

            end

        end

    end

    function SDKBackgroundSectorManager.WreckageCooldown(v)

        if not v then return end

        if not v:setValue("Count") then
            v:setValue("Count", 1)
        else
            local count = v:getValue("Count")
            v:setValue(count +1)
        end
        
        --Randomly Make wreckage go boom...                  
        if Rand.Truth(.3) then                         
            print("Target Wreck - Is Critical!")
            v.title = "Wreck (Supercritical)"
            v:setValue("SDKWreckCritical", 1) 
            return
        end 

        --Random Check to let it cool down.
        if Rand.Truth(.7) then                         
            print("Target Wreck - Got another look")
            v.title = "(" ..tostring(v:getValue("Count")) .. ") Wreck (Critical)"
            deferredCallback(5, "WreckageCooldown", v)

        end 
        
        -- Safely cooled down. Wont go boom.
        print("Target Wreck - Cooled Down. Safe.")
        v.title = "Wreck"
        return 

    end 

-- End Processing Functions

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
                Settings.volume = Volume.Get(10, 10) 
                Build:Generate(Fac, P, Settings)
            else                                        
                Settings.volume = Volume.Get(13, 13)    
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

-- Registered Callbacks

    --onDestroyed(index, lastDamageInflictor)
    function SDKBackgroundSectorManager.Destroyed(a, b)
        
        if onClient() then return end local e = Entity(a)   -- Only on the server
        if not e.isStation and not e.isShip then return end -- Only want ships and stations

        e:setValue("SDKNewWreck", 1)

        --print(e.name .. " | New Wreck = " .. tostring(e:getValue("SDKNewWreck")))

        --print("Entity ID: " .. tostring(a))
        --print("Entity Pos: " .. tostring(pos))
        --print("Entity Rad: " .. tostring(rad))
        --print("Entity Vol: " .. tostring(vl))

        -- Let the wreck process then try and detect it.
        deferredCallback(1, "WreckageHandshake")

    end

--

-- Callback Functions
    
    -- Called Back from the Async Ship Generator
    function SDKBackgroundSectorManager.SpawnedScrapyardTug(ship) local Method = self.LogName("Callback Scrapyard Tug")
        ship:addScript("ai/patrol.lua")
        ship.title = "Scrapyard Tug" 
        ship:setValue("SDKLifeTime", Rand.Int(45, 135))
    end

    -- Called Back from the Async Ship Generator
    function SDKBackgroundSectorManager.SpawnedWreckageTug()
    end

    -- Called Back from the Async Ship Generator
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

    function SDKBackgroundSectorManager.EntityLoad(Ships, Stations, Wreckage, Asteroids, Fighters)
        if onClient() then return end   -- Server Process Only.

        local sec = Sector() print("Sector: " .. tostring(sec.name) .. " | Entities: " .. tostring(sec.numEntities))

        local Sh = 0
        local St = 0
        local W = 0
        local A = 0
        local F = 0

        if Ships then
            for k, v in pairs({Sector():getEntitiesByType(EntityType.Ship)}) do Sh = Sh +1 end
        end

        if Stations then
            for k, v in pairs({Sector():getEntitiesByType(EntityType.Station)}) do St = St +1 end
        end

        if Wreckage then
            for k, v in pairs({Sector():getEntitiesByType(EntityType.Wreckage)}) do W = W +1 end
        end

        if Asteroids then
            for k, v in pairs({Sector():getEntitiesByType(EntityType.Asteroid)}) do A = A +1 end
        end

        if Fighters then
            for k, v in pairs({Sector():getEntitiesByType(EntityType.Fighter)}) do F = F +1 end
        end

        print("Sector: " .. tostring(sec.name) .. " | Ships: " .. tostring(Sh))
        print("Sector: " .. tostring(sec.name) .. " | Stations: " .. tostring(St))
        print("Sector: " .. tostring(sec.name) .. " | Wrecks: " .. tostring(W))
        print("Sector: " .. tostring(sec.name) .. " | Asteroids: " .. tostring(A))
        print("Sector: " .. tostring(sec.name) .. " | Fighters: " .. tostring(F))

        local Total = Sh + St + W + A + F

        return Total, Sh, St, W, A, F

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

    -- Data Formatting
    function SDKBackgroundSectorManager.FWreck(id, v1, v2, v3)
        local Temp = {}
        Temp.id = id
        Temp.DustExplosion = v1
        Temp.Explosion1 = v2
        Temp.Explosion2 = v3
        return Temp
    end

-- End Support Functions

-- Functions with Client Calls

    --createDust(vec3 pos, float size, Color color, float lifeSpan)
    --createDustExplosion(vec3 pos, float size, Color color)
    --createExplosion(vec3 pos, float size, bool silent)

    function SDKBackgroundSectorManager.WreckExplosion(pos, buff)
        if onServer() then broadcastInvokeClientFunction("WreckExplosion", pos, buff) return end

        --print("Explostion Pos: " .. tostring(pos))
        --print("Explostion Buff: " .. tostring(buff))

        local p1 = Position.Around(pos, nil, buff)
        Sector():createExplosion(p1, Rand.Float(1, 3), false)
        self.WreckDust(p1, Rand.Float(3, 7), Rand.Float(20, 40))

        if Rand.Truth() then
            local p2 = Position.Around(pos, nil, buff)
            Sector():createExplosion(p2, Rand.Float(1, 3), false)
            self.WreckDust(p2, Rand.Float(3, 7), Rand.Float(20, 40))
        end

        if Rand.Truth(0.25) then
            local p3 = Position.Around(pos, nil, buff)
            Sector():createExplosion(p3, Rand.Float(1, 3), false)
            self.WreckDust(p3, Rand.Float(3, 7), Rand.Float(20, 40))
        end

    end
    
    function SDKBackgroundSectorManager.WreckDustExplosion(pos, buff)
        if onServer() then broadcastInvokeClientFunction("WreckDustExplosion", pos, buff) return end
        
        --print("Dust Explostion Pos: " .. tostring(pos))
        --print("Dust Explostion Buff: " .. tostring(buff))

        local C = ColorRGB(0.466,0.466,0.466)   -- Dim Grey Dust Clouds
        local p1 = Position.Around(pos, nil, buff)
        Sector():createDustExplosion(p1, Rand.Float(1, 3), C)
        self.WreckDust(p1, Rand.Float(2, 4), Rand.Float(20, 40))

        if Rand.Truth() then
            local p2 = Position.Around(pos, nil, buff)
            Sector():createDustExplosion(p2, Rand.Float(1, 3), C)
            self.WreckDust(p2, Rand.Float(2, 4), Rand.Float(20, 40))
        end

        if Rand.Truth(0.25) then
            local p3 = Position.Around(pos, nil, buff)
            Sector():createDustExplosion(p3, Rand.Float(1, 3), C)
            self.WreckDust(p3, Rand.Float(2, 4), Rand.Float(20, 40))
        end
    end
    
    function SDKBackgroundSectorManager.WreckDust(pos, size, life)
        if onServer() then broadcastInvokeClientFunction("WreckDust", pos, size, life) return end

        -- Dim Grey Dust Clouds
        Sector():createDust(pos, size, ColorRGB(0.466,0.466,0.466), life)
        
    end

    function SDKBackgroundSectorManager.DeathExplosion(E)

        local pos = E.translationf
        local rad = E:getBoundingSphere().radius
        
        if onServer() then broadcastInvokeClientFunction("DeathExplosion", E) end
        
        if onClient() then
            --print("Starting Visuals...")

            local C = ColorRGB(0.466,0.466,0.466)   -- Dim Grey Dust Clouds
            local p1 = Position.Around(pos, rad/8, rad/7)
            local p2 = Position.Around(pos, rad/8, rad/7)
            local p3 = Position.Around(pos, rad/8, rad/7)
            local p4 = Position.Around(pos, rad/8, rad/7)
            local p5 = Position.Around(pos, rad/8, rad/7)
    
            Sector():createDustExplosion(p1, Rand.Float(rad/5, rad/3), C)
            Sector():createDustExplosion(p2, Rand.Float(rad/5, rad/3), C)
            Sector():createDustExplosion(p3, Rand.Float(rad/5, rad/3), C)
            Sector():createExplosion(p4, Rand.Float(rad/5, rad/3), false)
            Sector():createExplosion(p5, Rand.Float(rad/5, rad/3), false)

            Sector():createDustExplosion(pos, rad, C)
            Sector():createDustExplosion(pos, rad * 2, C)
            Sector():createDustExplosion(pos, rad * 3, C)
            Sector():createDustExplosion(pos, rad * 4, C)
            Sector():createExplosion(pos, rad, false)
            
        end

        if onServer() then 

            --print("Dealing Damage: " .. tostring(E.volume))

            local rng1 = Sphere(pos, rad * 1.5) 
            local rng2 = Sphere(pos, rad * 2.25) 
            local rng3 = Sphere(pos, rad * 3.15) 
            local rng4 = Sphere(pos, rad * 4) 
                
            for k, v in pairs({Sector():getEntitiesByLocation(rng1)}) do
                if v.isShieldActive then
                    local temp = v.shieldDurability - E.volume
                    if temp < 0 then temp = 0 end
                    v.shieldDurability = temp
                elseif v.durability then
                    v.durability = v.durability - E.volume
                end
            end

            for k, v in pairs({Sector():getEntitiesByLocation(rng2)}) do
                if v.isShieldActive then
                    local temp = v.shieldDurability - E.volume
                    if temp < 0 then temp = 0 end
                    v.shieldDurability = temp
                elseif v.durability then
                    v.durability = v.durability - E.volume
                end
            end

            for k, v in pairs({Sector():getEntitiesByLocation(rng3)}) do
                if v.isShieldActive then
                    local temp = v.shieldDurability - E.volume
                    if temp < 0 then temp = 0 end
                    v.shieldDurability = temp
                elseif v.durability then
                    v.durability = v.durability - E.volume
                end
            end

            for k, v in pairs({Sector():getEntitiesByLocation(rng4)}) do
                if v.isShieldActive then
                    local temp = v.shieldDurability - E.volume
                    if temp < 0 then temp = 0 end
                    v.shieldDurability = temp
                elseif v.durability then
                    v.durability = v.durability - E.volume
                end
            end
        end

    end
    
    function SDKBackgroundSectorManager.DeathDamage(E)

        local pos = E.translationf
        local rad = E:getBoundingSphere().radius
        
        if onServer() then broadcastInvokeClientFunction("DeathDamage", E) return end
        
        local C = ColorRGB(0.466,0.466,0.466)   -- Dim Grey Dust Clouds
        local p1 = Position.Around(pos, rad/8, rad/7)
        local p2 = Position.Around(pos, rad/8, rad/7)
        local p3 = Position.Around(pos, rad/8, rad/7)
        local p4 = Position.Around(pos, rad/8, rad/7)
        local p5 = Position.Around(pos, rad/8, rad/7)

        Sector():createExplosion(p1, Rand.Float(rad/8, rad/6), false)
        Sector():createExplosion(p2, Rand.Float(rad/8, rad/6), false)
        Sector():createExplosion(p3, Rand.Float(rad/8, rad/6), false)
        Sector():createExplosion(p4, Rand.Float(rad/8, rad/6), false)
        Sector():createExplosion(p5, Rand.Float(rad/8, rad/6), false)

        Sector():createExplosion(pos, rad/5, false)

    end

-- 