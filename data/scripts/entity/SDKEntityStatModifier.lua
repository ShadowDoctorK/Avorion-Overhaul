package.path = package.path .. ";data/scripts/entity/?.lua"
package.path = package.path .. ";data/scripts/lib/?.lua"

include ("utility")
include ("randomext")
include ("SDKEntityModifier")
local Log = include ("SDKDebugLogging")

local _ModName = "Entity Stat Modifier"
local _Debug = 0

-- Planned Ship Rebalance (Not currently used)
local _ModSlot1Durability = 4
local _ModSlot1DamageFactor = 0.2
local _ModSlot2Durability = 3.66
local _ModSlot2DamageFactor = 0.3
local _ModSlot3Durability = 3.33
local _ModSlot3DamageFactor = 0.4
local _ModSlot4Durability = 3
local _ModSlot4DamageFactor = 0.5
local _ModSlot5Durability = 2.66
local _ModSlot5DamageFactor = 0.6
local _ModSlot6Durability = 2.33
local _ModSlot6DamageFactor = 0.7
local _ModSlot7Durability = 2
local _ModSlot7DamageFactor = 0.8
local _ModSlot8Durability = 1.66
local _ModSlot8DamageFactor = 0.9
local _ModSlot9Durability = 1.33
local _ModSlot9DamageFactor = 1


-- Repalance the stats of the people so they can manage the larger building (Offset cost)
function initialize()
    _Entity = Entity()

    -- if valid(_Entity) then end

    if _Entity.isStation then

        _Entity:addMultiplier(StatsBonuses.Engineers, 10)
        _Entity:addMultiplier(StatsBonuses.Mechanics, 10)
        -- _Entity:addMultiplier(StatsBonuses.Sergeants, 6)       Changed in 2.0
        -- _Entity:addMultiplier(StatsBonuses.Lieutenants, 4)     Changed in 2.0
        -- _Entity:addMultiplier(StatsBonuses.Commanders, 2.5)    Changed in 2.0
        -- _Entity:addMultiplier(StatsBonuses.Generals, 2.5)      Changed in 2.0

        _Entity:addMultiplier(StatsBonuses.Security, 0.2)

        _Entity:addAbsoluteBias(StatsBonuses.DefenseWeapons, 50)
        _Entity:addAbsoluteBias(StatsBonuses.ArbitraryTurrets,26)  
        _Entity:addMultiplyableBias(StatsBonuses.PointDefenseTurrets, 10)  -- Add 10 Defense Turrets

    end

    if _Entity.isShip then
        _Entity:addMultiplier(StatsBonuses.Security, 3) 
        _Entity:addMultiplyableBias(StatsBonuses.PointDefenseTurrets, 2)   -- Add 2 Defense Turrets   
    end

    _Entity:addMultiplier(StatsBonuses.Attackers, 3)

end

-- Planned Code for Ship Management and Balances
function UpdateSlotBonuses()   
    
    local _Entity = Entity()    
    local _ShipSystem = ShipSystem(_Entity)    
    local _Slots = _ShipSystem.numSockets

end