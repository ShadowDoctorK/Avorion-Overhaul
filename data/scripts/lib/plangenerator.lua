--[[
    Developer Notes:
    - Pirates are divided by 3 till a dedicated solution is able to be used. This will require the generator overhaul to be finished.
]]

--[[
    To Do List"
    - Update all PlanGenerator.GetShipVolume() refs to local Volume = include("SDKGlobalDesigns - Volumes") Volume.Ship()

    - Use BD's AC Groundhog Light Miner as a drone default
    - Update data/scripts/sector/passingships.lua to use new PlanGenerator to build ship
]]

include ("defaultscripts")
local Rand = include("SDKUtilityRandom")
local Plan = include("SDKUtilityBlockPlan")
local Designs = include("SDKGlobalDesigns")
local Volume = include("SDKGlobalDesigns - Volumes")
local Class = include("SDKGlobalDesigns - Classes")

-- Logging Setup
    local Log = include("SDKDebugLogging")
    local _ModName = "Plan Generator"
    local _Debug = 0
-- End Logging

------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------ Stored Vanilla Functions  ---------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------

-- Stores the Vanilla Function For Use If Requried
PlanGenerator.old_makeStationPlan =        PlanGenerator.makeStationPlan
PlanGenerator.old_makeShipPlan =           PlanGenerator.makeShipPlan
PlanGenerator.old_makeAsyncShipPlan =      PlanGenerator.makeAsyncShipPlan
PlanGenerator.old_makeMinerPlan =          PlanGenerator.makeMinerPlan
PlanGenerator.old_makeAsyncMinerPlan =     PlanGenerator.makeAsyncMinerPlan
PlanGenerator.old_makeFreighterPlan =      PlanGenerator.makeFreighterPlan
PlanGenerator.old_makeAsyncFreighterPlan = PlanGenerator.makeAsyncFreighterPlan
PlanGenerator.old_makeAsyncCarrierPlan =   PlanGenerator.makeAsyncCarrierPlan

PlanGenerator.old_makeGatePlan =            PlanGenerator.makeGatePlan


------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------- Plan Generator  --------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------

local self = PlanGenerator

-- Fucntion to build Methodname
function PlanGenerator.LogName(n)
    return _ModName .. " - " .. n
end

function PlanGenerator.GetDeisgns()
    return Designs
end 

function PlanGenerator.GetVolume()
    return Volume
end

function PlanGenerator.GetBlockPlan()
    return Plan
end

