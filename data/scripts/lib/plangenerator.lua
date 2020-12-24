local Plan = include("SDKUtilityBlockPlan")
local Designs = include("SDKGlobalDesigns")
local Rand = include("SDKUtilityRandom")
local Log = include("SDKDebugLogging")


local _ModName = "Plan Generator"
local _Debug = 0

-- Fucntion to build Methodname
function GetName(n)
    return _ModName .. " - " .. n
end

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

------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------- Plan Generator  --------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------

PlanGenerator.VolumeShips = {}
PlanGenerator.VolumeShips[1]  = 1       -- Slot 1
PlanGenerator.VolumeShips[2]  = 51      -- Slot 2: 51660m3
PlanGenerator.VolumeShips[3]  = 128     -- Slot 3: 131000m3
PlanGenerator.VolumeShips[4]  = 320     -- Slot 4
PlanGenerator.VolumeShips[5]  = 800     -- Slot 5
PlanGenerator.VolumeShips[6]  = 2000    -- Slot 6
PlanGenerator.VolumeShips[7]  = 5000    -- Slot 7
PlanGenerator.VolumeShips[8]  = 12500   -- Slot 8
PlanGenerator.VolumeShips[9]  = 19764   -- Slot 9
PlanGenerator.VolumeShips[10] = 31250   -- Slot 10
PlanGenerator.VolumeShips[11] = 43065   -- Slot 11
PlanGenerator.VolumeShips[12] = 59348   -- Slot 12
PlanGenerator.VolumeShips[13] = 78125   -- Slot 13
PlanGenerator.VolumeShips[14] = 107554  -- Slot 14
PlanGenerator.VolumeShips[15] = 148371  -- Slot 15
PlanGenerator.VolumeShips[16] = 250000  -- Titan Scale / Max Size Limit For Slot 15 
PlanGenerator.VolumeShips[17] = 500000  -- Max Size Limit for AI Titan Class

PlanGenerator.VolumeStations = {}
PlanGenerator.VolumeStations[1] = 200000
PlanGenerator.VolumeStations[2] = 300000
PlanGenerator.VolumeStations[3] = 400000
PlanGenerator.VolumeStations[4] = 600000
PlanGenerator.VolumeStations[5] = 800000
PlanGenerator.VolumeStations[6] = 1000000

-- Allows Overrideing Global Volume Scales for Ships
-- This will effect all mods that use these volumes
function PlanGenerator.OverrideVolumeShips(new)
    PlanGenerator.VolumeShips = new
end

-- Allows Overrideing Global Volume Scales for Stations
-- This will effect all mods that use these volumes
function PlanGenerator.OverrideVolumeStations(new)
    PlanGenerator.VolumeStations = new
end

function PlanGenerator.GetStationVolume(override)
    local _MethodName = GetName("Get Station Volume")

    math.random()
    local R = Random(Seed(appTimeMs()))

    local Chance = {}
    Chance[1]   = 15
    Chance[2]   = 30
    Chance[3]   = 60
    Chance[4]   = 85 
    Chance[5]   = 100 

    if override then
        Log.Debug(_MethodName, "Overriding Default Chance", _Debug)
        Chance = override
    end

    local Roll = R:getInt(1, 100)
    local Volume = 2000000000

    Log.Debug(_MethodName, "Rolled Dice: " .. tostring(Roll), _Debug)

    if Roll < Chance[1] then            
        Volume = R:getInt(PlanGenerator.VolumeStations[1], PlanGenerator.VolumeStations[2] -1)
    elseif Roll < Chance[2] then        
        Volume = R:getInt(PlanGenerator.VolumeStations[2], PlanGenerator.VolumeStations[3] -1)
    elseif Roll < Chance[3] then       
        Volume = R:getInt(PlanGenerator.VolumeStations[3], PlanGenerator.VolumeStations[4] -1)
    elseif Roll < Chance[4] then        
        Volume = R:getInt(PlanGenerator.VolumeStations[4], PlanGenerator.VolumeStations[5] -1)
    elseif Roll <= Chance[5] then        
        Volume = R:getInt(PlanGenerator.VolumeStations[5], PlanGenerator.VolumeStations[6] -1)
    else                                
        Volume = R:getInt(PlanGenerator.VolumeStations[1], PlanGenerator.VolumeStations[6])
        Log.Warning(_MethodName, "Something Went Wrong, Selecting Random Total Volume: " .. tostring(Volume))
    end

    Log.Debug(_MethodName, "Selected Volume: " .. tostring(Volume), _Debug)

    return Volume / 2

