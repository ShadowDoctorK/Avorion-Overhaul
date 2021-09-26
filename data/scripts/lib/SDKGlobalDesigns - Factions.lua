include ("defaultscripts")

-- Logging Setup
    local Log = include("SDKDebugLogging")
    local _ModName = "Global Factions"
    local _Debug = 0

    -- Fucntion to build Methodname
    function GetName(n)
        return _ModName .. " - " .. n
    end
-- End Logging

SDKFactions = {}

function SDKFactions.BossAsteroid()
    local N = "The Pariah"%_T
    local F = Galaxy():findFaction(N)
    if F == nil then
        F = Galaxy():createFaction(N, 0, 0)
        F.initialRelations = 0
        F.initialRelationsToPlayer = 0
        F.staticRelationsToPlayers = true
    end

    F.initialRelationsToPlayer = 0
    F.staticRelationsToPlayers = true
    F.homeSectorUnknown = true

    return F
end

return SDKFactions