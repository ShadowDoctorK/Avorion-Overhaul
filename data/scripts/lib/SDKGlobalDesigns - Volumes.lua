include ("defaultscripts")
local Rand = include("SDKUtilityRandom")
local Class = include("SDKGlobalDesigns - Classes")

-- Logging Setup
    local Log = include("SDKDebugLogging")
    local _ModName = "Plan Volumes"
    local _Debug = 0
-- End Logging

SDKPlanVolumes = {}

SDKPlanVolumes.Ships = {}
SDKPlanVolumes.Ships[1]  = 1       -- Slot 1
SDKPlanVolumes.Ships[2]  = 51      -- Slot 2: 51660m3
SDKPlanVolumes.Ships[3]  = 128     -- Slot 3: 131000m3
SDKPlanVolumes.Ships[4]  = 320     -- Slot 4
SDKPlanVolumes.Ships[5]  = 800     -- Slot 5
SDKPlanVolumes.Ships[6]  = 2000    -- Slot 6
SDKPlanVolumes.Ships[7]  = 5000    -- Slot 7
SDKPlanVolumes.Ships[8]  = 12500   -- Slot 8
SDKPlanVolumes.Ships[9]  = 19764   -- Slot 9
SDKPlanVolumes.Ships[10] = 31250   -- Slot 10
SDKPlanVolumes.Ships[11] = 43065   -- Slot 11
SDKPlanVolumes.Ships[12] = 59348   -- Slot 12
SDKPlanVolumes.Ships[13] = 78125   -- Slot 13
SDKPlanVolumes.Ships[14] = 107554  -- Slot 14
SDKPlanVolumes.Ships[15] = 148371  -- Slot 15
SDKPlanVolumes.Ships[16] = 250000  -- Titan Scale / Max Size Limit For Slot 15 
SDKPlanVolumes.Ships[17] = 500000  -- Max Size Limit for AI Titan Class

SDKPlanVolumes.Stations = {}
SDKPlanVolumes.Stations[1] = 200000
SDKPlanVolumes.Stations[2] = 300000
SDKPlanVolumes.Stations[3] = 400000
SDKPlanVolumes.Stations[4] = 600000
SDKPlanVolumes.Stations[5] = 800000
SDKPlanVolumes.Stations[6] = 1000000

local self = SDKPlanVolumes

-- Fucntion to build Methodname
function SDKPlanVolumes.LogName(n)
    return _ModName .. " - " .. n
end

function SDKPlanVolumes.GlobalVolumes()
    local Volumes = {}    
    local Modifier = 2
    
    Volumes[1]  = 319 / Modifier
    Volumes[2]  = 799 / Modifier
    Volumes[3]  = 1999 / Modifier
    Volumes[4]  = 2999 / Modifier
    Volumes[5]  = 3999 / Modifier
    Volumes[6]  = 4999 / Modifier
    Volumes[7]  = 9921 / Modifier
    Volumes[8]  = 12842 / Modifier
    Volumes[9]  = 19763 / Modifier
    Volumes[10] = 27531 / Modifier
    Volumes[11] = 35298 / Modifier
    Volumes[12] = 43064 / Modifier 
    Volumes[13] = 54751 / Modifier
    Volumes[14] = 66437 / Modifier
    Volumes[15] = 78124 / Modifier
    Volumes[16] = 101540 / Modifier
    Volumes[17] = 124995 / Modifier
    Volumes[18] = 148370 / Modifier
    Volumes[19] = 182247 / Modifier
    Volumes[20] = 216123 / Modifier
    Volumes[21] = 249999 / Modifier
    Volumes[22] = 500000 / Modifier

    return Volumes

end

function SDKPlanVolumes.Slots(v)
    if v < 1 then return 0 end
    for i = 1, #self.Ships do
        if v <= self.Ships[i] then return i end
    end return 18
end

function SDKPlanVolumes.Get(v1, v2, station) MethodName = self.LogName("Get")
    
    if station then 
        if v1 > 6 then v1 = 6 end 
        if not v2 then return self.Stations[v1] end        -- Target Size

        if v2 > 6 then v2 = 6 end
        return Rand.Int(self.Stations[v1], self.Stations[v2])
    end

    if not v2 then return self.Ships[v1] end        -- Target Size
    return Rand.Int(self.Ships[v1], self.Ships[v2] - 1)

end

