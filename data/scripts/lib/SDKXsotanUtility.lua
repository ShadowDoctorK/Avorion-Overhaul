package.path = package.path .. ";data/scripts/lib/?.lua"
package.path = package.path .. ";data/scripts/?.lua"

include ("galaxy")
include ("stringutility")
include ("randomext")
include ("utility")

local StyleGenerator = include ("internal/stylegenerator.lua")      -- Added to support generating ships locally in script
local Log = include("SDKDebugLogging")

local _Debug = 0
local _Mod = "Xsotan Utility" function GetName(n)
    return _Mod .. " - " .. n
end

SDKXsotanUtility = {}
local self = SDKXsotanUtility

SDKXsotanUtility.RandomCalled = 0

SDKXsotanUtility.Volume = {}
SDKXsotanUtility.Volume[1]  = 1       -- Slot 1
SDKXsotanUtility.Volume[2]  = 51      -- Slot 2
SDKXsotanUtility.Volume[3]  = 128     -- Slot 3
SDKXsotanUtility.Volume[4]  = 320     -- Slot 4
SDKXsotanUtility.Volume[5]  = 800     -- Slot 5
SDKXsotanUtility.Volume[6]  = 2000    -- Slot 6
SDKXsotanUtility.Volume[7]  = 5000    -- Slot 7
SDKXsotanUtility.Volume[8]  = 12500   -- Slot 8
SDKXsotanUtility.Volume[9]  = 19764   -- Slot 9
SDKXsotanUtility.Volume[10] = 31250   -- Slot 10
SDKXsotanUtility.Volume[11] = 43065   -- Slot 11
SDKXsotanUtility.Volume[12] = 59348   -- Slot 12
SDKXsotanUtility.Volume[13] = 78125   -- Slot 13
SDKXsotanUtility.Volume[14] = 107554  -- Slot 14
SDKXsotanUtility.Volume[15] = 148371  -- Slot 15
SDKXsotanUtility.Volume[16] = 250000  -- Titan Scale / Max Size Limit For Slot 15 
SDKXsotanUtility.Volume[17] = 500000  -- Max Size Limit for AI Titan Class
SDKXsotanUtility.Volume[18] = 1500000 -- Max Size For Guardian

function SDKXsotanUtility.Rand()
    self.RandomCalled = self.RandomCalled + random():getInt(1, 720)
    return Random(Seed(os.time() + self.RandomCalled))
end

function SDKXsotanUtility.DistanceFromCore(_X, _Y) local _MethodName = GetName("Distance From Core")
    if not _X or not _Y then 
        _X, _Y = Sector():getCoordinates()
    end

    Log.Debug(_MethodName, "(Absolute) X: " .. tostring(_X) .. " | (Absolute) Y: " .. tostring(_Y), _Debug)
    _X = math.abs(_X) _Y = math.abs(_Y)
    local _Distance = math.sqrt((_X ^ 2) + (_Y ^ 2))

    Log.Debug(_MethodName, "Sectors From Core: "  .. tostring(_Distance), _Debug)
    return _Distance
end

-- Replaces "Upscale" from the xsotan.lua. Xsotan grow and breed from Asteroids, Stations
-- Ships and anything that has a energy signature. Their developement (Size) should reach
-- a certain state before they attempt to leave the "nest" so you should see a small variation
-- in size but the class of ship and size should be constant. The longer the distance from the
-- core the more lower class ship types should be encountered with less developed tech and material
-- due to the "breeding ground" effect.
-- You can pass it a class and a X,Y to override the default
-- Chance Auto Adjusts based on the distance from the core.
function SDKXsotanUtility.ClassByDistance(_Class, _X, _Y) local _MethodName = GetName("Class By Distance")
    
    local _Selected = self.Rand():getInt(1, 10000) / 100
    local _Distance = self.DistanceFromCore(_X, _Y)
    local _UseTable = true
    
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
            C4 = 25   -- Hunters
            C5 = 60   -- Reclaimers
            C6 = 80   -- Decimators
            C7 = 100  -- Annihilators
        end
    end        

    -- Xsotan are have grown more near the core where they breached the galaxy
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

    Log.Debug(_MethodName, "Selected: " .. tostring(_Selected), _Debug)
    Log.Debug(_MethodName, "Probe: " .. tostring(C1) .. " | Latcher: " .. tostring(C2) .. " | Scout: " .. tostring(C3) .. " | Hunter: " .. tostring(C4) .. " | Reclaimer: " .. tostring(C5) .. 
    " | Decimator: " .. tostring(C6) .. " | Annihilator: " .. tostring(C7) .. " | Summoner: " .. tostring(C8) .. " | Incubator: " .. tostring(C9) .. " | Dreadnought: " .. tostring(C10), _Debug)

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
        Log.Warning(_MethodName, "Returning Default: Decimator.")
        return "Decimator"
    end

end

function SDKXsotanUtility.PlansByClass(_Class) local _MethodName = GetName("Plan By Class")

    if not _Class then _Class = self.ClassByDistance() end

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

function SDKXsotanUtility.Corrdinates()
    return Sector():getCoordinates()
end

function SDKXsotanUtility.RandomRarity()

    local _Target = self.Rand():getInt(-1, 5)

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

