local Logging = include("SDKDebugLogging")
Logging.Debugging = 0
Logging.ModName = "SDK Background Sector Manager"

-- namespace SDKBackgroundSectorManager
SDKBackgroundSectorManager = {} local self = SDKBackgroundSectorManager

self.Log = Logging

function SDKBackgroundSectorManager.initialize() local _Method = "Initialize"
    self.Log(_MethodName, tostring(Sector().name) .. ": Sector Manager Initialized")
end

function SDKBackgroundSectorManager.update(_TimeStep) local _Method = "Update"
    
    if onServer() then

    end

    if onClient() then

    end

end

-- Detect Damaged Alliance/Faction Ship & Stations --> Send Repair Ships

-- Detect Wreckage In Populated Sectors --> Send Scrap Tugs In To Clear/Harvest It

-- Add Roving Sector Patrols To Lightly Guarded Sectors --> Scan for Smugglers, 
-- Clear out Strong Hostiles, etc... then move to next area