end

function PlanGenerator.MilitaryShipStyleByVolume(_Volume)
    local _Style
    if _Volume >= PlanGenerator.VolumeShips[1] and _Volume < PlanGenerator.VolumeShips[5] then             _Style = "Scout"
    elseif _Volume >= PlanGenerator.VolumeShips[6] and _Volume < PlanGenerator.VolumeShips[7] then         _Style = "Corvette"
    elseif _Volume >= PlanGenerator.VolumeShips[7] and _Volume < PlanGenerator.VolumeShips[9] then         _Style = "Frigate"
    elseif _Volume >= PlanGenerator.VolumeShips[9] and _Volume < PlanGenerator.VolumeShips[11] then        _Style = "Destroyer"
    elseif _Volume >= PlanGenerator.VolumeShips[11] and _Volume < PlanGenerator.VolumeShips[13] then       _Style = "Cruiser"
    elseif _Volume >= PlanGenerator.VolumeShips[13] and _Volume < PlanGenerator.VolumeShips[15] then       _Style = "Battleship"
    elseif _Volume >= PlanGenerator.VolumeShips[15] and _Volume < PlanGenerator.VolumeShips[16] then       _Style = "Dreadnought"
    elseif _Volume >= PlanGenerator.VolumeShips[16] then                                                   _Style = "Titan"
    end return _Style
end

