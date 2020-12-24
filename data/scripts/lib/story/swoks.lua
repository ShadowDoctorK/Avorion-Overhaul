--[[
package.path = package.path .. ";data/scripts/lib/?.lua"
package.path = package.path .. ";data/scripts/?.lua"
include ("randomext")
include ("utility")
local SectorSpecifics = include ("sectorspecifics")
local PirateGenerator = include ("pirategenerator")
local SectorTurretGenerator = include ("sectorturretgenerator")
local PlanGen = include("plangenerator")
local Plan = include("SDKUtilityBlockPlan")

local Swoks = {}
]]

----------------------------------------------------------------------------------------------------------
----------------------------------------- Added Funcitons ------------------------------------------------
----------------------------------------------------------------------------------------------------------


local PlanGen = include("plangenerator")
local Plan = include("SDKUtilityBlockPlan")
local ShipUtility = include("shiputility")

function Swoks.ScaleChances()
    -- Adjust based on Difficulty
    local _Chances = {0, 0, 0, 0, 0, 0, 0, 0, 0, 250, 500, 750, 1000, 1000, 1000, 1000}
    local _Settings = GameSettings()
    if _Settings.difficulty == Difficulty.Insane then        _Chances = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 333, 666, 1000}
    elseif _Settings.difficulty == Difficulty.Hardcore then  _Chances = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 250, 500, 750, 1000}
    elseif _Settings.difficulty == Difficulty.Expert then    _Chances = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 250, 500, 750, 1000, 1000}
    elseif _Settings.difficulty == Difficulty.Veteran then   _Chances = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 250, 500, 750, 1000, 1000, 1000}
    elseif _Settings.difficulty == Difficulty.Normal then    _Chances = {0, 0, 0, 0, 0, 0, 0, 0, 0, 250, 500, 750, 1000, 1000, 1000, 1000}
    elseif _Settings.difficulty == Difficulty.Easy then      _Chances = {0, 0, 0, 0, 0, 0, 0, 0, 250, 500, 750, 1000, 1000, 1000, 1000, 1000}
    end return _Chances
end

-- Custom Function
function Swoks.TotalTurrets()
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

function Swoks.Faction()
    local name = "The Pirate Guild"%_T

    local galaxy = Galaxy()
    local faction = galaxy:findFaction(name)
    if faction == nil then
        faction = galaxy:createFaction(name, 350, 0)
        faction.initialRelations = -100000
        faction.initialRelationsToPlayer = -100000
        faction.staticRelationsToPlayers = true

        for trait, value in pairs(faction:getTraits()) do
            faction:setTrait("aggressive", 1)
            faction:setTrait("greedy", 1)
            faction:setTrait("opportunistic", 1)
            faction:setTrait("brave", 1)
            faction:setTrait("mistrustful", 1)
        end
    end

    faction.initialRelationsToPlayer = -100000
    faction.staticRelationsToPlayers = true
    faction.homeSectorUnknown = true

    return faction

end

----------------------------------------------------------------------------------------------------------
------------------------------------- Modified Vanilla Funcitons -----------------------------------------
----------------------------------------------------------------------------------------------------------

--[[
if onClient() then

    function Swoks.UpdateIcon(_Entity)
        EntityIcon(_Entity).icon = "data/textures/icons/pixel/skull_big.png"
    end

end
]]

