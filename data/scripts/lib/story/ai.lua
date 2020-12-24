local Plan = include("SDKUtilityBlockPlan")

--[[
package.path = package.path .. ";data/scripts/lib/?.lua"
package.path = package.path .. ";data/scripts/?.lua"
include ("randomext")
include ("utility")
include ("stringutility")
SectorTurretGenerator = include ("sectorturretgenerator")
ShipUtility = include ("shiputility")
include("weapontype")

local AI = {}

function AI.getFaction()
    local faction = Galaxy():findFaction("The AI"%_T)
    if faction == nil then
        faction = Galaxy():createFaction("The AI"%_T, 300, 0)
        faction.initialRelations = 0
        faction.initialRelationsToPlayer = 0
        faction.staticRelationsToAll = true
    end

    faction.homeSectorUnknown = true

    return faction
end

function AI.addTurrets(boss, numTurrets)

    -- create custom plasma turrets
    local turret = SectorTurretGenerator(Seed(150)):generate(300, 0, 0, Rarity(RarityType.Exceptional), WeaponType.PlasmaGun)
    local weapons = {turret:getWeapons()}
    turret:clearWeapons()
    for _, weapon in pairs(weapons) do
        weapon.damage = 15 / #weapons
        weapon.fireRate = 2
        weapon.reach = 1000
        weapon.pmaximumTime = weapon.reach / weapon.pvelocity
        weapon.pcolor = Material(2).color
        turret:addWeapon(weapon)
    end
    turret.crew = Crew()
    ShipUtility.addTurretsToCraft(boss, turret, numTurrets, numTurrets)

    ShipUtility.addBossAntiTorpedoEquipment(boss, numTurrets)

end
]]

-- Custom Function
function AI.TotalTurrets()
    -- Adjust based on Difficulty
    local _Number = 15
    local _Settings = GameSettings()
    if _Settings.difficulty == Difficulty.Insane then 
        _Number = 40
    elseif _Settings.difficulty == Difficulty.Hardcore then 
        _Number = 30
    elseif _Settings.difficulty == Difficulty.Expert then 
        _Number = 25
    elseif _Settings.difficulty == Difficulty.Veteran then 
        _Number = 20
    elseif _Settings.difficulty == Difficulty.Normal then 
        _Number = 15
    elseif _Settings.difficulty == Difficulty.Easy then 
        _Number = 10
    end return _Number
end

-- Save Vanilla Function
AI.old_spawn = AI.spawn 
function AI.spawn(x, y)

    -- no double spawning
    if Sector():getEntitiesByScript("entity/story/aibehaviour.lua") then return end

    local faction = AI.getFaction()

    local _Plan if Plan.Load("data/plans/Default/Boss/Little Brother.xml") then
        Plan.Material()
        _Plan = Plan.Get()
    else
        _Plan = LoadPlanFromFile("data/plans/the_ai.xml")
    end

    local s = 1.5
    _Plan:scale(vec3(s, s, s))
    _Plan.accumulatingHealth = false

    local pos = random():getVector(-1000, 1000)
    pos = MatrixLookUpPosition(-pos, vec3(0, 1, 0), pos)

    local boss = Sector():createShip(faction, "", _Plan, pos)

    boss.shieldDurability = boss.shieldMaxDurability
    boss.title = "The AI"%_T
    boss.name = ""
    boss.crew = boss.minCrew
    boss:addScriptOnce("story/aibehaviour")
    boss:addScriptOnce("story/aidialog")
    boss:addScriptOnce("deleteonplayersleft")

    WreckageCreator(boss.index).active = false
    Loot(boss.index):insert(InventoryTurret(SectorTurretGenerator():generate(x, y, 0, Rarity(RarityType.Exotic))))
    Loot(boss.index):insert(InventoryTurret(SectorTurretGenerator():generate(x, y, 0, Rarity(RarityType.Exotic))))
    boss:addScriptOnce("internal/common/entity/background/legendaryloot.lua")

    -- create custom plasma turrets
    AI.addTurrets(boss, AI.TotalTurrets())

    Boarding(boss).boardable = false

    AI.checkForDrop()

    return boss
end

--[[
local lastAIPosition = nil
local lastSector = {}

function AI.checkForDrop()

    -- if it's the last one, then drop the key
    local faction = AI.getFaction()

    local all = {Sector():getEntitiesByScript("story/aibehaviour")}
    local aiPosition = nil

    -- make sure this is all happening in the same sector
    local x, y = Sector():getCoordinates()
    if lastSector.x ~= x or lastSector.y ~= y then
        -- this must be set in order to drop the loot
        -- if the sector changed, simply unset it
        lastAIPosition = nil
    end
    lastSector.x = x
    lastSector.y = y

    local aiPresent = false
    for _, entity in pairs(all) do
        aiPosition = entity.translationf
        aiPresent = true
        break
    end

    local dropped

    -- if there are no ais now but there have been before, drop the upgrade
    if aiPosition == nil and lastAIPosition ~= nil then
        local players = {Sector():getPlayers()}

        for _, player in pairs(players) do
            local system = SystemUpgradeTemplate("data/scripts/systems/teleporterkey6.lua", Rarity(RarityType.Legendary), random():createSeed())
            Sector():dropUpgrade(lastAIPosition, player, nil, system)
            dropped = true

        end
    end

    lastAIPosition = aiPosition

    return dropped, aiPresent
end

return AI
]]