function PlanGenerator.GetShipVolume(override)
    local _MethodName = GetName("Get Ship Volume")

    -- Chance Number Must be Matched with PlanGenerator.VolumeShips 
    -- Leave out the last item in PlanGenerator.VolumeShips because
    -- it will act as the upper limit for plan volume
    local Chance = {}
    Chance[1]   = 0
    Chance[2]   = 0
    Chance[3]   = 0
    Chance[4]   = 40    -- 40 Ships
    Chance[5]   = 80    -- 40 Ships
    Chance[6]   = 150   -- 70 Ships
    Chance[7]   = 300   -- 150 Ships
    Chance[8]   = 450   -- 110 Ships
    Chance[9]   = 560   -- 100 Ships
    Chance[10]  = 660   -- 100 Ships
    Chance[11]  = 740   -- 80 Ships
    Chance[12]  = 800   -- 60 Ships
    Chance[13]  = 870   -- 70 Ships
    Chance[14]  = 940   -- 70 Ships
    Chance[15]  = 995   -- 59 Ships
    Chance[16]  = 1000  -- 5 Ships / 1000 Ships

    if override then
        Log.Debug(_MethodName, "Overriding Default Chance", _Debug)
        Chance = override
    end

    local Roll = Rand.Int(1, 1000)
    local Volume = 1

    Log.Debug(_MethodName, "Rolled Dice: " .. tostring(Roll), _Debug)

    if Roll < Chance[1] then            Volume = Rand.Int(PlanGenerator.VolumeShips[1], PlanGenerator.VolumeShips[2] -1)
    elseif Roll < Chance[2] then        Volume = Rand.Int(PlanGenerator.VolumeShips[2], PlanGenerator.VolumeShips[3] -1)
    elseif Roll < Chance[3] then        Volume = Rand.Int(PlanGenerator.VolumeShips[3], PlanGenerator.VolumeShips[4] -1)
    elseif Roll < Chance[4] then        Volume = Rand.Int(PlanGenerator.VolumeShips[4], PlanGenerator.VolumeShips[5] -1)
    elseif Roll < Chance[5] then        Volume = Rand.Int(PlanGenerator.VolumeShips[5], PlanGenerator.VolumeShips[6] -1)
    elseif Roll < Chance[6] then        Volume = Rand.Int(PlanGenerator.VolumeShips[6], PlanGenerator.VolumeShips[7] -1)        
    elseif Roll < Chance[7] then        Volume = Rand.Int(PlanGenerator.VolumeShips[7], PlanGenerator.VolumeShips[8] -1)
    elseif Roll < Chance[8] then        Volume = Rand.Int(PlanGenerator.VolumeShips[8], PlanGenerator.VolumeShips[9] -1)
    elseif Roll < Chance[9] then        Volume = Rand.Int(PlanGenerator.VolumeShips[9], PlanGenerator.VolumeShips[10] -1)
    elseif Roll < Chance[10] then       Volume = Rand.Int(PlanGenerator.VolumeShips[10], PlanGenerator.VolumeShips[11] -1)
    elseif Roll < Chance[11] then       Volume = Rand.Int(PlanGenerator.VolumeShips[11], PlanGenerator.VolumeShips[12] -1)
    elseif Roll < Chance[12] then       Volume = Rand.Int(PlanGenerator.VolumeShips[12], PlanGenerator.VolumeShips[13] -1)
    elseif Roll < Chance[13] then       Volume = Rand.Int(PlanGenerator.VolumeShips[13], PlanGenerator.VolumeShips[14] -1)
    elseif Roll < Chance[14] then       Volume = Rand.Int(PlanGenerator.VolumeShips[14], PlanGenerator.VolumeShips[15] -1)
    elseif Roll < Chance[15] then       Volume = Rand.Int(PlanGenerator.VolumeShips[15], PlanGenerator.VolumeShips[16] -1)
    elseif Roll < Chance[16] then       Volume = Rand.Int(PlanGenerator.VolumeShips[16], PlanGenerator.VolumeShips[17])   
    else                                Volume = Rand.Int(PlanGenerator.VolumeShips[1], PlanGenerator.VolumeShips[15])
        Log.Warning(_MethodName, "Something Went Wrong, Selecting Random Slot Volume: " .. tostring(Volume))
    end

    Log.Debug(_MethodName, "Selected Volume: " .. tostring(Volume), _Debug)

    return Volume / 2

end

function PlanGenerator.GlobalStationPlan(_Faction, _Style, _Volume, _Material)
    local _MethodName = GetName("Global Station Plan")

    if onClient() then 
        Log.Debug(_MethodName, "Tried To Execute On Client", _Debug)
        return 
    end

    Log.Debug(_MethodName, "Value (Volume): " .. tostring(_Volume), _Debug)
    Log.Debug(_MethodName, "Value (Material): " .. tostring(_Material), _Debug)
    Log.Debug(_MethodName, "Value (Faction): " .. tostring(_Faction.index), _Debug)
    Log.Debug(_MethodName, "Loading Station Type: " .. tostring(_Style), _Debug)

    if Plan.Pick(PlanGenerator.GlobalStationTable(_Faction.index, _Style)) then
        Plan.Material(_Material, "Tier")
        Plan.Scale(_Volume)
    end
    
    return Plan.Get()

end

function PlanGenerator.GlobalMilitaryShipPlan(_FactionIndex, _Style, _Volume, _Material)
    local _MethodName = GetName("Global Ship Plan")

    if onClient() then 
        Log.Debug(_MethodName, "Tried To Execute On Client", _Debug)
        return 
    end

    -- Temp Pirate Solution. Remove when we have a dedicated Generator for Pirates
    if _Style == "Pirate" then _Volume = _Volume / 3 end
    
    Log.Debug(_MethodName, "Value (Faction): " .. tostring(_FactionIndex), _Debug)
    Log.Debug(_MethodName, "Value (Style): " .. tostring(_Style), _Debug)
    Log.Debug(_MethodName, "Value (Volume): " .. tostring(_Volume), _Debug)
    Log.Debug(_MethodName, "Value (Material): " .. tostring(_Material), _Debug)

    -- Pick New Style Randomly
    _Style = PlanGenerator.MilitaryShipStyleByVolume(_Volume)

    -- Pick A Plan And Set It Up
    if Plan.Pick(PlanGenerator.GlobalMilitaryShipTable(_FactionIndex, _Volume, _Style)) then
        Plan.Material(_Material, "Tier")
        Plan.Scale(_Volume)
    end
    
    return Plan.Get()