-- Save Vanilla Function
Swoks.old_spawn = Swoks.spawn function Swoks.spawn(player, x, y)

    local function piratePosition()
        local pos = random():getVector(-1000, 1000)
        return MatrixLookUpPosition(-pos, vec3(0, 1, 0), pos)
    end

    local bossBeaten = Server():getValue("swoks_beaten") or 2
    local number = bossBeaten + 1

    
    ----------------- Create Boss Swoks ----------------
    local _Boss
    local Chances = Swoks.ScaleChances() -- Get Volume Ranges
    local _Volume = PlanGen.GetShipVolume(Chances) * 3 -- Volume will be divided by 3 in the Plan Generator
    local _Faction = Swoks.Faction()

    -- Try Loading Custom Design
    local _Plan if Plan.Load("data/plans/Default/Boss/Swoks.xml") then
        Plan.Material() Plan.Scale(_Volume) _Plan = Plan.Get()               

        -- Set Up Basic Stuff Missed Since We Didn't Use The Pirate Generator
        _Boss = Sector():createShip(_Faction, "", _Plan, piratePosition())
        PirateGenerator.addPirateEquipment(_Boss, "Pirate Mothership")
        _Boss.crew = _Boss.minCrew
        _Boss.shieldDurability = _Boss.shieldMaxDurability
        ShipUtility.addArmedTurretsToCraft(_Boss, Swoks.TotalTurrets())
        --broadcastInvokeClientFunction("UpdateIcon", _Boss)    
    else -- Fallback to Games Generator
        _Boss = PirateGenerator.createBoss(piratePosition())
    end
    ----------------------------------------------------

    _Boss:setTitle("Boss Swoks ${num}"%_T, {num = toRomanLiterals(number)})
    _Boss.dockable = false

    pirates = {}
    table.insert(pirates, _Boss)
    table.insert(pirates, PirateGenerator.createRaider(piratePosition()))
    table.insert(pirates, PirateGenerator.createRaider(piratePosition()))
    table.insert(pirates, PirateGenerator.createRavager(piratePosition()))
    table.insert(pirates, PirateGenerator.createRavager(piratePosition()))
    table.insert(pirates, PirateGenerator.createMarauder(piratePosition()))
    table.insert(pirates, PirateGenerator.createMarauder(piratePosition()))
    table.insert(pirates, PirateGenerator.createPirate(piratePosition()))
    table.insert(pirates, PirateGenerator.createPirate(piratePosition()))
    table.insert(pirates, PirateGenerator.createBandit(piratePosition()))
    table.insert(pirates, PirateGenerator.createBandit(piratePosition()))
    table.insert(pirates, PirateGenerator.createBandit(piratePosition()))

    -- Correct Factions.
    for i = 1, #pirates do
        pirates[i].factionIndex = _Faction.index
    end   

    -- adds legendary turret drop
    _Boss:registerCallback("onDestroyed", "onSwoksDestroyed")

    Loot(_Boss.index):insert(InventoryTurret(SectorTurretGenerator():generate(x, y, 0, Rarity(RarityType.Rare))))
    Loot(_Boss.index):insert(InventoryTurret(SectorTurretGenerator():generate(x, y, 0, Rarity(RarityType.Rare))))
    Loot(_Boss.index):insert(InventoryTurret(SectorTurretGenerator():generate(x, y, 0, Rarity(RarityType.Rare))))
    Loot(_Boss.index):insert(InventoryTurret(SectorTurretGenerator():generate(x, y, 0, Rarity(RarityType.Exceptional))))
    Loot(_Boss.index):insert(InventoryTurret(SectorTurretGenerator():generate(x, y, 0, Rarity(RarityType.Exceptional))))
    Loot(_Boss.index):insert(InventoryTurret(SectorTurretGenerator():generate(x, y, 0, Rarity(RarityType.Exotic))))
    Loot(_Boss.index):insert(InventoryTurret(SectorTurretGenerator():generate(x, y, 0, Rarity(RarityType.Legendary))))
    Loot(_Boss.index):insert(SystemUpgradeTemplate("data/scripts/systems/teleporterkey3.lua", Rarity(RarityType.Legendary), Seed()))

    for _, pirate in pairs(pirates) do
        pirate:addScript("deleteonplayersleft.lua")

        if not player then break end
        local allianceIndex = player.allianceIndex
        local ai = ShipAI(pirate.index)
        ai:registerFriendFaction(player.index)
        if allianceIndex then
            ai:registerFriendFaction(allianceIndex)
        end
    end

    _Boss:addScript("story/swoks.lua")
    _Boss:addScriptOnce("internal/common/entity/background/legendaryloot.lua")
    _Boss:setValue("is_pirate", true)

    Boarding(_Boss).boardable = false
end

--[[
return Swoks
]]