-- Will return the ship class based on the passed volume
function SDKPlanVolumes.MilitaryClass(V) MethodName = self.LogName("Military Class")
    local S = "Unknown"
    if V >= self.Ships[1] and V < self.Ships[5] then             S = Class.Scout
    elseif V >= self.Ships[5] and V < self.Ships[7] then         S = Class.Corvette
    elseif V >= self.Ships[7] and V < self.Ships[9] then         S = Class.Frigate
    elseif V >= self.Ships[9] and V < self.Ships[11] then        S = Class.Destroyer
    elseif V >= self.Ships[11] and V < self.Ships[13] then       S = Class.Cruiser
    elseif V >= self.Ships[13] and V < self.Ships[15] then       S = Class.Battleship
    elseif V >= self.Ships[15] and V < self.Ships[16] then       S = Class.Dreadnought
    elseif V >= self.Ships[16] then                              S = Class.Titan
    else Log.Error(MethodName, "Volume: " .. tostring(V) .. " - No Class Returned", 1)
    end return S
end

function SDKPlanVolumes.SalvagerClass(V) MethodName = self.LogName("Salvager Class")
    local S = "Unknown"
    if V >= self.Ships[1] and V < self.Ships[7] then             S = Class.SalvagerS
    elseif V >= self.Ships[7] and V < self.Ships[11] then        S = Class.SalvagerM
    elseif V >= self.Ships[11] and V < self.Ships[14] then       S = Class.SalvagerL
    elseif V >= self.Ships[14] then                              S = Class.SalvagerH
    else Log.Error(MethodName, "Volume: " .. tostring(V) .. " - No Class Returned", 1)
    end return S
end

function SDKPlanVolumes.FreighterClass(V) MethodName = self.LogName("Freighter Class")
    local S = "Unknown"
    if V >= self.Ships[1] and V < self.Ships[7] then             S = Class.FreighterS
    elseif V >= self.Ships[7] and V < self.Ships[11] then        S = Class.FreighterM
    elseif V >= self.Ships[11] and V < self.Ships[14] then       S = Class.FreighterL
    elseif V >= self.Ships[14] then                              S = Class.FreighterH
    else Log.Error(MethodName, "Volume: " .. tostring(V) .. " - No Class Returned", 1)
    end return S
end

function SDKPlanVolumes.MinerClass(V) MethodName = self.LogName("Miner Class")
    local S = "Unknown"
    if V >= self.Ships[1] and V < self.Ships[7] then             S = Class.MinerS
    elseif V >= self.Ships[7] and V < self.Ships[11] then        S = Class.MinerM
    elseif V >= self.Ships[11] and V < self.Ships[14] then       S = Class.MinerL
    elseif V >= self.Ships[14] then                              S = Class.MinerH
    else Log.Error(MethodName, "Volume: " .. tostring(V) .. " - No Class Returned", 1)
    end return S
end

function SDKPlanVolumes.Turrets(V)
    local S = 10
    if V >= self.Ships[1] and V < self.Ships[5] then             S = 4
    elseif V >= self.Ships[5] and V < self.Ships[7] then         S = 6
    elseif V >= self.Ships[7] and V < self.Ships[9] then         S = 8
    elseif V >= self.Ships[9] and V < self.Ships[11] then        S = 10
    elseif V >= self.Ships[11] and V < self.Ships[13] then       S = 12
    elseif V >= self.Ships[13] and V < self.Ships[15] then       S = 16
    elseif V >= self.Ships[15] and V < self.Ships[16] then       S = 20
    elseif V >= self.Ships[16] then                              S = 24
    end return S
end

function SDKPlanVolumes.Chance(v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12, v13, v14, v15)

    local Chance = {}
    Chance[1]   = v1
    Chance[2]   = v2 + Chance[1]
    Chance[3]   = v3 + Chance[2]
    Chance[4]   = v4 + Chance[3]
    Chance[5]   = v5 + Chance[4]
    Chance[6]   = v6 + Chance[5]
    Chance[7]   = v7 + Chance[6]
    Chance[8]   = v8 + Chance[7]
    Chance[9]   = v9 + Chance[8]
    Chance[10]  = v10 + Chance[9]
    Chance[11]  = v11 + Chance[10]
    Chance[12]  = v12 + Chance[11]
    Chance[13]  = v13 + Chance[12]
    Chance[14]  = v14 + Chance[13]
    Chance[15]  = v15 + Chance[14]
    Chance[16]  = 1000

    return Chance

end

function SDKPlanVolumes.Defender()
    return self.Ship(self.Chance(
        0,0,0,0,0,0,0,0,
        210,    -- 9 Slot
        360,    -- 10 Slot
        510,    -- 11 Slot
        710,    -- 12 Slot 
        810,    -- 13 Slot
        950,    -- 14 Slot
        990     -- 15 Slot
     -- 10  Titains
    ))
end

