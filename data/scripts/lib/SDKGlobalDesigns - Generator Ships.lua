--[[
    Developer Notes:
    - Upgrade Turret Code
]]

package.path = package.path .. ";data/scripts/lib/?.lua"
package.path = package.path .. ";data/scripts/?.lua"

include ("galaxy")
include ("utility")
include ("defaultscripts")
include ("goods")
local ShipUtility = include ("shiputility")                         -- Not Used Currently
local SectorFighterGenerator = include("sectorfightergenerator")    -- Not Used Currently

local Plans = include ("plangenerator")
local Rand = include("SDKUtilityRandom")
local Faction = include("SDKUtilityFaction")
local Class = include("SDKGlobalDesigns - Classes")
local Volume = include("SDKGlobalDesigns - Volumes")
local Equip = include("SDKGlobalDesigns - Equipment")

local SDKShipGenerator = {}
local self = SDKShipGenerator

function SDKShipGenerator.Generator()
    return Plans
end

function SDKShipGenerator.Equipment()
    return Equip
end

function SDKShipGenerator.Defaults(ship)
    AddDefaultShipScripts(ship)
    SetBoardingDefenseLevel(ship)
end

function SDKShipGenerator.GetTurrets(ship, fac)
    local F = Faction.New() F.Is(fac)
    local num = Volume.Turrets(ship.volume)
    local Armed = num + (math.max(0, F.Trait("careful") * num))
    local Defense = math.floor(num /2) + (math.max(0, F.Trait("careful") * math.floor(num /2)))

    return Armed, Defense
end

function SDKShipGenerator.Ship(fac, pos, o)
    pos = pos or Matrix()
    o = o or Plans.GetOverride()

    local plan = Plans.Ship(fac, "Military", o)
    local ship = Sector():createShip(fac, "", plan, pos)

    ship.crew = ship.idealCrew
    ship.shieldDurability = ship.shieldMaxDurability

    self.Defaults(ship)

    return ship
end

function SDKShipGenerator.Defender(fac, pos, o)
    
    local F = Faction.New() F.Is(fac) -- Load Faction

    pos = pos or Matrix()

    -- Customized Standard Override
    o = o or Plans.GetOverride(nil, Volume.Defender())

    local ship = self.Ship(fac, pos, o)
    ship:setValue("SDKShipType", "Defender")

    local Armed, Defense = self.GetTurrets(ship, fac)
    Equip.FactionTurret(ship, fac, Equip._Armed, Armed)        -- Armed Faction Turrets
    Equip.FactionTurret(ship, fac, Equip._Defense, Defense)    -- Defense Faction Turrets

    ship.title = Volume.MilitaryName(ship.volume)
    ship.shieldDurability = ship.shieldMaxDurability
    ship.crew = ship.idealCrew   
    
    -- Vanilla Code
        ship:addScript("ai/patrol.lua")
        ship:addScript("antismuggle.lua")
        ship:setValue("is_armed", true)     -- Vanilla Item
        ship:setValue("is_defender", true)  -- Vanilla Item
        ship:setValue("npc_chatter", true)  -- Vanilla Variable
        ship:addScript("icon.lua", "data/textures/icons/pixel/defender.png")
    -- End Vanilla Code

    return ship
end

-- Hanger will be used later when I set up dedicated equipment configs
function SDKShipGenerator.Carrier(fac, pos, hanger, o)

    local F = Faction.New() F.Is(fac) -- Load Faction
    pos = pos or Matrix()

    -- Customized Standard Override
    o = o or Plans.GetOverride(nil, Volume.Carrier())
    
    local plan = Plans.Ship(fac, Class.Carrier, o)
    local ship = Sector():createShip(fac, "", plan, pos)
    ship:setValue("SDKShipType", "Carrier")

    local Armed, Defense = self.GetTurrets(ship, fac)
    Equip.FactionTurret(ship, fac, Equip._Armed, Armed)        -- Armed Faction Turrets
    Equip.FactionTurret(ship, fac, Equip._Defense, Defense)    -- Defense Faction Turrets
    Equip.CombatHanger(ship)                                   -- Add Fighters Wings

    ship.shieldDurability = ship.shieldMaxDurability
    ship.title = Volume.CarrierName(ship.volume)
    ship.crew = ship.idealCrew

    ship:addScript("ai/patrol.lua")
    ship:setValue("is_armed", true)      -- Vanilla Variable
    ship:addScript("icon.lua", "data/textures/icons/pixel/carrier.png")

    return ship
