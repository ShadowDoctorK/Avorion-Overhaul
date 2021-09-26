include ("defaultscripts")
local Rand = include("SDKUtilityRandom")

-- Logging Setup
    local Log = include("SDKDebugLogging")
    local _ModName = "Global Classes"
    local _Debug = 0

    -- Fucntion to build Methodname
    function GetName(n)
        return _ModName .. " - " .. n
    end
-- End Logging

SDKGlobalClasses = {}

-- Defined Classes

    -- Military Ships
    SDKGlobalClasses.Scout         = "Scout"
    SDKGlobalClasses.Corvette      = "Corvette"
    SDKGlobalClasses.Frigate       = "Frigate"
    SDKGlobalClasses.Destroyer     = "Destroyer"
    SDKGlobalClasses.Cruiser       = "Cruiser"
    SDKGlobalClasses.Battleship    = "Battleship"
    SDKGlobalClasses.Dreadnought   = "Dreadnought"
    SDKGlobalClasses.Titan         = "Titan"

    SDKGlobalClasses.Carrier       = "Carrier"

    -- Fighters
    SDKGlobalClasses.FighterArmed   = "FighterArmed"  
    SDKGlobalClasses.FighterUnarmed = "FighterUnarmed"        
    SDKGlobalClasses.FighterCrew    = "FighterCrew"        
    SDKGlobalClasses.FighterCargo   = "FighterCargo"              

    -- Civilian Ships
    SDKGlobalClasses.Miner         = "Miner"        
    SDKGlobalClasses.MinerS        = "MinerSmall"
    SDKGlobalClasses.MinerM        = "MinerMed"
    SDKGlobalClasses.MinerL        = "MinerLarge"
    SDKGlobalClasses.MinerH        = "MinerHuge"

    SDKGlobalClasses.Freighter     = "Freighter"
    SDKGlobalClasses.FreighterS    = "FreighterSmall"
    SDKGlobalClasses.FreighterM    = "FreighterMed"
    SDKGlobalClasses.FreighterL    = "FreighterLarge"
    SDKGlobalClasses.FreighterH    = "FreighterHuge"

    SDKGlobalClasses.Salvager      = "Salvager"
    SDKGlobalClasses.SalvagerS     = "SalvagerSmall"
    SDKGlobalClasses.SalvagerM     = "SalvagerMed"
    SDKGlobalClasses.SalvagerL     = "SalvagerLarge"
    SDKGlobalClasses.SalvagerH     = "SalvagerHuge"

    SDKGlobalClasses.CruiseShip    = "CruiseShip"
    SDKGlobalClasses.CrewTransport = "CrewTransport"
    SDKGlobalClasses.Drone         = "Drone"
    SDKGlobalClasses.Civilian      = "Civilian"


    -- Station Types
    SDKGlobalClasses.Factory            = "Factory"
    SDKGlobalClasses.Shipyard           = "Shipyard"
    SDKGlobalClasses.RepairDock         = "RepairDock"
    SDKGlobalClasses.ResourceDepot      = "ResourceDepot"
    SDKGlobalClasses.TradingPost        = "TradingPost"
    SDKGlobalClasses.EquipmentDock      = "EquipmentDock"
    SDKGlobalClasses.SmugglersMarket    = "SmugglersMarket"
    SDKGlobalClasses.Scrapyard          = "Scrapyard"
    SDKGlobalClasses.Mine               = "Mine"
    SDKGlobalClasses.IceMine            = "IceMine"
    SDKGlobalClasses.FighterFactory     = "FighterFactory"
    SDKGlobalClasses.TurretFactory      = "TurretFactory"
    SDKGlobalClasses.SolarPowerPlant    = "SolarPowerPlant"
    SDKGlobalClasses.Farm               = "Farm"
    SDKGlobalClasses.Ranch              = "Ranch"
    SDKGlobalClasses.Collector          = "Collector"
    SDKGlobalClasses.Biotope            = "Biotope"
    SDKGlobalClasses.Casino             = "Casino"
    SDKGlobalClasses.Habitat            = "Habitat"
    SDKGlobalClasses.MilitaryOutpost    = "MilitaryOutpost"
    SDKGlobalClasses.Headquarters       = "Headquarters"
    SDKGlobalClasses.ResearchStation    = "ResearchStation"
    SDKGlobalClasses.TravelHub          = "TravelHub"

    -- Background Items
    SDKGlobalClasses.Satalite       = "Satalite"
    SDKGlobalClasses.Gate           = "Gate"
    SDKGlobalClasses.Container      = "Container"

