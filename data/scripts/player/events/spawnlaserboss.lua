local Plan = include("SDKUtilityBlockPlan")
--local Mod = include("SDKUtilityMods")
--[[
if onClient() then

    function LaserBoss.onMapRenderAfterUI()
        LaserBoss.renderIcons()
    end
    
    function LaserBoss.renderIcons()
        if not data.foundBoth then return end
    
        local map = GalaxyMap()
        local renderer = UIRenderer()
        local icon = "data/textures/icons/pixel/skull_big.png"
    
        local sx, sy = map:getCoordinatesScreenPosition(ivec2(data.xCoord, data.yCoord))
        renderer:renderCenteredPixelIcon(vec2(sx, sy), ColorRGB(1, 0.1, 0), icon)
    
        renderer:display()
    end

end -- if onClient()
]]

if onServer() then
    --[[
    function LaserBoss.getHint()
        if data.countTries >= 4 then
            data.countTries = 0
            LaserBoss.setHintCoordinate()
        else
            local test = rand:test(0.1)
            if test == false then
                data.countTries = data.countTries + 1
            else
                LaserBoss.setHintCoordinate()
            end
        end
    end
        
    function LaserBoss.setHintCoordinate()
        if not data.foundX then
            data.xCoord = LaserBossLocation.getCoordinate("x")
            data.foundX = true
            LaserBoss.sync()
            Player():sendChatMessage("General Bliks"%_T, ChatMessageType.Information, "We found a weird shard. It that seems there is another part missing. We'll wait for more information."%_T)
        else
            data.yCoord = LaserBossLocation.getCoordinate("y")
            Player():sendChatMessage("General Bliks"%_T, ChatMessageType.Information, "Another part of this weird shard. Together they show coordinates. The coordinates are \\s(%1%:%2%)."%_T, data.xCoord, data.yCoord)
            data.foundBoth = true
            LaserBoss.sync()
        end
    end
    
    
    function LaserBoss.onSectorEntered(player, x, y, changeType)
        if onServer() then
            if not Server():getValue("laser_boss_respawn_timer") then
                local targetX, targetY = LaserBossLocation.getSector()
                if x == targetX and y == targetY then
                    data.foundBoth = false
                    data.foundX = false
                    LaserBoss.spawnBoss()
                end
            else
                Player():sendChatMessage("Server", ChatMessageType.Information, "There are remnants of a battle. But nobody's here right now."%_t)
            end
        end
    end
    
    function LaserBoss.spawnBoss()
        -- no double spawning
        if Sector():getEntitiesByScript("data/scripts/entity/story/laserbossbehavior.lua") then return end
    
        LaserBoss.spawnLaserBoss()
        LaserBoss.spawnArena()
    end
    ]]

    -- Custom Function
    function LaserBoss.TotalTurrets()
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

    -- Saved Vanilla Function
    LaserBoss.old_spawnLaserBoss = LaserBoss.spawnLaserBoss
    function LaserBoss.spawnLaserBoss()
        -- no double spawning
        if Sector():getEntitiesByScript("data/scripts/entity/story/laserbossbehavior.lua") then return end

        local faction = LaserBoss.getFaction()
        --local volume = Balancing_GetSectorShipVolume(Sector():getCoordinates()) * 30

        local _Plan if Plan.Load("data/plans/Default/Boss/IHDTX2.xml") then
            Plan.Material()
            _Plan = Plan.Get()
        else
            _Plan = LoadPlanFromFile("data/plans/laserboss.xml")
        end

        _Plan.accumulatingHealth = false

        local pos = random():getVector(-1000, 1000)
        pos = MatrixLookUpPosition(-pos, vec3(0, 1, 0), pos)

        local boss = Sector():createShip(faction, "", _Plan, pos)
        boss.shieldDurability = boss.shieldMaxDurability
        boss.title = "Project IHDTX"%_T
        boss.name = ""
        boss.crew = boss.minCrew

        -- increase turning speed independent of plan
        local thrusters = Thrusters(boss.id)
        thrusters.baseYaw = thrusters.baseYaw * ((GameSettings().difficulty+3)/3) * 2
        thrusters.basePitch = thrusters.basePitch * ((GameSettings().difficulty+3)/3)
        thrusters.baseRoll = thrusters.baseRoll * ((GameSettings().difficulty+3)/3)
        thrusters.fixedStats = true

        -- boss is invincible until asteroids destroyed
        boss.invincible = true
        local shield = Shield(boss.id)
        shield.invincible = true

        boss:addScriptOnce("data/scripts/entity/story/laserbossbehavior.lua")
        LaserBoss.addTurrets(boss, LaserBoss.TotalTurrets())

        --[[
        if Mod.Enabled("2083280364") then -- SDK's Specialized Military Sheild Booster
            Loot(boss.index):insert(SystemUpgradeTemplate("data/scripts/systems/SpecializedShieldUpgrade1.lua", Rarity(RarityType.Legendary), random():createSeed()))
            Loot(boss.index):insert(SystemUpgradeTemplate("data/scripts/systems/SpecializedShieldUpgrade1.lua", Rarity(RarityType.Legendary), random():createSeed()))
        else
            Loot(boss.index):insert(SystemUpgradeTemplate("data/scripts/systems/shieldbooster.lua", Rarity(RarityType.Legendary), random():createSeed()))
            Loot(boss.index):insert(SystemUpgradeTemplate("data/scripts/systems/shieldbooster.lua", Rarity(RarityType.Legendary), random():createSeed()))
        end
        ]]

        local generator = SectorTurretGenerator()

        Loot(boss.index):insert(SystemUpgradeTemplate("data/scripts/systems/shieldbooster.lua", Rarity(RarityType.Legendary), random():createSeed()))
        Loot(boss.index):insert(SystemUpgradeTemplate("data/scripts/systems/shieldbooster.lua", Rarity(RarityType.Legendary), random():createSeed()))

        Loot(boss.index):insert(InventoryTurret(generator:generate(0, 5, 0, Rarity(RarityType.Exotic), WeaponType.Laser)))
        Loot(boss.index):insert(InventoryTurret(generator:generate(0, 5, 0, Rarity(RarityType.Legendary), WeaponType.Laser)))

        -- adds legendary turret drop
        boss:addScriptOnce("internal/common/entity/background/legendaryloot.lua")

        WreckageCreator(boss.index).active = false
        Boarding(boss).boardable = false
        boss.dockable = false

        return boss
    end

    --[[
    function LaserBoss.spawnArena()
        maxAsteroids = 4
        local dimChanges =
        {
            vec3(1500 + math.random(1, 1500), math.random(1, 10), math.random(1, 10)),
            vec3(-1500 - math.random(1, 1500), math.random(1, 10), math.random(1, 10)),
            vec3(math.random(1, 10), math.random(1, 10), 1500 + math.random(1, 1500)),
            vec3(math.random(1, 10), math.random(1, 10), -1500 - math.random(1, 1500)),
        }

        local sectorCoords = {}
        sectorCoords.x, sectorCoords.y = Sector():getCoordinates()
        local generator = SectorGenerator(sectorCoords.x, sectorCoords.y)

        for i = 1, maxAsteroids do
            local matrix = Matrix()
            local translation = vec3(0 + (dimChanges[i].x), 0 + (dimChanges[i].y), 0 + (dimChanges[i].z))
            matrix.translation = translation
            local plan = PlanGenerator.makeBigAsteroidPlan(50, false, Material(MaterialType.Avorion))
            plan.accumulatingHealth = false

            plan:scale(vec3(3, 3, 3))
            local desc = AsteroidDescriptor()
            desc:removeComponent(ComponentType.MineableMaterial)
            desc:addComponents(
            ComponentType.Owner,
            ComponentType.FactionNotifier
            )

            desc.position = matrix
            desc:setMovePlan(plan)

            local asteroid = Sector():createEntity(desc)

            asteroid:setValue("laser_asteroid", true)
            asteroid:addScript("data/scripts/player/events/laserasteroid.lua")

            local asteroidfieldgenerator = AsteroidFieldGenerator(sectorCoords.x, sectorCoords.y)

            -- spawns the "explosion shaped" asteroid balls around the shield asteroids
            ballAsteroidPosition = translation
            local asteroid = asteroidfieldgenerator:createBallAsteroidField(0.1, ballAsteroidPosition)
        end

        Placer.resolveIntersections()
    end

    function LaserBoss.getFaction()
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

    function LaserBoss.addTurrets(boss, numTurrets)
        ShipUtility.addBossAntiTorpedoEquipment(boss, numTurrets)
    end

    function LaserBoss.secure()
        return data
    end

    function LaserBoss.restore(data_in)
        data = data_in
    end
    ]]

end -- if onServer()