end

function SDKShipGenerator.Military(fac, pos, o)

    local ship = self.Ship(fac, pos, o)
    ship:setValue("SDKShipType", "Military")

    local Armed, Defense = self.GetTurrets(ship, fac)
    Equip.FactionTurret(ship, fac, Equip._Armed, Armed)        -- Armed Faction Turrets
    Equip.FactionTurret(ship, fac, Equip._Defense, Defense)    -- Defense Faction Turrets

    ship.crew = ship.idealCrew
    ship.title = Volume.MilitaryName(ship.volume)
    ship.shieldDurability = ship.shieldMaxDurability

    ship:setValue("is_armed", true)      -- Vanilla Variable
    ship:addScript("icon.lua", "data/textures/icons/pixel/military-ship.png")

    return ship
end

function SDKShipGenerator.Trader(fac, pos, o)
    local ship = self.Ship(fac, pos, o)
    ship:setValue("SDKShipType", "Trader")

    local Armed, Defense = self.GetTurrets(ship, fac)
    if Rand.Truth(0.75) then
        Equip.FactionTurret(ship, fac, Equip._Armed, Armed)    -- Armed Faction Turrets
        ship:setValue("is_armed", true)      -- Vanilla Variable
    end
    Equip.FactionTurret(ship, fac, Equip._Defense, Defense)    -- Defense Faction Turrets

    ship.crew = ship.idealCrew
    ship.title = Volume.TraderName(ship.volume)
    ship.shieldDurability = ship.shieldMaxDurability

    ship:addScript("civilship.lua")
    ship:addScript("dialogs/storyhints.lua")
    ship:setValue("is_civil", true)         -- Vanilla Variable
    ship:setValue("is_trader", true)        -- Vanilla Variable
    ship:setValue("npc_chatter", true)      -- Vanilla Variable
    ship:addScript("icon.lua", "data/textures/icons/pixel/civil-ship.png")

    return ship
end

function SDKShipGenerator.Freighter(fac, pos, o)
    pos = pos or Matrix()
    o = o or Plans.GetOverride()

    local plan = Plans.Ship(fac, Class.Freighter, o)
    local ship = Sector():createShip(fac, "", plan, pos)
    ship:setValue("SDKShipType", "Freighter")
    
    self.Defaults(ship)
    ship.shieldDurability = ship.shieldMaxDurability

    local Armed, Defense = self.GetTurrets(ship, fac)
    if Rand.Truth() then
        Equip.FactionTurret(ship, fac, Equip._Armed, Armed)    -- Armed Faction Turrets
        ship:setValue("is_armed", true)      -- Vanilla Variable
    end
    Equip.FactionTurret(ship, fac, Equip._Defense, Defense)    -- Defense Faction Turrets
    
    ship.crew = ship.idealCrew
    ship.title = Volume.FreighterName(ship.volume)

    ship:addScript("civilship.lua")
    ship:addScript("dialogs/storyhints.lua")
    ship:setValue("is_civil", true)         -- Vanilla Variable
    ship:setValue("is_freighter", true)     -- Vanilla Variable
    ship:setValue("npc_chatter", true)      -- Vanilla Variable
    ship:addScript("icon.lua", "data/textures/icons/pixel/civil-ship.png")

    return ship
end

