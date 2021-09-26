--[[ 
    Instructions:
    1. NEW FOLDER: In this mod there is a folder "data/plans". Make a folder in the "plans" folder to place
       your deisngs. I would name the folder after the name of the faction or after your steam name to keep 
       your designs seprate from other peoples deigns. When these are loaded they are collected in the plans 
       folder for the game and plans with the same name in a folder will be overwritten. 

       I would recommend naming your folder like this:
       (Your ID) - (Faction Name)
       "SDK - ArcTech"
       "SDK ArcTech"
       "Black Disciple - TR"
       "Black Disciple TR"     
    
    
    2. ADD/NAME FILES: Add your ship/station/background item designs (xml files) in the plan folders.
       You will want to make more uniuqe name for your files so I'd recommend something like this:
       
       (Your ID) - (File Name)
       "SDK - SS Harmony 2.0.xml"
       "Black Disicple - TR Factory 0.xml"
    
       Naming your files like this will help you ID if there are any issues. The name will post with an
       error to help you trouble shoot any problems.


    3. ADD PATHS: Add the paths to the correct areas below. If you want to use the same Design in more
       then one area you can. You just need to provide the path where to pull the design.

        Examples of the items filled out:

            SmallFreighters = {
                "data/plans/Extension/Ship/Black Disciple - TR C-2500 Light Freighter0.xml",
                "data/plans/Extension/Ship/Black Disciple - TR C-2500 Light Freighter1.xml",
            }, 

            Factories = {
                "data/plans/Extension/Station/Black Disciple - TR Factory0.xml",
                "data/plans/Extension/Station/Black Disciple - TR Factory1.xml",
                "data/plans/Extension/Station/Black Disciple - TR Factory2.xml",
                "data/plans/Extension/Station/Black Disciple - TR Factory3.xml",
                "data/plans/Extension/Station/Black Disciple - TR Factory4.xml",
                "data/plans/Extension/Station/Black Disciple - TR Factory5.xml",
            },


    GENERAL INFO:
    - All deisngs in this pack will be loaded in to the Global designs. So you may see your designs used in other regions of space
    in the game. This happens when someone doesn't have all the items to make a full pack. The generator will pull items from 
    the global area to fill it in.

    - "Faction Pack Item" = When a faction gets assigned a pack. It will ALWAYS try to use one of the designs from the list. If none
    are found it will use the global designs to fill in the station/ship.

    - Faction Packs will only use Military Ships and Military/Infrastructure Stations. Civilian ships/stations will use the 
    Generic Pool. Civilian Ships/Stations aren't goverment controlled so they should have variety.
]]

