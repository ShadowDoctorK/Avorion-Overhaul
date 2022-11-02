--[[
    Developer Notes:
    - Divide Carriers Into Different Sizes: Small, Med, Large, Huge
]]

local Class = include("SDKGlobalDesigns - Classes")
local Rand = include("SDKUtilityRandom")
local Log = include("SDKDebugLogging")

Log.ModName = "Global Designs"
Log.Debugging = 0

SDKGlobalDesigns = {}
local self = SDKGlobalDesigns
SDKGlobalDesigns.Log = Log

SDKGlobalDesigns.PackNames ={}
SDKGlobalDesigns.Packs = {}

-- Global Stations
SDKGlobalDesigns.Stations = {}              SDKGlobalDesigns.Shipyards = {}
SDKGlobalDesigns.RepairDocks = {}           SDKGlobalDesigns.ResourceDepots = {} 
SDKGlobalDesigns.TradingPosts = {}          SDKGlobalDesigns.EquipmentDocks = {}
SDKGlobalDesigns.SmugglersMarkets = {}      SDKGlobalDesigns.Scrapyards = {}
SDKGlobalDesigns.Mines = {}                 SDKGlobalDesigns.IceMines = {}
SDKGlobalDesigns.Factories = {}             SDKGlobalDesigns.FighterFactories = {}
SDKGlobalDesigns.TurretFactories = {}       SDKGlobalDesigns.SolarPowerPlants = {} 
SDKGlobalDesigns.Farms = {}                 SDKGlobalDesigns.Ranches = {}
SDKGlobalDesigns.Collectors = {}            SDKGlobalDesigns.Biotopes = {}
SDKGlobalDesigns.Casinos = {}               SDKGlobalDesigns.Habitats = {}
SDKGlobalDesigns.MilitaryOutposts = {}      SDKGlobalDesigns.Headquarters = {}
SDKGlobalDesigns.ResearchStations = {}      SDKGlobalDesigns.TravelHubs = {}  

-- Global Military Ships
SDKGlobalDesigns.Scouts = {}                
SDKGlobalDesigns.Corvettes = {}
SDKGlobalDesigns.Frigates = {}
SDKGlobalDesigns.Destroyers = {}
SDKGlobalDesigns.Cruisers = {}
SDKGlobalDesigns.Battleships = {}
SDKGlobalDesigns.Dreadnoughts = {}
SDKGlobalDesigns.Titans = {}

-- Global Carriers
SDKGlobalDesigns.Carriers = {}

-- Global Fighters
SDKGlobalDesigns.FightersCrew = {}
SDKGlobalDesigns.FightersCargo = {}
SDKGlobalDesigns.FightersArmed = {}
SDKGlobalDesigns.FightersUnamred = {}

-- Global Civial Ships
SDKGlobalDesigns.SmallFreighters = {}
SDKGlobalDesigns.MediumFreighters = {}
SDKGlobalDesigns.LargeFreighters = {}
SDKGlobalDesigns.HugeFreighters = {}

SDKGlobalDesigns.SmallMiners = {}
SDKGlobalDesigns.MediumMiners = {}
SDKGlobalDesigns.LargeMiners = {}
SDKGlobalDesigns.HugeMiners = {}

SDKGlobalDesigns.SmallSalvagers = {}
SDKGlobalDesigns.MediumSalvagers = {}
SDKGlobalDesigns.LargeSalvagers = {}
SDKGlobalDesigns.HugeSalvagers = {}

SDKGlobalDesigns.CrewTransports = {}
SDKGlobalDesigns.CruiseShips = {}
SDKGlobalDesigns.Drones = {}
SDKGlobalDesigns.Civilians = {}

-- Global Background Items
SDKGlobalDesigns.Satalites = {}
SDKGlobalDesigns.Gates = {}
SDKGlobalDesigns.Containers = {}

