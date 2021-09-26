package.path = package.path .. ";data/scripts/lib/?.lua"
include ("galaxy")
include ("utility")
include ("randomext")
include ("faction")
include ("stringutility")
include ("weapontype")
--local Rand = include("SDKUtilityRandom")
local ShopAPI = include ("shop")
local SectorTurretGenerator = include ("sectorturretgenerator")

-- Don't remove or alter the following comment, it tells the game the namespace this script lives in. If you remove it, the script will break.
-- namespace SDKTurretMerchant
SDKTurretMerchant = {}
SDKTurretMerchant = ShopAPI.CreateNamespace()
SDKTurretMerchant.interactionThreshold = -50000    -- Local merchants don't care as much as the factory.

SDKTurretMerchant.rarityFactors = {}
SDKTurretMerchant.rarityFactors[-1] = 1.0
SDKTurretMerchant.rarityFactors[0] = 1.0
SDKTurretMerchant.rarityFactors[1] = 1.0
SDKTurretMerchant.rarityFactors[2] = 1.0
SDKTurretMerchant.rarityFactors[3] = 1.0
SDKTurretMerchant.rarityFactors[4] = 1.0
SDKTurretMerchant.rarityFactors[5] = 1.0

SDKTurretMerchant.specialOfferRarityFactors = {}
SDKTurretMerchant.specialOfferRarityFactors[-1] = 0.0
SDKTurretMerchant.specialOfferRarityFactors[0] = 0.0
SDKTurretMerchant.specialOfferRarityFactors[1] = 0.0
SDKTurretMerchant.specialOfferRarityFactors[2] = 1.0
SDKTurretMerchant.specialOfferRarityFactors[3] = 1.0
SDKTurretMerchant.specialOfferRarityFactors[4] = 0.25
SDKTurretMerchant.specialOfferRarityFactors[5] = 0.0

-- if this function returns false, the script will not be listed in the interaction window,
-- even though its UI may be registered
function SDKTurretMerchant.interactionPossible(playerIndex, option)
    return CheckFactionInteraction(playerIndex, SDKTurretMerchant.interactionThreshold)
end

local function comp(a, b)
    local ta = a.turret;
    local tb = b.turret;

    if ta.rarity.value == tb.rarity.value then
        if ta.material.value == tb.material.value then
            return ta.weaponPrefix < tb.weaponPrefix
        else
            return ta.material.value > tb.material.value
        end
    else
        return ta.rarity.value > tb.rarity.value
    end
end

function SDKTurretMerchant.shop:addItems()

    -- simply init with a 'random' seed
    local station = Entity()

    -- create all turrets
    local turrets = {}

    local x, y = Sector():getCoordinates()
    local generator = SectorTurretGenerator()
    generator.rarities = generator:getSectorRarityDistribution(x, y)

    for i, rarity in pairs(generator.rarities) do
        generator.rarities[i] = rarity * SDKTurretMerchant.rarityFactors[i] or 1
    end

    for i = 1, 13 do
        local turret = InventoryTurret(generator:generate(x, y))
        local amount = 1
        if i == 1 then
            turret = InventoryTurret(generator:generate(x, y, nil, nil, WeaponType.MiningLaser))
            amount = 2
        elseif i == 2 then
            turret = InventoryTurret(generator:generate(x, y, nil, nil, WeaponType.PointDefenseChainGun))
            amount = 2
        elseif i == 3 then
            turret = InventoryTurret(generator:generate(x, y, nil, nil, WeaponType.ChainGun))
            amount = 2
        end

        local pair = {}
        pair.turret = turret
        pair.amount = amount

        if turret.rarity.value == 1 then -- uncommon weapons may be more than one
            if math.random() < 0.3 then
                pair.amount = pair.amount + 1
            end
        elseif turret.rarity.value == 0 then -- common weapons may be some more than one
            if math.random() < 0.5 then
                pair.amount = pair.amount + 1
            end
            if math.random() < 0.5 then
                pair.amount = pair.amount + 1
            end
        end

        table.insert(turrets, pair)
    end

    table.sort(turrets, comp)

    for _, pair in pairs(turrets) do
        SDKTurretMerchant.shop:add(pair.turret, pair.amount)
    end
end

-- sets the special offer that gets updated every 20 minutes
function SDKTurretMerchant.shop:onSpecialOfferSeedChanged()
    local generator = SectorTurretGenerator(SDKTurretMerchant.shop:generateSeed())

    local x, y = Sector():getCoordinates()
    local rarities = generator:getSectorRarityDistribution(x, y)

    for i, rarity in pairs(rarities) do
        rarities[i] = rarity * SDKTurretMerchant.specialOfferRarityFactors[i] or 1
    end

    generator.rarities = rarities

    local specialOfferTurret = InventoryTurret(generator:generate(x, y))
    SDKTurretMerchant.shop:setSpecialOffer(specialOfferTurret)
end

function SDKTurretMerchant.initialize()
    SDKTurretMerchant.shop:initialize("Merchant Bay #1"%_t)

    if onClient() and EntityIcon().icon == "" then
        EntityIcon().icon = "data/textures/icons/pixel/turret.png"
    end
end

function SDKTurretMerchant.initUI()
    SDKTurretMerchant.shop:initUI("Independant Merchants"%_t, "Turrets"%_t, "Turrets"%_t, "data/textures/icons/bag_turret.png")
end