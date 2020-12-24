package.path = package.path .. ";data/scripts/lib/?.lua"
package.path = package.path .. ";data/scripts/?.lua"
local GenXsotan = include("SDKXsotanGenerator")
local Log = include("SDKDebugLogging")

local _Debug = 0
local _ModName = "Xsotan Lua" function GetName(n)
    return _ModName .. " - " .. n
end

----------------------------------------------------------------------------------------------------------
------------------------------------- Modified Vanilla Funcitons -----------------------------------------
----------------------------------------------------------------------------------------------------------

-- "Unused" is the VolumeFactor for the old method call.
-- Save the Vanilla Function
Xsotan.old_createShip = Xsotan.createShip 
function Xsotan.createShip(_Position, _Unused) local _MethodName = GetName("Create Ship")
    
    local _Class = GenXsotan.ClassByDistance()
    local _Ship

    Log.Debug(_MethodName, "Selected Ship Class: " .. tostring(_Class), _Debug)

    if _Class == "Probe" then           _Ship = GenXsotan.Probe(_Position)
    elseif _Class == "Latcher" then     _Ship = GenXsotan.Latcher(_Position)
    elseif _Class == "Scout" then       _Ship = GenXsotan.Scout(_Position)
    elseif _Class == "Hunter" then      _Ship = GenXsotan.Hunter(_Position)
    elseif _Class == "Reclaimer" then   _Ship = GenXsotan.Reclaimer(_Position)
    elseif _Class == "Decimator" then   _Ship = GenXsotan.Decimator(_Position)
    elseif _Class == "Annihilator" then _Ship = GenXsotan.Annihilator(_Position)
    elseif _Class == "Summoner" then    _Ship = GenXsotan.Summoner(_Position)
    elseif _Class == "Incubator" then   _Ship = GenXsotan.Incubator(_Position)
    elseif _Class == "Dreadnought" then _Ship = GenXsotan.Dreadnought(_Position)
    end

    return _Ship
end

-- "Unused" is the VolumeFactor for the old method call.
-- Save the Vanilla Function
Xsotan.old_createCarrier = Xsotan.createCarrier function Xsotan.createCarrier(_Position, _Unused, _Fighters)
    return GenXsotan.Incubator(_Position, _Fighters)
end

-- Save the Vanilla Function
Xsotan.old_createQuantum = Xsotan.createQuantum function Xsotan.createQuantum(_Position, _Unused)
    return GenXsotan.Quantum(_Position)
end

-- Save the Vanilla Function
Xsotan.old_createSummoner = Xsotan.createSummoner function Xsotan.createSummoner(_Position, _Unused)
    return GenXsotan.Summoner(_Position)
end

-- Save the Vanilla Function
Xsotan.old_createGuardian = Xsotan.createGuardian function Xsotan.createGuardian(_Position, _Unused)
    return GenXsotan.WormholeGuardian(_Position)
end

----------------------------------------------------------------------------------------------------------
----------------------------------------- Added Funcitons ------------------------------------------------
----------------------------------------------------------------------------------------------------------

-- Prevent items above the Annihiliator from spawning as a Minion.
-- We don't want summoners spawning in more summoners... yet.
function Xsotan.createSummonerMinion(_Position, _Class) local _MethodName = GetName("Create Minion")
    
    local _Class = GenXsotan.ClassByDistance("Summoner") -- Constant Spawn Table Settings
    local _Ship

    Log.Debug(_MethodName, "Selected Ship Class: " .. tostring(_Class), _Debug)

    if _Class == "Probe" then           _Ship = GenXsotan.Probe(_Position)
    elseif _Class == "Latcher" then     _Ship = GenXsotan.Latcher(_Position)      
    elseif _Class == "Scout" then       _Ship = GenXsotan.Scout(_Position)
    elseif _Class == "Hunter" then      _Ship = GenXsotan.Hunter(_Position)
    elseif _Class == "Reclaimer" then   _Ship = GenXsotan.Reclaimer(_Position)
    elseif _Class == "Decimator" then   _Ship = GenXsotan.Decimator(_Position)
    elseif _Class == "Annihilator" then _Ship = GenXsotan.Annihilator(_Position)
    elseif _Class == "Summoner" then    _Ship = GenXsotan.Annihilator(_Position)
    elseif _Class == "Incubator" then   _Ship = GenXsotan.Annihilator(_Position)
    elseif _Class == "Dreadnought" then _Ship = GenXsotan.Annihilator(_Position)
    end

    return _Ship
end

function Xsotan.createReclaimer(_Position, _Unused)
    return GenXsotan.Reclaimer(_Position)
end

function Xsotan.createProtoGuardian(_Position, _Unused)
    return GenXsotan.ProtoGuardian(_Position)
end

function Xsotan.createReclaimerMinion(_Position, _Unused, _Class) local _MethodName = GetName("Create Minion")

    local _Class = GenXsotan.ClassByDistance("Reclaimer")
    local _Ship = GenXsotan.Latcher(_Position)

    return _Ship
end