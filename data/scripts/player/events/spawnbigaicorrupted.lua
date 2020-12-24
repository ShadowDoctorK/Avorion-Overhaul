local Plan = include("SDKUtilityBlockPlan")
--[[
package.path = package.path .. ";data/scripts/lib/story/?.lua"
package.path = package.path .. ";data/scripts/lib/?.lua"
package.path = package.path .. ";data/scripts/?.lua"
include ("randomext")
include ("utility")
include ("stringutility")
SectorTurretGenerator = include ("sectorturretgenerator")
local AILocatorUtility = include("ailocatorutility")
ShipUtility = include ("shiputility")
SpawnUtility = include ("spawnutility")
include("weapontype")
include ("callable")


BigAICorrupted = {}

local coordinates = {}

function BigAICorrupted.sync(data_in)
    if onServer() then
        invokeClientFunction(Player(), "sync", coordinates)
    else
        if data_in then
            coordinates = data_in
        else
            invokeServerFunction("sync")
        end
    end
end
callable(BigAICorrupted, "sync")

function BigAICorrupted.initialize()
    local player = Player()

    if onServer() then
        player:registerCallback("onSectorEntered", "onSectorEntered")
        if not _restoring then
            local x, y = AILocatorUtility.getCoordinates(true)
            coordinates.x = x
            coordinates.y = y

            local currentX, currentY = player:getSectorCoordinates()
            if currentX == x and currentY == y then
                BigAICorrupted.spawn(x, y)
            end

            BigAICorrupted.sync()
        end
    else
        -- to be able to mark sector
        player:registerCallback("onMapRenderAfterUI", "onMapRenderAfterUI")
        BigAICorrupted.sync()
    end
end
]]

----------------------------------------------------------------

--[[
if onClient() then

    function BigAICorrupted.onMapRenderAfterUI()
        BigAICorrupted.renderIcons()
    end

    function BigAICorrupted.renderIcons()
        local map = GalaxyMap()
        local renderer = UIRenderer()
        local icon = "data/textures/icons/pixel/skull_big.png"

        local sx, sy = map:getCoordinatesScreenPosition(ivec2(coordinates.x, coordinates.y))
        renderer:renderCenteredPixelIcon(vec2(sx, sy), ColorRGB(1, 0.1, 0), icon)

        renderer:display()
    end

end
]]

----------------------------------------------------------------