function SDKPlanVolumes.Ship(override)
    local MethodName = self.LogName("Ship Volume")

    -- Chance Number Must be Matched with Ships Volumes above. 
    -- Leave out the last ship volume because they act as ranges. 

    local Chance = {}
    Chance[1]   = 0
    Chance[2]   = 0
    Chance[3]   = 0
    Chance[4]   = 0 
    Chance[5]   = 80    -- 80 Ships
    Chance[6]   = 150   -- 70 Ships
    Chance[7]   = 300   -- 150 Ships
    Chance[8]   = 450   -- 110 Ships
    Chance[9]   = 560   -- 100 Ships
    Chance[10]  = 660   -- 100 Ships
    Chance[11]  = 740   -- 80 Ships
    Chance[12]  = 800   -- 60 Ships
    Chance[13]  = 870   -- 70 Ships
    Chance[14]  = 940   -- 70 Ships
    Chance[15]  = 995   -- 59 Ships
    Chance[16]  = 1000  -- 5 Ships / 1000 Ships

    if override then
        Log.Debug(MethodName, "Overriding Default Chance", _Debug)
        Chance = override
    end

    local Roll = Rand.Int(1, 1000)
    local V = 1

    Log.Debug(MethodName, "Rolled Dice: " .. tostring(Roll), _Debug)

    if Roll < Chance[1] then            V = Rand.Int(self.Ships[1],  self.Ships[2] -1)
    elseif Roll < Chance[2] then        V = Rand.Int(self.Ships[2],  self.Ships[3] -1)
    elseif Roll < Chance[3] then        V = Rand.Int(self.Ships[3],  self.Ships[4] -1)
    elseif Roll < Chance[4] then        V = Rand.Int(self.Ships[4],  self.Ships[5] -1)
    elseif Roll < Chance[5] then        V = Rand.Int(self.Ships[5],  self.Ships[6] -1)
    elseif Roll < Chance[6] then        V = Rand.Int(self.Ships[6],  self.Ships[7] -1)        
    elseif Roll < Chance[7] then        V = Rand.Int(self.Ships[7],  self.Ships[8] -1)
    elseif Roll < Chance[8] then        V = Rand.Int(self.Ships[8],  self.Ships[9] -1)
    elseif Roll < Chance[9] then        V = Rand.Int(self.Ships[9],  self.Ships[10] -1)
    elseif Roll < Chance[10] then       V = Rand.Int(self.Ships[10], self.Ships[11] -1)
    elseif Roll < Chance[11] then       V = Rand.Int(self.Ships[11], self.Ships[12] -1)
    elseif Roll < Chance[12] then       V = Rand.Int(self.Ships[12], self.Ships[13] -1)
    elseif Roll < Chance[13] then       V = Rand.Int(self.Ships[13], self.Ships[14] -1)
    elseif Roll < Chance[14] then       V = Rand.Int(self.Ships[14], self.Ships[15] -1)
    elseif Roll < Chance[15] then       V = Rand.Int(self.Ships[15], self.Ships[16] -1)
    elseif Roll < Chance[16] then       V = Rand.Int(self.Ships[16], self.Ships[17])   
    else                                V = Rand.Int(self.Ships[1],  self.Ships[15])
        Log.Warning(MethodName, "Something Went Wrong, Selecting Random Slot Volume: " .. tostring(V))
    end Log.Debug(MethodName, "Selected Volume: " .. tostring(V), _Debug)

    return V / 2

end

function SDKPlanVolumes.Carrier(override)
    local MethodName = self.LogName("Carrier Volume")

    -- Chance Number Must be Matched with Ships Volumes above. 
    -- Leave out the last ship volume because they act as ranges. 

    local Chance = {}
    Chance[1]  = 240   -- 11
    Chance[2]  = 400   -- 12
    Chance[3]  = 670   -- 13
    Chance[4]  = 840   -- 14
    Chance[5]  = 980   -- 15
    Chance[6]  = 1000  -- 16 Titans

    if override then
        Log.Debug(MethodName, "Overriding Default Chance", _Debug)
        Chance = override
    end

    local Roll = Rand.Int(1, 1000)
    local V = 1

    Log.Debug(MethodName, "Rolled Dice: " .. tostring(Roll), _Debug)

    
    if Roll < Chance[1] then           V = Rand.Int(self.Ships[8],  self.Ships[9] -1)
    elseif Roll < Chance[2] then       V = Rand.Int(self.Ships[9],  self.Ships[11] -1)
    elseif Roll < Chance[3] then       V = Rand.Int(self.Ships[11], self.Ships[13] -1)
    elseif Roll < Chance[4] then       V = Rand.Int(self.Ships[13], self.Ships[15] -1)
    elseif Roll < Chance[5] then       V = Rand.Int(self.Ships[15], self.Ships[16] -1)
    elseif Roll < Chance[6] then       V = Rand.Int(self.Ships[16], self.Ships[17])
    else                                V = Rand.Int(self.Ships[8],  self.Ships[17])
        Log.Warning(MethodName, "Something Went Wrong, Selecting Random Slot Volume: " .. tostring(V))
    end Log.Debug(MethodName, "Selected Volume: " .. tostring(V), _Debug)

    return V / 2

