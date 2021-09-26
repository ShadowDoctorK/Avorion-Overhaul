--[[
    Developer Notes:
    - Build a dedicated Fighter Generator to allow more features.
]]

include("weapontype")
local SectorTurretGenerator = include ("sectorturretgenerator")
local SectorFighterGenerator = include("sectorfightergenerator")

local Log = include("SDKDebugLogging")
local Faction = include("SDKUtilityFaction")
local Rand = include("SDKUtilityRandom")
local Volume = include("SDKGlobalDesigns - Volumes")

local _ModName = "Equipment Utility"
local _Debug = 0

SDKEquipment = {}

SDKEquipment._Armed      = "Armed"
SDKEquipment._Defense    = "Defense"
SDKEquipment._Repair     = "Repair"
SDKEquipment._Miner      = "Miner"
SDKEquipment._Salvager   = "Salvager"
SDKEquipment._Combat     = "Combat"
SDKEquipment._Cargo      = "Cargo"
SDKEquipment._Crew       = "Crew"

local self = SDKEquipment

-- Fucntion to build Methodname
function SDKEquipment.LogName(n)
    return _ModName .. " - " .. n
end

-- Set the number of Fither Wings based on Difficulty
function SDKEquipment.Wings() local Method = self.LogName("Wings")
    local S = GameSettings() local W = 2

    Log.Debug(Method, "Game Difficuty: " .. Log.S(S.difficulty), _Debug)

    if S.difficulty == Difficulty.Insane then           W = 10
    elseif S.difficulty == Difficulty.Hardcore then     W = 7
    elseif S.difficulty == Difficulty.Expert then       W = 6
    elseif S.difficulty == Difficulty.Veteran then      W = 4
    elseif S.difficulty == Difficulty.Normal then       W = 2
    elseif S.difficulty == Difficulty.Easy then         W = 1
    end 
    
    Log.Debug(Method, "Returing: " .. Log.S(W), _Debug)

    return W
end

--[[
    fac = Faction
    t   = Fighter Type    
]]
function SDKEquipment.GetFighter(fac, t)

    local G = SectorFighterGenerator() G.factionIndex = fac.index

    local F -- Fighter
    if t == self._Salvager then
    elseif t == self._Miner then
    elseif t == self._Repair then
    elseif t == self._Cargo then
    elseif t == self._Crew then
    else -- Combat
        F = G:generateArmed(fac:getHomeSectorCoordinates())
    end

    return F
end

function SDKEquipment.CombatHanger(target, wings)

    wings = wings or self.Wings()   -- Total Wings
    local H = Hangar(target.index)  -- Ship Hanger
    
    local fac = Faction.New() fac.Load(target.factionIndex)

    if wings >= 0     then H:addSquad("Alpha")
        local F = self.GetFighter(fac.Get(), self._Combat) for i = 1, 10 do H:addFighter(0, F) end
    elseif wings > 1  then H:addSquad("Bravo")
        local F = self.GetFighter(fac.Get(), self._Combat) for i = 1, 10 do H:addFighter(1, F) end
    elseif wings > 2  then H:addSquad("Charlie")
        local F = self.GetFighter(fac.Get(), self._Combat) for i = 1, 10 do H:addFighter(2, F) end
    elseif wings > 3  then H:addSquad("Delta")
        local F = self.GetFighter(fac.Get(), self._Combat) for i = 1, 10 do H:addFighter(3, F) end
    elseif wings > 4  then H:addSquad("Foxtrot")
        local F = self.GetFighter(fac.Get(), self._Combat) for i = 1, 10 do H:addFighter(4, F) end
    elseif wings > 5  then H:addSquad("Golf")
        local F = self.GetFighter(fac.Get(), self._Combat) for i = 1, 10 do H:addFighter(5, F) end
    elseif wings > 6  then H:addSquad("Hotel")
        local F = self.GetFighter(fac.Get(), self._Combat) for i = 1, 10 do H:addFighter(6, F) end
    elseif wings > 7  then H:addSquad("India")
        local F = self.GetFighter(fac.Get(), self._Combat) for i = 1, 10 do H:addFighter(7, F) end
    elseif wings > 8  then H:addSquad("Juliet")
        local F = self.GetFighter(fac.Get(), self._Combat) for i = 1, 10 do H:addFighter(8, F) end
    elseif wings > 9  then H:addSquad("Kilo")
        local F = self.GetFighter(fac.Get(), self._Combat) for i = 1, 10 do H:addFighter(9, F) end
    end