UnpackGlobalItems({   

    ------------------------------------------------------
    ------------------ Basic Pack Info -------------------
    ------------------------------------------------------

    -- Replace this with your Alias. ie. Steam Name or Discord Name.                            
    -- Example "(Steam) SDK" or (Discord) Shadow Doctor K#2203"
    Owner = "Shadow Doctor K",     

    Settings = 
    {
        IsGrouped = false,      -- true = assign this to factions as a pack, false = don't assign to factions.
        Name = "",              -- Recommend [Steam Name] - [Pack Name] ie. "SDK - Federation" or "Random Designs 1".
    },

    ------------------------------------------------------
    --------------- Military Ship Designs ----------------
    ------------------------------------------------------

    -- Scale: 4 Slot
    Scouts = { -- Faction Pack Item
        "",        
    },

    -- Scale: 6 Slot
    Corvettes = { -- Faction Pack Item
        "",        
    },

    -- Scale: 7 to 8 Slot
    Frigates = { -- Faction Pack Item
        "",        
    },

    -- Scale: 9 to 10 Slot
    Destroyers = { -- Faction Pack Item
        "",        
    },

    -- Scale: 11 to 12 Slot
    Cruisers = { -- Faction Pack Item
        "",        
    },

    -- Scale: 13 to 14 Slot
    Battleships = { -- Faction Pack Item
        "",        
    },

    -- Scale: 15 Slot
    Dreadnoughts = { -- Faction Pack Item
        "",        
    },

    -- Scale: 15 Slot +
    Titans = { -- Faction Pack Item
        "",        
    },

    -- Scale: 8 Slot - 15 Slot + Designs
    Carriers = { -- Faction Pack Item
        "",        
    },   

    ------------------------------------------------------
    --------------- Civilian Ship Designs ----------------
    ------------------------------------------------------    

    -- Scale: 1 to 4 Slot
    Civilians = { -- These are just generic background civilian traffic.
        "",        
    }, 

    -- Scale: 4 to 6 Slot
    SmallFreighters = {
        "",        
    }, 

    -- Scale: 7 to 10 Slot
    MediumFreighters = {
        "",        
    }, 
    
    -- Scale: 11 to 13 Slot
    LargeFreighters = {
        "",        
    }, 

    -- Scale: 14 to 15 Slot
    HugeFreighters = {
        "",
    }, 

    -- Scale: 4 to 6 Slot
    SmallMiners = {
        "",        
    },   
    
    -- Scale: 7 to 10 Slot
    MediumMiners = {
        "",        
    },   

    -- Scale: 11 to 13 Slot
    LargeMiners = {
        "",
    }, 
    
    -- Scale: 14 to 15 Slot
    HugeMiners = {
        "",
    }, 
    
    -- Scale: 4 to 6 Slot
    SmallSalvagers = {
        "",        
    },   
    
    -- Scale: 7 to 10 Slot
    MediumSalvagers = {
        
    },   

    -- Scale: 11 to 13 Slot
    LargeSalvagers = {
        "",
    },  

    -- Scale: 14 to 15 Slot
    HugeSalvagers = {
        "",
    },  

    -- Scale: 10 to 13 Slot
    -- Background Ship: Party ships, Cruise Liners, etc...
    CruiseShips = {
        "",
    },  

    -- Scale: 8 to 10 Slot
    -- Crew Transports used to bring your Crew
    CrewTransports = {
        "",
    },  

    -- Scale: 2 Slot
    -- Used for the Factories and Miscellaneous Background Drones
    Drones = {
        "",
    },  

    ------------------------------------------------------
    ------------------ Fighter Designs -------------------
    ------------------------------------------------------

    FightersMining = {
        "",
    },

    FightersCrew = {
        "",
    },

    FightersCargo = {
        "",
    },

    FightersArmed = { -- Faction Pack Item
        "",
    },

    ------------------------------------------------------
    ------------------ Station Designs -------------------
    ------------------------------------------------------

    --[[
        "Stations" list is a generic station deisgn which will be used
        in the event that designs are not loaded for the named station
        types or if its just a generic in game station with no special
        use. Its always good to have at least one of these. Not required.
    ]]
    Stations = {
        "",        
    },
    
    --[[
        Named stations below will load their specialized designs and 
        fallback to the "Stations" above if none are listed.
    ]]

    Shipyards = { -- Faction Pack Item
        "",                
    },

    RepairDocks = { -- Faction Pack Item
        "",               
    },

    ResourceDepots = { -- Faction Pack Item
        "",        
    },
  
    EquipmentDocks = { -- Faction Pack Item
        "",        
    },

    Scrapyards = { -- Faction Pack Item
        "",        
    },
    
    FighterFactories = { -- Faction Pack Item
        "",        
    },
    
    TurretFactories = { -- Faction Pack Item
        "",        
    },
    
    MilitaryOutposts = { -- Faction Pack Item
        "",        
    },
    
    Headquarters = { -- Faction Pack Item
        "",            
    },
    
    ResearchStations = { -- Faction Pack Item
        "",        
    },

    TradingPosts = {
        "",        
    },
    
    SmugglersMarkets = {
        "",
    },
        
    Mines = {
        "",        
    },

    IceMines = {
        "",
    },
    
    Factories = {
        "",        
    },
    
    SolarPowerPlants = {
        "",        
    },
    
    Farms = {
        "",        
    },
    
    Ranches = {
        "",        
    },
    
    Collectors = {
        "",        
    },
    
    Biotopes = {
        "",
    },
    
    Casinos = {
        "",
    },
    
    Habitats = {
        "",        
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
        "",        
    },

    -- Energy Suppression Sats.
    Satalites = { 
        "",        
    },
    
}) -- !! DONT DELETE THIS LINE !!