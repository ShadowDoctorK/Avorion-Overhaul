--[[
    Developer Notes:
    - Added more turret types to each faction on creation
]]

--[[  
package.path = package.path .. ";data/scripts/lib/?.lua"
include ("randomext")
include ("galaxy")
local SectorTurretGenerator = include ("sectorturretgenerator")
local SectorSpecifics = include("sectorspecifics")
include("weapontype")
include("faction")
local FactionPacks = include("factionpacks")
]]

function initializeAIFaction(faction)

    -- Vanilla Code
        local seed = Server().seed + faction.index
        local random = Random(seed)

        function createRandomTrait(trait, contrary)
            SetFactionTrait(faction, trait, contrary, random:getFloat(-1.0, 1.0))
        end

        local turretGenerator = SectorTurretGenerator(seed)

        local x, y = faction:getHomeSectorCoordinates()
    -- End Vanilla Code

    local Turrets = {}
    
    local Bolter = turretGenerator:generate(x, y, 0, nil, WeaponType.Bolter) 
    Bolter.coaxial = false table.insert(Turrets, Bolter)

    local Chaingun = turretGenerator:generate(x, y, 0, nil, WeaponType.Chaingun)
    Chaingun.coaxial = false table.insert(Turrets, Chaingun)
    
    local Railgun = turretGenerator:generate(x, y, 0, nil, WeaponType.Railgun)
    Railgun.coaxial = false table.insert(Turrets, Railgun)
    
    local Laser = turretGenerator:generate(x, y, 0, nil, WeaponType.Laser)
    Laser.coaxial = false table.insert(Turrets, Laser)
    
    local PlasmaGun = turretGenerator:generate(x, y, 0, nil, WeaponType.PlasmaGun)
    PlasmaGun.coaxial = false table.insert(Turrets, PlasmaGun)
    
    local RocketLauncher = turretGenerator:generate(x, y, 0, nil, WeaponType.RocketLauncher)
    RocketLauncher.coaxial = false table.insert(Turrets, RocketLauncher)
    
    local Cannon = turretGenerator:generate(x, y, 0, nil, WeaponType.Cannon)
    Cannon.coaxial = false table.insert(Turrets, Cannon)
    
    local PulseCannon = turretGenerator:generate(x, y, 0, nil, WeaponType.PulseCannon)
    PulseCannon.coaxial = false table.insert(Turrets, PulseCannon) 
    
    local LightningGun = turretGenerator:generate(x, y, 0, nil, WeaponType.LightningGun)
    LightningGun.coaxial = false table.insert(Turrets, LightningGun) 

    local MiningLaser = turretGenerator:generate(x, y, 0, nil, WeaponType.MiningLaser)
    MiningLaser.coaxial = false;

    -- make sure the armed turrets don't have a too high fire rate
    -- so they don't slow down update times too much when there's lots of firing going on
    for _, turret in pairs(Turrets) do

        local weapons = {turret:getWeapons()}
        turret:clearWeapons()

        for _, weapon in pairs(weapons) do

            if weapon.isProjectile and (weapon.fireRate or 0) > 2 then
                local old = weapon.fireRate
                weapon.fireRate = math.random(1.0, 2.0)
                weapon.damage = weapon.damage * old / weapon.fireRate;
            end

            turret:addWeapon(weapon)
        end
    end

    local Inventory = faction:getInventory() for k, v in pairs(Turrets) do
        --print(faction.name .. ": Adding (" .. tostring(v.rarity) .. ") " .. tostring(v.name))
        Inventory:add(v, false)
    end

    Inventory:add(MiningLaser, false)

    -- Vanilla Code
        createRandomTrait("peaceful"%_T, "aggressive"%_T)
        createRandomTrait("careful"%_T, "brave"%_T)
        createRandomTrait("generous"%_T, "greedy"%_T)
        createRandomTrait("opportunistic"%_T, "honorable"%_T)
        createRandomTrait("trusting"%_T, "mistrustful"%_T)

        if random:test(0.5) then
            faction:setTrait("forgiving", random:getFloat(0.0, 1.0))
        end

        FactionPacks.tryApply(faction)
    -- End Vanilla Code
end