end

function PlanGenerator.GlobalCarrierPlan(_FactionIndex, _Style, _Volume, _Material)
    local _MethodName = GetName("Global Carrier Ship Plan")

    if onClient() then 
        Log.Debug(_MethodName, "Tried To Execute On Client", _Debug)
        return 
    end

    Log.Debug(_MethodName, "Value (Faction): " .. tostring(_FactionIndex), _Debug)
    Log.Debug(_MethodName, "Value (Style): " .. tostring(_Style), _Debug)
    Log.Debug(_MethodName, "Value (Volume): " .. tostring(_Volume), _Debug)
    Log.Debug(_MethodName, "Value (Material): " .. tostring(_Material), _Debug)
    
    if Plan.Pick(PlanGenerator.GlobalMilitaryShipTable(_FactionIndex,_Volume, _Style)) then
        Plan.Material(_Material, "Tier")
        Plan.Scale(_Volume)
    end
    
    return Plan.Get()

end

function PlanGenerator.GlobalFreighterPlan(_FactionIndex, _Style, _Volume, _Material)
    local _MethodName = GetName("Global Freighter Plan")

    if onClient() then 
        Log.Debug(_MethodName, "Tried To Execute On Client", _Debug)
        return 
    end

    Log.Debug(_MethodName, "Value (Faction): " .. tostring(_FactionIndex), _Debug)
    Log.Debug(_MethodName, "Value (Style): " .. tostring(_Style), _Debug)
    Log.Debug(_MethodName, "Value (Volume): " .. tostring(_Volume), _Debug)
    Log.Debug(_MethodName, "Value (Material): " .. tostring(_Material), _Debug)
    
    if Plan.Pick(PlanGenerator.GlobalFreighterTable(_Volume, _Style)) then
        Plan.Material(_Material, "Tier")
        Plan.Scale(_Volume)
    end
    
    return Plan.Get()

end

function PlanGenerator.GlobalMinerPlan(_FactionIndex, _Style, _Volume, _Material)
    local _MethodName = GetName("Global Freighter Plan")

    if onClient() then 
        Log.Debug(_MethodName, "Tried To Execute On Client", _Debug)
        return 
    end

    Log.Debug(_MethodName, "Value (Faction): " .. tostring(_FactionIndex), _Debug)
    Log.Debug(_MethodName, "Value (Style): " .. tostring(_Style), _Debug)
    Log.Debug(_MethodName, "Value (Volume): " .. tostring(_Volume), _Debug)
    Log.Debug(_MethodName, "Value (Material): " .. tostring(_Material), _Debug)
    
    if Plan.Pick(PlanGenerator.GlobalMinerTable(_Volume, _Style)) then
        Plan.Material(_Material, "Tier")
        Plan.Scale(_Volume)
    end
    
    return Plan.Get()

end

