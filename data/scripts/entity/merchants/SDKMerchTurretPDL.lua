package.path = package.path .. ";data/scripts/lib/?.lua"
include ("galaxy")
include ("utility")
include ("randomext")
include ("faction")
include ("stringutility")
include ("weapontype")
local ShopAPI = include ("shop")
local SectorTurretGenerator = include ("sectorturretgenerator")

-- Don't remove or alter the following comment, it tells the game the namespace this script lives in. If you remove it, the script will break.
-- namespace SDKMerchTurretPDL
SDKMerchTurretPDL = {}
SDKMerchTurretPDL = ShopAPI.CreateNamespace()
SDKMerchTurretPDL.interactionThreshold = -30000

SDKMerchTurretPDL.rarityFactors = {}
SDKMerchTurretPDL.rarityFactors[-1] = 1.0
SDKMerchTurretPDL.rarityFactors[0] = 1.0
SDKMerchTurretPDL.rarityFactors[1] = 1.0
SDKMerchTurretPDL.rarityFactors[2] = 0.8
SDKMerchTurretPDL.rarityFactors[3] = 0.7
SDKMerchTurretPDL.rarityFactors[4] = 0.5
SDKMerchTurretPDL.rarityFactors[5] = 0.1

SDKMerchTurretPDL.specialOfferRarityFactors = {}
SDKMerchTurretPDL.specialOfferRarityFactors[-1] = 0.0
SDKMerchTurretPDL.specialOfferRarityFactors[0] = 0.0
SDKMerchTurretPDL.specialOfferRarityFactors[1] = 0.0
SDKMerchTurretPDL.specialOfferRarityFactors[2] = 1.0
SDKMerchTurretPDL.specialOfferRarityFactors[3] = 1.0
SDKMerchTurretPDL.specialOfferRarityFactors[4] = 0.25
SDKMerchTurretPDL.specialOfferRarityFactors[5] = 0.05

-- if this function returns false, the script will not be listed in the interaction window,
-- even though its UI may be registered
function SDKMerchTurretPDL.interactionPossible(playerIndex, option)
    return CheckFactionInteraction(playerIndex, SDKMerchTurretPDL.interactionThreshold)
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

function SDKMerchTurretPDL.shop:addItems()

    -- simply init with a 'random' seed
    local station = Entity()

    -- create all turrets
    local turrets = {}

    local x, y = Sector():getCoordinates()
    local generator = SectorTurretGenerator()
    generator.rarities = generator:getSectorRarityDistribution(x, y)

    for i, rarity in pairs(generator.rarities) do
        generator.rarities[i] = rarity * SDKMerchTurretPDL.rarityFactors[i] or 1
    end

    for i = 1, 8 do

        local type = WeaponType.PointDefenseLaser

        local turret = InventoryTurret(generator:generate(x, y, nil, nil, type))
        local amount = random():getInt(1, 3)

        local pair = {}
        pair.turret = turret
        pair.amount = amount

        if turret.rarity.value == 1 then -- uncommon weapons
            if math.random() < 0.3 then
                pair.amount = pair.amount + random():getInt(1, 3)
            end
        elseif turret.rarity.value == 0 then -- common weapons
            if math.random() < 0.5 then
                pair.amount = pair.amount + random():getInt(1, 3)
            end
            if math.random() < 0.5 then
                pair.amount = pair.amount + random():getInt(1, 3)
            end
        end

        table.insert(turrets, pair)
    end

    table.sort(turrets, comp)

    for _, pair in pairs(turrets) do
        SDKMerchTurretPDL.shop:add(pair.turret, pair.amount)
    end
end

-- sets the special offer that gets updated every 20 minutes
function SDKMerchTurretPDL.shop:onSpecialOfferSeedChanged()
    local generator = SectorTurretGenerator(SDKMerchTurretPDL.shop:generateSeed())

    local x, y = Sector():getCoordinates()
    local rarities = generator:getSectorRarityDistribution(x, y)

    for i, rarity in pairs(rarities) do
        rarities[i] = rarity * SDKMerchTurretPDL.specialOfferRarityFactors[i] or 1
    end

    generator.rarities = rarities

    local type = WeaponType.PointDefenseLaser
    
    local specialOfferTurret = InventoryTurret(generator:generate(x, y, nil, nil, type))
    SDKMerchTurretPDL.shop:setSpecialOffer(specialOfferTurret)
end

function SDKMerchTurretPDL.initialize(Roll)

    if Roll then
        -- 25% to Remove this script from the Equipment Dock
        local _Dice = Rand.Float(0, 1) if _Dice < 0.25 then terminate() return end
    end
    
    SDKMerchTurretPDL.shop:initialize("PDL Turret Merchant"%_t)

    if onClient() and EntityIcon().icon == "" then
        EntityIcon().icon = "data/textures/icons/pixel/turret.png"
    end
end

function SDKMerchTurretPDL.initUI()
    SDKMerchTurretPDL.shop:initUI("Trade Equipment"%_t, "PDL Turret Merchant"%_t, "PDL Turrets"%_t, "data/textures/icons/point-defense-laser.png")
end
