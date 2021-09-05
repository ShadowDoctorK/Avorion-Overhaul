
package.path = package.path .. ";data/scripts/lib/?.lua"
package.path = package.path .. ";data/scripts/?.lua"

include ("galaxy")
include ("stringutility")
include ("randomext")
include ("utility")
include ("defaultscripts")
local PlanGenerator = include ("plangenerator")
local ShipUtility = include ("shiputility")
local SectorTurretGenerator = include ("sectorturretgenerator")
local SectorFighterGenerator = include("sectorfightergenerator")
local StyleGenerator = include ("internal/stylegenerator.lua")      -- Added to support generating ships locally in script
local UpgradeGenerator = include ("upgradegenerator")
local Plan = include("SDKUtilityBlockPlan")
local Log = include("SDKDebugLogging")

local _Debug = 1
local _ModName = "Xsotan Generator" function GetName(n)
    return _ModName .. " - " .. n
end

--[[
Future Plans:
-- Probes:    Jump Into Sectors "Scan" it then send off a signal. If it sends the signal a infestation fleet/Attack fleet will spawn depending on the
--            sector type (Asteroids, Stations, ect...) Signal Levels: Short Burst, Intermedate Burst, Long Burst, Continous. Signal indicates the spawn.
-- Summoners: Convert to a Stationary "Wormhole" for Xsotan Ships to spawn breeders and reclaimers (Infest a Sector) linking infested sectors.
--            Temp Wormholes that will be removed once the Converted Summoner is destroyed. Wormhole allows spawning higher level threats (invasions).
-- Reclaimer: Salvage/Mining Type Ship: Used to Spawn Breeders in future scripts. Begins devloping a sector into a large breeding ground which will
--            connect to other breading grounds invading sector slowly as they "grow"
-- Barrier Gate Sector: Create New Asteroids Matching BD's Designs.

-- Latchers:  Use Tesla Turrets Paired with Force Turrets (Self Pull, High Value, 0.5km Range) to attach to ships and "Eat" them.
]]

local _Swarmers = {}              -- Fighter

local _Probes = {}                -- Slot 1
local _Latchers = {}              -- Slot 2
local _Scouts = {}                -- Slot 3
local _Hunters = {}               -- Slot 6
local _Reclaimers = {}            -- Slot 7
local _Decimators = {}            -- Slot 9
local _Annihilators = {}          -- Slot 10
local _Summoners = {}             -- Slot 12
local _Incubators = {}            -- Slot 12 thru Slot 14: Carrier Class
local _Dreadnoughts = {}          -- Slot 15: ~11M Hull / 21M Shield.
local _ProtoGuardians = {}        -- Slot 15: ~50M Hull / 100M Shield. Make Proto Guardian act like a beefy Summoner.
local _WormholeGuardians = {}     -- Slot 15: ~172M Hull / 100M Shield.

-- BD Designs with hangers: Dreadnought, Summoner, Proto Guardian

function AddSwarmer(t)            if not _Swarmers[t] then table.insert(_Swarmers, t) end end
function AddProbe(t)              if not _Probes[t] then table.insert(_Probes, t) end end
function AddLatcher(t)            if not _Latchers[t] then table.insert(_Latchers, t) end end
function AddScout(t)              if not _Scouts[t] then table.insert(_Scouts, t) end end
function AddHunter(t)             if not _Hunters[t] then table.insert(_Hunters, t) end end
function AddReclaimer(t)          if not _Reclaimers[t] then table.insert(_Reclaimers, t) end end
function AddDecimator(t)          if not _Decimators[t] then table.insert(_Decimators, t) end end
function AddAnnihilator(t)        if not _Annihilators[t] then table.insert(_Annihilators, t) end end
function AddSummoner(t)           if not _Summoners[t] then table.insert(_Summoners, t) end end
function AddCarrier(t)            if not _Incubators[t] then table.insert(_Incubators, t) end end
function AddDreadnought(t)        if not _Dreadnoughts[t] then table.insert(_Dreadnoughts, t) end end
function AddProtoGuardian(t)      if not _ProtoGuardians[t] then table.insert(_ProtoGuardians, t) end end
function AddWormholeGuardian(t)   if not _WormholeGuardians[t] then table.insert(_WormholeGuardians, t) end end

------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------ Standard Plans --------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------
--[[ The Following Designs were donated to this mod for the default assests. Additional ones can be added via an extension mod found
on the Workshop.]]

---------------------------------------------------- Black Disciple Items ----------------------------------------------------

AddSwarmer("data/plans/Default/Xsotan/Black Disciple - Xsotan Swarmer0.xml") 
AddProbe("data/plans/Default/Xsotan/Black Disciple - Xsotan Probe0.xml") 
AddLatcher("data/plans/Default/Xsotan/Black Disciple - Xsotan Latcher0.xml") 
AddScout("data/plans/Default/Xsotan/Black Disciple - Xsotan Scout0.xml") 
AddHunter("data/plans/Default/Xsotan/Black Disciple - Xsotan Hunter0.xml") 
AddReclaimer("data/plans/Default/Xsotan/Black Disciple - Xsotan Reclaimer0.xml") 
AddDecimator("data/plans/Default/Xsotan/Black Disciple - Xsotan Decimator0.xml") 
AddAnnihilator("data/plans/Default/Xsotan/Black Disciple - Xsotan Annihilator0.xml") 
AddSummoner("data/plans/Default/Xsotan/Black Disciple - Xsotan Summoner0.xml") 
AddCarrier("data/plans/Default/Xsotan/Black Disciple - Xsotan Incubator0.xml") 
AddDreadnought("data/plans/Default/Xsotan/Black Disciple - Xsotan Dreadnought0.xml") 
AddProtoGuardian("data/plans/Default/Xsotan/Black Disciple - Xsotan Proto Guardian0.xml") 
AddWormholeGuardian("data/plans/Default/Xsotan/Black Disciple - Xsotan Wormhole Guardian0.xml") 

------------------------------------------------------------------------------------------------------------------------------

local SDKXsotanGenerator = {}

SDKXsotanGenerator.VolumeShips = {}
SDKXsotanGenerator.VolumeShips[1]  = 1       -- Slot 1
SDKXsotanGenerator.VolumeShips[2]  = 51      -- Slot 2
SDKXsotanGenerator.VolumeShips[3]  = 128     -- Slot 3
SDKXsotanGenerator.VolumeShips[4]  = 320     -- Slot 4
SDKXsotanGenerator.VolumeShips[5]  = 800     -- Slot 5
SDKXsotanGenerator.VolumeShips[6]  = 2000    -- Slot 6
SDKXsotanGenerator.VolumeShips[7]  = 5000    -- Slot 7
SDKXsotanGenerator.VolumeShips[8]  = 12500   -- Slot 8
SDKXsotanGenerator.VolumeShips[9]  = 19764   -- Slot 9
SDKXsotanGenerator.VolumeShips[10] = 31250   -- Slot 10
SDKXsotanGenerator.VolumeShips[11] = 43065   -- Slot 11
SDKXsotanGenerator.VolumeShips[12] = 59348   -- Slot 12
SDKXsotanGenerator.VolumeShips[13] = 78125   -- Slot 13
SDKXsotanGenerator.VolumeShips[14] = 107554  -- Slot 14
SDKXsotanGenerator.VolumeShips[15] = 148371  -- Slot 15
SDKXsotanGenerator.VolumeShips[16] = 250000  -- Titan Scale / Max Size Limit For Slot 15 
SDKXsotanGenerator.VolumeShips[17] = 500000  -- Max Size Limit for AI Titan Class
SDKXsotanGenerator.VolumeShips[18] = 1500000  -- Max Size For Guardian

------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------- Support Functions -------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------


function SDKXsotanGenerator.DistanceFromCore(_X, _Y) local _MethodName = GetName("Distance From Core")
    if not _X or not _Y then 
        _X, _Y = Sector():getCoordinates()
    end

    Log.Debug(_MethodName, "(Absolute) X: " .. tostring(_X) .. " | (Absolute) Y: " .. tostring(_Y), _Debug)
    _X = math.abs(_X) _Y = math.abs(_Y)
    local _Distance = math.sqrt((_X ^ 2) + (_Y ^ 2))

    Log.Debug(_MethodName, "Sectors From Core: "  .. tostring(_Distance), _Debug)
    return _Distance
end