function PlanGenerator.GlobalStationTable(_FactionIndex, _Style)
    local _MethodName = GetName("Global Station Table")

    if onClient() then 
        Log.Debug(_MethodName, "Tried To Execute On Client", _Debug)
        return 
    end

    -- Get Faction Pack Stations
    local _Table = Designs.FactionStation(_FactionIndex, _Style)

    -- Return Faction Pack Table or Fallback to Global Designs
    if _Table and #_Table ~= 0 then return _Table end

    Log.Debug(_MethodName, "No Faction Design, Searching For Global Design...", _Debug)

    -- Global Default Fallback
    _Table = Designs.Stations

    -- Global Designs
    if _Style == "Shipyard" then                 _Table = Designs.Shipyards
    elseif _Style == "RepairDock" then           _Table = Designs.RepairDocks
    elseif _Style == "ResourceDepot" then        _Table = Designs.ResourceDepots
    elseif _Style == "TradingPost" then          _Table = Designs.TradingPosts
    elseif _Style == "EquipmentDock" then        _Table = Designs.EquipmentDocks
    elseif _Style == "SmugglersMarket" then      _Table = Designs.SmugglersMarkets
    elseif _Style == "Scrapyard" then            _Table = Designs.Scrapyards
    elseif _Style == "Mine" then                 _Table = Designs.Mines
    elseif _Style == "Factory" then              _Table = Designs.Factories
    elseif _Style == "FighterFactory" then       _Table = Designs.FighterFactories
    elseif _Style == "TurretFactory" then        _Table = Designs.TurretFactories
    elseif _Style == "SolarPowerPlant" then      _Table = Designs.SolarPowerPlants
    elseif _Style == "Farm" then                 _Table = Designs.Farms
    elseif _Style == "Ranch" then                _Table = Designs.Ranches
    elseif _Style == "Collector" then            _Table = Designs.Collectors
    elseif _Style == "Biotope" then              _Table = Designs.Biotopes
    elseif _Style == "Casino" then               _Table = Designs.Casinos
    elseif _Style == "Habitat" then              _Table = Designs.Habitats
    elseif _Style == "MilitaryOutpost" then      _Table = Designs.MilitaryOutposts
    elseif _Style == "Headquarters" then         _Table = Designs.Headquarters
    elseif _Style == "ResearchStation" then      _Table = Designs.ResearchStations
    elseif _Style == "Default" then              _Table = Designs.Stations
    elseif _Style then Log.Info(_MethodName, "[TRACKER#1] New/Untracked Staion Style: " .. tostring(_Style))  
    end
    

    -- Fallback To Generic Stations
    if #_Table == 0 then
        Log.Warning(_MethodName, "[" .. tostring(_Style) .. "] No Designs were returned. Attempting to use a generic station design.")
        
        _Table = Designs.Stations if #_Table == 0 then
            Log.Debug(_MethodName, tostring(#_Table) .. " Global Generic Stations Loaded")
            Log.Warning(_MethodName, "[" .. tostring(_Style) .. "] No Generic Designs. Using The Games Generator.")            
        end
    end

    return _Table

end

function PlanGenerator.GlobalMilitaryShipTable(_FactionIndex, _Volume, _Style)
    local _MethodName = GetName("Global Ship Table")
    Log.Debug(_MethodName, "Arg Style: " .. tostring(_Style))

    if not _Style then _Style = PlanGenerator.MilitaryShipStyleByVolume(_Volume) end

    -- Get Faction Pack Ships
    local _Table = Designs.FactionShip(_FactionIndex, _Style)

    -- Return Faction Pack Table or Fallback to Global Designs
    if _Table and #_Table ~= 0 then return _Table end

    -- Default Table
    local _Table = Designs.Destroyers

    -- Pick From Global Designs
    if _Style == "Scout" then               _Table = Designs.Scouts
    elseif _Style == "Corvette" then        _Table = Designs.Corvettes
    elseif _Style == "Frigate" then         _Table = Designs.Frigates
    elseif _Style == "Destroyer" then       _Table = Designs.Destroyers
    elseif _Style == "Cruiser" then         _Table = Designs.Cruisers
    elseif _Style == "Battleship" then      _Table = Designs.Battleships
    elseif _Style == "Dreadnought" then     _Table = Designs.Dreadnoughts
    elseif _Style == "Titan" then           _Table = Designs.Titans
    elseif _Style == "Carrier" then         _Table = Designs.Carriers
    end

    return _Table

end

function PlanGenerator.GlobalFreighterTable(_Volume, _Style)
    local _MethodName = GetName("Global Ship Table")

    local _Table = Designs.MediumFreighters

    if _Volume >= PlanGenerator.VolumeShips[1] and _Volume < PlanGenerator.VolumeShips[7] then          -- Small
        _Table = Designs.SmallFreighters
    elseif _Volume >= PlanGenerator.VolumeShips[7] and _Volume < PlanGenerator.VolumeShips[10] then     -- Medium
        _Table = Designs.MediumFreighters
    elseif _Volume >= PlanGenerator.VolumeShips[10] then                                                -- Large
        _Table = Designs.LargeFreighters
    end

    return _Table

end

function PlanGenerator.GlobalMinerTable(_Volume, _Style)
    local _MethodName = GetName("Global Miner Table")

    local _Table = Designs.MediumMiners

    if _Volume >= PlanGenerator.VolumeShips[1] and _Volume < PlanGenerator.VolumeShips[5] then          -- Mini
        _Table = Designs.SmallMiners
    elseif _Volume >= PlanGenerator.VolumeShips[5] and _Volume < PlanGenerator.VolumeShips[9] then      -- Small
        _Table = Designs.SmallMiners
    elseif _Volume >= PlanGenerator.VolumeShips[9] and _Volume < PlanGenerator.VolumeShips[12] then     -- Medium
        _Table = Designs.MediumMiners
    elseif _Volume >= PlanGenerator.VolumeShips[12] then                                                -- Large
        _Table = Designs.LargeMiners
    end

    return _Table

end

------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------- Station Plan ---------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------

function PlanGenerator.makeStationPlan(faction, styleName, seed, volume, material, overridevolume) local _MethodName = GetName("Make Station Plan")

    Log.Debug(_MethodName, "Value (Faction): " .. tostring(faction.index) .. " = " .. tostring(faction.name), _Debug)
    Log.Debug(_MethodName, "Value (Style): " .. tostring(styleName), _Debug)
    Log.Debug(_MethodName, "Value (Volume): " .. tostring(volume), _Debug)
    Log.Debug(_MethodName, "Value (Material): " .. tostring(material), _Debug)

    -- default the volume override to true allowing randomized volumes by chance
    -- set to true to use the passed volume in the function
    if not overridevolume or overridevolume == false then volume = PlanGenerator.GetStationVolume() end
    
    -- If using function value, make sure its set.
    if not volume then volume = PlanGenerator.GetStationVolume() end

    -- Mines don't need to be huge.
    if styleName == "Mine" then volume = 150000 end

    seed = seed or math.random(0xffffffff)
    material = material or PlanGenerator.selectMaterial(faction)

    Log.Debug(_MethodName, "Selected (Material): " .. tostring(material), _Debug)

    -- Try Faction Packs First
    local plan = FactionPacks.getStationPlan(faction, volume, material, styleName)
    if plan then plan:scale(vec3(3, 3, 3)) end
    if plan then return plan end

    -- Then Try Global Plans Second
    local plan = PlanGenerator.GlobalStationPlan(faction, styleName, volume, material)
    if plan then plan:scale(vec3(3, 3, 3)) return plan, seed, volume, material end

    -- Unfortunatly Use The Game Generator
    local style = PlanGenerator.getStationStyle(faction, styleName)
    local plan = GeneratePlanFromStyle(style, Seed(seed), volume, 10000, nil, material)
    plan:scale(vec3(3, 3, 3))

    return plan, seed, volume, material

end

------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------ Standard Ship ---------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------

function PlanGenerator.makeShipPlan(faction, volume, styleName, material, autooverride)
    return PlanGenerator.makeAsyncShipPlan(nil, nil, faction, volume, styleName, material, true, autooverride)
end

function PlanGenerator.makeAsyncShipPlan(callback, values, faction, volume, styleName, material, sync, overridevolume)
    local _MethodName = GetName("Make Async Ship Plan")

    Log.Debug(_MethodName, "Override = " .. tostring(overridevolume), _Debug)
    -- default the volume override to true allowing randomized volumes by chance
    -- set to true to use the passed volume in the function
    if not overridevolume or overridevolume == false then
        volume = PlanGenerator.GetShipVolume() 
    end

    Log.Debug("Plan Generator - Make Ship Plan (Code)", "Function Volume: " .. tostring(volume), _Debug)
    local seed = math.random(0xffffffff)

    if not material then
        material = PlanGenerator.selectMaterial(faction)
    end
    
    local code = [[
        package.path = package.path .. ";data/scripts/lib/?.lua"
        package.path = package.path .. ";data/scripts/?.lua"
    
        local FactionPacks = include ("factionpacks")
        local PlanGenerator = include ("plangenerator")
        local Log = include("SDKDebugLogging")
    
        function run(styleName, seed, volume, material, factionIndex, ...)
    
            --Log.Debug("Plan Generator - Make Async Ship Plan (Code)", "Function Volume: " .. tostring(volume), 1)
    
            local faction = Faction(factionIndex)
            volume = volume or PlanGenerator.GetShipVolume()
    
            --Log.Debug("Plan Generator - Make Async Ship Plan (Code)", "Using Volume: " .. tostring(volume), 1)
    
            local plan = FactionPacks.getShipPlan(faction, volume, material)
            if plan then return plan, ... end
    
            local plan = PlanGenerator.GlobalMilitaryShipPlan(factionIndex, styleName, volume, material)
            if plan then return plan, ... end
    
            local style = PlanGenerator.getShipStyle(faction, styleName)
            plan = GeneratePlanFromStyle(style, Seed(seed), volume, 6000, 1, material)
            return plan, ...
        end
    ]]

    if sync then
        return execute(code, styleName, seed, volume, material, faction.index)
    else
        values = values or {}
        async(callback, code, styleName, seed, volume, material, faction.index, unpack(values))
    end
end

------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------- Miner Plan -----------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------

function PlanGenerator.makeMinerPlan(faction, volume, styleName, material, autooverride)
    return PlanGenerator.makeAsyncMinerPlan(nil, nil, faction, volume, styleName, material, true, autooverride)
end

function PlanGenerator.makeAsyncMinerPlan(callback, values, faction, volume, styleName, material, sync, overridevolume)
    local _MethodName = GetName("Make Async Miner Plan")

    Log.Debug(_MethodName, "Override = " .. tostring(overridevolume), _Debug)

    -- default the volume override to true allowing randomized volumes by chance
    -- set to true to use the passed volume in the function
    if not overridevolume or overridevolume == false then
        volume = PlanGenerator.GetShipVolume() 
    end

    local seed = math.random(0xffffffff)

    if not material then
        material = PlanGenerator.selectMaterial(faction)
    end

    local code = [[
        package.path = package.path .. ";data/scripts/lib/?.lua"
        package.path = package.path .. ";data/scripts/?.lua"

        local FactionPacks = include ("factionpacks")
        local PlanGenerator = include ("plangenerator")
        local Log = include("SDKDebugLogging")

        function run(styleName, seed, volume, material, factionIndex, ...)

            Log.Debug("Plan Generator - Make Async Miner Plan (Code)", "Function Volume: " .. tostring(volume), 1)

            local faction = Faction(factionIndex)        
            volume = volume or PlanGenerator.GetShipVolume()

            local plan = FactionPacks.getMinerPlan(faction, volume, material)
            if plan then return plan, ... end

            local plan = PlanGenerator.GlobalMinerPlan(factionIndex, styleName, volume, material)
            if plan then return plan, ... end

            local style = PlanGenerator.getMinerStyle(faction, styleName)
            local plan = GeneratePlanFromStyle(style, Seed(seed), volume, 5000, 1, material)

            return plan, ...
        end
    ]]

    if sync then
        return execute(code, styleName, seed, volume, material, faction.index)
    else
        values = values or {}
        async(callback, code, styleName, seed, volume, material, faction.index, unpack(values))
    end
end

------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------- Freighter Plan ---------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------

function PlanGenerator.makeFreighterPlan(faction, volume, styleName, material, autooverride)
    return PlanGenerator.makeAsyncFreighterPlan(nil, nil, faction, volume, styleName, material, true, autooverride)
end

function PlanGenerator.makeAsyncFreighterPlan(callback, values, faction, volume, styleName, material, sync, overridevolume)
    local _MethodName = GetName("Make Async Freighter Plan")

    Log.Debug(_MethodName, "Override = " .. tostring(overridevolume), _Debug)

    -- default the volume override to true allowing randomized volumes by chance
    -- set to true to use the passed volume in the function
    if not overridevolume or overridevolume == false then
        volume = PlanGenerator.GetShipVolume() 
    end

    local seed = math.random(0xffffffff)

    if not material then
        material = PlanGenerator.selectMaterial(faction)
    end

    local code = [[
        package.path = package.path .. ";data/scripts/lib/?.lua"
        package.path = package.path .. ";data/scripts/?.lua"

        local FactionPacks = include ("factionpacks")
        local PlanGenerator = include ("plangenerator")
        local Log = include("SDKDebugLogging")

        function run(styleName, seed, volume, material, factionIndex, ...)

            --Log.Debug("Plan Generator - Make Async Freighter Plan (Code)", "Function Volume: " .. tostring(volume), 1)

            local faction = Faction(factionIndex)
            volume = volume or PlanGenerator.GetShipVolume()            

            local plan = FactionPacks.getFreighterPlan(faction, volume, material)
            if plan then return plan, ... end

            local plan = PlanGenerator.GlobalFreighterPlan(factionIndex, styleName, volume, material)
            if plan then return plan, ... end

            --Log.Debug("Plan Generator - Make Async Freighter Plan (Code)", "Using Volume: " .. tostring(volume), 1)

            local style = PlanGenerator.getFreighterStyle(faction, styleName)
            local plan = GeneratePlanFromStyle(style, Seed(seed), volume, 5000, nil, material)

            return plan, ...
        end
    ]]

    if sync then
        return execute(code, styleName, seed, volume, material, faction.index)
    else
        values = values or {}
        async(callback, code, styleName, seed, volume, material, faction.index, unpack(values))
    end
end

------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------ Carrier Plan ----------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------

function PlanGenerator.makeAsyncCarrierPlan(callback, values, faction, volume, styleName, material, sync, overridevolume)
    local _MethodName = GetName("Make Async Carrier Plan")

    -- default the volume override to true allowing randomized volumes by chance
    -- set to true to use the passed volume in the function
    if not overridevolume or overridevolume == false then
        volume = PlanGenerator.GetShipVolume() 
    end

    local seed = math.random(0xffffffff)

    if not material then
        material = PlanGenerator.selectMaterial(faction)
    end

    local code = [[
        package.path = package.path .. ";data/scripts/lib/?.lua"
        package.path = package.path .. ";data/scripts/?.lua"

        local FactionPacks = include ("factionpacks")
        local PlanGenerator = include ("plangenerator")
        local Log = include("SDKDebugLogging")

        function run(styleName, seed, volume, material, factionIndex, ...)

            --Log.Debug("Plan Generator - Make Async Carrier Plan (Code)", "Function Volume: " .. tostring(volume), 1)

            local faction = Faction(factionIndex)
            volume = volume or PlanGenerator.GetShipVolume()   

            local plan = FactionPacks.getCarrierPlan(faction, volume, material)
            if plan then return plan, ... end

            local plan = PlanGenerator.GlobalCarrierPlan(factionIndex, styleName, volume, material)
            if plan then return plan, ... end

            local style = PlanGenerator.getCarrierStyle(faction, styleName)
            local plan = GeneratePlanFromStyle(style, Seed(seed), volume, 5000, nil, material)

            --Log.Debug("Plan Generator - Make Async Carrier Plan (Code)", "Using Volume: " .. tostring(volume), 1)

            return plan, ...
        end
    ]]

    if sync then
        return execute(code, styleName, seed, volume, material, faction.index)
    else
        values = values or {}
        async(callback, code, styleName, seed, volume, material, faction.index, unpack(values))
    end
end