end

function SDKPlanVolumes.Station(override)
    local MethodName = self.LogName("Station Volume")

    math.random()
    local R = Random(Seed(appTimeMs()))

    local Chance = {}
    Chance[1]   = 15
    Chance[2]   = 30
    Chance[3]   = 60
    Chance[4]   = 85 
    Chance[5]   = 100 

    if override then
        Log.Debug(MethodName, "Overriding Default Chance", _Debug)
        Chance = override
    end

    local Roll = R:getInt(1, 100)
    local V = 2000000000

    Log.Debug(MethodName, "Rolled Dice: " .. tostring(Roll), _Debug)

    if Roll < Chance[1] then       V = R:getInt(self.Stations[1], self.Stations[2] -1)
    elseif Roll < Chance[2] then   V = R:getInt(self.Stations[2], self.Stations[3] -1)
    elseif Roll < Chance[3] then   V = R:getInt(self.Stations[3], self.Stations[4] -1)
    elseif Roll < Chance[4] then   V = R:getInt(self.Stations[4], self.Stations[5] -1)
    elseif Roll <= Chance[5] then  V = R:getInt(self.Stations[5], self.Stations[6] -1)
    else                                
        V = R:getInt(self.Stations[1], self.Stations[6])
        Log.Warning(MethodName, "Something Went Wrong, Selecting Random Total Volume: " .. tostring(V))
    end Log.Debug(MethodName, "Selected Volume: " .. tostring(V), _Debug)

    return V / 2

end

-- Civilian Ships are limited to 1 - 4 slot since they are personally owned craft.
function SDKPlanVolumes.Civilian(override)
    local MethodName = self.LogName("Civilian Volume")

    -- Chance Number Must be Matched with Ships Volumes above. 
    -- Leave out the last ship volume because they act as ranges. 

    local Chance = {}
    Chance[1]   = 250
    Chance[2]   = 450
    Chance[3]   = 800
    Chance[4]   = 1000   
    
    if override then
        Log.Debug(MethodName, "Overriding Default Chance", _Debug)
        Chance = override
    end

    local Roll = Rand.Int(1, 1000)
    local V = 1

    Log.Debug(MethodName, "Rolled Dice: " .. tostring(Roll), _Debug)

    if Roll < Chance[1] then            V = Rand.Int(self.Ships[1], self.Ships[2] -1)
    elseif Roll < Chance[2] then        V = Rand.Int(self.Ships[2], self.Ships[3] -1)
    elseif Roll < Chance[3] then        V = Rand.Int(self.Ships[3], self.Ships[4] -1)
    elseif Roll < Chance[4] then        V = Rand.Int(self.Ships[4], self.Ships[5] -1)
    else                                V = Rand.Int(self.Ships[1], self.Ships[5] -1)
        Log.Warning(MethodName, "Something Went Wrong, Selecting Random Slot Volume: " .. tostring(V))
    end Log.Debug(MethodName, "Selected Volume: " .. tostring(V), _Debug)

    return V / 2

end

-- Civilian Ships are limited to 1 - 4 slot since they are personally owned craft.
function SDKPlanVolumes.Drone(override)
    local MethodName = self.LogName("Drone Volume")

    -- Chance Number Must be Matched with Ships Volumes above. 
    -- Leave out the last ship volume because they act as ranges. 

    local Chance = {}
    Chance[1]   = 600
    Chance[2]   = 1000
    
    if override then
        Log.Debug(MethodName, "Overriding Default Chance", _Debug)
        Chance = override
    end

    local Roll = Rand.Int(1, 1000)
    local V = 1

    Log.Debug(MethodName, "Rolled Dice: " .. tostring(Roll), _Debug)

    if Roll < Chance[1] then            V = Rand.Int(self.Ships[1], self.Ships[2] -1)
    elseif Roll < Chance[2] then        V = Rand.Int(self.Ships[2], self.Ships[3] -1)
    else                                V = Rand.Int(self.Ships[1], self.Ships[5] -1)
        Log.Warning(MethodName, "Something Went Wrong, Selecting Random Slot Volume: " .. tostring(V))
    end Log.Debug(MethodName, "Selected Volume: " .. tostring(V), _Debug)

    return V / 2

end