-- Global Plans (Picks and Returns a Plan)
    function PlanGenerator.GlobalStationPlan(_Faction, S, V, MT)
        local _MethodName = self.LogName("Global Station Plan")

        if onClient() then 
            Log.Debug(_MethodName, "Tried To Execute On Client", _Debug) return 
        end

        Log.Debug(_MethodName, "Value (Volume): " .. tostring(V), _Debug)
        Log.Debug(_MethodName, "Value (Material): " .. tostring(MT), _Debug)
        Log.Debug(_MethodName, "Value (Faction): " .. tostring(_Faction.index), _Debug)
        Log.Debug(_MethodName, "Loading Station Type: " .. tostring(S), _Debug)

        if Plan.Pick(PlanGenerator.GlobalStationTable(_Faction.index, S)) then
            Plan.Material(MT, "Tier")
            Plan.Scale(V)
        end
        
        return Plan.Get()

    end

    function PlanGenerator.GlobalMilitaryShipPlan(FI, S, V, MT)
        local _MethodName = self.LogName("Global Ship Plan")

        if onClient() then 
            Log.Debug(_MethodName, "Tried To Execute On Client", _Debug) return 
        end

        -- Temp Pirate Solution. Remove when we have a dedicated Generator for Pirates
        if S == "Pirate" then V = V / 3 end
        
        Log.Debug(_MethodName, "Value (Faction): " .. tostring(FI), _Debug)
        Log.Debug(_MethodName, "Value (Style): " .. tostring(S), _Debug)
        Log.Debug(_MethodName, "Value (Volume): " .. tostring(V), _Debug)
        Log.Debug(_MethodName, "Value (Material): " .. tostring(MT), _Debug)

        -- Pick New Style Based of Volume
        S = Volume.MilitaryClass(V)

        -- Pick A Plan And Set It Up
        if Plan.Pick(PlanGenerator.GlobalMilitaryTable(FI, V, S)) then
            Plan.Material(MT, "Tier")
            Plan.Scale(V)
        end
        
        return Plan.Get()

    end

    function PlanGenerator.GlobalCarrierPlan(FI, S, V, MT)
        local _MethodName = self.LogName("Global Carrier Ship Plan")

        if onClient() then 
            Log.Debug(_MethodName, "Tried To Execute On Client", _Debug) return 
        end

        Log.Debug(_MethodName, "Value (Faction): " .. tostring(FI), _Debug)
        Log.Debug(_MethodName, "Value (Style): " .. tostring(S), _Debug)
        Log.Debug(_MethodName, "Value (Volume): " .. tostring(V), _Debug)
        Log.Debug(_MethodName, "Value (Material): " .. tostring(MT), _Debug)
        
        if Plan.Pick(PlanGenerator.GlobalCarrierTable(FI,V, S)) then
            Plan.Material(MT, "Tier")
            Plan.Scale(V)
        end
        
        return Plan.Get()

    end

    function PlanGenerator.GlobalFreighterPlan(FI, S, V, MT)
        local _MethodName = self.LogName("Global Freighter Plan")

        if onClient() then 
            Log.Debug(_MethodName, "Tried To Execute On Client", _Debug) return 
        end

        Log.Debug(_MethodName, "Value (Faction): " .. tostring(FI), _Debug)
        Log.Debug(_MethodName, "Value (Style): " .. tostring(S), _Debug)
        Log.Debug(_MethodName, "Value (Volume): " .. tostring(V), _Debug)
        Log.Debug(_MethodName, "Value (Material): " .. tostring(MT), _Debug)
        
        if Plan.Pick(PlanGenerator.GlobalFreighterTable(V, S)) then
            Plan.Material(MT, "Tier")
            Plan.Scale(V)
        end
        
        return Plan.Get()

    end

    function PlanGenerator.GlobalSalvagerPlan(FI, S, V, MT)
        local _MethodName = self.LogName("Global Salvager Plan")

        if onClient() then 
            Log.Debug(_MethodName, "Tried To Execute On Client", _Debug) return 
        end

        Log.Debug(_MethodName, "Value (Faction): " .. tostring(FI), _Debug)
        Log.Debug(_MethodName, "Value (Style): " .. tostring(S), _Debug)
        Log.Debug(_MethodName, "Value (Volume): " .. tostring(V), _Debug)
        Log.Debug(_MethodName, "Value (Material): " .. tostring(MT), _Debug)
        
        if Plan.Pick(PlanGenerator.GlobalSalvagerTable(V, S)) then
            Plan.Material(MT, "Tier")
            Plan.Scale(V)
        end
        
        return Plan.Get()

    end

    function PlanGenerator.GlobalMinerPlan(FI, S, V, MT)
        local _MethodName = self.LogName("Global Miner Plan")

        if onClient() then 
            Log.Debug(_MethodName, "Tried To Execute On Client", _Debug) return 
        end

        Log.Debug(_MethodName, "Value (Faction): " .. tostring(FI), _Debug)
        Log.Debug(_MethodName, "Value (Style): " .. tostring(S), _Debug)
        Log.Debug(_MethodName, "Value (Volume): " .. tostring(V), _Debug)
        Log.Debug(_MethodName, "Value (Material): " .. tostring(MT), _Debug)
        
        if Plan.Pick(PlanGenerator.GlobalMinerTable(V, S)) then
            Plan.Material(MT, "Tier")
            Plan.Scale(V)
        end
        
        return Plan.Get()

    end

    function PlanGenerator.GlobalCivilianPlan(FI, S, V, MT)
        local _MethodName = self.LogName("Global Civilian Plan")

        if onClient() then 
            Log.Debug(_MethodName, "Tried To Execute On Client", _Debug) return 
        end

        Log.Debug(_MethodName, "Value (Faction): " .. tostring(FI), _Debug)
        Log.Debug(_MethodName, "Value (Style): " .. tostring(S), _Debug)
        Log.Debug(_MethodName, "Value (Volume): " .. tostring(V), _Debug)
        Log.Debug(_MethodName, "Value (Material): " .. tostring(MT), _Debug)
        
        if Plan.Pick(PlanGenerator.GlobalCivilianTable(V, S)) then
            Plan.Material(MT, "Tier")
            Plan.Scale(V)
        end
        
        return Plan.Get()

    end

    function PlanGenerator.GlobalCrewTransportPlan(FI, S, V, MT)
        local _MethodName = self.LogName("Global Crew Transport Plan")

        if onClient() then 
            Log.Debug(_MethodName, "Tried To Execute On Client", _Debug) return 
        end

        Log.Debug(_MethodName, "Value (Faction): " .. tostring(FI), _Debug)
        Log.Debug(_MethodName, "Value (Style): " .. tostring(S), _Debug)
        Log.Debug(_MethodName, "Value (Volume): " .. tostring(V), _Debug)
        Log.Debug(_MethodName, "Value (Material): " .. tostring(MT), _Debug)
        
        if Plan.Pick(PlanGenerator.GlobalCrewTransportTable(V, S)) then
            Plan.Material(MT, "Tier")
            Plan.Scale(V)
        end
        
        return Plan.Get()

    end