-- Station Loading
function SDKGlobalDesigns.AddStation(t)            if not self.Stations[t] then if self.CheckPath(t) then table.insert(self.Stations, t) end end end
function SDKGlobalDesigns.AddShipyard(t)           if not self.Shipyards[t] then if self.CheckPath(t) then  table.insert(self.Shipyards, t) end end end
function SDKGlobalDesigns.AddRepairDock(t)         if not self.RepairDocks[t] then if self.CheckPath(t) then  table.insert(self.RepairDocks, t) end end end
function SDKGlobalDesigns.AddResourceDepot(t)      if not self.ResourceDepots[t] then if self.CheckPath(t) then  table.insert(self.ResourceDepots, t) end end end
function SDKGlobalDesigns.AddTradingPost(t)        if not self.TradingPosts[t] then if self.CheckPath(t) then  table.insert(self.TradingPosts, t) end end end
function SDKGlobalDesigns.AddEquipmentDock(t)      if not self.EquipmentDocks[t] then if self.CheckPath(t) then  table.insert(self.EquipmentDocks, t) end end end
function SDKGlobalDesigns.AddSmugglersMarket(t)    if not self.SmugglersMarkets[t] then if self.CheckPath(t) then  table.insert(self.SmugglersMarkets, t) end end end
function SDKGlobalDesigns.AddScrapyard(t)          if not self.Scrapyards[t] then if self.CheckPath(t) then  table.insert(self.Scrapyards, t) end end end
function SDKGlobalDesigns.AddMine(t)               if not self.Mines[t] then if self.CheckPath(t) then  table.insert(self.Mines, t) end end end
function SDKGlobalDesigns.AddIceMine(t)            if not self.IceMines[t] then if self.CheckPath(t) then  table.insert(self.IceMines, t) end end end
function SDKGlobalDesigns.AddFactory(t)            if not self.Factories[t] then if self.CheckPath(t) then  table.insert(self.Factories, t) end end end
function SDKGlobalDesigns.AddFighterFactory(t)     if not self.FighterFactories[t] then if self.CheckPath(t) then  table.insert(self.FighterFactories, t) end end end
function SDKGlobalDesigns.AddTurretFactory(t)      if not self.TurretFactories[t] then if self.CheckPath(t) then  table.insert(self.TurretFactories, t) end end end
function SDKGlobalDesigns.AddSolarPowerPlant(t)    if not self.SolarPowerPlants[t] then if self.CheckPath(t) then  table.insert(self.SolarPowerPlants, t) end end end
function SDKGlobalDesigns.AddFarm(t)               if not self.Farms[t] then if self.CheckPath(t) then  table.insert(self.Farms, t) end end end
function SDKGlobalDesigns.AddRanch(t)              if not self.Ranches[t] then if self.CheckPath(t) then  table.insert(self.Ranches, t) end end end
function SDKGlobalDesigns.AddCollector(t)          if not self.Collectors[t] then if self.CheckPath(t) then  table.insert(self.Collectors, t) end end end
function SDKGlobalDesigns.AddBiotope(t)            if not self.Biotopes[t] then if self.CheckPath(t) then  table.insert(self.Biotopes, t) end end end
function SDKGlobalDesigns.AddCasino(t)             if not self.Casinos[t] then if self.CheckPath(t) then  table.insert(self.Casinos, t) end end end
function SDKGlobalDesigns.AddHabitat(t)            if not self.Habitats[t] then if self.CheckPath(t) then  table.insert(self.Habitats, t) end end end
function SDKGlobalDesigns.AddMilitaryOutpost(t)    if not self.MilitaryOutposts[t] then if self.CheckPath(t) then  table.insert(self.MilitaryOutposts, t) end end end
function SDKGlobalDesigns.AddHeadquarter(t)        if not self.Headquarters[t] then if self.CheckPath(t) then  table.insert(self.Headquarters, t) end end end
function SDKGlobalDesigns.AddResearchStation(t)    if not self.ResearchStations[t] then if self.CheckPath(t) then  table.insert(self.ResearchStations, t) end end end
function SDKGlobalDesigns.AddTravelHubStation(t)   if not self.TravelHubs[t] then if self.CheckPath(t) then  table.insert(self.TravelHubs, t) end end end

-- Ship Loading
function SDKGlobalDesigns.AddScout(t)              if not self.Scouts[t] then if self.CheckPath(t) then  table.insert(self.Scouts, t) end end end
function SDKGlobalDesigns.AddCorvette(t)           if not self.Corvettes[t] then if self.CheckPath(t) then  table.insert(self.Corvettes, t) end end end
function SDKGlobalDesigns.AddFrigate(t)            if not self.Frigates[t] then if self.CheckPath(t) then  table.insert(self.Frigates, t) end end end
function SDKGlobalDesigns.AddDestroyer(t)          if not self.Destroyers[t] then if self.CheckPath(t) then  table.insert(self.Destroyers, t) end end end
function SDKGlobalDesigns.AddCruiser(t)            if not self.Cruisers[t] then if self.CheckPath(t) then  table.insert(self.Cruisers, t) end end end
function SDKGlobalDesigns.AddBattleship(t)         if not self.Battleships[t] then if self.CheckPath(t) then  table.insert(self.Battleships, t) end end end
function SDKGlobalDesigns.AddDreadnought(t)        if not self.Dreadnoughts[t] then if self.CheckPath(t) then  table.insert(self.Dreadnoughts, t) end end end
function SDKGlobalDesigns.AddTitan(t)              if not self.Titans[t] then if self.CheckPath(t) then  table.insert(self.Titans, t) end end end
function SDKGlobalDesigns.AddCarrier(t)            if not self.Carriers[t] then if self.CheckPath(t) then  table.insert(self.Carriers, t) end end end