function SDKXsotanGenerator.PlansByClass(_Class) local _MethodName = GetName("Plan By Class")

    Log.Debug(_MethodName, "Getting " .. tostring(_Class) .. " Designs", _Debug)

    local _Table = nil

    if _Class then
        if _Class == "Probe" then _Table = _Probes
        elseif _Class == "Latcher" then _Table = _Latchers 
        elseif _Class == "Scout" then _Table = _Scouts
        elseif _Class == "Hunter" then _Table = _Hunters
        elseif _Class == "Reclaimer" then _Table = _Reclaimers
        elseif _Class == "Decimator" then _Table = _Decimators
        elseif _Class == "Annihilator" then _Table = _Annihilators
        elseif _Class == "Summoner" then _Table = _Summoners
        elseif _Class == "Incubator" then _Table = _Incubators
        elseif _Class == "Dreadnought" then _Table = _Dreadnoughts
        elseif _Class == "Proto-Guardian" then _Table = _ProtoGuardians
        elseif _Class == "Guardian" then _Table = _WormholeGuardians
        end
    else
        Log.Warning(_MethodName, "No Vaild Class Given. Returning Game Generated Ship")
        return nil
    end

    if not _Table or #_Table == 0 then
        Log.Warning(_MethodName, "No Designs Were Found For The Class Given. Returning Game Generated Ship")
        return nil
    end

    return _Table

end

-- Replaces "Upscale" from the xsotan.lua. Xsotan grow and breed from Asteroids, Stations
-- Ships and anything that has a energy signature. Their developement (Size) should reach
-- a certain state before they attempt to leave the "nest" so you should see a small variation
-- in size but the class of ship and size should be constant. The longer the distance from the
-- core the more lower class ship types should be encountered with less developed tech and material
-- due to the "breeding ground" effect.
-- You can pass it a class and a X,Y to override the default
-- Chance Auto Adjusts based on the distance from the core.
function SDKXsotanGenerator.ClassByDistance(_Class, _X, _Y, _Overrides) local _MethodName = GetName("Class By Distance")

    local _Random = Random(Seed(os.time() + 4872))
    local _Selected = _Random:getInt(1, 10000) / 100
    local _Distance = SDKXsotanGenerator.DistanceFromCore(_X, _Y)

    local _UseTable = true if _Class ~= nil then _UseTable = false end
    
    local C1 = 0        -- Probes
    local C2 = 0        -- Latchers
    local C3 = 0        -- Scouts
    local C4 = 0        -- Hunters
    local C5 = 0        -- Reclaimers
    local C6 = 0        -- Decimators
    local C7 = 0        -- Annihilators
    local C8 = 0        -- Summoners
    local C9 = 0        -- Incubators
    local C10 = 0       -- Dreadnoughts

    if _Class then
        if _Class == "Reclaimer" then
            C2 = 100  -- Latchers
        elseif _Class == "Summoner" then
            C4 = 40   -- Hunters
            C5 = 40   -- Reclaimers
            C6 = 80   -- Decimators
            C7 = 100  -- Annihilators
        end
    end        

    -- Xsotan have grown more near the core where they breached the galaxy
    -- and are flooding in. They are less devloped at the outer edges of the galaxy
    -- so you should only see larger classes as you move to the center.
    -- Other classes wont be missed because they will be used by the summoner, reclaimer,
    -- and the incubator (Carrier) so they will still be seen.
    if _UseTable then           
        if _Distance <= 75 then                     -- 075 to 000: Avorion (Inside Barrier)
            C5 = 10     C6 = 20      C7 = 50
            C8 = 70     C9 = 90      C10 = 100
        elseif _Distance <= 150 then                -- 150 to 075: Ogonite (Inside Barrier)
            C4 = 10     C5 = 20      C6 = 40
            C7 = 70     C8 = 90      C9 = 100
        elseif _Distance <= 200 then                -- 200 to 150: Xanion 
            C5 = 10     C6 = 35      C7 = 65
            C8 = 95     C9 = 100
        elseif _Distance <= 300 then                -- 300 to 200: Trinium
            C4 = 10     C5 = 35     C6 = 65
            C7 = 95     C8 = 100
        elseif _Distance <= 375 then                -- 375 to 300: Naonite
            C3 = 10     C4 = 35     C5 = 65
            C6 = 95     C7 = 100
        elseif _Distance <= 425 then                -- 425 to 375: Second Part Iron/Titanium
            C2 = 10     C3 = 35     C4 = 65
            C5 = 65     C6 = 100
        else                                        -- 500 to 425: First Part Iron/Titanium
            C1 = 10     C2 = 35     C3 = 65
            C4 = 95     C5 = 100
        end
    end

    Log.Debug(_MethodName, 
        "Probe: " .. tostring(C1) .. 
        " | Latcher: " .. tostring(C2) .. 
        " | Scout: " .. tostring(C3) ..         
        " | Hunter: " .. tostring(C4) .. 
        " | Reclaimer: " .. tostring(C5) .. 
        " | Decimator: " .. tostring(C6) .. 
        " | Annihilator: " .. tostring(C7) .. 
        " | Summoner: " .. tostring(C8) ..
        " | Incubator: " .. tostring(C9) ..
        " | Dreadnought: " .. tostring(C10), _Debug)

    Log.Debug(_MethodName, "Selected: " .. tostring(_Selected), _Debug)

    if _Selected <= C1 then      return "Probe"
    elseif _Selected <= C2 then  return "Latcher"
    elseif _Selected <= C3 then  return "Scout"
    elseif _Selected <= C4 then  return "Hunter"
    elseif _Selected <= C5 then  return "Reclaimer"
    elseif _Selected <= C6 then  return "Decimator"
    elseif _Selected <= C7 then  return "Annihilator"
    elseif _Selected <= C8 then  return "Summoner"
    elseif _Selected <= C9 then  return "Incubator"
    elseif _Selected <= C10 then return "Dreadnought"
    else
        Log.Warning(_MethodName, "Returning Default: Hunter.")
        return "Hunter"
    end

end

function SDKXsotanGenerator.Corrdinates()
    return Sector():getCoordinates()
end

function SDKXsotanGenerator.Material()
    local _X, _Y = SDKXsotanGenerator.Corrdinates()
    local _Prob = Balancing_GetTechnologyMaterialProbability(_X, _Y)
    return Material(getValueFromDistribution(_Prob))
end

function SDKXsotanGenerator.Faction()
    local name = "The Xsotan"%_T

    local galaxy = Galaxy()
    local faction = galaxy:findFaction(name)
    if faction == nil then
        faction = galaxy:createFaction(name, 0, 0)
        faction.initialRelations = -100000
        faction.initialRelationsToPlayer = 0
        faction.staticRelationsToPlayers = true

        for trait, value in pairs(faction:getTraits()) do
            faction:setTrait(trait, 0) -- completely neutral / unknown
        end
    end

    faction.initialRelationsToPlayer = 0
    faction.staticRelationsToPlayers = true
    faction.homeSectorUnknown = true

    return faction

end

--[[
    Function used to make the Xsotan go to war with all factions but the Player in 
    the target sector the script is running in.
]]
function SDKXsotanGenerator.HateAll()
    local _Galaxy = Galaxy()
    local _Sector = Sector()
    local _Xsotan = SDKXsotanGenerator.Faction()

    -- worsen relations to all present players and alliances
    local _Factions = {_Sector:getPresentFactions()}
    for _, _Index in pairs(_Factions) do
        local _Faction = Faction(_Index)
        if _Faction then
            if _Faction.isAIFaction then
                _Galaxy:setFactionRelations(_Xsotan, _Faction, -100000)
                _Galaxy:setFactionRelationStatus(_Xsotan, _Faction, RelationStatus.War)
            else -- Player
                _Galaxy:setFactionRelations(_Xsotan, _Faction, 0, false, false)
                _Galaxy:setFactionRelationStatus(_Xsotan, _Faction, RelationStatus.Neutral, false, false)
            end
        end
    end
end

function SDKXsotanGenerator.GrowthPrefix(_Volume, _VolLow, _VolHigh) local _MethodName = GetName("Growth Prefix")
    local _Regular = (_VolHigh - _VolLow) / 3 
    local _Prefix = ""

    Log.Debug(_MethodName, "Regular: " .. tostring( _VolLow + _Regular), _Debug)
    Log.Debug(_MethodName, "Mature: " .. tostring( _VolLow + _Regular * 2), _Debug)
    Log.Debug(_MethodName, "Ship Volume: " .. tostring(_Volume), _Debug)

    -- Mature
    if _Volume > _VolLow + _Regular * 2 then
        _Prefix = "Overgrown "            
    -- Overgrown
    elseif _Volume > _VolLow +  _Regular then
        _Prefix = "Mature "            
    end
        
    return  _Prefix
