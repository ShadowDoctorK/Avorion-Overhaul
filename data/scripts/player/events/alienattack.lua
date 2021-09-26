
package.path = package.path .. ";data/scripts/lib/?.lua"
package.path = package.path .. ";data/scripts/?.lua"

include("stringutility")
include("galaxy")
include("player")
-- include("randomext")

-- local ShipGenerator = include ("shipgenerator")
-- local Xsotan = include("story/xsotan")
-- local SpawnUtility = include ("spawnutility")

local GenXsotan = include("SDKXsotanGenerator")
local Chat = include("SDKUtilityMessenger")
local ChatSensor = include("SDKChatSensors")
local EventUT = include ("eventutility")

local minute = 0
local attackType = 0

if onServer() then

function initialize(attackType_in)
    attackType = attackType_in or 0

    --print("Initialized Vanilla Lua version of Alien Attack Level " .. tostring(attackType))

    deferredCallback(1.0, "update", 1.0)

    -- Check If Allowed
    if not EventUT.attackEventAllowed() then
        terminate() return
    end

    -- Check if too many Xsotan exist
    local Present = Sector():getNumEntitiesByScriptValue("is_xsotan")
    if Present > 2 then
        terminate() return
    end
end

function getUpdateInterval() return 60 end

function update(timeStep)

    --print("Time Step...")

    -- Check If Allowed
    if not EventUT.attackEventAllowed() then
        terminate() return
    end

    minute = minute + 1
    --print("Time: " .. tostring(minute))

    -- Time Catch & Safe Exit
    if minute > 6 then terminate() return end

    -- Scouting Party
    if attackType == 0 then

        if minute == 1 then     Chat.Send("", Chat.I, ChatSensor.ShortBurst())
        elseif minute == 4 then Chat.Send("", Chat.I, ChatSensor.SignalGrowing())
        elseif minute == 5 then 
            Spawn(3) Chat.Send("", Chat.W, ChatSensor.XsotanGroupSmall())
            terminate()
        end

    -- Small Group
    elseif attackType == 1 then

        if minute == 1 then     Chat.Send("", Chat.I, ChatSensor.ShortBurst())
        elseif minute == 4 then Chat.Send("", Chat.I, ChatSensor.SignalGrowing())
        elseif minute == 5 then
            Spawn(5) Chat.Send("", Chat.W, ChatSensor.XsotanGroupMed())
            terminate()
        end

    -- Attack Party
    elseif attackType == 2 then

        if minute == 1 then     Chat.Send("", Chat.I, ChatSensor.ShortBurst())
        elseif minute == 2 then Chat.Send("", Chat.I, ChatSensor.SignalGrowing())
        elseif minute == 4 then Chat.Send("", Chat.I, ChatSensor.SignalWarning())
        elseif minute == 5 then
            Spawn(7) Chat.Send("", Chat.W, ChatSensor.XsotanGroupLarge())
            terminate()
        end

    -- Large Invasion Fleet
    elseif attackType == 3 then

        if minute == 1 then     Chat.Send("", Chat.I, ChatSensor.ShortBurst())
        elseif minute == 2 then Chat.Send("", Chat.I, ChatSensor.SignalGrowing())
        elseif minute == 4 then Chat.Send("", Chat.I, ChatSensor.SignalWarning())
        elseif minute == 5 then
            Spawn(11) Chat.Send("", Chat.W, ChatSensor.XsotanGroupHuge())
            terminate()
        end

    else terminate()
    end

end

function Spawn(n)
    local _Sector = Sector()
    local _Xsotan = GenXsotan.Faction()

    -- Check if there is a bunch of Xsotan Present. Don't overload the sector.
    local Test = Sector():getNumEntitiesByScriptValue("is_xsotan")
    if Test > 2 then terminate() return end

    -- Attack All Non-Player Factions
    GenXsotan.HateAll()

    -- Create Starting Matrix
    local _Dir = normalize(vec3(getFloat(-1, 1), getFloat(-1, 1), getFloat(-1, 1)))
    local _Up = vec3(0, 1, 0)
    local _Right = normalize(cross(_Dir, _Up))
    local _Pos = _Dir * 1500

    -- Spawn Xsotan (Auto Adjust based on distance from core)
    for i = n, 1, -1 do
        local _Ship = CreateShip(MatrixLookUpPosition(-_Dir, _Up, _Pos))
        
        -- Update Next Spawn Matrix
        local _Distance = _Ship:getBoundingSphere().radius + 20
        _Pos = _Pos + _Right * _Distance
        _Ship.translation = dvec3(_Pos.x, _Pos.y, _Pos.z)
        _Pos = _Pos + _Right * _Distance + 20

    end

    -- Warn Other Players
    AlertAbsentPlayers(2, "[Sensors] A Subspace Burst detected in sector \\s(%1%:%2%)!"%_t, _Sector:getCoordinates())

end

function CreateShip(_Position) 
    
    local _Class = GenXsotan.ClassByDistance()
    local _Ship

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

end -- End if OnServer()