function SDKXsotanUtility.DifficultyAdjustment(_Volume) local _MethodName = GetName("Difficulty Adjustment")
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

function SDKXsotanUtility.GrowthPrefix(_Name, _Volume, _VolLow, _VolHigh) local _MethodName = GetName("Growth Prefix")
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
        
    return  _Prefix .. _Name
end

function SDKXsotanUtility.Material()
    local _X, _Y = self.Corrdinates()
    local _Prob = Balancing_GetTechnologyMaterialProbability(_X, _Y)
    return Material(getValueFromDistribution(_Prob))
end

function SDKXsotanUtility.Faction()
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

function SDKXsotanUtility.Volume(_Low, _High)
    local _Volume = self.Rand():getInt(_Low, _High)    
    return self.DifficultyAdjustment(_Volume), self.GrowthPrefix(_Volume, _Low, _High)
end

-- Function To Add Quantum Ability To Other Ship Classes
-- Quantums will occur more at higher difficulty settings and closer to the core.
function SDKXsotanUtility.EvaluateQuantum(_ClassFactor) local _MethodName = GetName("Evaluate Quantum")

    if not _ClassFactor then 
        Log.Warning(_MethodName, "No Class Factor Passed. Returning False") return false
    end

    local _Base = 0.06 -- 6% Base Chance
    Log.Debug(_MethodName, "Chance (Base): " ..  tostring(_Base), _Debug)

    -- Adjust based on Difficulty
    local _Settings = GameSettings()
    if _Settings.difficulty == Difficulty.Insane then             _Base = _Base * 3
    elseif _Settings.difficulty == Difficulty.Hardcore then       _Base = _Base * 2
    elseif _Settings.difficulty == Difficulty.Expert then         _Base = _Base * 1.66
    elseif _Settings.difficulty == Difficulty.Veteran then        _Base = _Base * 1.33
    elseif _Settings.difficulty == Difficulty.Normal then         _Base = _Base * 1
    elseif _Settings.difficulty == Difficulty.Easy then           _Base = _Base * 0.5
    end

    
    local _Factor = self.DistanceFromCore() / 500
    Log.Debug(_MethodName, "Chance (Difficulty Adjustment): " ..  tostring(_Base), _Debug)
    Log.Debug(_MethodName, "Chance (Factor): " ..  tostring(_Factor), _Debug)
    
    local _Reduce = _Base * _Factor
    Log.Debug(_MethodName, "Chance (Class Factor): " ..  tostring(_ClassFactor), _Debug)
    Log.Debug(_MethodName, "Chance (Reduction): " ..  tostring(_Reduce), _Debug)

    _Base = _Base - _Reduce
    _Base = _Base * _ClassFactor
    _Base = _Base * 100
    
    Log.Debug(_MethodName, "Chance (Final): " ..  tostring(_Base), _Debug)
    local _Chance = self.Rand():getInt(0, 10000)/100 if _Chance <= _Base then
        return true
    end return false
end

function SDKXsotanUtility.MakeQuatum(_Ship, _Name)     
    _Ship:addScriptOnce("enemies/blinker.lua")
    return "Quantum " .. _Name    
end

function SDKXsotanUtility.GameGenerateShip(_Volume, _Material)
    local StyleGenerator = StyleGenerator(1337)

    local _Seed = math.random(0xffffffff)
    local _Style = StyleGenerator:makeXsotanShipStyle(_Seed)
    local _Plan = GeneratePlanFromStyle(_Style, Seed(tostring(_Seed)), _Volume, 5000, nil, _Material)
    return _Plan
end

function SDKXsotanUtility.GameGenerateGuardian(_Volume, _Material)

    _Volume = _Volume / 8 -- divide by 8 so we don't use the plan scale volume for all 8 parts.

    local _Plan = self.GameGenerateGuardian(_Volume, _Material)
    local front = self.GameGenerateGuardian(_Volume, _Material)
    local back = self.GameGenerateGuardian(_Volume, _Material)
    local top = self.GameGenerateGuardian(_Volume, _Material)
    local bottom = self.GameGenerateGuardian(_Volume, _Material)
    local left = self.GameGenerateGuardian(_Volume, _Material)
    local right = self.GameGenerateGuardian(_Volume, _Material)
    local frontleft= self.GameGenerateGuardian(_Volume, _Material)
    local frontright = self.GameGenerateGuardian(_Volume, _Material)

    self.infectPlan(_Plan)
    self.infectPlan(front)
    self.infectPlan(back)
    self.infectPlan(top)
    self.infectPlan(bottom)
    self.infectPlan(left)
    self.infectPlan(right)
    self.infectPlan(frontleft)
    self.infectPlan(frontright)

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
function SDKXsotanUtility.infectPlan(_Plan)
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
        local addition = self.makeInfectAddition(vec3(15, 4, 15), material, 0)

        addition:scale(vec3(getFloat(0.5, 2.5), getFloat(0.9, 1.1), getFloat(0.5, 2.5)))
        addition:center()

        _Plan:addPlanDisplaced(p.index, addition, addition.rootIndex, p.position)
    end

end

-- Used when using the games generator to make a Guardian
function SDKXsotanUtility.makeInfectAddition(size, material, level)

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

return SDKXsotanUtility