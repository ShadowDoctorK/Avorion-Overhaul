-- Global Items
UnpackGlobalItems({   

    -- Replace this with your Alias. ie. Steam Name or Discord Name.                            
    -- Example "(Steam) SDK" or (Discord) Shadow Doctor K#2203"
    Owner = "Overhaul Defaults: Various Global Designs",     

    Settings = 
    {
        IsGrouped = false,      -- Changing this to true will Mark this as a "Global Faction Pack" and Will assigns designs to factions
        Name = "",              -- Pack Name if Grouped. Recommend [Steam Name] - [Pack Name] ie. "SDK - Federation".
    },

    -- Military Ship Designs
    Scouts = { -- Faction Pack Ship

    },

    Corvettes = { -- Faction Pack Ship
        "data/plans/Default/Ship/Arakiss - S-9 Corvette0.xml",
        "data/plans/Default/Ship/Arakiss - S-9 Corvette1.xml",

    },

    Frigates = { -- Faction Pack Ship

    },

    Destroyers = { -- Faction Pack Ship
        "data/plans/Default/Ship/Arakiss - Z-7 Destroyer0.xml",
        "data/plans/Default/Ship/Arakiss - Z-7 Destroyer1.xml",
        "data/plans/Default/Ship/Redg - Heavy Cruiser (9 Slot).xml",

    },

    Cruisers = { -- Faction Pack Ship
        "data/plans/Default/Ship/Arakiss - Konigsberg Cruiser0.xml",
        "data/plans/Default/Ship/Arakiss - Konigsberg Cruiser1.xml",
    },

    Battleships = { -- Faction Pack Ship

    },

    Dreadnoughts = { -- Faction Pack Ship

    },

    Titans = { -- Faction Pack Ship

    },

    Carriers = { -- Faction Pack Ship
        "data/plans/Default/Ship/Arakiss - Konigsberg Cruiser0.xml",    -- Temp Move Remove These When We Have More Carrier Designs
        "data/plans/Default/Ship/Arakiss - Konigsberg Cruiser1.xml",    -- Temp Move Remove These When We Have More Carrier Designs
    },   

    -- Civilian Ship Designs:
    SmallFreighters = {

    }, 

    MediumFreighters = {
        "data/plans/Default/Ship/FELDruebe - Industrial Ship0.xml",
        "data/plans/Default/Ship/FELDruebe - Industrial Ship1.xml",
        "data/plans/Default/Ship/FELDruebe - Industrial Ship2.xml",
    }, 
    
    LargeFreighters = {
        "data/plans/Default/Ship/Tigor - Gannet Class Freighter0.xml",
        "data/plans/Default/Ship/Tigor - Gannet Class Freighter1.xml",
        "data/plans/Default/Ship/Tigor - Pelican Class Tanker0.xml",
        "data/plans/Default/Ship/Tigor - Pelican Class Tanker0.xml",
    }, 

    -- Scale: 14 to 15 Slot
    HugeFreighters = {
        "data/plans/Default/Ship/EloSpartan - Atlas 1 Freighter (15 Slot).xml",
        "data/plans/Default/Ship/EloSpartan - Atlas 2 Freighter (15 Slot).xml",
    }, 

    SmallMiners = {
        "",
    },   
    
    MediumMiners = {
        "data/plans/Default/Ship/FELDruebe - Industrial Ship0.xml",
        "data/plans/Default/Ship/FELDruebe - Industrial Ship1.xml",
        "data/plans/Default/Ship/FELDruebe - Industrial Ship2.xml",
    },   

    LargeMiners = {
        "",
    },  
    
    -- Scale: 14 to 15 Slot
    HugeMiners = {
        "data/plans/Default/Ship/EloSpartan - Atlas 0 Miner (15 Slot).xml",
    }, 

    SmallSalvagers = {
        "data/plans/Default/Ship/Duke Nukem - Erlkonig Salvager (6 Slot).xml",
    },   
    
    MediumSalvagers = {
        "data/plans/Default/Ship/Test - Salvager.xml",
    },   

    LargeSalvagers = {
        "data/plans/Default/Ship/Two Hands - N.C Industries Salvager-Miner (10 Slot).xml",
    },  

    -- Scale: 14 to 15 Slot
    HugeSalvagers = {
        "data/plans/Default/Ship/Two Hands - N.C.Industries Salvager-Miner (14 Slot).xml",
    },  

    CruiseShips = {
        "data/plans/Default/Cruise Ship/Tigor - Alien Battlecruiser (Cruise Ship).xml",
    },  

    CrewTransports = {
        "data/plans/Default/Crew Transport/Ren Atlas - Berserk (Crew Transport).xml",
    },  

    Drones = {
        "",
    },  

    Civilians = {
        "data/plans/Default/Civilian/Araksis - S9 Corvett (Civilian).xml",
        "data/plans/Default/Civilian/les9876 - Drake (Civilian).xml",
        "data/plans/Default/Civilian/Ren Atlas - Federation Shuttle (Civilian).xml",
        "data/plans/Default/Civilian/SDK - Cargo Transport (Civilian).xml",
        "data/plans/Default/Civilian/Two Hands - NC Polaris (Civilian).xml",
        "data/plans/Default/Civilian/Two Hands - NC Tristain (Civilain).xml",
        "data/plans/Default/Civilian/Two Hands - NC Ventor (Civilian).xml",
    },  

    -- Fighter Ship Designs
    FightersMining = {
        "",
    },

    FightersCrew = {
        "",
    },

    FightersCargo = {
        "",
    },

    FightersArmed = { -- Faction Pack Ship
        "",
    },

    -- Station Designs: Any Station not marked with a "Faction Pack Station" is considered a Civilian Station.
    Stations = { -- Generic Station Designs which will be used in the event that Designs are not avaiable or it is generic station type.
        "",
    },
    
    Shipyards = { -- Faction Pack Station
        "data/plans/Default/Station/Shipyard/SivCorp - Junk Shipyard0.xml",
        "data/plans/Default/Station/Shipyard/SivCorp - SmallShipyard.xml",
    },

    RepairDocks = { -- Faction Pack Station
        "data/plans/Default/Station/Repair Dock/Sivcorp - Repair Dock0.xml",
    },

    ResourceDepots = { -- Faction Pack Station
        "data/plans/Default/Station/Resource Depot/SivCorp - Resource Depot0.xml",
    },
    
    TradingPosts = {
        "data/plans/Default/Station/Trading Post/SivCorp - Trading Post0.xml",
        "data/plans/Default/Station/Trading Post/SivCorp - Trading Post1.xml",
    },
    
    EquipmentDocks = { -- Faction Pack Station

    },
    
    SmugglersMarkets = {
        "",
    },
    
    Scrapyards = { -- Faction Pack Station
        "data/plans/Default/Station/Scrapyard/Black Disciple - Generic Scrapyard 0.xml",
    },
    
    Mines = {
        "data/plans/Default/Station/Mine/SivCorp - SmallMine.xml",
        "data/plans/Default/Station/Mine/SivCorp - MediumMine.xml",
        "data/plans/Default/Station/Mine/SivCorp - Mine0.xml"
    },
    
    Factories = {
        "data/plans/Default/Station/Factory/SivCorp - StandardFactory.xml",
        "data/plans/Default/Station/Factory/SivCorp - FoundryFactory.xml",
        "data/plans/Default/Station/Factory/SivCorp - FluidFactory.xml",
        "data/plans/Default/Station/Factory/SivCorp - Factory0.xml",
    },
    
    FighterFactories = { -- Faction Pack Station

    },
    
    TurretFactories = { -- Faction Pack Station

    },
    
    SolarPowerPlants = {
        "data/plans/Default/Station/Solar Power Plant/SivCorp - SmallSolarPlant.xml",
    },
    
    Farms = {
        "data/plans/Default/Station/Farm/SivCorp - Farm0.xml",
        "data/plans/Default/Station/Farm/SivCorp - SmallFarm.xml",
    },
    
    Ranches = {
        "data/plans/Default/Station/Ranch/SivCorp - RanchSmall.xml",
    },
    
    Collectors = {
        "data/plans/Default/Station/Collector/SivCorp - CollectorFactory.xml",
    },
    
    Biotopes = {
        "",
    },
    
    Casinos = {
        "",
    },
    
    Habitats = {
        "data/plans/Default/Station/Habitat/SivCorp - Habitat0.xml",
    },
    
    MilitaryOutposts = { -- Faction Pack Station

    },
    
    Headquarters = { -- Faction Pack Station

    },
    
    ResearchStations = { -- Faction Pack Station
        "data/plans/Default/Station/Research Station/SivCorp - Research0.xml",
    },

    ------------------------------------------------------
    ----------------- Background Items -------------------
    ------------------------------------------------------

    -- Container Field Containers
    Conatiners = { 
        "",        
    },

    -- Obvisous...
    Gates = {
        "data/plans/Default/Environment/Gate 0.xml",
    },

    -- Energy Suppression Sats.
    Satalites = { 
        "data/plans/Default/Environment/Supressor Satellite 0.xml",
    },

})