function SDKPlanVolumes.MilitaryName(volume) local MethodName = self.LogName("Military Name")

    Log.Debug(MethodName, "Picking Name for Volume: " .. tostring(volume), _Debug)

    local names = {}
    names[1]  = "Light Scout /* ship title */"%_T        -- 1 -> 319                 (Slot 1 thru 4)
    names[2]  = "Scout /* ship title */"%_T              -- 320 -> 799               (Slot 4)
    names[3]  = "Heavy Scout /* ship title */"%_T        -- 800 -> 1999              (Slot 5)
    names[4]  = "Light Corvette /* ship title */"%_T     -- 2000 -> 2999             (Slot 6)
    names[5]  = "Corvette /* ship title */"%_T           -- 3000 -> 3999             (Slot 6)
    names[6]  = "Heavy Corvette /* ship title */"%_T     -- 4000 -> 4999             (Slot 6)
    names[7]  = "Light Frigate /* ship title */"%_T      -- 5000 -> 9921             (Slot 7)
    names[8]  = "Frigate /* ship title */"%_T            -- 9922 -> 12842            (Slot 7/8)
    names[9]  = "Heavy Frigate /* ship title */"%_T      -- 12843 -> 19763           (Slot 8)
    names[10] = "Light Destroyer /* ship title */"%_T    -- 19764 -> 27531           (Slot 9)
    names[11] = "Destroyer /* ship title */"%_T          -- 27530 -> 35298           (Slot 9/10)
    names[12] = "Heavy Destroyer /* ship title */"%_T    -- 35299 -> 43064           (Slot 10)
    names[13] = "Light Crusier /* ship title */"%_T      -- 43065 -> 54751           (Slot 11)
    names[14] = "Crusier /* ship title */"%_T            -- 54752 -> 66437           (Slot 11/12)
    names[15] = "Heavy Crusier /* ship title */"%_T      -- 66438 -> 78124           (Slot 12)
    names[16] = "Light Battleship /* ship title */"%_T   -- 78125 -> 101540          (Slot 13)
    names[17] = "Battleship /* ship title */"%_T         -- 101541 -> 124995         (Slot 13/14)
    names[18] = "Heavy Battleship /* ship title */"%_T   -- 124996 -> 148370         (Slot 14)
    names[19] = "Light Dreadnought /* ship title */"%_T  -- 148371 -> 182247         (Slot 15)
    names[20] = "Dreadnought /* ship title */"%_T        -- 182248 -> 216123         (Slot 15)
    names[21] = "Heavy Dreadnought /* ship title */"%_T  -- 216124 -> 249999         (Slot 15)
    names[22] = "Titan /* ship title */"%_T              -- 250000 or Larger         (Slot 15)

    local _Volumes = self.GlobalVolumes() for i = 1, #names do
        Log.Debug(MethodName, "Evaluating [" .. tostring(i) .. "] : " .. tostring(volume) .. " = " .. tostring(_Volumes[i]), _Debug)
        if volume <= _Volumes[i] then
            Log.Debug(MethodName, "Returning Name: " .. tostring(names[i]), _Debug)
            return names[i]
        end
    end return "Unmarked Warship /* ship title */"%_T

end

function SDKPlanVolumes.CarrierName(volume) local MethodName = self.LogName("Carrier Name")

    Log.Debug(MethodName, "Picking Name for Volume: " .. tostring(volume), _Debug)

    local names = {}
    names[1]  = "Carrier /* ship title */"%_T                   -- 1 -> 319                 (Slot 1 thru 4)
    names[2]  = "Carrier /* ship title */"%_T                   -- 320 -> 799               (Slot 4)
    names[3]  = "Carrier /* ship title */"%_T                   -- 800 -> 1999              (Slot 5)
    names[4]  = "Carrier /* ship title */"%_T                   -- 2000 -> 2999             (Slot 6)
    names[5]  = "Carrier /* ship title */"%_T                   -- 3000 -> 3999             (Slot 6)
    names[6]  = "Carrier /* ship title */"%_T                   -- 4000 -> 4999             (Slot 6)
    names[7]  = "Carrier /* ship title */"%_T                   -- 5000 -> 9921             (Slot 7)
    names[8]  = "Carrier /* ship title */"%_T                   -- 9922 -> 12842            (Slot 7/8)
    names[9]  = "Carrier /* ship title */"%_T                   -- 12843 -> 19763           (Slot 8)
    names[10] = "Light Support Carrier /* ship title */"%_T     -- 19764 -> 27531           (Slot 9)
    names[11] = "Support Carrier /* ship title */"%_T           -- 27530 -> 35298           (Slot 9/10)
    names[12] = "Heavy Support Carrier /* ship title */"%_T     -- 35299 -> 43064           (Slot 10)
    names[13] = "Light Fleet Carrier /* ship title */"%_T       -- 43065 -> 54751           (Slot 11)
    names[14] = "Fleet Carrier /* ship title */"%_T             -- 54752 -> 66437           (Slot 11/12)
    names[15] = "Heavy Fleet Carrier /* ship title */"%_T       -- 66438 -> 78124           (Slot 12)
    names[16] = "Light Battle Carrier /* ship title */"%_T      -- 78125 -> 101540          (Slot 13)
    names[17] = "Battle Carrier /* ship title */"%_T            -- 101541 -> 124995         (Slot 13/14)
    names[18] = "Heavy Battle Carrier /* ship title */"%_T      -- 124996 -> 148370         (Slot 14)
    names[19] = "Dreadnought Carrier /* ship title */"%_T       -- 148371 -> 182247         (Slot 15)
    names[20] = "Dreadnought Carrier /* ship title */"%_T       -- 182248 -> 216123         (Slot 15)
    names[21] = "Heavy Dreadnought Carrier /* ship title */"%_T -- 216124 -> 249999         (Slot 15)
    names[22] = "Titain Carrier /* ship title */"%_T             -- 250000 or Larger         (Slot 15)

    local _Volumes = self.GlobalVolumes() for i = 1, #names do
        Log.Debug(MethodName, "Evaluating [" .. tostring(i) .. "] : " .. tostring(volume) .. " = " .. tostring(_Volumes[i]), _Debug)
        if volume <= _Volumes[i] then
            Log.Debug(MethodName, "Returning Name: " .. tostring(names[i]), _Debug)
            return names[i]
        end
    end return "Unmarked Carrier /* ship title */"%_T