function SDKShipGenerator.Miner(fac, pos, o)
    pos = pos or Matrix()
    o = o or Plans.GetOverride()

    local plan = Plans.Ship(fac, Class.Miner, o)
    local ship = Sector():createShip(fac, "", plan, pos)
    ship:setValue("SDKShipType", "Miner")
    
    self.Defaults(ship)
    ship.shieldDurability = ship.shieldMaxDurability
    
    local Armed, Defense = self.GetTurrets(ship, fac)
    Equip.FactionTurret(ship, fac, Equip._Miner, Armed)        -- Miner Faction Turrets
    Equip.FactionTurret(ship, fac, Equip._Defense, Defense)    -- Defense Faction Turrets
    if Rand.Truth(0.25) then
        Equip.FactionTurret(ship, fac, Equip._Armed, Armed)    -- Armed Faction Turrets
        ship:setValue("is_armed", true)      -- Vanilla Variable
    end
    
    ship.crew = ship.idealCrew
    ship.title = Volume.MinerName(ship.volume)

    ship:addScript("civilship.lua")
    ship:addScript("dialogs/storyhints.lua")
    ship:setValue("is_civil", true)             -- Vanilla Variable
    ship:setValue("is_miner", true)             -- Vanilla Variable
    ship:setValue("npc_chatter", true)          -- Vanilla Variable
    ship:addScript("icon.lua", "data/textures/icons/pixel/civil-ship.png")

    return ship
end

function SDKShipGenerator.Salvager(fac, pos, o)
    pos = pos or Matrix()
    o = o or Plans.GetOverride()

    local plan = Plans.Ship(fac, Class.Salvager, o)
    local ship = Sector():createShip(fac, "", plan, pos)
    ship:setValue("SDKShipType", "Salvager")
    
    self.Defaults(ship)
    ship.shieldDurability = ship.shieldMaxDurability
    
    local Armed, Defense = self.GetTurrets(ship, fac)
    Equip.FactionTurret(ship, fac, Equip._Salvager, Armed)     -- Salvager Faction Turrets
    Equip.FactionTurret(ship, fac, Equip._Defense, Defense)    -- Defense Faction Turrets
    if Rand.Truth(0.25) then
        Equip.FactionTurret(ship, fac, Equip._Armed, Armed)    -- Armed Faction Turrets
        ship:setValue("is_armed", true)      -- Vanilla Variable
    end

    ship.crew = ship.idealCrew
    ship.title = Volume.SalvagerName(ship.volume)
       
    ship:addScriptOnce("civilship.lua")
    ship:addScriptOnce("ai/patrol.lua")
    ship:setValue("is_civil", 1)             -- Vanilla Variable
    ship:setValue("npc_chatter", true)       -- Vanilla Variable
    ship:addScriptOnce("icon.lua", "data/textures/icons/pixel/civil-ship.png")

    return ship
end

function SDKShipGenerator.Civilian(fac, pos, o)
    pos = pos or Matrix()
    fac = fac or Faction.Civilian()     -- Global Civilian Faction
    o = o or Plans.GetOverride()

    local plan = Plans.Ship(fac, Class.Civilian, o)
    local ship = Sector():createShip(fac, "", plan, pos)
    ship:setValue("SDKShipType", "Civilian")
    
    self.Defaults(ship)
    ship.shieldDurability = ship.shieldMaxDurability
    
    local _, Defense = self.GetTurrets(ship, fac)
    if Rand.Truth(0.5) then
        Equip.FactionTurret(ship, fac, Equip._Defense, Defense)    -- Defense Faction Turrets
    end
    
    ship.crew = ship.idealCrew
    ship.title = "Civilian"
       
    ship:addScriptOnce("civilship.lua")    
    ship:setValue("is_civil", 1)             -- Vanilla Variable
    ship:setValue("npc_chatter", true)       -- Vanilla Variable
    ship:addScriptOnce("icon.lua", "data/textures/icons/pixel/civil-ship.png")

    return ship
end

return SDKShipGenerator