end

function SDKEquipment.GetTurrets(ship, fac)
    local F = Faction.New() F.Is(fac)
    local num = Volume.Turrets(ship.volume)
    local Armed = num + (math.max(0, F.Trait("careful") * num))
    local Defense = math.floor(num /2) + (math.max(0, F.Trait("careful") * math.floor(num /2)))

    return Armed, Defense
end

function SDKEquipment.StoreTurret(fac, turret)
    local F = Faction.New() F.Is(fac)
    if not Faction.InventoryAdd(Turret) then 
        Log.Error(MethodName, "Failed to add new turret to faction...", 1) 
    end
end

--[[
    This function will pull the target Factions Inventory and sort the turrets they have. It will then
    randomly pull turrets of the target type to add to the target craft.
    fac  = Faction
    type = Type of turret to add
    num  = How many to add
]]
function SDKEquipment.FactionTurret(target, fac, type, num) local MethodName = self.LogName("Faction Turret")

    -- Load and check the faction type is AI. Player and Alliances don't get free stuff.
    Faction.Is(fac) if Faction.Type() ~= 2 then return end
    num = num or Volume.Turrets(target.volume)
    
    local S -- Selected

    if Faction.IsSelf(Faction.Civilian()) then
        S = self.NewFactionTurret(fac, type, false)                         -- Generate new turret and don't store it.
        self.InstallTurrets(target, S, num) return
    end

    --[[
        function table<int, table<unsigned int, InventoryItem>> getItemsByType(InventoryItemType type)
            Use Turret or TurretTemplate?
    ]]
    local Items = Faction.InventoryItems(InventoryItemType.TurretTemplate)  -- Grab all the Factions Turrets.

    local Armed = {}    local Repair = {}       local Defense = {}
    local Miner = {}    local Salvager = {}

    Log.Info(MethodName, "# Items: " .. Log.S(#Items), _Debug)

    for i, SlotItem in pairs(Items) do -- Pull the Inventory Slot
        
        local v = SlotItem.item -- Pull the item from the Inventory Slot
        
        Log.Info(MethodName, "Item Name: " .. Log.S(v.name), _Debug)

        -- Allow weapons with more then one of these traits to be added to more the one table.
        -- Using the raw stats vice the Weapon Catagory so we can also sort Modded weapons.
        if v.armed == true then 
            if v.damageType ~= DamageType.Fragments then
                 table.insert(Armed, v)                                     -- Check for Armed
            else table.insert(Defense, v) end end                           -- Check for Defense
        if v.hullRepairRate > 0 then table.insert(Reapir, v) end            -- Check for Hull Repair
        if v.shieldRepairRate > 0 then table.insert(Reapir, v) end          -- Check for Shield Repair
        if v.stoneRawEfficiency > 0 then table.insert(Miner, v) end         -- Check for Miner
        if v.stoneRefinedEfficiency > 0 then table.insert(Miner, v) end     -- Check for R-Miner
        if v.metalRawEfficiency > 0 then table.insert(Salvager, v) end      -- Check for Salvager
        if v.metalRefinedEfficiency > 0 then table.insert(Salvager, v) end  -- Check for R-Salvager

    end 

    if type == self._Armed then
        if   #Armed ~= 0 then S = Armed[Rand.Int(1, #Armed)] end           -- Random Faction Turret
    elseif type == self._Defense then
        if   #Defense ~= 0 then S = Defense[Rand.Int(1, #Defense)] end     -- Random Faction Turret
    elseif type == self._Miner then
        if   #Miner ~= 0 then S = Miner[Rand.Int(1, #Miner)] end           -- Random Faction Turret
    elseif type == self._Salvager then
        if   #Salvager ~= 0 then S = Salvager[Rand.Int(1, #Salvager)] end  -- Random Faction Turret
    elseif type == self._Repair then
        if   #Repair ~= 0 then S = Repair[Rand.Int(1, #Repair)] end        -- Random Faction Turret
    end

    -- Check if we have a turret to return
    if not S then 
        Log.Warning(MethodName, Log.S(Faction.Name()) .. " - Had to create a new turret: " .. Log.S(type), 1)
        S = self.NewFactionTurret(fac, type, true)                         -- Generate new turret and store it.
    end

    self.InstallTurrets(target, S, num)

end

function SDKEquipment.NewFactionTurret(fac, type, store) local MethodName = self.LogName("New Faction Turret")

    Faction.Is(fac)                 -- Load Faction
    local x, y = Faction.Home()     -- Faction Home Sector

    local seed = Server().seed + fac.index
    local turretGenerator = SectorTurretGenerator(seed)

    local Turret if type == self._Armed then
        Turret = turretGenerator:generateArmed(x, y, 0, Rarity(RarityType.Common))
    elseif type == self._Miner then
        Turret = turretGenerator:generate(x, y, 0, Rarity(RarityType.Common), WeaponType.MiningLaser)
    elseif type == self._Defense then
        Turret = turretGenerator:generate(x, y, 0, Rarity(RarityType.Common), WeaponType.PointDefenseChainGun)
    elseif type == self._Salvager then
        Turret = turretGenerator:generate(x, y, 0, Rarity(RarityType.Common), WeaponType.SalvagingLaser)
    elseif type == self._Repair then
        Turret = turretGenerator:generate(x, y, 0, Rarity(RarityType.Common), WeaponType.RepairBeam)
    end Turret.coaxial = false

    -- make sure the armed turrets don't have a too high fire rate
    -- so they don't slow down update times too much when there's lots of firing going on
    local weapons = {Turret:getWeapons()} Turret:clearWeapons() 
    for _, weapon in pairs(weapons) do

        if weapon.isProjectile and (weapon.fireRate or 0) > 2 then
            local old = weapon.fireRate
            weapon.fireRate = math.random(1.0, 2.0)
            weapon.damage = weapon.damage * old / weapon.fireRate;
        end Turret:addWeapon(weapon)
    end

    -- Store New Turret
    if store then 
       -- Try to store the new turret and log failure.
       if not Faction.InventoryAdd(Turret) then Log.Error(MethodName, "Failed to add new turret to faction...", 1) end
    end

    return Turret
end

function SDKEquipment.InstallTurrets(target, turret, num)

    turret = copy(turret)
    turret.coaxial = false

    --[[
        Modify this code later to adjust the turret based on the size reduction.
        we don't want to create turrets that don't fall within the normal generator.
    ]]
    local values = {target:getTurretPositionsLineOfSight(turret, num)}
    while #values == 0 and turret.size > 0.5 do
        turret.size = turret.size - 0.5 -- This only make it smaller, doesn't adjust damage.
        values = {target:getTurretPositionsLineOfSight(turret, num)}
    end

    local c = 1;
    num = tablelength(values) / 2 -- divide by 2 since getTurretPositions returns 2 values per turret

    -- Try to fill max open spots.
    for i = 1, num do
        local position = values[c]; c = c + 1;
        local part = values[c]; c = c + 1;

        if part ~= nil then
            target:addTurret(turret, position, part)
        else
            -- print("no turrets added, no place for turret found")
        end
    end

end

return SDKEquipment