end

function SDKPlanVolumes.FreighterName(volume) local MethodName = self.LogName("Frighter Name")

    Log.Debug(MethodName, "Picking Name for Volume: " .. tostring(volume), _Debug)

    local names = {}
    names[1]  = "Transporter /* ship title */"%_T       -- 1 -> 319                 (Slot 1 thru 4)
    names[2]  = "Transporter /* ship title */"%_T       -- 320 -> 799               (Slot 4)
    names[3]  = "Transporter /* ship title */"%_T       -- 800 -> 1999              (Slot 5)
    names[4]  = "Transporter /* ship title */"%_T       -- 2000 -> 2999             (Slot 6)
    names[5]  = "Transporter /* ship title */"%_T       -- 3000 -> 3999             (Slot 6)
    names[6]  = "Transporter /* ship title */"%_T       -- 4000 -> 4999             (Slot 6)
    names[7]  = "Transporter /* ship title */"%_T       -- 5000 -> 9921             (Slot 7)
    names[8]  = "Transporter /* ship title */"%_T       -- 9922 -> 12842            (Slot 7/8)
    names[9]  = "Transporter /* ship title */"%_T       -- 12843 -> 19763           (Slot 8)
    names[10] = "Light Lifter /* ship title */"%_T      -- 19764 -> 27531           (Slot 9)
    names[11] = "Lifter /* ship title */"%_T            -- 27530 -> 35298           (Slot 9/10)
    names[12] = "Heavy Lifter /* ship title */"%_T      -- 35299 -> 43064           (Slot 10)
    names[13] = "Light Freighter /* ship title */"%_T   -- 43065 -> 54751           (Slot 11)
    names[14] = "Freighter /* ship title */"%_T         -- 54752 -> 66437           (Slot 11/12)
    names[15] = "Heavy Freighter /* ship title */"%_T   -- 66438 -> 78124           (Slot 12)
    names[16] = "Light Transport /* ship title */"%_T   -- 78125 -> 101540          (Slot 13)
    names[17] = "Transport /* ship title */"%_T         -- 101541 -> 124995         (Slot 13/14)
    names[18] = "Heavy Transport /* ship title */"%_T   -- 124996 -> 148370         (Slot 14)
    names[19] = "Light Hauler /* ship title */"%_T      -- 148371 -> 182247         (Slot 15)
    names[20] = "Hauler /* ship title */"%_T            -- 182248 -> 216123         (Slot 15)
    names[21] = "Heavy Hauler /* ship title */"%_T      -- 216124 -> 249999         (Slot 15)
    names[22] = "Titain Hauler /* ship title */"%_T     -- 250000 or Larger         (Slot 15)

    local _Volumes = self.GlobalVolumes() for i = 1, #names do
        Log.Debug(MethodName, "Evaluating [" .. tostring(i) .. "] : " .. tostring(volume) .. " = " .. tostring(_Volumes[i]), _Debug)
        if volume <= _Volumes[i] then
            Log.Debug(MethodName, "Returning Name: " .. tostring(names[i]), _Debug)
            return names[i]
        end
    end return "Unmarked Frighter /* ship title */"%_T

end