--

-- Global Tables (Picks and Returns Design Tables)

    function PlanGenerator.GlobalStationTable(FI, S)
        local _MethodName = self.LogName("Global Station Table")

        if onClient() then 
            Log.Debug(_MethodName, "Tried To Execute On Client", _Debug)
            return 
        end

        -- Get Faction Pack Stations
        local T = Designs.FactionStation(FI, S)

        -- Return Faction Pack Table or Fallback to Global Designs
        if T and #T ~= 0 then return T end

        --Log.Debug(_MethodName, "No Faction Design, Searching For Global Design...", _Debug)

        -- Global Default Fallback
        T = Designs.Stations

        -- Global Designs
        if S == Class.Shipyard then                 T = Designs.Shipyards
        elseif S == Class.RepairDock then           T = Designs.RepairDocks
        elseif S == Class.ResourceDepot then        T = Designs.ResourceDepots
        elseif S == Class.TradingPost then          T = Designs.TradingPosts
        elseif S == Class.EquipmentDock then        T = Designs.EquipmentDocks
        elseif S == Class.SmugglersMarket then      T = Designs.SmugglersMarkets
        elseif S == Class.Scrapyard then            T = Designs.Scrapyards
        elseif S == Class.Mine then                 T = Designs.Mines
        elseif S == Class.Factory then              T = Designs.Factories
        elseif S == Class.FighterFactory then       T = Designs.FighterFactories
        elseif S == Class.TurretFactory then        T = Designs.TurretFactories
        elseif S == Class.SolarPowerPlant then      T = Designs.SolarPowerPlants
        elseif S == Class.Farm then                 T = Designs.Farms
        elseif S == Class.Ranch then                T = Designs.Ranches
        elseif S == Class.Collector then            T = Designs.Collectors
        elseif S == Class.Biotope then              T = Designs.Biotopes
        elseif S == Class.Casino then               T = Designs.Casinos
        elseif S == Class.Habitat then              T = Designs.Habitats
        elseif S == Class.MilitaryOutpost then      T = Designs.MilitaryOutposts
        elseif S == Class.Headquarters then         T = Designs.Headquarters
        elseif S == Class.ResearchStation then      T = Designs.ResearchStations
        elseif S == Class.TravelHub then            T = Designs.TravelHubs
        elseif S == "Default" then                  T = Designs.Stations
        elseif S then Log.Info(_MethodName, "[TRACKER#1] New/Untracked Staion Style: " .. tostring(S))  
        end
        

        -- Fallback To Generic Stations
        if #T == 0 then
            Log.Warning(_MethodName, "[" .. tostring(S) .. "] No Designs were returned. Attempting to use a generic station design.")
            
            T = Designs.Stations if #T == 0 then
                Log.Debug(_MethodName, tostring(#T) .. " Global Generic Stations Loaded")
                Log.Warning(_MethodName, "[" .. tostring(S) .. "] No Generic Designs. Using The Games Generator.")            
            end
        end

        return T

    end

    function PlanGenerator.GlobalMilitaryTable(FI, V, S) local _MethodName = self.LogName("Global Military Table")
        Log.Debug(_MethodName, "Style: " .. tostring(S), _Debug)

        if not Class.IsMilitary(S) then S = Volume.MilitaryClass(V) end
        local T = Designs.FactionShip(FI, S)
        if T and #T ~= 0 then return T end -- Get Faction Plan
        local T = Designs.Get(S) return T  -- Get Generic Plan

    end

    function PlanGenerator.GlobalCarrierTable(FI, V, S) local _MethodName = self.LogName("Global Carrier Table")
        Log.Debug(_MethodName, "Style: " .. tostring(S), _Debug)

        local T = Designs.FactionShip(FI, "Carrier") 
        if T and #T ~= 0 then return T end -- Return Faction Plan
        local T = Designs.Get(S) return T  -- Get Generic Plan

    end

    function PlanGenerator.GlobalFreighterTable(V, S) local _MethodName = self.LogName("Global Freighter Table")
        Log.Debug(_MethodName, "Style: " .. tostring(S), _Debug)

        if not Class.IsFreighter(S) then S = Volume.FreighterClass(V) end    
        local T = Designs.Get(S) return T  -- Get Generic Plan

    end

    function PlanGenerator.GlobalMinerTable(V, S) local _MethodName = self.LogName("Global Miner Table")
        Log.Debug(_MethodName, "Style: " .. tostring(S), _Debug)

        if not Class.IsMiner(S) then S = Volume.MinerClass(V) end    
        local T = Designs.Get(S) return T  -- Get Generic Plan

    end

    function PlanGenerator.GlobalSalvagerTable(V, S) local _MethodName = self.LogName("Global Salvager Table")
        Log.Debug(_MethodName, "Style: " .. tostring(S), _Debug)

        if not Class.IsSalvager(S) then S = Volume.SalvagerClass(V) end    
        local T = Designs.Get(S) return T  -- Get Generic Plan

    end

    function PlanGenerator.GlobalCivilianTable(V, S) local _MethodName = self.LogName("Global Civilian Table")
        Log.Debug(_MethodName, "Style: " .. tostring(S), _Debug)
        if S ~= Class.Civilian then S = Class.Civilian end

        local T = Designs.Get(S) return T  -- Get Generic Plan

    end

    function PlanGenerator.GlobalCrewTransportTable(V, S) local _MethodName = self.LogName("Global Crew Transport Table")
        Log.Debug(_MethodName, "Style: " .. tostring(S), _Debug)
        if S ~= Class.CrewTransport then S = Class.CrewTransport end

        local T = Designs.Get(S) return T  -- Get Generic Plan

    end

    -- Environment Tables

    function PlanGenerator.GlobalSataliteTable(V, S) local _MethodName = self.LogName("Global Satalite Table")
        Log.Debug(_MethodName, "Style: " .. tostring(S), _Debug)
        if S ~= Class.Satalite then S = Class.Satalite end

        local T = Designs.Get(S) return T  -- Get Generic Plan

    end

--

------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------- Station Plan ---------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------

function PlanGenerator.Station(fac, sn, sd, vl, mt, o) local _MethodName = self.LogName("Station Plan")

    Log.Debug(_MethodName, "Value (Faction): " .. tostring(fac.index) .. " = " .. tostring(fac.name), _Debug)
    Log.Debug(_MethodName, "Value (Style): " .. tostring(sn), _Debug)
    Log.Debug(_MethodName, "Value (Volume): " .. tostring(vl), _Debug)
    Log.Debug(_MethodName, "Value (Material): " .. tostring(mt), _Debug)

    o = o or self.GetOverride()
    sd = sd or math.random(0xffffffff)
    vl = o.volume or vl or Volume.Station()
    mt = o.material or mt or PlanGenerator.selectMaterial(fac)

    -- Mines don't need to be huge.
    if sn == Class.Mine then vl = 150000 end
    if sn == Class.IceMine then vl = 150000 end

    Log.Debug(_MethodName, "Selected (Material): " .. tostring(mt), _Debug)

    -- Try Global Plans First
    local plan = PlanGenerator.GlobalStationPlan(fac, sn, vl, mt)
    if plan then plan:scale(vec3(3, 3, 3)) return plan, sd, vl, mt end

    -- Try Faction Packs Second
    local plan = FactionPacks.getStationPlan(fac, vl, mt, sn)
    if plan then plan:scale(vec3(3, 3, 3)) end
    if plan then return plan end

    -- Unfortunatly Use The Game Generator
    local style = PlanGenerator.getStationStyle(fac, sn)
    local plan = GeneratePlanFromStyle(style, Seed(sd), vl, 10000, nil, mt)
    plan:scale(vec3(3, 3, 3))

    return plan, sd, vl, mt

end

------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------ Standard Ships --------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------

--[[
    Formats the override object so it can be passed to the generator from other scripts
    to force build a plan that doesn't take in account sector location variables.
]]
function PlanGenerator.GetOverride(sn, vl, mt, ti, at, cb)
    local o = {}
    o.style = sn
    o.volume = vl
    o.material = mt
    o.title = ti
    o.arrival = at
    o.callback = cb
    return o
end

-- Volume is a vanilla value not used in the new generator.
-- styleName is a vanilla value only used if default game generator is used.
-- material is a vanilla value only used if default game generator is used.

--[[
    fac = faction
    vl  = volume
    sn  = styleName
    mt  = material
    o   = override
]]
function PlanGenerator.Ship(fac, sn, o) local _MethodName = self.LogName("Ship Plan")
    Log.Debug(_MethodName, "Value (fac): " .. tostring(fac), _Debug)
    Log.Debug(_MethodName, "Value (sn): " .. tostring(sn), _Debug)
    return PlanGenerator.ShipAsync(nil, nil, fac, sn, true, o)
end

--[[
    cb  = callback
    v   = values
    fac = faction
    sn  = styleName
    s   = sync
    o   = override
]]

function PlanGenerator.ShipAsync(cb, v, fac, sn, s, o) local _MethodName = self.LogName("Async Ship Plan")
    o = o or self.GetOverride()

    Log.Debug(_MethodName, "Value (fac): " .. tostring(fac), _Debug)
    Log.Debug(_MethodName, "Value (sn): " .. tostring(sn), _Debug)

    local code = self.CodeMilitary()   -- Defaults to Generic Ships
    local vl = Volume.Ship() 
    local mt = self.selectMaterial(fac)
    local sd = math.random(0xffffffff) -- Seed

    -- Ensure we have a Style we are targeting. Defaul to a Military type.
    -- "Military" can be received when any military type ship will do.
    if not sn or sn == "Military" then sn = Volume.MilitaryClass(vl) end

    if o.volume then vl = o.volume end
    if o.material then mt = o.material end
    if o.style then sn = o.stlye end

    if Class.IsMilitary(sn) then 
        code = self.CodeMilitary()
        vl = Volume.Ship() 

    elseif sn == Class.Carrier then 
        code = self.CodeCarrier()
        vl = Volume.Carrier() 

    elseif sn == Class.Miner then 
        code = self.CodeMiner()
        vl = Volume.Ship() 

    elseif sn == Class.Freighter then 
        code = self.CodeFreighter()
        vl = Volume.Ship() 

    elseif sn == Class.Salvager then 
        code = self.CodeSalvager()
        vl = Volume.Ship() 

    elseif sn == Class.Civilian then 
        code = self.CodeCivilian()
        vl = Volume.Civilian() 

    elseif sn == Class.CrewTransport then 
        code = self.CodeCrewTransport()
        vl = Volume.Ship() 

    end

    if s then
        return execute(code, sn, sd, vl, mt, fac.index)
    else
        v = v or {}
        async(cb, code, sn, sd, vl, mt, fac.index, unpack(v))
    end
end

function PlanGenerator.Wreckage(fac, sn, o) local _MethodName = self.LogName("Wreckage Plan")
    local Wreck = Plan.New()

    Wreck.Obj = self.Ship(fac, sn, o)
    Wreck.NoStone() Wreck.Material()

    return Wreck.Get()
end

--[[
    sn = styleName
    sd = Seed
    vl = Volume
    mt = Material
    fi = Faction Index
]]
-- General Military Ship
function PlanGenerator.CodeMilitary()
    local code = [[
        package.path = package.path .. ";data/scripts/lib/?.lua"
        package.path = package.path .. ";data/scripts/?.lua"
    
        local Packs = include ("factionpacks")
        local Plans = include ("plangenerator")
            
        function run(sn, sd, vl, mt, fi, ...)

            local fac = Faction(fi)
            vl = vl or Plans.GetShipVolume()
            
            local plan = Plans.GlobalMilitaryShipPlan(fi, sn, vl, mt)
            if plan then return plan, ... end
    
            local plan = Packs.getShipPlan(fac, vl, mt)
            if plan then return plan, ... end
    
            local style = Plans.getShipStyle(fac, sn)
            plan = GeneratePlanFromStyle(style, Seed(sd), vl, 6000, 1, mt)
            return plan, ...
        end
    ]]
    return code
end

-- Carrier Military Ship
function PlanGenerator.CodeCarrier()
    local code = [[
        package.path = package.path .. ";data/scripts/lib/?.lua"
        package.path = package.path .. ";data/scripts/?.lua"
    
        local Packs = include ("factionpacks")
        local Plans = include ("plangenerator")
            
        function run(sn, sd, vl, mt, fi, ...)

            local fac = Faction(fi)
            vl = vl or Plans.GetShipVolume()
    
            local plan = Plans.GlobalCarrierPlan(fi, sn, vl, mt)
            if plan then return plan, ... end

            local plan = Packs.getCarrierPlan(fac, vl, mt)
            if plan then return plan, ... end   
    
            local style = Plans.getCarrierStyle(fac, sn)
            plan = GeneratePlanFromStyle(style, Seed(sd), vl, 6000, 1, mt)

            return plan, ...
        end
    ]]
    return code
end

-- Civilian: Miner
function PlanGenerator.CodeMiner()
    local code = [[
        package.path = package.path .. ";data/scripts/lib/?.lua"
        package.path = package.path .. ";data/scripts/?.lua"
    
        local Packs = include ("factionpacks")
        local Plans = include ("plangenerator")
            
        function run(sn, sd, vl, mt, fi, ...)

            local fac = Faction(fi)
            vl = vl or Plans.GetShipVolume()
    
            local plan = Plans.GlobalMinerPlan(fi, sn, vl, mt)
            if plan then return plan, ... end
    
            local plan = Packs.getMinerPlan(fac, vl, mt)
            if plan then return plan, ... end
            
            local style = Plans.getMinerStyle(fac, sn)
            plan = GeneratePlanFromStyle(style, Seed(sd), vl, 6000, 1, mt)

            return plan, ...
        end
    ]]
    return code
end

-- Civilian: Freighter
function PlanGenerator.CodeFreighter()
    local code = [[
        package.path = package.path .. ";data/scripts/lib/?.lua"
        package.path = package.path .. ";data/scripts/?.lua"
    
        local Packs = include ("factionpacks")
        local Plans = include ("plangenerator")
            
        function run(sn, sd, vl, mt, fi, ...)

            local fac = Faction(fi)
            vl = vl or Plans.GetShipVolume()
    
            local plan = Plans.GlobalFreighterPlan(fi, sn, vl, mt)
            if plan then return plan, ... end

            local plan = Packs.getFreighterPlan(fac, vl, mt)
            if plan then return plan, ... end   
    
            local style = Plans.getFreighterStyle(fac, sn)
            plan = GeneratePlanFromStyle(style, Seed(sd), vl, 6000, 1, mt)

            return plan, ...
        end
    ]]
    return code
end

-- Civilian: Salvager
-- Used the Miners from the default faction pack for generated ships.
function PlanGenerator.CodeSalvager()
    local code = [[
        package.path = package.path .. ";data/scripts/lib/?.lua"
        package.path = package.path .. ";data/scripts/?.lua"
    
        local Packs = include ("factionpacks")
        local Plans = include ("plangenerator")
            
        function run(sn, sd, vl, mt, fi, ...)

            local fac = Faction(fi)
            vl = vl or Plans.GetShipVolume()
    
            local plan = Plans.GlobalSalvagerPlan(fi, sn, vl, mt)
            if plan then return plan, ... end

            local plan = Packs.getMinerPlan(fac, vl, mt)
            if plan then return plan, ... end   
    
            local style = Plans.getMinerStyle(fac, sn)
            plan = GeneratePlanFromStyle(style, Seed(sd), vl, 6000, 1, mt)

            return plan, ...
        end
    ]]
    return code
end

-- Civilian: Salvager
-- Used the Miners from the default faction pack for generated ships.
function PlanGenerator.CodeCivilian()
    local code = [[
        package.path = package.path .. ";data/scripts/lib/?.lua"
        package.path = package.path .. ";data/scripts/?.lua"
    
        local Packs = include ("factionpacks")
        local Plans = include ("plangenerator")
            
        function run(sn, sd, vl, mt, fi, ...)

            local fac = Faction(fi)
            vl = vl or Plans.GetShipVolume()
    
            local plan = Plans.GlobalCivilianPlan(fi, sn, vl, mt)
            if plan then return plan, ... end

            local plan = Packs.getMinerPlan(fac, vl, mt)
            if plan then return plan, ... end   
    
            local style = Plans.getMinerStyle(fac, sn)
            plan = GeneratePlanFromStyle(style, Seed(sd), vl, 6000, 1, mt)

            return plan, ...
        end
    ]]
    return code
end

-- Civilian: Salvager
-- Used the Generic ship from the default faction pack for generated ships.
function PlanGenerator.CodeCrewTransport()
    local code = [[
        package.path = package.path .. ";data/scripts/lib/?.lua"
        package.path = package.path .. ";data/scripts/?.lua"
    
        local Packs = include ("factionpacks")
        local Plans = include ("plangenerator")
            
        function run(sn, sd, vl, mt, fi, ...)

            local fac = Faction(fi)
            vl = vl or Plans.GetShipVolume()
    
            local plan = Plans.GlobalCrewTransportPlan(fi, sn, vl, mt)
            if plan then return plan, ... end

            local plan = Packs.getShipPlan(fac, vl, mt)
            if plan then return plan, ... end   
    
            local style = Plans.getShipStyle(fac, sn)
            plan = GeneratePlanFromStyle(style, Seed(sd), vl, 6000, 1, mt)

            return plan, ...
        end
    ]]
    return code
end

--function PlanGenerator.Fighter(fi, sd, mt, sn)
--    sn = sn or Class.FighterArmed
--end

------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------- Environment ---------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------

function PlanGenerator.Gate(seed, color1, color2, color3)

    if Plan.Load("data/plans/Default/Environment/Gate 0.xml") then
         return Plan.Get()   
    else return PlanGenerator.old_makeGatePlan(seed, color1, color2, color3)
    end

end

------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------- Redirects ------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------

--[[
    Developer Notes:
    - Redirect the old generator calls to the new structure...
    - Eventually remove these and force update the code that depends on these. (When I can do more work on this)
]]
function PlanGenerator.makeShipPlan(faction, volume, styleName, material, override)
    if override == true then override = nil end
    return self.ShipAsync(nil, nil, faction, styleName, true, override)
end

function PlanGenerator.makeAsyncShipPlan(callback, values, faction, volume, styleName, material, sync, override)
    return self.ShipAsync(callback, values, faction, styleName, sync, override)
end

function PlanGenerator.makeMinerPlan(faction, volume, styleName, material, override)
    return self.ShipAsync(nil, nil, faction, "Miner", true, override)
end

function PlanGenerator.makeAsyncMinerPlan(callback, values, faction, volume, styleName, material, sync, override)
    return self.ShipAsync(callback, values, faction, "Miner", sync, override)
end

function PlanGenerator.makeFreighterPlan(faction, volume, styleName, material, override)
    return self.ShipAsync(nil, nil, faction, "Freighter", true, override)
end

function PlanGenerator.makeAsyncFreighterPlan(callback, values, faction, volume, styleName, material, sync, override)
    return self.ShipAsync(callback, values, faction, "Freighter", sync, override)
end

-- No makeCarrierPlan function
function PlanGenerator.makeAsyncCarrierPlan(callback, values, faction, volume, styleName, material, sync, override)
    return self.ShipAsync(callback, values, faction, "Carrier", sync, override)
end

function PlanGenerator.makeStationPlan(fac, sn, sd, vl, mt, o)
    return PlanGenerator.Station(fac, sn, sd, vl, mt, o)
end

function PlanGenerator.makeGatePlan(seed, color1, color2, color3)
    return self.Gate(seed, color1, color2, color3)
end
