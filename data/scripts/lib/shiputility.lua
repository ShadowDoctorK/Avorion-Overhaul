local GenTurret = ("turretgenertor.lua")
local Log = include("SDKDebugLogging")

local _Debug = 0
local _ModName = "Ship Utility"

-- Fucntion to build Methodname
function GetName(n)
    return _ModName .. " - " .. n
end

----------------------------------------------------------------------------------------------------------
----------------------------------------- Added Funcitons ------------------------------------------------
----------------------------------------------------------------------------------------------------------


function ShipUtility.GlobalVolumes()
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

function ShipUtility.getCarrierNameByVolume(volume)
    local _MethodName = GetName("Carrier Name By Volume")

    Log.Debug(_MethodName, "Picking Name for Volume: " .. tostring(volume), _Debug)

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

    local _Volumes = ShipUtility.GlobalVolumes()

    for i = 1, #names do

        Log.Debug(_MethodName, "Evaluating [" .. tostring(i) .. "] : " .. tostring(volume) .. " = " .. tostring(_Volumes[i]), _Debug)

        if volume <= _Volumes[i] then
            Log.Debug(_MethodName, "Returning Name: " .. tostring(names[i]), _Debug)
            return names[i]
        end
    end

    return "Unmarked Carrier /* ship title */"%_T

end

----------------------------------------------------------------------------------------------------------
------------------------------------- Modified Vanilla Funcitons -----------------------------------------
----------------------------------------------------------------------------------------------------------

-- Saved Vanilla Function
ShipUtility.old_getMilitaryNameByVolume = ShipUtility.getMilitaryNameByVolume
function ShipUtility.getMilitaryNameByVolume(volume)
    local _MethodName = GetName("Military Name By Volume")

    Log.Debug(_MethodName, "Picking Name for Volume: " .. tostring(volume), _Debug)

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

    local _Volumes = ShipUtility.GlobalVolumes()

    for i = 1, #names do

        --Log.Debug(_MethodName, "Evaluating [" .. tostring(i) .. "] : " .. tostring(volume) .. " = " .. tostring(_Volumes[i]), _Debug)

        if volume <= _Volumes[i] then
            Log.Debug(_MethodName, "Returning Name: " .. tostring(names[i]), _Debug)
            return names[i]
        end
    end

    return "Unmarked Warship /* ship title */"%_T

end

-- Saved Vanilla Function
ShipUtility.old_addCarrierEquipment = ShipUtility.addCarrierEquipment
function ShipUtility.addCarrierEquipment(craft, fighters)
    fighters = fighters or 24

    -- add fighters
    local hangar = Hangar(craft.index)
    hangar:addSquad("Alpha")
    hangar:addSquad("Beta")
    hangar:addSquad("Gamma")

    local faction = Faction(craft.factionIndex)

    local generator = SectorFighterGenerator()
    generator.factionIndex = faction.index

    local numFighters = 0
    for squad = 0, 2 do
        local fighter = generator:generateArmed(faction:getHomeSectorCoordinates())
        for i = 1, 7 do
            hangar:addFighter(squad, fighter)

            numFighters = numFighters + 1
            if numFighters >= fighters then break end
        end

        if numFighters >= fighters then break end
    end

    ShipUtility.addCIWSEquipment(craft)

    craft:setTitle("${toughness}${class}"%_T, {toughness = "", class = ShipUtility.getCarrierNameByVolume(craft.volume)})
    craft:setValue("is_armed", 1)
    craft:addScript("icon.lua", "data/textures/icons/pixel/carrier.png")

end