end

function SDKXsotanGenerator.RandomRarity()
    local _Random = Random(Seed(os.time() + 234))
    local _Target = _Random:getInt(-1, 5)

    if _Target == -1 then
        return RarityType.Petty
    elseif _Target == 0 then
        return RarityType.Common
    elseif _Target == 1 then
        return RarityType.Uncommon
    elseif _Target == 2 then
        return RarityType.Rare
    elseif _Target == 3 then
        return RarityType.Exceptional
    elseif _Target == 4 then
        return RarityType.Exotic
    elseif _Target == 5 then
        return RarityType.Legendary
    end
end

function SDKXsotanGenerator.DifficultyAdjustment(_Volume) local _MethodName = GetName("Difficulty Adjustment")
    -- Adjust based on Difficulty
    local _Settings = GameSettings()
    if _Settings.difficulty == Difficulty.Insane then 
        _Volume = _Volume * 1.15
    elseif _Settings.difficulty == Difficulty.Hardcore then 
        _Volume = _Volume
    elseif _Settings.difficulty == Difficulty.Expert then 
        _Volume = _Volume * 0.65
    elseif _Settings.difficulty == Difficulty.Veteran then 
        _Volume = _Volume * 0.55
    elseif _Settings.difficulty == Difficulty.Normal then 
        _Volume = _Volume * 0.40
    elseif _Settings.difficulty == Difficulty.Easy then 
        _Volume = _Volume * 0.30
    end

    Log.Debug(_MethodName, "Adjusted Volume: " .. tostring(_Volume), _Debug)
    return _Volume
end