function SDKGlobalDesigns.AddFighterArmed(t)       if not self.FightersArmed[t] then if self.CheckPath(t) then  table.insert(self.FightersArmed, t) end end end
function SDKGlobalDesigns.AddFighterUnarmed(t)     if not self.FightersUnamred[t] then if self.CheckPath(t) then  table.insert(self.FightersUnamred, t) end end end
function SDKGlobalDesigns.AddFighterCrew(t)        if not self.FightersCrew[t] then if self.CheckPath(t) then  table.insert(self.FightersCrew, t) end end end
function SDKGlobalDesigns.AddFighterCargo(t)       if not self.FightersCargo[t] then if self.CheckPath(t) then  table.insert(self.FightersCargo, t) end end end

function SDKGlobalDesigns.AddSmallFreighter(t)     if not self.SmallFreighters[t] then if self.CheckPath(t) then  table.insert(self.SmallFreighters, t) end end end
function SDKGlobalDesigns.AddMediumFreighter(t)    if not self.MediumFreighters[t] then if self.CheckPath(t) then  table.insert(self.MediumFreighters, t) end end end
function SDKGlobalDesigns.AddLargeFreighter(t)     if not self.LargeFreighters[t] then if self.CheckPath(t) then  table.insert(self.LargeFreighters, t) end end end
function SDKGlobalDesigns.AddHugeFreighter(t)      if not self.HugeFreighters[t] then if self.CheckPath(t) then  table.insert(self.HugeFreighters, t) end end end

function SDKGlobalDesigns.AddSmallMiner(t)         if not self.SmallMiners[t] then if self.CheckPath(t) then  table.insert(self.SmallMiners, t) end end end
function SDKGlobalDesigns.AddMediumMiner(t)        if not self.MediumMiners[t] then if self.CheckPath(t) then  table.insert(self.MediumMiners, t) end end end
function SDKGlobalDesigns.AddLargeMiner(t)         if not self.LargeMiners[t] then if self.CheckPath(t) then  table.insert(self.LargeMiners, t) end end end
function SDKGlobalDesigns.AddHugeMiner(t)          if not self.HugeMiners[t] then if self.CheckPath(t) then  table.insert(self.HugeMiners, t) end end end

function SDKGlobalDesigns.AddSmallSalvager(t)      if not self.SmallSalvagers[t] then if self.CheckPath(t) then  table.insert(self.SmallSalvagers, t) end end end
function SDKGlobalDesigns.AddMediumSalvager(t)     if not self.MediumSalvagers[t] then if self.CheckPath(t) then  table.insert(self.MediumSalvagers, t) end end end
function SDKGlobalDesigns.AddLargeSalvager(t)      if not self.LargeSalvagers[t] then if self.CheckPath(t) then  table.insert(self.LargeSalvagers, t) end end end
function SDKGlobalDesigns.AddHugeSalvager(t)       if not self.HugeSalvagers[t] then if self.CheckPath(t) then  table.insert(self.HugeSalvagers, t) end end end

function SDKGlobalDesigns.AddCrewTransport(t)      if not self.CrewTransports[t] then if self.CheckPath(t) then  table.insert(self.CrewTransports, t) end end end
function SDKGlobalDesigns.AddCruiseShip(t)         if not self.CruiseShips[t] then if self.CheckPath(t) then  table.insert(self.CruiseShips, t) end end end
function SDKGlobalDesigns.AddDrone(t)              if not self.Drones[t] then if self.CheckPath(t) then  table.insert(self.Drones, t) end end end
function SDKGlobalDesigns.AddCivilian(t)           if not self.Civilians[t] then if self.CheckPath(t) then  table.insert(self.Civilians, t) end end end

-- Background Item Loading
function SDKGlobalDesigns.AddSatalite(t)           if not self.Satalites[t] then if self.CheckPath(t) then  table.insert(self.Satalites, t) end end end
function SDKGlobalDesigns.AddGate(t)               if not self.Gates[t] then if self.CheckPath(t) then  table.insert(self.Gates, t) end end end
function SDKGlobalDesigns.AddContainer(t)          if not self.Containers[t] then if self.CheckPath(t) then  table.insert(self.Containers, t) end end end



function SDKGlobalDesigns.CheckPath(_Path) local _Method = "Check Path"
    if string.match(_Path, ".xml") then 
        --Log.Debug(_Method, "Adding: " .. tostring(_Path)) 
        return true
    else 
        if _Path ~= "" then 
            Log.Error(_Method, "Invalid Path: " .. tostring(_Path), 1) 
            return false 
        end 
    end
end