--[[
-- Custom Weapon Function
function ShipUtility.getWeaponRarity()

    local sector = Sector()
    if not sector then return nil end    if not Server then return nil end
    local distanceValue = round((500 - length(vec2(sector:getCoordinates()))) / 150)
    local rarityValue = math.min(RarityType.Exotic, math.max(RarityType.Common, distanceValue + Server().difficulty))

    return Rarity(rarityValue)
end

-- Custom Weapon Function
function ShipUtility.getTurretTempletByType()

    local _X, _Y = Sector():getCoordinates()
    local _Random = Random(Seed(os.time()))
    local _DPS

end

function ShipUtility.genTurret(x, y, offset_in, rarity_in, type_in, material_in)

    local offset = offset_in or 0
    local dps = 0

    local rarities = self.rarities or self:getSectorRarityDistribution(x, y)
    local rarity = rarity_in or Rarity(getValueFromDistribution(rarities, self.random))
    local seed, qx, qy = self:getTurretSeed(x, y, weaponType, rarity)

    local sector = math.max(0, math.floor(length(vec2(qx, qy))) + offset)

    local weaponDPS, weaponTech = Balancing_GetSectorWeaponDPS(sector, 0)
    local miningDPS, miningTech = Balancing_GetSectorMiningDPS(sector, 0)
    local materialProbabilities = Balancing_GetTechnologyMaterialProbability(sector, 0)
    local material = material_in or Material(getValueFromDistribution(materialProbabilities, self.random))
    local weaponType = type_in or getValueFromDistribution(Balancing_GetWeaponProbability(sector, 0), self.random)

    local tech = 0
    if weaponType == WeaponType.MiningLaser then
        dps = miningDPS
        tech = miningTech
    elseif weaponType == WeaponType.RawMiningLaser then
        dps = miningDPS * 2
        tech = miningTech
    elseif weaponType == WeaponType.ForceGun then
        dps = 1200
        tech = weaponTech
    else
        dps = weaponDPS
        tech = weaponTech
    end

    return TurretGenerator.generateSeeded(seed, weaponType, dps, tech, rarity, material)
end

function ShipUtility.addTurretsToCraft(entity, turret, numTurrets, maxNumTurrets)

    local maxNumTurrets = maxNumTurrets or 10
    if maxNumTurrets == 0 then return end

    turret = copy(turret)
    turret.coaxial = false

    local wantedTurrets = math.max(1, round(numTurrets / turret.slots))

    local values = {entity:getTurretPositionsLineOfSight(turret, numTurrets)}
    while #values == 0 and turret.size > 0.5 do
        turret.size = turret.size - 0.5
        values = {entity:getTurretPositionsLineOfSight(turret, numTurrets)}
    end

    local c = 1;
    numTurrets = tablelength(values) / 2 -- divide by 2 since getTurretPositions returns 2 values per turret

    -- limit the turrets of the ships to maxNumTurrets
    numTurrets = math.min(numTurrets, maxNumTurrets)

    local strengthFactor = wantedTurrets / numTurrets
    if numTurrets > 0 and strengthFactor > 1.0 then
        entity.damageMultiplier = math.max(entity.damageMultiplier, strengthFactor)
    end

    for i = 1, numTurrets do
        local position = values[c]; c = c + 1;
        local part = values[c]; c = c + 1;

        if part ~= nil then
            entity:addTurret(turret, position, part)
        else
            -- print("no turrets added, no place for turret found")
        end
    end

end

function ShipUtility.addArmedTurretsToCraft(entity, amount)

    local faction = Faction(entity.factionIndex)

    local turrets = {}

    local items = faction:getInventory():getItemsByType(InventoryItemType.TurretTemplate)

    for i, slotItem in pairs(items) do
        local turret = slotItem.item

        if turret.armed then
            table.insert(turrets, turret)
        end
    end

    -- find out what kind of turret to add to the craft
    if #turrets == 0 then return end

    local turret
    if entity.isStation then
        -- stations get turrets with highest reach

        local currentReach = 0.0

        for i, t in pairs(turrets) do
            for j = 0, t.numWeapons - 1 do

                local reach = t.reach
                if reach > currentReach then
                    currentReach = reach
                    turret = t
                end
            end
        end

    else
        -- ships get random turrets
        turret = turrets[math.random(1, #turrets)]
    end

    -- find out how many are possible with the current crew limitations
    local requiredCrew = turret:getCrew()

    if requiredCrew.size > 0 then
        local numTurrets = 0;

        if entity.isStation then
            numTurrets = math.random(40, 60)
        else
            numTurrets = amount
        end

        -- add turrets
        ShipUtility.addTurretsToCraft(entity, turret, numTurrets)

    end

end
]]