-- End Defined Classes

local self = SDKGlobalClasses

-- Class Groups
    function SDKGlobalClasses.Salvagers()
        return {
            self.SalvagerS,
            self.SalvagerM,
            self.SalvagerL,
            self.SalvagerH
        }
    end

    function SDKGlobalClasses.Miners()
        return {
            self.MinerS,
            self.MinerM,
            self.MinerL,
            self.MinerH
        }
    end

    function SDKGlobalClasses.Freighters()
        return {
            self.FreighterS,
            self.FreighterM,
            self.FreighterL,
            self.FreighterH
        }
    end

    function SDKGlobalClasses.Military()
        return {
            self.Scout,         
            self.Corvette,      
            self.Frigate,       
            self.Destroyer,     
            self.Cruiser,       
            self.Battleship,    
            self.Dreadnought,   
            self.Titan,         
            self.Carrier
        }
    end

    function SDKGlobalClasses.Ships()
        return {
            self.Scout,         
            self.Corvette,      
            self.Frigate,       
            self.Destroyer,     
            self.Cruiser,       
            self.Battleship,    
            self.Dreadnought,   
            self.Titan,         
            self.Carrier,   
            self.FreighterS,
            self.FreighterM,
            self.FreighterL,
            self.FreighterH,
            self.MinerS,
            self.MinerM,
            self.MinerL,
            self.MinerH,
            self.SalvagerS,
            self.SalvagerM,
            self.SalvagerL,
            self.SalvagerH,
            self.Civilian
        }
    end

    function SDKGlobalClasses.Civilians()
        return {
            self.FreighterS,
            self.FreighterM,
            self.FreighterL,
            self.FreighterH,
            self.MinerS,
            self.MinerM,
            self.MinerL,
            self.MinerH,
            self.SalvagerS,
            self.SalvagerM,
            self.SalvagerL,
            self.SalvagerH,
            self.Civilian
        }
    end

-- End Class Groups

-- Class Checks
    function SDKGlobalClasses.IsMilitary(c)
        if self.Scout == c then return true
        elseif self.Corvette == c then return true 
        elseif self.Frigate == c then return true 
        elseif self.Destroyer == c then return true 
        elseif self.Cruiser == c then return true 
        elseif self.Battleship == c then return true 
        elseif self.Dreadnought == c then return true 
        elseif self.Titan == c then return true 
        end return false
    end

    function SDKGlobalClasses.IsFreighter(c)
        if self.FreighterS == c then return true
        elseif self.FreighterM == c then return true 
        elseif self.FreighterL == c then return true 
        elseif self.FreighterH == c then return true 
        end return false
    end

    function SDKGlobalClasses.IsMiner(c)
        if self.MinerS == c then return true
        elseif self.MinerM == c then return true 
        elseif self.MinerL == c then return true 
        elseif self.MinerH == c then return true 
        end return false
    end

    function SDKGlobalClasses.IsSalvager(c)
        if self.SalvagerS == c then return true
        elseif self.SalvagerM == c then return true 
        elseif self.SalvagerL == c then return true 
        elseif self.SalvagerH == c then return true 
        end return false
    end

    function SDKGlobalClasses.IsStation(c)
        if self.Factory == c then return true
        elseif self.Shipyard == c then return true 
        elseif self.RepairDock == c then return true 
        elseif self.ResourceDepot == c then return true 
        elseif self.TradingPost == c then return true 
        elseif self.EquipmentDock == c then return true 
        elseif self.SmugglersMarket == c then return true 
        elseif self.Scrapyard == c then return true 
        elseif self.Mine == c then return true 
        elseif self.IceMine == c then return true 
        elseif self.FighterFactory == c then return true 
        elseif self.TurretFactory == c then return true 
        elseif self.SolarPowerPlant == c then return true 
        elseif self.Farm == c then return true 
        elseif self.Ranch == c then return true 
        elseif self.Collector == c then return true 
        elseif self.Biotope == c then return true 
        elseif self.Casino == c then return true 
        elseif self.Habitat == c then return true 
        elseif self.MilitaryOutpost == c then return true 
        elseif self.Headquarters == c then return true 
        elseif self.ResearchStation == c then return true     
        end return false
    end
-- End Class Checks

return SDKGlobalClasses