function SDKGlobalDesigns.Get(_Name) local _Method = "Get"

    -- Stations
    if _Name == "Station" then                  return SDKGlobalDesigns.Stations
    elseif _Name == "Shipyard" then             return SDKGlobalDesigns.Shipyards
    elseif _Name == "RepairDock" then           return SDKGlobalDesigns.RepairDocks
    elseif _Name == "ResourceDepot" then        return SDKGlobalDesigns.ResourceDepots
    elseif _Name == "TradingPost" then          return SDKGlobalDesigns.TradingPosts
    elseif _Name == "EquipmentDock" then        return SDKGlobalDesigns.EquipmentDocks
    elseif _Name == "SmugglersMarket" then      return SDKGlobalDesigns.SmugglersMarkets
    elseif _Name == "Scrapyard" then            return SDKGlobalDesigns.Scrapyards
    elseif _Name == "Mine" then                 return SDKGlobalDesigns.Mines
    elseif _Name == "IceMine" then              return SDKGlobalDesigns.IceMines
    elseif _Name == "Factories" then            return SDKGlobalDesigns.Factories
    elseif _Name == "FighterFactories" then     return SDKGlobalDesigns.FighterFactories
    elseif _Name == "TurretFactories" then      return SDKGlobalDesigns.TurretFactories
    elseif _Name == "SolarPowerPlants " then    return SDKGlobalDesigns.SolarPowerPlants
    elseif _Name == "Farm" then                 return SDKGlobalDesigns.Farms
    elseif _Name == "Ranche" then               return SDKGlobalDesigns.Ranches
    elseif _Name == "Collector" then            return SDKGlobalDesigns.Collectors
    elseif _Name == "Biotope" then              return SDKGlobalDesigns.Biotopes
    elseif _Name == "Casino" then               return SDKGlobalDesigns.Casinos
    elseif _Name == "Habitat" then              return SDKGlobalDesigns.Habitats
    elseif _Name == "MilitaryOutpost" then      return SDKGlobalDesigns.MilitaryOutposts
    elseif _Name == "Headquarter" then          return SDKGlobalDesigns.Headquarters
    elseif _Name == "ResearchStation" then      return SDKGlobalDesigns.ResearchStations
    elseif _Name == "TravelHub" then            return SDKGlobalDesigns.TravelHubs

    -- Military Ships
    elseif _Name == Class.Scout then            return SDKGlobalDesigns.Scouts
    elseif _Name == Class.Corvette then         return SDKGlobalDesigns.Corvettes
    elseif _Name == Class.Frigate then          return SDKGlobalDesigns.Frigates
    elseif _Name == Class.Destroyer then        return SDKGlobalDesigns.Destroyers
    elseif _Name == Class.Cruiser then          return SDKGlobalDesigns.Cruisers
    elseif _Name == Class.Battleship then       return SDKGlobalDesigns.Battleships
    elseif _Name == Class.Dreadnought then      return SDKGlobalDesigns.Dreadnoughts
    elseif _Name == Class.Titan then            return SDKGlobalDesigns.Titans
    elseif _Name == Class.Carrier then          return SDKGlobalDesigns.Carriers

    -- Fighters
    elseif _Name == "FightersCrew" then         return SDKGlobalDesigns.FightersCrew
    elseif _Name == "FightersCargo" then        return SDKGlobalDesigns.FightersCargo
    elseif _Name == "FightersArmed" then        return SDKGlobalDesigns.FightersArmed
    elseif _Name == "FightersUnamred" then      return SDKGlobalDesigns.FightersUnamred

    -- Civilian Ships
    elseif _Name == Class.FreighterS then       return SDKGlobalDesigns.SmallFreighters
    elseif _Name == Class.FreighterM then       return SDKGlobalDesigns.MediumFreighters
    elseif _Name == Class.FreighterL then       return SDKGlobalDesigns.LargeFreighters
    elseif _Name == Class.FreighterH then       return SDKGlobalDesigns.HugeFreighters
    elseif _Name == Class.MinerS then           return SDKGlobalDesigns.SmallMiners
    elseif _Name == Class.MinerM then           return SDKGlobalDesigns.MediumMiners
    elseif _Name == Class.MinerL then           return SDKGlobalDesigns.LargeMiners
    elseif _Name == Class.MinerH then           return SDKGlobalDesigns.HugeMiners
    elseif _Name == Class.SalvagerS then        return SDKGlobalDesigns.SmallSalvagers
    elseif _Name == Class.SalvagerM then        return SDKGlobalDesigns.MediumSalvagers
    elseif _Name == Class.SalvagerL then        return SDKGlobalDesigns.LargeSalvagers
    elseif _Name == Class.SalvagerH then        return SDKGlobalDesigns.HugeSalvagers
    elseif _Name == Class.CruiseShip then       return SDKGlobalDesigns.CruiseShips
    elseif _Name == Class.CrewTransport then    return SDKGlobalDesigns.CrewTransports
    elseif _Name == Class.Drone then            return SDKGlobalDesigns.Drones
    elseif _Name == Class.Civilian then         return SDKGlobalDesigns.Civilians

    -- Environment
    elseif _Name == Class.Gate then             return SDKGlobalDesigns.Gates
    elseif _Name == Class.Satalite then         return SDKGlobalDesigns.Satalites
    elseif _Name == Class.Container then        return SDKGlobalDesigns.Containers

    else self.Log.Warning(_Method, tostring(_Name) .. ": is not a valid collection of designs. Returning nil.")
    end return nil