--[[
function initializePlayer(player)

    local galaxy = Galaxy()
    local server = Server()

    local random = Random(server.seed)

    -- get a random angle, fixed for the server seed
    local angle = random:getFloat(2.0 * math.pi)


    -- for each player registered, add a small amount on top of this angle
    -- this way, all players are near each other
    local home = nil
    local faction

    local distFromCenter = 450.0
    local distBetweenPlayers = 1 + random:getFloat(0, 1) -- distance between the home sectors of different players

    local tries = {}

    for i = 1, 3000 do
        -- we're looking at a distance of 450, so the perimeter is ~1413
        -- with every failure we walk a distance of 3 on the perimeter, so we're finishing a complete round about every 500 failing iterations
        -- every failed round we reduce the radius by several sectors to cover a bigger area.
        local offset = math.floor(i / 500) * 5

        local coords =
        {
            x = math.cos(angle) * (distFromCenter - offset),
            y = math.sin(angle) * (distFromCenter - offset),
        }

        table.insert(tries, coords)

        -- try to place the player in the area of a faction
        faction = galaxy:getLocalFaction(coords.x, coords.y)
        if faction then
            -- found a faction we can place the player to - stop looking if we don't need different start sectors
            if server.sameStartSector then
                home = coords
                break
            end

            -- in case we need different starting sectors: keep looking
            if galaxy:sectorExists(coords.x, coords.y) then
                angle = angle + (distBetweenPlayers / distFromCenter)
            else
                home = coords
                break
            end
        else
            angle = angle + (3 / distFromCenter)
        end
    end

    if not home then
        home = randomEntry(random, tries)
        faction = galaxy:getLocalFaction(home.x, home.y)
    end

    player:setHomeSectorCoordinates(home.x, home.y)
    player:setRespawnSectorCoordinates(home.x, home.y)

    -- make sure the player has an early ally
    if not faction then
        faction = galaxy:getNearestFaction(home.x, home.y)
    end

    faction:setValue("enemy_faction", -1) -- this faction won't participate in faction wars
    galaxy:setFactionRelations(faction, player, 85000)
    player:setValue("start_ally", faction.index)
    player:setValue("gates2.0", true)

    local random = Random(SectorSeed(home.x, home.y) + player.index)
    local settings = GameSettings()

    if settings.startingResources == -4 then -- -4 means quick start
        player:receive(250000, 25000, 15000)
    elseif settings.startingResources == Difficulty.Beginner then
        player:receive(50000, 5000)
    elseif settings.startingResources == Difficulty.Easy then
        player:receive(40000, 2000)
    elseif settings.startingResources == Difficulty.Normal then
        player:receive(30000)
    else
        player:receive(10000)
    end

    -- create turret generator
    local generator = SectorTurretGenerator()

    local miningLaser = InventoryTurret(generator:generate(450, 0, nil, Rarity(RarityType.Common), WeaponType.MiningLaser, Material(MaterialType.Iron)))
    for i = 1, 2 do
        player:getInventory():add(miningLaser, false)
    end

    local chaingun = InventoryTurret(generator:generate(450, 0, nil, Rarity(RarityType.Common), WeaponType.ChainGun, Material(MaterialType.Iron)))
    for i = 1, 2 do
        player:getInventory():add(chaingun, false)
    end

    if settings.playTutorial then
        -- extra inventory items for tutorial: One arbitrary tcs, three more armed turrets with the name used in the text of tutorial stage
        local upgrade = SystemUpgradeTemplate("data/scripts/systems/arbitrarytcs.lua", Rarity(RarityType.Uncommon), Seed(121))
        player:getInventory():add(upgrade, true)

        chaingun.title = "Chaingun /* Weapon Type */"%_T
        player:getInventory():add(chaingun, false)
        player:getInventory():add(chaingun, false)
        player:getInventory():add(chaingun, false)

        -- start with 750 iron and 30.000 credits into tutorial independent of difficulty
        player.money = 30000
        player:setResources(750, 0, 0, 0, 0, 0, 0, 0)
    else
        if server.difficulty <= Difficulty.Normal then

            local upgrade = SystemUpgradeTemplate("data/scripts/systems/arbitrarytcs.lua", Rarity(RarityType.Uncommon), Seed(1))
            player:getInventory():add(upgrade, true)

            player:receive(0, 7500)

            for i = 1, 2 do
                player:getInventory():add(miningLaser, false)
                player:getInventory():add(chaingun, false)
            end
        end
    end

    if settings.fullBuildingUnlocked then
        player.maxBuildableMaterial = Material(MaterialType.Avorion)
        player.maxBuildableSockets = 0
    else
        player.maxBuildableMaterial = Material(MaterialType.Iron)
        player.maxBuildableSockets = 4
    end

end

function initializeAlliance(alliance)
    alliance:setValue("gates2.0", true)

end
]]