function SDKPlanVolumes.SalvagerName(volume) local MethodName = self.LogName("Salvager Name")

    Log.Debug(MethodName, "Picking Name for Volume: " .. tostring(volume), _Debug)

    local names = {}
    names[1]  = "Light Salvager /* ship title */"%_T        -- 1 -> 319                 (Slot 1 thru 4)
    names[2]  = "Light Salvager /* ship title */"%_T        -- 320 -> 799               (Slot 4)
    names[3]  = "Light Salvager /* ship title */"%_T        -- 800 -> 1999              (Slot 5)
    names[4]  = "Light Salvager /* ship title */"%_T        -- 2000 -> 2999             (Slot 6)
    names[5]  = "Light Salvager /* ship title */"%_T        -- 3000 -> 3999             (Slot 6)
    names[6]  = "Light Salvager /* ship title */"%_T        -- 4000 -> 4999             (Slot 6)
    names[7]  = "Salvager /* ship title */"%_T              -- 5000 -> 9921             (Slot 7)
    names[8]  = "Salvager /* ship title */"%_T              -- 9922 -> 12842            (Slot 7/8)
    names[9]  = "Salvager /* ship title */"%_T              -- 12843 -> 19763           (Slot 8)
    names[10] = "Salvager /* ship title */"%_T              -- 19764 -> 27531           (Slot 9)
    names[11] = "Salvager /* ship title */"%_T              -- 27530 -> 35298           (Slot 9/10)
    names[12] = "Salvager /* ship title */"%_T              -- 35299 -> 43064           (Slot 10)
    names[13] = "Salvager /* ship title */"%_T              -- 43065 -> 54751           (Slot 11)
    names[14] = "Salvager /* ship title */"%_T              -- 54752 -> 66437           (Slot 11/12)
    names[15] = "Heavy Salvager /* ship title */"%_T        -- 66438 -> 78124           (Slot 12)
    names[16] = "Heavy Salvager /* ship title */"%_T        -- 78125 -> 101540          (Slot 13)
    names[17] = "Heavy Salvager /* ship title */"%_T        -- 101541 -> 124995         (Slot 13/14)
    names[18] = "Heavy Salvager /* ship title */"%_T        -- 124996 -> 148370         (Slot 14)
    names[19] = "Salvaging Moloch /* ship title */"%_T      -- 148371 -> 182247         (Slot 15)
    names[20] = "Salvaging Moloch /* ship title */"%_T      -- 182248 -> 216123         (Slot 15)
    names[21] = "Salvaging Moloch /* ship title */"%_T      -- 216124 -> 249999         (Slot 15)
    names[22] = "Salvaging Moloch /* ship title */"%_T      -- 250000 or Larger         (Slot 15)

    local _Volumes = self.GlobalVolumes() for i = 1, #names do
        Log.Debug(MethodName, "Evaluating [" .. tostring(i) .. "] : " .. tostring(volume) .. " = " .. tostring(_Volumes[i]), _Debug)
        if volume <= _Volumes[i] then 
            Log.Debug(MethodName, "Returning Name: " .. tostring(names[i]), _Debug) return names[i]
        end
    end return "Unmarked Salvager /* ship title */"%_T

end

function SDKPlanVolumes.MinerName(volume) local MethodName = self.LogName("Miner Name")

    Log.Debug(MethodName, "Picking Name for Volume: " .. tostring(volume), _Debug)

    local names = {}
    names[1]  = "Light Miner /* ship title */"%_T        -- 1 -> 319                 (Slot 1 thru 4)
    names[2]  = "Light Miner /* ship title */"%_T        -- 320 -> 799               (Slot 4)
    names[3]  = "Light Miner /* ship title */"%_T        -- 800 -> 1999              (Slot 5)
    names[4]  = "Light Miner /* ship title */"%_T        -- 2000 -> 2999             (Slot 6)
    names[5]  = "Light Miner /* ship title */"%_T        -- 3000 -> 3999             (Slot 6)
    names[6]  = "Light Miner /* ship title */"%_T        -- 4000 -> 4999             (Slot 6)
    names[7]  = "Light Miner /* ship title */"%_T        -- 5000 -> 9921             (Slot 7)
    names[8]  = "Light Miner /* ship title */"%_T        -- 9922 -> 12842            (Slot 7/8)
    names[9]  = "Light Miner /* ship title */"%_T        -- 12843 -> 19763           (Slot 8)
    names[10] = "Miner /* ship title */"%_T              -- 19764 -> 27531           (Slot 9)
    names[11] = "Miner /* ship title */"%_T              -- 27530 -> 35298           (Slot 9/10)
    names[12] = "Miner /* ship title */"%_T              -- 35299 -> 43064           (Slot 10)
    names[13] = "Miner /* ship title */"%_T              -- 43065 -> 54751           (Slot 11)
    names[14] = "Miner /* ship title */"%_T              -- 54752 -> 66437           (Slot 11/12)
    names[15] = "Heavy Miner /* ship title */"%_T        -- 66438 -> 78124           (Slot 12)
    names[16] = "Heavy Miner /* ship title */"%_T        -- 78125 -> 101540          (Slot 13)
    names[17] = "Heavy Miner /* ship title */"%_T        -- 101541 -> 124995         (Slot 13/14)
    names[18] = "Heavy Miner /* ship title */"%_T        -- 124996 -> 148370         (Slot 14)
    names[19] = "Mining Moloch /* ship title */"%_T      -- 148371 -> 182247         (Slot 15)
    names[20] = "Mining Moloch /* ship title */"%_T      -- 182248 -> 216123         (Slot 15)
    names[21] = "Mining Moloch /* ship title */"%_T      -- 216124 -> 249999         (Slot 15)
    names[22] = "Mining Moloch /* ship title */"%_T      -- 250000 or Larger         (Slot 15)

    local _Volumes = self.GlobalVolumes() for i = 1, #names do
        Log.Debug(MethodName, "Evaluating [" .. tostring(i) .. "] : " .. tostring(volume) .. " = " .. tostring(_Volumes[i]), _Debug)
        if volume <= _Volumes[i] then 
            Log.Debug(MethodName, "Returning Name: " .. tostring(names[i]), _Debug) return names[i]
        end
    end return "Unmarked Miner /* ship title */"%_T

