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
include("callable")

BigAI = {}

local coordinates = {}

function BigAI.sync(data_in)
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
callable(BigAI, "sync")


function BigAI.initialize()
    local player = Player()

    if onServer() then
        player:registerCallback("onSectorEntered", "onSectorEntered")
        if not _restoring then
            local x, y = AILocatorUtility.getCoordinates(false)
            coordinates.x = x
            coordinates.y = y

            local currentX, currentY = player:getSectorCoordinates()
            if currentX == x and currentY == y then
                BigAI.spawn(x, y)
            end

            BigAI.sync()
        end
    else
        -- to be able to mark sector
        player:registerCallback("onMapRenderAfterUI", "onMapRenderAfterUI")
        BigAI.sync()
    end
end


if onClient() then

    function BigAI.onMapRenderAfterUI()
        BigAI.renderIcons()
    end

    function BigAI.renderIcons()
        local map = GalaxyMap()
        local renderer = UIRenderer()
        local icon = "data/textures/icons/pixel/skull_big.png"

        local sx, sy = map:getCoordinatesScreenPosition(ivec2(coordinates.x, coordinates.y))
        renderer:renderCenteredPixelIcon(vec2(sx, sy), ColorRGB(1, 0.1, 0), icon)

        renderer:display()
    end

end
]]

if onServer() then

    --[[
    local aiPresent = false
    function getUpdateInterval()
        if aiPresent then
            return 1
        else
            return 10
        end
    end

    function BigAI.update(timestep)
        -- check if the AI upgrade was dropped
        local done, present = BigAI.checkForDefeat()
        aiPresent = present

        if done then
            local killCounter = (Server():getValue("big_ai_kill_counter") or 0) + 1
            print ("Big AI was beaten for the ".. killCounter ..". time!")
            Server():setValue("big_ai_kill_counter", killCounter) -- set this to get new server-wide location
        end
    end

    local lastAIPosition = nil
    local lastSector = {}
    function BigAI.checkForDefeat()
        local faction = BigAI.getFaction()

        local all = {Sector():getEntitiesByScript("story/bigaibehaviour")}
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

    function BigAI.onSectorEntered(playerIndex, x, y, sectorChangeType)
        -- test if coords are the ones the player got marked on map
        if coordinates.x == x and coordinates.y == y then
            -- test if coords are current spawn location of Big AI
            local xCurrent, yCurrent = AILocatorUtility.getCoordinates(false)
            local player = Player()
            if x == xCurrent and y == yCurrent then
                BigAI.spawn(x, y)
                player:registerCallback("onSectorLeft", "onSectorLeft")
            else
                player:sendChatMessage("", ChatMessageType.Notification, "It seems the AI has already moved on."%_T)
            end
        end
    end

    function BigAI.onSectorLeft(playerId, x, y, changeType)
        local player = Player(playerId)
        player:removeScript("spawnbigai.lua") -- if player runs, he shouldn't be able to respawn Big AI on reenter
    end

    function BigAI.getFaction()
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

    function BigAI.addTurrets(boss, numTurrets)
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
            weapon.reach = 1500
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
            weapon.reach = 1500
            weapon.blength = 1500
            weapon.shieldDamageMultiplier = 0.5
            weapon.bouterColor = ColorHSV(random:getFloat(0, 35), random:getFloat(0.8, 1), 0.5)
            weapon.binnerColor = ColorHSV(random:getFloat(0, 35), random:getFloat(0.1, 0.5), 1)
            turret:addWeapon(weapon)
        end
        turret.turningSpeed = 2.0
        turret.crew = Crew()
        ShipUtility.addTurretsToCraft(boss, turret, math.floor(2 * numTurrets/3), numTurrets)

        -- add PDCs and Anti-Fighter
        ShipUtility.addBossAntiTorpedoEquipment(boss, numTurrets/2, Material(6).color, 1500)
        ShipUtility.addBossAntiFighterEquipment(boss, numTurrets/2, Material(6).color, 1500)

    end
    ]]

    -- Custom Function
    function BigAI.TotalTurrets()
        -- Adjust based on Difficulty
        local _Number = 60
        local _Settings = GameSettings()
        if _Settings.difficulty == Difficulty.Insane then 
            _Number = 100
        elseif _Settings.difficulty == Difficulty.Hardcore then 
            _Number = 90
        elseif _Settings.difficulty == Difficulty.Expert then 
            _Number = 80
        elseif _Settings.difficulty == Difficulty.Veteran then 
            _Number = 70
        elseif _Settings.difficulty == Difficulty.Normal then 
            _Number = 60
        elseif _Settings.difficulty == Difficulty.Easy then 
            _Number = 30
        end return _Number
    end

    -- Save Vanilla Function
    BigAI.old_spawn = BigAI.spawn
    function BigAI.spawn(x, y)

        -- no double spawning
        if Sector():getEntitiesByScript("entity/story/bigaibehaviour.lua") then return end

        local faction = BigAI.getFaction()

        local _Plan if Plan.Load("data/plans/Default/Boss/Big Brother.xml") then
            Plan.Material()
            _Plan = Plan.Get()
        else
            _Plan = LoadPlanFromFile("data/plans/big_ai.xml")
        end

        local s = 1.5 * 1.5
        _Plan:scale(vec3(s, s, s))
        _Plan.accumulatingHealth = false

        local pos = random():getVector(-1000, 1000)
        pos = MatrixLookUpPosition(-pos, vec3(0, 1, 0), pos)

        local boss = Sector():createShip(faction, "", _Plan, pos)

        boss.shieldDurability = boss.shieldMaxDurability
        boss.title = "The Big Brother"%_T
        boss.name = ""
        boss.crew = boss.minCrew
        boss:addScriptOnce("story/bigaibehaviour")
        boss:addScriptOnce("story/aidialog")
        boss:addScriptOnce("deleteonplayersleft")

        WreckageCreator(boss.index).active = false

        -- adds legendary turret drop
        boss:addScriptOnce("internal/common/entity/background/legendaryloot.lua")

        Loot(boss.index):insert(InventoryTurret(SectorTurretGenerator():generate(x, y, 0, Rarity(RarityType.Exotic))))
        Loot(boss.index):insert(InventoryTurret(SectorTurretGenerator():generate(x, y, 0, Rarity(RarityType.Legendary))))
        Loot(boss.index):insert(InventoryTurret(SectorTurretGenerator():generate(x, y, 0, Rarity(RarityType.Legendary))))
        Loot(boss.index):insert(InventoryTurret(SectorTurretGenerator():generate(x, y, 0, Rarity(RarityType.Legendary))))

        -- create custom turrets
        BigAI.addTurrets(boss, BigAI.TotalTurrets())

        Boarding(boss).boardable = false
        boss.dockable = false

        return boss
    end

    --[[
    function BigAI.secure()
        return coordinates
    end

    function BigAI.restore(data_in)
        coordinates = data_in
    end
    ]]

end

-- return BigAI