if onServer() then

    --[[
    local aiPresent = false
    function BigAICorrupted.getUpdateInterval()
        if aiPresent then
            return 1
        else
            return 10
        end
    end

    function BigAICorrupted.update(timestep)
        local done, present = BigAICorrupted.checkForDefeat()
        aiPresent = present

        if done then
            local server = Server()
            local killCounter = (server:getValue("corrupted_ai_kill_counter") or 0) + 1
            print ("Corrupted AI was beaten for the ".. killCounter ..". time!")
            server:setValue("corrupted_ai_kill_counter", killCounter) -- set this to get new server-wide location
            server:setValue("corrupted_ai_timer", server.unpausedRuntime)
        end
    end

    local lastAIPosition = nil
    local lastSector = {}
    function BigAICorrupted.checkForDefeat()
        local faction = BigAICorrupted.getFaction()

        local all = {Sector():getEntitiesByScript("story/corruptedaibehaviour")}
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

        local defeated

        -- if there are no ais now but there have been before, it has been defeated
        if aiPosition == nil and lastAIPosition ~= nil then
            defeated = true
            terminate()
        end

        lastAIPosition = aiPosition

        return defeated, aiPresent
    end

    function BigAICorrupted.onSectorEntered(playerIndex, x, y, sectorChangeType)
        -- test if coords are the ones the player got marked on map
        if coordinates.x == x and coordinates.y == y then
            -- test if coords are current spawn location of Corrupted AI
            local xCurrent, yCurrent = AILocatorUtility.getCoordinates(true)
            local player = Player()
            if x == xCurrent and y == yCurrent then
                BigAICorrupted.spawn(x, y)
                player:registerCallback("onSectorLeft", "onSectorLeft")
            else
                player:sendChatMessage("", ChatMessageType.Notification, "It seems the AI has already moved on."%_T, x, y)
            end
        end
    end

    function BigAICorrupted.onSectorLeft(playerId, x, y, changeType)
        local player = Player(playerId)
        player:removeScript("spawnbigaicorrupted.lua") -- if player runs, he shouldn't be able to respawn Corrupted AI on reenter
    end


    function BigAICorrupted.getFaction()
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

    function BigAICorrupted.addTurrets(boss, numTurrets)
        local random = Random(Seed(151))
        if numTurrets < 3 then
            numTurrets = 3
        end

        -- create custom plasma turrets
        local turret = SectorTurretGenerator(Seed(150)):generate(0, 0, 0, Rarity(RarityType.Exceptional), WeaponType.PlasmaGun)
        local weapons = {turret:getWeapons()}
        turret:clearWeapons()
        for _, weapon in pairs(weapons) do
            weapon.damage = 15 / #weapons
            weapon.fireRate = 2
            weapon.reach = 2500
            weapon.pmaximumTime = weapon.reach / weapon.pvelocity
            weapon.pcolor = Material(6).color
            turret:addWeapon(weapon)
        end
        turret.crew = Crew()
        turret.turningSpeed = 2.0
        ShipUtility.addTurretsToCraft(boss, turret, math.floor(numTurrets/3), numTurrets)

        -- create custom railgun turrets
        turret = SectorTurretGenerator(Seed(150)):generate(0, 0, 0, Rarity(RarityType.Exceptional), WeaponType.RailGun)
        weapons = {turret:getWeapons()}
        turret:clearWeapons()
        for _, weapon in pairs(weapons) do
            weapon.reach = 2500
            weapon.blength = 2500
            weapon.shieldDamageMultiplier = 0.5
            weapon.bouterColor = ColorHSV(random:getFloat(0, 35), random:getFloat(0.8, 1), 0.5)
            weapon.binnerColor = ColorHSV(random:getFloat(0, 35), random:getFloat(0.1, 0.5), 1)
            turret:addWeapon(weapon)
        end
        turret.turningSpeed = 2.0
        turret.crew = Crew()
        ShipUtility.addTurretsToCraft(boss, turret, math.floor(2*numTurrets/3), numTurrets)

        -- add PDCs and Anti-Fighter
        if numTurrets < 4 then
            numTurrets = 4
        end
        ShipUtility.addBossAntiTorpedoEquipment(boss, numTurrets/4, Material(6).color, 2500)
        ShipUtility.addBossAntiFighterEquipment(boss, numTurrets/4, Material(6).color, 2500)
    end
    ]]

    -- Custom Function
    function BigAICorrupted.TotalTurrets()
        -- Adjust based on Difficulty
        local _Number = 100
        local _Settings = GameSettings()
        if _Settings.difficulty == Difficulty.Insane then 
            _Number = 150
        elseif _Settings.difficulty == Difficulty.Hardcore then 
            _Number = 130
        elseif _Settings.difficulty == Difficulty.Expert then 
            _Number = 120
        elseif _Settings.difficulty == Difficulty.Veteran then 
            _Number = 110
        elseif _Settings.difficulty == Difficulty.Normal then 
            _Number = 100
        elseif _Settings.difficulty == Difficulty.Easy then 
            _Number = 60
        end return _Number
    end

    -- Saved Vanilla Function
    BigAICorrupted.old_spawn = BigAICorrupted.spawn
    function BigAICorrupted.spawn(x, y)

        -- no double spawning
        if Sector():getEntitiesByScript("entity/story/corruptedaibehaviour.lua") then return end

        local faction = BigAICorrupted.getFaction()

        local _Plan if Plan.Load("data/plans/Default/Boss/Corrupted Big Brother.xml") then
            Plan.Material()
            _Plan = Plan.Get()
        else
            _Plan = LoadPlanFromFile("data/plans/big_ai_corrupted.xml")
        end

        local s = 1.5 * 3
        _Plan:scale(vec3(s, s, s))
        _Plan.accumulatingHealth = false

        local pos = random():getVector(-1000, 1000)
        pos = MatrixLookUpPosition(-pos, vec3(0, 1, 0), pos)

        local boss = Sector():createShip(faction, "", _Plan, pos)

        -- less shield for this boss
        local shield = Shield(boss.id)
        shield.maxDurabilityFactor = 0.5

        boss.title = "#*/S46B 6S2O 4I49/+"%_T
        boss.name = ""
        boss.crew = boss.minCrew
        boss:addScriptOnce("story/corruptedaibehaviour")
        boss:addScriptOnce("story/aicorrupteddialog")
        boss:addScriptOnce("deleteonplayersleft")

        WreckageCreator(boss.index).active = false

        -- adds legendary turret drop
        boss:addScriptOnce("internal/common/entity/background/legendaryloot.lua")

        Loot(boss.index):insert(InventoryTurret(SectorTurretGenerator():generate(x, y, 0, Rarity(RarityType.Exotic))))
        Loot(boss.index):insert(InventoryTurret(SectorTurretGenerator():generate(x, y, 0, Rarity(RarityType.Legendary))))
        Loot(boss.index):insert(InventoryTurret(SectorTurretGenerator():generate(x, y, 0, Rarity(RarityType.Legendary))))
        Loot(boss.index):insert(InventoryTurret(SectorTurretGenerator():generate(x, y, 0, Rarity(RarityType.Legendary))))

        -- create custom turrets
        BigAICorrupted.addTurrets(boss, BigAICorrupted.TotalTurrets())

        Boarding(boss).boardable = false
        boss.dockable = false

        return boss
    end

end

--[[
return BigAICorrupted
]]