end

function SDKPlanVolumes.TraderName(volume) local MethodName = self.LogName("Trader Name")

    Log.Debug(MethodName, "Picking Name for Volume: " .. tostring(volume), _Debug)

    local names = {}
    names[1]  = "Trader /* ship title */"%_T                -- 1 -> 319                 (Slot 1 thru 4)
    names[2]  = "Trader /* ship title */"%_T                -- 320 -> 799               (Slot 4)
    names[3]  = "Trader /* ship title */"%_T                -- 800 -> 1999              (Slot 5)
    names[4]  = "Trader /* ship title */"%_T                -- 2000 -> 2999             (Slot 6)
    names[5]  = "Trader /* ship title */"%_T                -- 3000 -> 3999             (Slot 6)
    names[6]  = "Trader /* ship title */"%_T                -- 4000 -> 4999             (Slot 6)
    names[7]  = "Trader /* ship title */"%_T                -- 5000 -> 9921             (Slot 7)
    names[8]  = "Trader /* ship title */"%_T                -- 9922 -> 12842            (Slot 7/8)
    names[9]  = "Trader /* ship title */"%_T                -- 12843 -> 19763           (Slot 8)
    names[10] = "Novice Merchant /* ship title */"%_T       -- 19764 -> 27531           (Slot 9)
    names[11] = "Novice Merchant /* ship title */"%_T       -- 27530 -> 35298           (Slot 9/10)
    names[12] = "Merchant /* ship title */"%_T              -- 35299 -> 43064           (Slot 10)
    names[13] = "Expert Merchant /* ship title */"%_T       -- 43065 -> 54751           (Slot 11)
    names[14] = "Master Merchant /* ship title */"%_T       -- 54752 -> 66437           (Slot 11/12)
    names[15] = "Novice Salesman /* ship title */"%_T       -- 66438 -> 78124           (Slot 12)
    names[16] = "Salesman /* ship title */"%_T              -- 78125 -> 101540          (Slot 13)
    names[17] = "Expert Salesman /* ship title */"%_T       -- 101541 -> 124995         (Slot 13/14)
    names[18] = "Master Salesman /* ship title */"%_T       -- 124996 -> 148370         (Slot 14)
    names[19] = "Trading Hub /* ship title */"%_T           -- 148371 -> 182247         (Slot 15)
    names[20] = "Sector Trading Hub /* ship title */"%_T    -- 182248 -> 216123         (Slot 15)
    names[21] = "Regional Trading Hub /* ship title */"%_T  -- 216124 -> 249999         (Slot 15)
    names[22] = "Planetary Trading Hub /* ship title */"%_T -- 250000 or Larger         (Slot 15)

    local _Volumes = self.GlobalVolumes() for i = 1, #names do
        Log.Debug(MethodName, "Evaluating [" .. tostring(i) .. "] : " .. tostring(volume) .. " = " .. tostring(_Volumes[i]), _Debug)
        if volume <= _Volumes[i] then 
            Log.Debug(MethodName, "Returning Name: " .. tostring(names[i]), _Debug) return names[i]
        end
    end return "Unmarked Trader /* ship title */"%_T

end

return SDKPlanVolumes