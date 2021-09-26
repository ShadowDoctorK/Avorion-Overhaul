--[[
package.path = package.path .. ";data/scripts/lib/?.lua"
package.path = package.path .. ";data/scripts/?.lua"

include("randomext")
local shipGenerator = include("shipgenerator")
local asteroidList = {}
local bossInvincible = true
local PlanGenerator = include ("plangenerator")
local ShipUtility = include ("shiputility")
local SectorTurretGenerator = include ("sectorturretgenerator")
local SectorSpecifics = include ("sectorspecifics")

JumperBoss = {}
]]

local Volume = include("SDKGlobalDesigns - Volumes")
local Equip = include("SDKGlobalDesigns - Equipment")

-- Saved Vanilla Function
JumperBoss.old_spawnBoss = JumperBoss.spawnBoss
function JumperBoss.spawnBoss(x, y)
    if not x and not y then
        x, y = Sector():getCoordinates()
    end

    -- no double spawning
    if Sector():getEntitiesByScript("entity/events/jumperboss.lua") then return end

    -- create ship
    local faction = JumperBoss.getFaction()
    local translation = random():getDirection() * 500
    local position = MatrixLookUpPosition(-translation, vec3(0, 1, 0), translation)
    -- local volume = Balancing_GetSectorShipVolume(Sector():getCoordinates()) * 30

    ---------------------Create Fidget --------------------
    -- Slot 13 to 15+ (Titans) Only
    local Chances = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 250, 500, 750, 1000}

    -- Get Volume Ranges
    local volume = Volume.Ship(Chances)

    -- Override the Volume Passing Custom Volume
    local plan = PlanGenerator.makeShipPlan(faction, volume, "Boss Fidget", nil, true)
    local boss = Sector():createShip(faction, "", plan, position, EntityArrivalType.Jump)

    boss.crew = boss.idealCrew
    boss.shieldDurability = boss.shieldMaxDurability

    AddDefaultShipScripts(boss)
    SetBoardingDefenseLevel(boss)
    -------------------------------------------------------

    -- remove shield if there is one
    local plan = Plan(boss.id)
    if not plan then return end
    local shieldBlocks = plan:getBlocksByType(BlockType.ShieldGenerator)
    for _, blockIndex in pairs(shieldBlocks) do
        plan:setBlockType(blockIndex, BlockType.Armor)
    end

    -- add turrets
    local generator = SectorTurretGenerator()
    local cannon = generator:generate(x, y, 0, Rarity(RarityType.Exceptional), WeaponType.Cannon)
    ShipUtility.addTurretsToCraft(boss, cannon, 3)

    local laser = generator:generate(x, y, 0, Rarity(RarityType.Exotic), WeaponType.Laser)
    ShipUtility.addTurretsToCraft(boss, laser, 2)

    local rocketLauncher = generator:generate(x, y, 0, Rarity(RarityType.Exceptional), WeaponType.RocketLauncher)
    ShipUtility.addTurretsToCraft(boss, rocketLauncher, 5)

    local pdc = generator:generate(x, y, 0, Rarity(RarityType.Exotic), WeaponType.PointDefenseChainGun)
    ShipUtility.addTurretsToCraft(boss, pdc, 2)

    -- add drops
    local randomRarityType = function()
        local rand = random():getInt(1, 10)
        if rand <= 2 then
            return RarityType.Legendary
        else
            return RarityType.Exotic
        end
    end
    Loot(boss.index):insert(InventoryTurret(generator:generate(x, y, 0, Rarity(randomRarityType()), WeaponType.Cannon)))
    Loot(boss.index):insert(InventoryTurret(generator:generate(x, y, 0, Rarity(randomRarityType()), WeaponType.Laser)))

    -- adds legendary turret drop
    boss:addScriptOnce("internal/common/entity/background/legendaryloot.lua")

    -- add properties
    boss.name = ""
    boss.title = "Fidget"%_T
    Boarding(boss).boardable = false
    boss.dockable = false
    boss:addScript("data/scripts/entity/events/jumperboss.lua")
    boss:addScript("deleteonplayersleft.lua")

    -- set boss aggressive immediately
    local players = {Sector():getPlayers()}
    for _, player in pairs(players) do
        ShipAI(boss.id):registerEnemyFaction(player.index)
    end
    ShipAI(boss.id):setAggressive()

end

--[[
function JumperBoss.getFaction()
    local name = "The Pariah"%_T
    local faction = Galaxy():findFaction(name)
    if faction == nil then
        faction = Galaxy():createFaction(name, 0, 0)
        faction.initialRelations = 0
        faction.initialRelationsToPlayer = 0
        faction.staticRelationsToPlayers = true
    end

    faction.initialRelationsToPlayer = 0
    faction.staticRelationsToPlayers = true
    faction.homeSectorUnknown = true

    return faction
end

return JumperBoss
]]