end

-- These factions wont have a dedicated set up designs.
SDKGlobalDesigns.Forbidden = {
    "Pirate",
    "The Brotherhood",
    "The Xsotan",
    "Xsotan",
    "The Cavalier",
    "The AI",    
}

function SDKGlobalDesigns.IsForbidden(_FactionName)    
    for i = 1, #self.Forbidden do
        if string.match(_FactionName, self.Forbidden[i]) then return true end
    end return false
end

function SDKGlobalDesigns.FactionDesigns(_FactionIndex) local _Method = "Faction Designs"

    --self.Log.Debug(_Method, "Faction Index: " .. tostring(_FactionIndex))

    -- If Debugging Enabled Print Pack Information
    if self.Log.Debugging == 1 then
        for i = 1, #self.PackNames do self.Log.Debug(_Method, "Pack: " .. self.PackNames[i])
            --if self.Packs[self.PackNames[i]] then self.Log.Debug(_Method, "Pack Is Loaded and Ready") end
        end
    end

    local _Faction = Faction(_FactionIndex)
    if not _Faction then return nil end

    -- Pirates use the Global Pool since they pretty much use the ships they steal.
    if self.IsForbidden(_Faction.name) then self.Log.Debug(_Method, tostring(_Faction.name) .. ": Returing To Global Pool. Faction Does Not Get Assigned Packs.") return nil end

    local _Pack = _Faction:getValue("SDKGlobalPack")
    if _Pack == 1 then _Pack = nil end

    --self.Log.Debug(_Method, "Pulled Faction Pack: " .. tostring(_Pack))

    -- Check/Reassign Pack Assignment
    if not _Pack then
        if self.PackNames and #self.PackNames ~= 0 then 
            local Assign = Rand.Int(1, #self.PackNames)  -- Pick A Random Pack
            _Faction:setValue("SDKGlobalPack", self.PackNames[Assign])   -- Set/Update Pack
            _Pack = self.PackNames[Assign]

            --self.Log.Debug(_Method, "Assigned Faction Pack: " .. tostring(_Pack))
        end        
    end

    --self.Log.Debug(_Method, "Faction Pack: " .. tostring(_Pack))    

    if _Pack then
        return self.Packs[_Pack] -- Return Designs   
    end return nil               -- Return Nil To Incidace No Designs

end

function SDKGlobalDesigns.FactionShip(_FactionIndex, _Style)
    local _FactionDesigns = self.FactionDesigns(_FactionIndex)
    if not _FactionDesigns then return nil end

    local _Table = nil

    if _Style == "Scout" then                    _Table = _FactionDesigns.Scouts
    elseif _Style == "Corvette" then             _Table = _FactionDesigns.Corvettes
    elseif _Style == "Frigate" then              _Table = _FactionDesigns.Frigates
    elseif _Style == "Destroyer" then            _Table = _FactionDesigns.Destroyers
    elseif _Style == "Cruiser" then              _Table = _FactionDesigns.Cruisers
    elseif _Style == "Battleship" then           _Table = _FactionDesigns.Battleships
    elseif _Style == "Dreadnought" then          _Table = _FactionDesigns.Dreadnoughts
    elseif _Style == "Titan" then                _Table = _FactionDesigns.Titans
    elseif _Style == "Carrier" then              _Table = _FactionDesigns.Carriers
    end

    -- Check Valid Table/Remove "" Items
    local _NewTable = {} 
    if _Table and #_Table ~= 0 then 
        for i = 1, #_Table do 
            if _Table[i] ~= "" then table.insert(_NewTable, _Table[i]) end
        end
    end    

    -- Check Table & Return
    if #_NewTable ~= 0 then
        return _NewTable
    end return nil

end

function SDKGlobalDesigns.FactionStation(_FactionIndex, _Style)
    local _FactionDesigns = self.FactionDesigns(_FactionIndex)
    if not _FactionDesigns then return nil end

    local _Table = nil

    if _Style == "Shipyard" then                 _Table = _FactionDesigns.Shipyards
    elseif _Style == "RepairDock" then           _Table = _FactionDesigns.RepairDocks
    elseif _Style == "ResourceDepot" then        _Table = _FactionDesigns.ResourceDepots
    elseif _Style == "EquipmentDock" then        _Table = _FactionDesigns.EquipmentDocks
    elseif _Style == "Scrapyard" then            _Table = _FactionDesigns.Scrapyards
    elseif _Style == "FighterFactory" then       _Table = _FactionDesigns.FighterFactories
    elseif _Style == "TurretFactory" then        _Table = _FactionDesigns.TurretFactories
    elseif _Style == "MilitaryOutpost" then      _Table = _FactionDesigns.MilitaryOutposts
    elseif _Style == "Headquarters" then         _Table = _FactionDesigns.Headquarters
    elseif _Style == "ResearchStation" then      _Table = _FactionDesigns.ResearchStations
    end 

    -- Check Valid Table/Remove "" Items
    local _NewTable = {} 
    if _Table and #_Table ~= 0 then 
        for i = 1, #_Table do 
            if _Table[i] ~= "" then table.insert(_NewTable, _Table[i]) end
        end
    end    

    -- Check Table & Return
    if #_NewTable ~= 0 then
        return _NewTable
    end return nil

end

function SDKGlobalDesigns.Faction(_Pack) local _Method = "Faction"
    local _Faction = {}
    _Faction.Designer =         _Pack.Owner
    _Faction.Name =             _Pack.Settings.Name

    _Faction.Scouts =           _Pack.Scouts
    _Faction.Corvettes =        _Pack.Corvettes
    _Faction.Frigates =         _Pack.Frigates
    _Faction.Destroyers =       _Pack.Destroyers
    _Faction.Cruisers =         _Pack.Cruisers
    _Faction.Battleships =      _Pack.Battleships
    _Faction.Dreadnoughts =     _Pack.Dreadnoughts
    _Faction.Titans =           _Pack.Titans
    _Faction.Carriers =         _Pack.Carriers
    _Faction.FightersArmed =    _Pack.FightersArmed

    _Faction.Shipyards =        _Pack.Shipyards
    _Faction.RepairDocks =      _Pack.RepairDocks
    _Faction.ResourceDepots =   _Pack.ResourceDepots
    _Faction.EquipmentDocks =   _Pack.EquipmentDocks
    _Faction.Scrapyards =       _Pack.Scrapyards
    _Faction.FighterFactories = _Pack.FighterFactories
    _Faction.TurretFactories =  _Pack.TurretFactories
    _Faction.MilitaryOutposts = _Pack.MilitaryOutposts
    _Faction.Headquarters =     _Pack.Headquarters
    _Faction.ResearchStations = _Pack.ResearchStations

    -- Check/Add New Faction Pack
    if not self.Packs[_Faction.Name] then 
         self.Packs[_Faction.Name] = _Faction
         table.insert(self.PackNames, _Faction.Name)
    else self.Log.Warning(_Method, _Faction.Name .. ": Unable To Add Faction. It Already Exists") end    

end

function UnpackGlobalItems(_Pack) local _Method = "Unpack Designs"
    if not _Pack then self.Log.Warning(_Method, "A Invalid Pack Was Passed... Returning") return end
    if not _Pack.Owner then _Pack.Owner = "No Name" end
    
    -- Check/Build New Faction Pack
    if _Pack.Settings then
        if _Pack.Settings.IsGrouped then
            if _Pack.Settings.Name then
                 self.Faction(_Pack)
                 --self.Log.Line(_Method, tostring(_Pack.Settings.Name) .. ": Global Pack Successfuly Loaded", 1)  
            else 
                if not _Pack.Owner then _Pack.Owner = "Unknown Owner" end
                self.Log.Warning(_Method, "[" .. _Pack.Owner .. "] - " .. "Unable To Construct Faction Pack, No Faction Name Set.") 
            end
        end
    end

    -- Global Military Ships
        if _Pack.Scouts and #_Pack.Scouts ~=0 then                          for i = 1, #_Pack.Scouts do self.AddScout(_Pack.Scouts[i]) end end
        if _Pack.Corvettes and #_Pack.Corvettes ~=0 then                    for i = 1, #_Pack.Corvettes do self.AddCorvette(_Pack.Corvettes[i]) end end
        if _Pack.Frigates and #_Pack.Frigates ~=0 then                      for i = 1, #_Pack.Frigates do self.AddFrigate(_Pack.Frigates[i]) end end
        if _Pack.Destroyers and #_Pack.Destroyers ~=0 then                  for i = 1, #_Pack.Destroyers do self.AddDestroyer(_Pack.Destroyers[i]) end end
        if _Pack.Cruisers and #_Pack.Cruisers ~=0 then                      for i = 1, #_Pack.Cruisers do self.AddCruiser(_Pack.Cruisers[i]) end end
        if _Pack.Battleships and #_Pack.Battleships ~=0 then                for i = 1, #_Pack.Battleships do self.AddBattleship(_Pack.Battleships[i]) end end
        if _Pack.Dreadnoughts and #_Pack.Dreadnoughts ~=0 then              for i = 1, #_Pack.Dreadnoughts do self.AddDreadnought(_Pack.Dreadnoughts[i]) end end
        if _Pack.Titans and #_Pack.Titans ~=0 then                          for i = 1, #_Pack.Titans do self.AddTitan(_Pack.Titans[i]) end end
        if _Pack.Carriers and #_Pack.Carriers ~=0 then                      for i = 1, #_Pack.Carriers do self.AddCarrier(_Pack.Carriers[i]) end end
    --

    -- Global Civilian Ships
        if _Pack.Civilians and #_Pack.Civilians ~=0 then                    for i = 1, #_Pack.Civilians do self.AddCivilian(_Pack.Civilians[i]) end end
        if _Pack.Drones and #_Pack.Drones ~=0 then                          for i = 1, #_Pack.Drones do self.AddDrone(_Pack.Drones[i]) end end
        if _Pack.CruiseShips and #_Pack.CruiseShips ~=0 then                for i = 1, #_Pack.CruiseShips do self.AddCruiseShip(_Pack.CruiseShips[i]) end end
        if _Pack.CrewTransports and #_Pack.CrewTransports ~=0 then          for i = 1, #_Pack.CrewTransports do self.AddCrewTransport(_Pack.CrewTransports[i]) end end
    
        if _Pack.SmallFreighters and #_Pack.SmallFreighters ~=0 then        for i = 1, #_Pack.SmallFreighters do self.AddSmallFreighter(_Pack.SmallFreighters[i]) end end
        if _Pack.MediumFreighters and #_Pack.MediumFreighters ~=0 then      for i = 1, #_Pack.MediumFreighters do self.AddMediumFreighter(_Pack.MediumFreighters[i]) end end
        if _Pack.LargeFreighters and #_Pack.LargeFreighters ~=0 then        for i = 1, #_Pack.LargeFreighters do self.AddLargeFreighter(_Pack.LargeFreighters[i]) end end
        if _Pack.HugeFreighters and #_Pack.HugeFreighters ~=0 then          for i = 1, #_Pack.HugeFreighters do self.AddHugeFreighter(_Pack.HugeFreighters[i]) end end
        
        if _Pack.SmallMiners and #_Pack.SmallMiners ~=0 then                for i = 1, #_Pack.SmallMiners do self.AddSmallMiner(_Pack.SmallMiners[i]) end end
        if _Pack.MediumMiners and #_Pack.MediumMiners ~=0 then              for i = 1, #_Pack.MediumMiners do self.AddMediumMiner(_Pack.MediumMiners[i]) end end
        if _Pack.LargeMiners and #_Pack.LargeMiners ~=0 then                for i = 1, #_Pack.LargeMiners do self.AddLargeMiner(_Pack.LargeMiners[i]) end end
        if _Pack.HugeMiners and #_Pack.HugeMiners ~=0 then                  for i = 1, #_Pack.HugeMiners do self.AddHugeMiner(_Pack.HugeMiners[i]) end end

        if _Pack.SmallSalvagers and #_Pack.SmallSalvagers ~=0 then          for i = 1, #_Pack.SmallSalvagers do self.AddSmallSalvager(_Pack.SmallSalvagers[i]) end end
        if _Pack.MediumSalvagers and #_Pack.MediumSalvagers ~=0 then        for i = 1, #_Pack.MediumSalvagers do self.AddMediumSalvager(_Pack.MediumSalvagers[i]) end end
        if _Pack.LargeSalvagers and #_Pack.LargeSalvagers ~=0 then          for i = 1, #_Pack.LargeSalvagers do self.AddLargeSalvager(_Pack.LargeSalvagers[i]) end end
        if _Pack.HugeSalvagers and #_Pack.HugeSalvagers ~=0 then            for i = 1, #_Pack.HugeSalvagers do self.AddHugeSalvager(_Pack.HugeSalvagers[i]) end end
    --
    
    -- Global Fighters
        if _Pack.FightersUnarmed and #_Pack.FightersUnarmed ~=0 then        for i = 1, #_Pack.FightersUnarmed do self.AddFighterUnarmed(_Pack.FightersUnarmed[i]) end end
        if _Pack.FightersCrew and #_Pack.FightersCrew ~=0 then              for i = 1, #_Pack.FightersCrew do self.AddFighterCrew(_Pack.FightersCrew[i]) end end
        if _Pack.FightersCargo and #_Pack.FightersCargo ~=0 then            for i = 1, #_Pack.FightersCargo do self.AddFighterCargo(_Pack.FightersCargo[i]) end end
        if _Pack.FightersArmed and #_Pack.FightersArmed ~=0 then            for i = 1, #_Pack.FightersArmed do self.AddFighterArmed(_Pack.FightersArmed[i]) end end
    --
    
    -- Global Station Plans
        if _Pack.Stations and #_Pack.Stations ~=0 then                      for i = 1, #_Pack.Stations do self.AddStation(_Pack.Stations[i]) end end

        if _Pack.Shipyards and #_Pack.Shipyards ~=0 then                    for i = 1, #_Pack.Shipyards do self.AddShipyard(_Pack.Shipyards[i]) end end
        if _Pack.RepairDocks and #_Pack.RepairDocks ~=0 then                for i = 1, #_Pack.RepairDocks do self.AddRepairDock(_Pack.RepairDocks[i]) end end
        if _Pack.ResourceDepots and #_Pack.ResourceDepots ~=0 then          for i = 1, #_Pack.ResourceDepots do self.AddResourceDepot(_Pack.ResourceDepots[i]) end end
        if _Pack.TradingPosts and #_Pack.TradingPosts ~=0 then              for i = 1, #_Pack.TradingPosts do self.AddTradingPost(_Pack.TradingPosts[i]) end end
        if _Pack.EquipmentDocks and #_Pack.EquipmentDocks ~=0 then          for i = 1, #_Pack.EquipmentDocks do self.AddEquipmentDock(_Pack.EquipmentDocks[i]) end end
        if _Pack.SmugglersMarkets and #_Pack.SmugglersMarkets ~=0 then      for i = 1, #_Pack.SmugglersMarkets do self.AddSmugglersMarket(_Pack.SmugglersMarkets[i]) end end
        if _Pack.Scrapyards and #_Pack.Scrapyards ~=0 then                  for i = 1, #_Pack.Scrapyards do self.AddScrapyard(_Pack.Scrapyards[i]) end end
        if _Pack.Mines and #_Pack.Mines ~=0 then                            for i = 1, #_Pack.Mines do self.AddMine(_Pack.Mines[i]) end end
        if _Pack.IceMines and #_Pack.IceMines ~=0 then                      for i = 1, #_Pack.IceMines do self.AddIceMine(_Pack.IceMines[i]) end end
        if _Pack.Factories and #_Pack.Factories ~=0 then                    for i = 1, #_Pack.Factories do self.AddFactory(_Pack.Factories[i]) end end
        
        if _Pack.FighterFactories and #_Pack.FighterFactories ~=0 then      for i = 1, #_Pack.FighterFactories do self.AddFighterFactory(_Pack.FighterFactories[i]) end end
        if _Pack.TurretFactories and #_Pack.TurretFactories ~=0 then        for i = 1, #_Pack.TurretFactories do self.AddTurretFactory(_Pack.TurretFactories[i]) end end
        if _Pack.SolarPowerPlants and #_Pack.SolarPowerPlants ~=0 then      for i = 1, #_Pack.SolarPowerPlants do self.AddSolarPowerPlant(_Pack.SolarPowerPlants[i]) end end
        if _Pack.Farms and #_Pack.Farms ~=0 then                            for i = 1, #_Pack.Farms do self.AddFarm(_Pack.Farms[i]) end end
        if _Pack.Ranches and #_Pack.Ranches ~=0 then                        for i = 1, #_Pack.Ranches do self.AddRanch(_Pack.Ranches[i]) end end
        if _Pack.Collectors and #_Pack.Collectors ~=0 then                  for i = 1, #_Pack.Collectors do self.AddCollector(_Pack.Collectors[i]) end end
        if _Pack.Biotopes and #_Pack.Biotopes ~=0 then                      for i = 1, #_Pack.Biotopes do self.AddBiotope(_Pack.Biotopes[i]) end end
        if _Pack.Casinos and #_Pack.Casinos ~=0 then                        for i = 1, #_Pack.Casinos do self.AddCasino(_Pack.Casinos[i]) end end
        if _Pack.Habitats and #_Pack.Habitats ~=0 then                      for i = 1, #_Pack.Habitats do self.AddHabitat(_Pack.Habitats[i]) end end
        if _Pack.MilitaryOutposts and #_Pack.MilitaryOutposts ~=0 then      for i = 1, #_Pack.MilitaryOutposts do self.AddMilitaryOutpost(_Pack.MilitaryOutposts[i]) end end
        if _Pack.Headquarters and #_Pack.Headquarters ~=0 then              for i = 1, #_Pack.Headquarters do self.AddHeadquarter(_Pack.Headquarters[i]) end end
        if _Pack.ResearchStations and #_Pack.ResearchStations ~=0 then      for i = 1, #_Pack.ResearchStations do self.AddResearchStation(_Pack.ResearchStations[i]) end end
        if _Pack.TravelHubs and #_Pack.TravelHubs ~=0 then                  for i = 1, #_Pack.TravelHubs do self.AddTravelHub(_Pack.TravelHubs[i]) end end
    --

    -- Global Environment Items
        if _Pack.Satalites and #_Pack.Satalites ~=0 then                    for i = 1, #_Pack.Satalites do self.AddSatalite(_Pack.Satalites[i]) end end
    --
end

-- Add Standard Designs
include("SDKGlobalDesigns - Pack Generic Items")
include("SDKGlobalDesigns - Pack SDK")
include("SDKGlobalDesigns - Pack SivCorps")
include("SDKGlobalDesigns - Pack Black Disciples")
include("SDKGlobalDesigns - Pack Drazhills")
include("SDKGlobalDesigns - Pack Nyancats")

return SDKGlobalDesigns