if onServer() then

    -- Function To Add Quantum Ability To Other Ship Classes
    -- Quantums will occur more at higher difficulty settings.
    function SDKXsotanGenerator.EvaluateQuantum(_ClassFactor, _Override) local _MethodName = GetName("Evaluate Quantum")

        _Override = _Override or "Eval"
        local _Answer = ""

        -- If nil then random roll
        if _Override == "Eval" then
            Log.Debug(_MethodName, "Evaluate...", _Debug)

            local _Random = Random(Seed(os.time() + 5))
            local _Base = 0.06 -- 6% Base Chance

            Log.Debug(_MethodName, "Chance (Base): " ..  tostring(_Base), _Debug)
        
            -- Adjust based on Difficulty
            local _Settings = GameSettings()
            if _Settings.difficulty == Difficulty.Insane then 
                _Base = _Base * 3
            elseif _Settings.difficulty == Difficulty.Hardcore then 
                _Base = _Base * 2
            elseif _Settings.difficulty == Difficulty.Expert then 
                _Base = _Base * 1.66
            elseif _Settings.difficulty == Difficulty.Veteran then 
                _Base = _Base * 1.33
            elseif _Settings.difficulty == Difficulty.Normal then 
                _Base = _Base * 1
            elseif _Settings.difficulty == Difficulty.Easy then 
                _Base = _Base * 0.5
            end

            Log.Debug(_MethodName, "Chance (Difficulty Adjustment): " ..  tostring(_Base), _Debug)

            -- Max 18% chance for Quantums on Insane at 0,0 Sector
            -- Reduces chance farther from the core.
            local _Factor = SDKXsotanGenerator.DistanceFromCore() / 500
            Log.Debug(_MethodName, "Chance (Factor): " ..  tostring(_Factor), _Debug)

            local _Reduce = _Base * _Factor
            Log.Debug(_MethodName, "Chance (Class Factor): " ..  tostring(_ClassFactor), _Debug)
            Log.Debug(_MethodName, "Chance (Reduction): " ..  tostring(_Reduce), _Debug)

            _Base = _Base - _Reduce
            _Base = _Base * _ClassFactor
            _Base = _Base * 100
            
            Log.Debug(_MethodName, "Chance (Final): " ..  tostring(_Base), _Debug)
            local _Chance = _Random:getInt(0, 10000)/100 if _Chance <= _Base then
                _Answer = "Quantum "
            end

        elseif _Override == "true" then 
            Log.Debug(_MethodName, "Override: True", _Debug)
            _Answer =  "Quantum "
        elseif _Override == "false" then 
            Log.Debug(_MethodName, "Override: False", _Debug)        
        end

        Log.Debug(_MethodName, "Answer: " .. tostring(_Answer), _Debug)
        return _Answer

    end

    function SDKXsotanGenerator.GameGenerateShip(_Volume, _Material)
        local StyleGenerator = StyleGenerator(1337)

        local _Seed = math.random(0xffffffff)
        local _Style = StyleGenerator:makeXsotanShipStyle(_Seed)
        local _Plan = GeneratePlanFromStyle(_Style, Seed(tostring(_Seed)), _Volume, 5000, nil, _Material)
        return _Plan
    end

    function SDKXsotanGenerator.GameGenerateGuardian(_Volume, _Material)

        _Volume = _Volume / 8 -- divide by 8 so we don't use the plan scale volume for all 8 parts.

        local _Plan = SDKXsotanGenerator.GameGenerateGuardian(_Volume, _Material)
        local front = SDKXsotanGenerator.GameGenerateGuardian(_Volume, _Material)
        local back = SDKXsotanGenerator.GameGenerateGuardian(_Volume, _Material)
        local top = SDKXsotanGenerator.GameGenerateGuardian(_Volume, _Material)
        local bottom = SDKXsotanGenerator.GameGenerateGuardian(_Volume, _Material)
        local left = SDKXsotanGenerator.GameGenerateGuardian(_Volume, _Material)
        local right = SDKXsotanGenerator.GameGenerateGuardian(_Volume, _Material)
        local frontleft= SDKXsotanGenerator.GameGenerateGuardian(_Volume, _Material)
        local frontright = SDKXsotanGenerator.GameGenerateGuardian(_Volume, _Material)

        SDKXsotanGenerator.infectPlan(_Plan)
        SDKXsotanGenerator.infectPlan(front)
        SDKXsotanGenerator.infectPlan(back)
        SDKXsotanGenerator.infectPlan(top)
        SDKXsotanGenerator.infectPlan(bottom)
        SDKXsotanGenerator.infectPlan(left)
        SDKXsotanGenerator.infectPlan(right)
        SDKXsotanGenerator.infectPlan(frontleft)
        SDKXsotanGenerator.infectPlan(frontright)

        attachMin(_Plan, back, "z")
        attachMax(_Plan, front, "z")
        attachMax(_Plan, front, "z")

        attachMin(_Plan, bottom, "y")
        attachMax(_Plan, top, "y")

        attachMin(_Plan, left, "x")
        attachMax(_Plan, right, "x")

        local self = findMaxBlock(_Plan, "z")
        local other = findMinBlock(frontleft, "x")
        _Plan:addPlanDisplaced(self.index, frontleft, other.index, self.box.center - other.box.center)

        local other = findMaxBlock(frontright, "x")
        _Plan:addPlanDisplaced(self.index, frontright, other.index, self.box.center - other.box.center)

        return _Plan
    end

    -- Used when using the games generator to make a Guardian
    function SDKXsotanGenerator.infectPlan(_Plan)
        _Plan:center()

        local tree = PlanBspTree(_Plan)

        local height = _Plan:getBoundingBox().size.y

        local positions = {}

        for i = 0, 15 do

            local rad = getFloat(0, math.pi * 2)
            local hspread = height / getFloat(2.5, 3.5)

            for h = -hspread, hspread, 15 do
                local ray = Ray()
                ray.origin = vec3(math.sin(rad), 0, math.cos(rad)) * 100 + vec3(getFloat(10, 100), 0, getFloat(10, 100))
                ray.direction = -ray.origin

                ray.origin = ray.origin + vec3(0, h + getFloat(-7.5, 7.5), 0)

                local dir = normalize(ray.direction)

                local index, p = tree:intersectRay(ray, 0, 1)
                if index then
                    table.insert(positions, {position = p + dir, index = index})
                end
            end
        end

        local material = _Plan.root.material

        for _, p in pairs(positions) do
            local addition = SDKXsotanGenerator.makeInfectAddition(vec3(15, 4, 15), material, 0)

            addition:scale(vec3(getFloat(0.5, 2.5), getFloat(0.9, 1.1), getFloat(0.5, 2.5)))
            addition:center()

            _Plan:addPlanDisplaced(p.index, addition, addition.rootIndex, p.position)
        end

    end

    -- Used when using the games generator to make a Guardian
    function SDKXsotanGenerator.makeInfectAddition(size, material, level)

        level = level or 0

        local color = ColorRGB(0.35, 0.35, 0.35)

        local ls = vec3(getFloat(0.1, 0.3), getFloat(0.1, 0.3), getFloat(0.1, 0.3))
        local us = vec3(getFloat(0.1, 0.3), getFloat(0.1, 0.3), getFloat(0.1, 0.3))
        local s = vec3(1, 1, 1) - ls - us

        local hls = ls * 0.5
        local hus = us * 0.5
        local hs = s * 0.5

        local center = BlockType.BlankHull
        local edge = BlockType.EdgeHull
        local corner = BlockType.CornerHull

        local plan = BlockPlan()
        local ci = plan:addBlock(vec3(0, 0, 0), s, -1, -1, color, material, Matrix(), center)

        -- top left right
        plan:addBlock(vec3(hs.x + hus.x, 0, 0), vec3(us.x, s.y, s.z), ci, -1, color, material, MatrixLookUp(vec3(-1, 0, 0), vec3(0, 1, 0)), edge)
        plan:addBlock(vec3(-hs.x - hls.x, 0, 0), vec3(ls.x, s.y, s.z), ci, -1, color, material, MatrixLookUp(vec3(1, 0, 0), vec3(0, 1, 0)), edge)

        -- top front back
        plan:addBlock(vec3(0, 0, hs.z + hus.z), vec3(s.x, s.y, us.z), ci, -1, color, material, MatrixLookUp(vec3(0, 0, -1), vec3(0, 1, 0)), edge)
        plan:addBlock(vec3(0, 0, -hs.z - hls.z), vec3(s.x, s.y, ls.z), ci, -1, color, material, MatrixLookUp(vec3(0, 0, 1), vec3(0, 1, 0)), edge)

        -- top edges
        -- left right
        plan:addBlock(vec3(hs.x + hus.x, 0, -hs.z - hls.z), vec3(us.x, s.y, ls.z), ci, -1, color, material, MatrixLookUp(vec3(-1, 0, 0), vec3(0, 1, 0)), corner)
        plan:addBlock(vec3(-hs.x - hls.x, 0, -hs.z - hls.z), vec3(ls.x, s.y, ls.z), ci, -1, color, material, MatrixLookUp(vec3(1, 0, 0), vec3(0, 0, -1)), corner)

        -- front back
        plan:addBlock(vec3(hs.x + hus.x, 0, hs.z + hus.z), vec3(us.x, s.y, us.z), ci, -1, color, material, MatrixLookUp(vec3(-1, 0, 0), vec3(0, 0, 1)), corner)
        plan:addBlock(vec3(-hs.x - hls.x, 0, hs.z + hus.z), vec3(ls.x, s.y, us.z), ci, -1, color, material, MatrixLookUp(vec3(1, 0, 0), vec3(0, 1, 0)), corner)

        plan:scale(size)

        local addition = copy(plan)
        addition:displace(vec3(size.x * 0.05, -size.y * getFloat(0.6, 0.9), size.z * 0.05))

        if level >= 1 then
            local displacement = vec3(
                size.x * getFloat(0.1, 0.2),
                0,
                size.z * getFloat(0.1, 0.2)
            )

            addition:addPlanDisplaced(addition.rootIndex, plan, 0, displacement)
        end
        if level >= 2 then
            local displacement = vec3(
                size.x * getFloat(0.2, 0.3),
                size.y * getFloat(0.6, 0.9),
                size.z * getFloat(0.2, 0.3)
            )

            addition:addPlanDisplaced(addition.rootIndex, plan, 0, displacement)
        end

        return addition
    end

    ------------------------------------------------------------------------------------------------------------------------------
    ---------------------------------------------------- Ship Construction -------------------------------------------------------
    ------------------------------------------------------------------------------------------------------------------------------

    function SDKXsotanGenerator.Quantum(_Position) local _MethodName = GetName("Quantum")
    
        local _Class = SDKXsotanGenerator.ClassByDistance()
        local _Ship
    
        Log.Debug(_MethodName, "Selected Ship Class: " .. tostring(_Class), _Debug)
    
        if _Class == "Probe" then                               -- No Quantum Probes
            _Ship = SDKXsotanGenerator.Hunter(_Position, "true")
        elseif _Class == "Latcher" then                         -- No Quantum Latchers
            _Ship = SDKXsotanGenerator.Hunter(_Position, "true")
        elseif _Class == "Scout" then                           -- No Quantum Scouts
            _Ship = SDKXsotanGenerator.Hunter(_Position, "true")
        elseif _Class == "Hunter" then
            _Ship = SDKXsotanGenerator.Hunter(_Position, "true")
        elseif _Class == "Reclaimer" then
            _Ship = SDKXsotanGenerator.Reclaimer(_Position, "true")
        elseif _Class == "Decimator" then
            _Ship = SDKXsotanGenerator.Decimator(_Position, "true")
        elseif _Class == "Annihilator" then
            _Ship = SDKXsotanGenerator.Annihilator(_Position, "true")
        elseif _Class == "Summoner" then
            _Ship = SDKXsotanGenerator.Summoner(_Position, "true")
        elseif _Class == "Incubator" then
            _Ship = SDKXsotanGenerator.Incubator(_Position, nil, "true")
        elseif _Class == "Dreadnought" then
            _Ship = SDKXsotanGenerator.Annihilator(_Position, "true") -- No Quantum Dreadnoughts
        end
    
        return _Ship
        
    end
    
    function SDKXsotanGenerator.Probe(_Position) local _MethodName = GetName("Probe")
        
        _Position = _Position or Matrix()
        local _X, _Y = SDKXsotanGenerator.Corrdinates()
        local _Name = "Probe"
        local _VolLow = SDKXsotanGenerator.VolumeShips[1]
        local _VolHigh = SDKXsotanGenerator.VolumeShips[2] - 1
        local _Volume = random():getInt(_VolLow, _VolHigh)
        local _Prefix = SDKXsotanGenerator.GrowthPrefix(_Volume, _VolLow, _VolHigh)
        local _Material = SDKXsotanGenerator.Material()
        local _Faction = SDKXsotanGenerator.Faction()
    
        _Volume = SDKXsotanGenerator.DifficultyAdjustment(_Volume)
    
        local _Plan local _Table = SDKXsotanGenerator.PlansByClass("Probe") if _Table then
            Plan.Pick(_Table)
            Plan.Material(_Material, "Tier")
            _Plan = Plan.Get()
        else
            Log.Warning(_MethodName, "No Valid Plan, Using Game Generatored Ship")
            _Plan = SDKXsotanGenerator.GameGenerateShip(_Volume, _Material)
        end
    
        -- scale
        if _Volume and _Plan then
            local _Factor = math.pow(_Volume / _Plan.volume, 1 / 3)
            _Plan:scale(vec3(_Factor))
        end
    
        local _Ship = Sector():createShip(_Faction, "", _Plan, _Position)
    
        -- Xsotan have random turrets
        local turret = SectorTurretGenerator():generateArmed(_X, _Y, 0, Rarity(RarityType.Rare))
    
        ShipUtility.addTurretsToCraft(_Ship, turret, 1)
    
        _Ship:setTitle("${toughness}"%_T .. _Prefix .. "${name}"%_T, {toughness = "", name = _Name})
        _Ship.crew = _Ship.idealCrew
        _Ship.shieldDurability = _Ship.shieldMaxDurability
    
        AddDefaultShipScripts(_Ship)
    
        _Ship:addScriptOnce("ai/patrol.lua")
        _Ship:addScriptOnce("story/xsotanbehaviour.lua")
        _Ship:setValue("is_xsotan", 1)
    
        Boarding(_Ship).boardable = false
    
        return _Ship
    end
    
    -- Future Ship Design
    function SDKXsotanGenerator.Latcher(_Position) local _MethodName = GetName("Latcher")
        
        _Position = _Position or Matrix()
        local _X, _Y = SDKXsotanGenerator.Corrdinates()
        local _Name = "Latcher"
        local _VolLow = SDKXsotanGenerator.VolumeShips[2]
        local _VolHigh = SDKXsotanGenerator.VolumeShips[3] - 1
        local _Volume = random():getInt(_VolLow, _VolHigh)
        local _Prefix = SDKXsotanGenerator.GrowthPrefix(_Volume, _VolLow, _VolHigh)
        local _Material = SDKXsotanGenerator.Material()
        local _Faction = SDKXsotanGenerator.Faction()
    
        _Volume = SDKXsotanGenerator.DifficultyAdjustment(_Volume)
    
        local _Plan local _Table = SDKXsotanGenerator.PlansByClass("Latcher") if _Table then
            Plan.Pick(_Table)
            Plan.Material(_Material, "Tier")
            _Plan = Plan.Get()
        else
            Log.Warning(_MethodName, "No Valid Plan, Using Game Generatored Ship")
            _Plan = SDKXsotanGenerator.GameGenerateShip(_Volume, _Material)
        end
    
        -- scale
        if _Volume and _Plan then
            local _Factor = math.pow(_Volume / _Plan.volume, 1 / 3)
            _Plan:scale(vec3(_Factor))
        end
    
        local _Ship = Sector():createShip(_Faction, "", _Plan, _Position)
    
        -- Xsotan have random turrets     
        ShipUtility.addTurretsToCraft(_Ship, SDKXsotanGenerator.LatcherTeslaTurret(), 4, 4)
    
        _Ship:setTitle("${toughness}"%_T .. _Prefix .. "${name}"%_T, {toughness = "", name = _Name})
        _Ship.crew = _Ship.idealCrew
        _Ship.shieldDurability = _Ship.shieldMaxDurability
    
        AddDefaultShipScripts(_Ship)
    
        _Ship:addScriptOnce("ai/patrol.lua")
        _Ship:addScriptOnce("story/xsotanbehaviour.lua")
        _Ship:setValue("is_xsotan", 1)
        _Ship:addAbsoluteBias(StatsBonuses.Velocity, 10000000.0)
        _Ship:addAbsoluteBias(StatsBonuses.Acceleration, 250.0)
    
        Boarding(_Ship).boardable = false
    
        return _Ship
    end
    
    function SDKXsotanGenerator.Scout(_Position) local _MethodName = GetName("Scout")
        
        _Position = _Position or Matrix()
        local _X, _Y = SDKXsotanGenerator.Corrdinates()
        local _Name = "Scout"
        local _VolLow = SDKXsotanGenerator.VolumeShips[3]
        local _VolHigh = SDKXsotanGenerator.VolumeShips[5] - 1
        local _Volume = random():getInt(_VolLow, _VolHigh)
        local _Prefix = SDKXsotanGenerator.GrowthPrefix(_Volume, _VolLow, _VolHigh)
        local _Material = SDKXsotanGenerator.Material()
        local _Faction = SDKXsotanGenerator.Faction()
    
        _Volume = SDKXsotanGenerator.DifficultyAdjustment(_Volume)
    
        local _Plan local _Table = SDKXsotanGenerator.PlansByClass("Scout") if _Table then
            Plan.Pick(_Table)
            Plan.Material(_Material, "Tier")
            _Plan = Plan.Get()
        else
            Log.Warning(_MethodName, "No Valid Plan, Using Game Generatored Ship")
            _Plan = SDKXsotanGenerator.GameGenerateShip(_Volume, _Material)
        end
        
        -- scale
        if _Volume and _Plan then
            local _Factor = math.pow(_Volume / _Plan.volume, 1 / 3)
            _Plan:scale(vec3(_Factor))
        end
    
        local _Ship = Sector():createShip(_Faction, "", _Plan, _Position)
    
        -- Xsotan have random turrets
        local turret = SectorTurretGenerator():generateArmed(_X, _Y, 0, Rarity(RarityType.Rare))
    
        ShipUtility.addTurretsToCraft(_Ship, turret, 1)
    
        _Ship:setTitle("${toughness}"%_T .. _Prefix .. "${name}"%_T, {toughness = "", name = _Name})
        _Ship.crew = _Ship.idealCrew
        _Ship.shieldDurability = _Ship.shieldMaxDurability
    
        AddDefaultShipScripts(_Ship)
    
        _Ship:addScriptOnce("ai/patrol.lua")
        _Ship:addScriptOnce("story/xsotanbehaviour.lua")
        _Ship:setValue("is_xsotan", 1)
    
        Boarding(_Ship).boardable = false
    
        return _Ship
    end
    
    function SDKXsotanGenerator.Hunter(_Position, _OverrideQuantum) local _MethodName = GetName("Hunter")
        
        _Position = _Position or Matrix()
        local _X, _Y = SDKXsotanGenerator.Corrdinates()
        local _Name = "Hunter"
        local _VolLow = SDKXsotanGenerator.VolumeShips[6]
        local _VolHigh = SDKXsotanGenerator.VolumeShips[7] - 1
        local _Volume = random():getInt(_VolLow, _VolHigh)
        local _Prefix = SDKXsotanGenerator.GrowthPrefix(_Volume, _VolLow, _VolHigh)
        local _Material = SDKXsotanGenerator.Material()
        local _Faction = SDKXsotanGenerator.Faction()
    
        _Volume = SDKXsotanGenerator.DifficultyAdjustment(_Volume)
    
        local _Plan local _Table = SDKXsotanGenerator.PlansByClass("Hunter") if _Table then
            Plan.Pick(_Table)
            Plan.Material(_Material, "Tier")
            _Plan = Plan.Get()
        else
            Log.Warning(_MethodName, "No Valid Plan, Using Game Generatored Ship")
            _Plan = SDKXsotanGenerator.GameGenerateShip(_Volume, _Material)
        end
    
        -- scale
        if _Volume and _Plan then
            local _Factor = math.pow(_Volume / _Plan.volume, 1 / 3)
            _Plan:scale(vec3(_Factor))
        end
    
        local _Ship = Sector():createShip(_Faction, "", _Plan, _Position)
        
        -- Xsotan have random turrets
        local turret = SectorTurretGenerator():generateArmed(_X, _Y, 0, Rarity(RarityType.Rare))
        local numTurrets = math.max(2, Balancing_GetEnemySectorTurrets(x, y) * 0.75)
    
        local _Quantum = SDKXsotanGenerator.EvaluateQuantum(0.25, _OverrideQuantum)     
    
        ShipUtility.addTurretsToCraft(_Ship, turret, numTurrets)
    
        _Ship:setTitle("${toughness}"%_T .. _Prefix .. _Quantum .. "${name}"%_T, {toughness = "", name = _Name})
        _Ship.crew = _Ship.idealCrew
        _Ship.shieldDurability = _Ship.shieldMaxDurability
    
        AddDefaultShipScripts(_Ship)
    
        _Ship:addScriptOnce("ai/patrol.lua")
        _Ship:addScriptOnce("story/xsotanbehaviour.lua")
        _Ship:setValue("is_xsotan", 1)
        if _Quantum == "Quantum " then _Ship:addScriptOnce("enemies/SDKQuantum.lua") end
    
        Boarding(_Ship).boardable = false
    
        return _Ship
    end
    
    function SDKXsotanGenerator.Reclaimer(_Position, _OverrideQuantum) local _MethodName = GetName("Reclaimer")
        
        _Position = _Position or Matrix()
        local _X, _Y = SDKXsotanGenerator.Corrdinates()
        local _Name = "Reclaimer"
        local _VolLow = SDKXsotanGenerator.VolumeShips[7]
        local _VolHigh = SDKXsotanGenerator.VolumeShips[8] - 1
        local _Volume = random():getInt(_VolLow, _VolHigh)
        local _Prefix = SDKXsotanGenerator.GrowthPrefix(_Volume, _VolLow, _VolHigh)
        local _Material = SDKXsotanGenerator.Material()
        local _Faction = SDKXsotanGenerator.Faction()
    
        _Volume = SDKXsotanGenerator.DifficultyAdjustment(_Volume)
    
        local _Plan local _Table = SDKXsotanGenerator.PlansByClass("Reclaimer") if _Table then
            Plan.Pick(_Table)
            Plan.Material(_Material, "Tier")
            _Plan = Plan.Get()
        else
            Log.Warning(_MethodName, "No Valid Plan, Using Game Generatored Ship")
            _Plan = SDKXsotanGenerator.GameGenerateShip(_Volume, _Material)
        end
    
        -- scale
        if _Volume and _Plan then
            local _Factor = math.pow(_Volume / _Plan.volume, 1 / 3)
            _Plan:scale(vec3(_Factor))
        end
        
        local _Ship = Sector():createShip(_Faction, "", _Plan, _Position)
    
        -- Xsotan have random turrets
        local turret = SectorTurretGenerator():generateArmed(_X, _Y, 0, Rarity(RarityType.Rare))
        local numTurrets = math.max(2, Balancing_GetEnemySectorTurrets(x, y) * 0.75)
    
        local _Quantum = SDKXsotanGenerator.EvaluateQuantum(0.35, _OverrideQuantum)     
        
        ShipUtility.addTurretsToCraft(_Ship, turret, numTurrets)
    
        _Ship:setTitle("${toughness}"%_T .. _Prefix .. _Quantum .. "${name}"%_T, {toughness = "", name = _Name})
        _Ship.crew = _Ship.idealCrew
        _Ship.shieldDurability = _Ship.shieldMaxDurability
    
        AddDefaultShipScripts(_Ship)
    
        _Ship:addScriptOnce("ai/patrol.lua")
        _Ship:addScriptOnce("story/xsotanbehaviour.lua")
        _Ship:addScriptOnce("enemies/SDKReclaimer.lua")
        _Ship:setValue("is_xsotan", 1)
        if _Quantum == "Quantum " then _Ship:addScriptOnce("enemies/SDKQuantum.lua") end
    
        Boarding(_Ship).boardable = false
    
        return _Ship
    end
    
    function SDKXsotanGenerator.Decimator(_Position, _OverrideQuantum) local _MethodName = GetName("Decimator")
        
        _Position = _Position or Matrix()
        local _X, _Y = SDKXsotanGenerator.Corrdinates()
        local _Name = "Decimator"
        local _VolLow = SDKXsotanGenerator.VolumeShips[9]
        local _VolHigh = SDKXsotanGenerator.VolumeShips[10] - 1
        local _Volume = random():getInt(_VolLow, _VolHigh)
        local _Prefix = SDKXsotanGenerator.GrowthPrefix(_Volume, _VolLow, _VolHigh)
        local _Material = SDKXsotanGenerator.Material()
        local _Faction = SDKXsotanGenerator.Faction()
    
        _Volume = SDKXsotanGenerator.DifficultyAdjustment(_Volume)
    
        local _Plan local _Table = SDKXsotanGenerator.PlansByClass("Decimator") if _Table then
            Plan.Pick(_Table)
            Plan.Material(_Material, "Tier")
            _Plan = Plan.Get()
        else
            Log.Warning(_MethodName, "No Valid Plan, Using Game Generatored Ship")
            _Plan = SDKXsotanGenerator.GameGenerateShip(_Volume, _Material)
        end
    
        -- scale
        if _Volume and _Plan then
            local _Factor = math.pow(_Volume / _Plan.volume, 1 / 3)
            _Plan:scale(vec3(_Factor))
        end
    
        local _Ship = Sector():createShip(_Faction, "", _Plan, _Position)
    
        -- Xsotan have random turrets
        local turret = SectorTurretGenerator():generateArmed(_X, _Y, 0, Rarity(RarityType.Rare))
        local numTurrets = math.max(2, Balancing_GetEnemySectorTurrets(x, y) * 0.75)
    
        local _Quantum = SDKXsotanGenerator.EvaluateQuantum(0.55, _OverrideQuantum)     
    
        ShipUtility.addTurretsToCraft(_Ship, turret, numTurrets)
    
        _Ship:setTitle("${toughness}"%_T .. _Prefix .. _Quantum .. "${name}"%_T, {toughness = "", name = _Name})
        _Ship.crew = _Ship.idealCrew
        _Ship.shieldDurability = _Ship.shieldMaxDurability
    
        AddDefaultShipScripts(_Ship)
    
        _Ship:addScriptOnce("ai/patrol.lua")
        _Ship:addScriptOnce("story/xsotanbehaviour.lua")
        _Ship:setValue("is_xsotan", 1)
        if _Quantum == "Quantum " then _Ship:addScriptOnce("enemies/SDKQuantum.lua") end
    
        Boarding(_Ship).boardable = false
    
        return _Ship
    end
    
    function SDKXsotanGenerator.Annihilator(_Position, _OverrideQuantum) local _MethodName = GetName("Annihilator")
        
        _Position = _Position or Matrix()
        local _X, _Y = SDKXsotanGenerator.Corrdinates()
        local _Name = "Annihilator"
        local _VolLow = SDKXsotanGenerator.VolumeShips[10]
        local _VolHigh = SDKXsotanGenerator.VolumeShips[12] - 1
        local _Volume = random():getInt(_VolLow, _VolHigh)
        local _Prefix = SDKXsotanGenerator.GrowthPrefix(_Volume, _VolLow, _VolHigh)
        local _Material = SDKXsotanGenerator.Material()
        local _Faction = SDKXsotanGenerator.Faction()
    
        _Volume = SDKXsotanGenerator.DifficultyAdjustment(_Volume)
    
        local _Plan local _Table = SDKXsotanGenerator.PlansByClass("Annihilator") if _Table then
            Plan.Pick(_Table)
            Plan.Material(_Material, "Tier")
            _Plan = Plan.Get()
        else
            Log.Warning(_MethodName, "No Valid Plan, Using Game Generatored Ship")
            _Plan = SDKXsotanGenerator.GameGenerateShip(_Volume, _Material)
        end
    
        -- scale
        if _Volume and _Plan then
            local _Factor = math.pow(_Volume / _Plan.volume, 1 / 3)
            _Plan:scale(vec3(_Factor))
        end
    
        local _Ship = Sector():createShip(_Faction, "", _Plan, _Position)
    
        -- Xsotan have random turrets
        local turret = SectorTurretGenerator():generateArmed(_X, _Y, 0, Rarity(RarityType.Rare))
        local numTurrets = math.max(2, Balancing_GetEnemySectorTurrets(x, y) * 0.75) * 2
    
        local _Quantum = SDKXsotanGenerator.EvaluateQuantum(1.5, _OverrideQuantum)     
    
        ShipUtility.addTurretsToCraft(_Ship, turret, numTurrets)
    
        _Ship:setTitle("${toughness}"%_T .. _Prefix .. _Quantum .. "${name}"%_T, {toughness = "", name = _Name})
        _Ship.crew = _Ship.idealCrew
        _Ship.shieldDurability = _Ship.shieldMaxDurability
    
        AddDefaultShipScripts(_Ship)
    
        _Ship:addScriptOnce("ai/patrol.lua")
        _Ship:addScriptOnce("story/xsotanbehaviour.lua")
        _Ship:setValue("is_xsotan", 1)
        if _Quantum == "Quantum " then _Ship:addScriptOnce("enemies/SDKQuantum.lua") end
    
        Boarding(_Ship).boardable = false
    
        return _Ship
    end
    
    function SDKXsotanGenerator.Summoner(_Position, _OverrideQuantum) local _MethodName = GetName("Summoner")
        
        _Position = _Position or Matrix()
        local _X, _Y = SDKXsotanGenerator.Corrdinates()
        local _Name = "Summoner"
        local _VolLow = SDKXsotanGenerator.VolumeShips[12]
        local _VolHigh = SDKXsotanGenerator.VolumeShips[13] - 1
        local _Volume = random():getInt(_VolLow, _VolHigh)
        local _Prefix = SDKXsotanGenerator.GrowthPrefix(_Volume, _VolLow, _VolHigh)
        local _Material = SDKXsotanGenerator.Material()
        local _Faction = SDKXsotanGenerator.Faction()
    
        _Volume = SDKXsotanGenerator.DifficultyAdjustment(_Volume)
    
        local _Plan local _Table = SDKXsotanGenerator.PlansByClass("Summoner") if _Table then
            Plan.Pick(_Table)
            Plan.Material(_Material, "Tier")
            _Plan = Plan.Get()
        else
            Log.Warning(_MethodName, "No Valid Plan, Using Game Generatored Ship")
            _Plan = SDKXsotanGenerator.GameGenerateShip(_Volume, _Material)
        end
    
        -- scale
        if _Volume and _Plan then
            local _Factor = math.pow(_Volume / _Plan.volume, 1 / 3)
            _Plan:scale(vec3(_Factor))
        end
        
        local _Ship = Sector():createShip(_Faction, "", _Plan, _Position)
    
        -- Xsotan have random turrets
        local turret = SectorTurretGenerator():generateArmed(_X, _Y, 0, Rarity(RarityType.Rare))
        local numTurrets = math.max(2, Balancing_GetEnemySectorTurrets(x, y) * 0.75)
    
        local _Quantum = SDKXsotanGenerator.EvaluateQuantum(0.25, _OverrideQuantum)     
    
        ShipUtility.addTurretsToCraft(_Ship, turret, numTurrets)
    
        _Ship:setTitle("${toughness}"%_T .. _Prefix .. _Quantum .. "${name}"%_T, {toughness = "", name = _Name})
        _Ship.crew = _Ship.idealCrew
        _Ship.shieldDurability = _Ship.shieldMaxDurability
    
        AddDefaultShipScripts(_Ship)
    
        _Ship:addScriptOnce("ai/patrol.lua")
        _Ship:addScriptOnce("story/xsotanbehaviour.lua")
        _Ship:addScriptOnce("enemies/SDKSummoner.lua")
        _Ship:setValue("is_xsotan", 1)
        if _Quantum == "Quantum " then _Ship:addScriptOnce("enemies/SDKQuantum.lua") end
    
        Boarding(_Ship).boardable = false
    
        return _Ship
    end
    
    function SDKXsotanGenerator.Incubator(_Position, _Fighters, _OverrideQuantum, _OverrideHanger) local _MethodName = GetName("Incubator")
        
        _Fighters = _Fighters or 12
        _Position = _Position or Matrix()
        local _X, _Y = SDKXsotanGenerator.Corrdinates()
        local _Name = "Incubator"
        local _VolLow = SDKXsotanGenerator.VolumeShips[12]
        local _VolHigh = SDKXsotanGenerator.VolumeShips[14] - 1
        local _Volume = random():getInt(_VolLow, _VolHigh)
        local _Prefix = SDKXsotanGenerator.GrowthPrefix(_Volume, _VolLow, _VolHigh)
        local _Material = SDKXsotanGenerator.Material()
        local _Faction = SDKXsotanGenerator.Faction()
    
        _Volume = SDKXsotanGenerator.DifficultyAdjustment(_Volume)
    
        local _Plan local _Table = SDKXsotanGenerator.PlansByClass("Incubator") if _Table then
            Plan.Pick(_Table)
            Plan.Material(_Material, "Tier")
            _Plan = Plan.Get()
        else
            Log.Warning(_MethodName, "No Valid Plan, Using Game Generatored Ship")
            _Plan = SDKXsotanGenerator.GameGenerateShip(_Volume, _Material)
        end
    
        -- scale
        if _Volume and _Plan then
            local _Factor = math.pow(_Volume / _Plan.volume, 1 / 3)
            _Plan:scale(vec3(_Factor))
        end
    
        local _Ship = Sector():createShip(_Faction, "", _Plan, _Position)
    
        -- Add Hanger and # Sqrads of Fighters
        local _Hangar = Hangar(_Ship.index)
        _Hangar:addSquad("Alpha")
        _Hangar:addSquad("Beta")
        _Hangar:addSquad("Gamma")
    
        local GenFighter = SectorFighterGenerator()
        GenFighter.factionIndex = _Faction.index
        
        local _NumFighters = 0
        for _Squad = 0, 2 do
            local _Fighter = GenFighter:generateArmed(_Faction:getHomeSectorCoordinates())
            for i = 1, 7 do
                _Hangar:addFighter(_Squad, _Fighter)
    
                _NumFighters = _NumFighters + 1
                if _NumFighters >= _Fighters then break end
            end
    
            if _NumFighters >= _Fighters then break end
        end
    
        -- Xsotan have random turrets
        local turret = SectorTurretGenerator():generateArmed(_X, _Y, 0, Rarity(RarityType.Rare))
        local numTurrets = math.max(2, Balancing_GetEnemySectorTurrets(x, y) * 0.75) * 2
    
        local _Quantum = SDKXsotanGenerator.EvaluateQuantum(0.25, _OverrideQuantum)     
    
        ShipUtility.addTurretsToCraft(_Ship, turret, numTurrets)
    
        _Ship:setTitle("${toughness}"%_T .. _Prefix .. _Quantum .. "${name}"%_T, {toughness = "", name = _Name})
        _Ship.crew = _Ship.idealCrew
        _Ship.shieldDurability = _Ship.shieldMaxDurability
    
        AddDefaultShipScripts(_Ship)
    
        _Ship:addScriptOnce("ai/patrol.lua")
        _Ship:addScriptOnce("story/xsotanbehaviour.lua")
        _Ship:setValue("is_xsotan", 1)
        if _Quantum == "Quantum " then _Ship:addScriptOnce("enemies/SDKQuantum.lua") end
    
        Boarding(_Ship).boardable = false
    
        return _Ship
    end
    
    function SDKXsotanGenerator.Dreadnought(_Position, _OverrideAdjustment) local _MethodName = GetName("Dreadnought")
        
        _OverrideAdjustment = _OverrideAdjustment or false
        _Position = _Position or Matrix()
        local _X, _Y = SDKXsotanGenerator.Corrdinates()
        local _Name = "Dreadnought"
        local _VolLow = SDKXsotanGenerator.VolumeShips[15]
        local _VolHigh = SDKXsotanGenerator.VolumeShips[16] - 1
        local _Volume = random():getInt(_VolLow, _VolHigh)
        local _Prefix = SDKXsotanGenerator.GrowthPrefix(_Volume, _VolLow, _VolHigh)
        local _Material = SDKXsotanGenerator.Material()
        local _Faction = SDKXsotanGenerator.Faction()
    
        if _OverrideAdjustment == false then
            _Volume = SDKXsotanGenerator.DifficultyAdjustment(_Volume)
        end
    
        local _Plan local _Table = SDKXsotanGenerator.PlansByClass("Dreadnought") if _Table then
            Plan.Pick(_Table)
            Plan.Material(_Material, "Tier")
            _Plan = Plan.Get()
        else
            Log.Warning(_MethodName, "No Valid Plan, Using Game Generatored Ship")
            _Plan = SDKXsotanGenerator.GameGenerateShip(_Volume, _Material)
        end
    
        -- scale
        if _Volume and _Plan then
            local _Factor = math.pow(_Volume / _Plan.volume, 1 / 3)
            _Plan:scale(vec3(_Factor))
        end
    
        local _Ship = Sector():createShip(_Faction, "", _Plan, _Position)
    
        -- Xsotan have random turrets
        local numTurrets = math.max(2, Balancing_GetEnemySectorTurrets(x, y) * 0.75) 
     
        ShipUtility.addTurretsToCraft(_Ship, SDKXsotanGenerator.PlasmaTurret(), numTurrets, numTurrets)
        ShipUtility.addTurretsToCraft(_Ship, SDKXsotanGenerator.LaserTurret(), numTurrets, numTurrets)
        ShipUtility.addTurretsToCraft(_Ship, SDKXsotanGenerator.RailgunTurret(), numTurrets, numTurrets)
    
        _Ship:setTitle("${toughness}"%_T .. _Prefix .. "${name}"%_T, {toughness = "", name = _Name})
        _Ship.crew = _Ship.idealCrew
        _Ship.shieldDurability = _Ship.shieldMaxDurability
    
        AddDefaultShipScripts(_Ship)
    
        _Ship:addScriptOnce("ai/patrol.lua")
        _Ship:addScriptOnce("story/xsotanbehaviour.lua")
        _Ship:setValue("is_xsotan", 1)
    
        Boarding(_Ship).boardable = false
    
        return _Ship
    end
    
    -- Proto Guardian Notes:
    -- 1. does not get a volume adjustment based on difficulty
    -- 2. Is always made of Avorion
    function SDKXsotanGenerator.ProtoGuardian(_Position) local _MethodName = GetName("Proto Guardian")
        
        _Position = _Position or Matrix()
        local _X, _Y = SDKXsotanGenerator.Corrdinates()
        local _VolLow = SDKXsotanGenerator.VolumeShips[16]
        local _VolHigh = SDKXsotanGenerator.VolumeShips[17] - 1
        local _Volume = random():getInt(_VolLow, _VolHigh)
        local _Material = Material(MaterialType.Avorion)        -- Avorion Always        
        local _Faction = SDKXsotanGenerator.Faction()
          
        local _Plan local _Table = SDKXsotanGenerator.PlansByClass("Proto-Guardian") if _Table then
            Plan.Pick(_Table)
            Plan.Material(_Material, "Tier")
            _Plan = Plan.Get()
        else
            Log.Warning(_MethodName, "No Valid Plan, Using Game Generatored Ship")
            _Plan = SDKXsotanGenerator.GameGenerateGuardian(_Volume, _Material)
        end
    
        local _Ship = Sector():createShip(_Faction, "", _Plan, _Position)
    
        -- Xsotan have random turrets
        local numTurrets = math.max(2, Balancing_GetEnemySectorTurrets(x, y) * 0.75)
     
        ShipUtility.addTurretsToCraft(_Ship, SDKXsotanGenerator.PlasmaTurret(), numTurrets, numTurrets)
        ShipUtility.addTurretsToCraft(_Ship, SDKXsotanGenerator.LaserTurret(), numTurrets, numTurrets)
        ShipUtility.addTurretsToCraft(_Ship, SDKXsotanGenerator.RailgunTurret(), numTurrets, numTurrets)
        ShipUtility.addBossAntiTorpedoEquipment(_Ship)
    
        _Ship:setTitle("${toughness} ${name}"%_T, {toughness = "", name = "Wormhole Guardian Prototype"})    
        _Ship.crew = _Ship.idealCrew
        _Ship.shieldDurability = _Ship.shieldMaxDurability
    
        AddDefaultShipScripts(_Ship)
    
        ShipAI(_Ship.id):setAggressive()
        _Ship:addScriptOnce("story/xsotanbehaviour.lua")
        _Ship:setValue("is_xsotan", 1)
        _Ship:setValue("xsotan_swarm_boss", 1)
        WreckageCreator(_Ship.index).active = false
    
        Boarding(_Ship).boardable = false
    
        return _Ship
    end
    
    -- Guardian Notes:
    -- 1. does not get a volume adjustment based on difficulty
    -- 2. Is always made of Avorion
    function SDKXsotanGenerator.WormholeGuardian(_Position) local _MethodName = GetName("Wormhole Guardian")
        
        _Position = _Position or Matrix()
        local _X, _Y = SDKXsotanGenerator.Corrdinates()
        local _VolLow = SDKXsotanGenerator.VolumeShips[17]
        local _VolHigh = SDKXsotanGenerator.VolumeShips[18]
        local _Volume = random():getInt(_VolLow, _VolHigh)
        local _Material = Material(MaterialType.Avorion)        -- Avorion Always
        local _Faction = SDKXsotanGenerator.Faction()
    
        local _Plan local _Table = SDKXsotanGenerator.PlansByClass("Guardian") if _Table then
            Plan.Pick(_Table)
            Plan.Material(_Material, "Tier")
            _Plan = Plan.Get()
        else
            Log.Warning(_MethodName, "No Valid Plan, Using Game Generatored Ship")
            _Plan = SDKXsotanGenerator.GameGenerateGuardian(_Volume, _Material)
        end
    
        local _Ship = Sector():createShip(_Faction, "", _Plan, _Position)
    
        -- Xsotan have random turrets
        local numTurrets = math.max(2, Balancing_GetEnemySectorTurrets(_X, _Y) * 0.75)
     
        ShipUtility.addTurretsToCraft(_Ship, SDKXsotanGenerator.PlasmaTurret(), numTurrets, numTurrets)
        ShipUtility.addTurretsToCraft(_Ship, SDKXsotanGenerator.LaserTurret(), numTurrets, numTurrets)
        ShipUtility.addTurretsToCraft(_Ship, SDKXsotanGenerator.RailgunTurret(), numTurrets, numTurrets)
        ShipUtility.addBossAntiTorpedoEquipment(_Ship)
    
        _Ship:setTitle("${toughness} ${name}"%_T, {toughness = "", name = "Wormhole Guardian"})    
        _Ship.crew = _Ship.idealCrew
        _Ship.shieldDurability = _Ship.shieldMaxDurability
    
        local upgrades =
        {
            {rarity = Rarity(RarityType.Legendary), amount = 2},
            {rarity = Rarity(RarityType.Exotic), amount = 3},
            {rarity = Rarity(RarityType.Exceptional), amount = 3},
            {rarity = Rarity(RarityType.Rare), amount = 5},
            {rarity = Rarity(RarityType.Uncommon), amount = 8},
            {rarity = Rarity(RarityType.Common), amount = 14},
        }
    
        local turrets =
        {
            {rarity = Rarity(RarityType.Legendary), amount = 2},
            {rarity = Rarity(RarityType.Exotic), amount = 3},
            {rarity = Rarity(RarityType.Exceptional), amount = 3},
            {rarity = Rarity(RarityType.Rare), amount = 5},
            {rarity = Rarity(RarityType.Uncommon), amount = 8},
            {rarity = Rarity(RarityType.Common), amount = 14},
        }
    
        local generator = UpgradeGenerator()
        for _, p in pairs(upgrades) do
            for i = 1, p.amount do
                Loot(_Ship.index):insert(generator:generateSectorSystem(_X, _Y, p.rarity))
            end
        end
    
        for _, p in pairs(turrets) do
            for i = 1, p.amount do
                Loot(_Ship.index):insert(InventoryTurret(SectorTurretGenerator():generate(_X, _Y, 0, p.rarity)))
            end
        end
    
        AddDefaultShipScripts(_Ship)
    
        ShipAI(_Ship.id):setAggressive()
        _Ship:addScriptOnce("story/wormholeguardian.lua")
        _Ship:addScriptOnce("story/xsotanbehaviour.lua")
        _Ship:setValue("is_xsotan", 1)
    
        Boarding(_Ship).boardable = false
    
        return _Ship
    end
    
    ------------------------------------------------------------------------------------------------------------------------------
    ------------------------------------------------------ Custom Weapons --------------------------------------------------------
    ------------------------------------------------------------------------------------------------------------------------------
    
    function SDKXsotanGenerator.PlasmaTurret(_Rarity)
        local _Rarity = _Rarity or SDKXsotanGenerator.RandomRarity()
        local turret = SectorTurretGenerator(Seed(151)):generate(0, 0, 0, Rarity(_Rarity), WeaponType.PlasmaGun)
        local weapons = {turret:getWeapons()}
        turret:clearWeapons()
        for _, weapon in pairs(weapons) do
            weapon.reach = 1500
            weapon.pmaximumTime = weapon.reach / weapon.pvelocity
            weapon.hullDamageMultiplier = 0.35
            turret:addWeapon(weapon)
        end
    
        turret.turningSpeed = 3.0
        turret.crew = Crew()
    
        return turret
    end
    
    function SDKXsotanGenerator.LaserTurret()
        local _Rarity = _Rarity or SDKXsotanGenerator.RandomRarity(_Rarity)
        local turret = SectorTurretGenerator(Seed(152)):generate(0, 0, 0, Rarity(_Rarity), WeaponType.Laser)
        local weapons = {turret:getWeapons()}
        turret:clearWeapons()
        for _, weapon in pairs(weapons) do
            weapon.reach = 1500
            weapon.blength = 1500
            turret:addWeapon(weapon)
        end
    
        turret.turningSpeed = 3.0
        turret.crew = Crew()
    
        return turret
    end
    
    function SDKXsotanGenerator.RailgunTurret()
        local _Rarity = _Rarity or SDKXsotanGenerator.RandomRarity(_Rarity)
        local turret = SectorTurretGenerator(Seed(153)):generate(0, 0, 0, Rarity(_Rarity), WeaponType.RailGun)
        local weapons = {turret:getWeapons()}
        turret:clearWeapons()
        for _, weapon in pairs(weapons) do
            weapon.reach = 1500
            turret:addWeapon(weapon)
        end
    
        turret.turningSpeed = 3.0
        turret.crew = Crew()
    
        return turret
    end
    
    function SDKXsotanGenerator.LatcherTeslaTurret()
        local _Rarity = _Rarity or SDKXsotanGenerator.RandomRarity(_Rarity)
        local turret = SectorTurretGenerator(Seed(153)):generate(0, 0, 0, Rarity(_Rarity), WeaponType.TeslaGun)
        local weapons = {turret:getWeapons()}
        turret:clearWeapons()
        for _, weapon in pairs(weapons) do
            weapon.reach = 200
            turret:addWeapon(weapon)
        end
    
        turret.turningSpeed = 3.0
        turret.crew = Crew()
    
        return turret
    end
    
    function SDKXsotanGenerator.LatcherForceTurret()
        local _Rarity = _Rarity or SDKXsotanGenerator.RandomRarity(_Rarity)
        local turret = SectorTurretGenerator(Seed(153)):generate(0, 0, 0, Rarity(_Rarity), WeaponType.ForceGun)
        local weapons = {turret:getWeapons()}
        turret:clearWeapons()
        for _, weapon in pairs(weapons) do
            weapon.reach = 200
            weapon.banimationSpeed = -1
            weapon.selfForce = -5000
            weapon.otherForce = 0
            weapon.bshape = BeamShape.Swirly
            weapon.bshapeSize = 1.25
            turret:addWeapon(weapon)
        end
    
        turret.coaxial = true
        turret.turningSpeed = 3.0
        turret.crew = Crew()
    
        return turret
    end

end -- if onServer then


return SDKXsotanGenerator