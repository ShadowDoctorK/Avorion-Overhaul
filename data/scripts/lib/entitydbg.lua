function initUI()

    local res = getResolution()
    local size = vec2(1200, 650)

    local menu = ScriptUI()
    window = menu:createWindow(Rect(res * 0.5 - size * 0.5, res * 0.5 + size * 0.5))

    window.caption = "Debug"
    window.showCloseButton = 1
    window.moveable = 1
    menu:registerWindow(window, "~dev");

    -- create a tabbed window inside the main window
    local tabbedWindow = window:createTabbedWindow(Rect(vec2(10, 10), size - 10))


    local topLevelTab = tabbedWindow:createTab("Entity", "data/textures/icons/ship.png", "Ship Commands")
    local window = topLevelTab:createTabbedWindow(Rect(topLevelTab.rect.size))
    local tab = window:createTab("", "data/textures/icons/ship.png", "General")
    numButtons = 0
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "GoTo", "onGoToButtonPressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Entity Scripts", "onEntityScriptsButtonPressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Entity Values", "onEntityValuesButtonPressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Faction Values", "onFactionValuesButtonPressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Spawn Ship", "onCreateShipsButtonPressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Spawn Ship Copy", "onCreateShipCopyButtonPressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Fly", "onFlyButtonPressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Own", "onOwnButtonPressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Own Alliance", "onOwnAllianceButtonPressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Own Locals", "onOwnLocalsButtonPressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Destroy", "onDestroyButtonPressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Delete", "onDeleteButtonPressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Delete Jump", "onDeleteJumpButtonPressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Toggle Invincible", "onInvincibleButtonPressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Partially Invincible", "onPartialInvincibilityButtonPressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Toggle Shield Invincible", "onShieldInvincibleButtonPressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Insta-Board", "onInstaBoardButtonPressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "War", "onWarPressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Ceasefire", "onCeasefirePressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Neutral", "onNeutralPressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Ally", "onAllyPressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Like", "onLikePressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Dislike", "onDislikePressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Damage", "onDamagePressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Title", "onTitlePressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Faction Index", "onFactionIndexPressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Speech Bubble", "onSpeechBubbleButtonPressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Speech Bubble Spam", "onSpeechBubbleSpamButtonPressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Speech Bubble Dialog", "onSpeechBubbleDialogButtonPressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Dock To Me", "onDockToMePressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "CraftStats", "onCraftStatsPressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Random Yield", "onYieldPressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Boost Jump Range", "onBoostJumpRangePressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Personal Friend", "onPersonalFriendPressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Personal Faction Friend", "onPersonalFactionFriendPressed")


    local tab = window:createTab("", "data/textures/icons/fighter.png", "Equipment Commands")
    numButtons = 0
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Add Crew", "onAddCrewButtonPressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Add Captain", "onAddCaptainButtonPressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Clear Crew", "onClearCrewButtonPressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Clear Passengers", "onClearPassengersButtonPressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Clear Cargo", "onClearCargoButtonPressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Add Pilots", "onAddPilotsPressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Add Security", "onAddSecurityPressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Add Boarders", "onAddBoardersPressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Armed Fighters", "onAddArmedFightersButtonPressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Repair Fighters", "onAddRepairFightersButtonPressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Mining Fighters", "onAddMiningFightersButtonPressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Raw Mining Fighters", "onAddRawMiningFightersButtonPressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Salvaging Fighters", "onAddSalvagingFightersButtonPressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Raw Salvaging Fighters", "onAddRawSalvagingFightersButtonPressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Boarding Shuttles", "onAddCrewShuttlesButtonPressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Clear Hangar", "onClearHangarButtonPressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Add Torpedoes", "onAddTorpedoesButtonPressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Clear Torpedoes", "onClearTorpedoesButtonPressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Start Fighter", "onStartFighterButtonPressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Default Shield", "onAddResiDefaultButtonPressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Add Physical Resistance", "onAddResiPhysicalButtonPressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Add Plasma Resistance", "onAddResiPlasmaButtonPressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Add Electric Resistance", "onAddResiElectricButtonPressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Add AntiMatter Resistance", "onAddResiAntiMatterButtonPressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Reset Weakness", "onResetWeaknessButtonPressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Add Energy Weakness", "onAddEnergyWeaknessButtonPressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Add Plasma Weakness", "onAddPlasmaWeaknessButtonPressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Add Electric Weakness", "onAddElectricWeaknessButtonPressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Add AntiMatter Weakness", "onAddAntiMatterWeaknessButtonPressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Add Immunity To Player", "onAddImmunityButtonPressed")


    local tab = window:createTab("Icons", "data/textures/icons/crate.png", "Cargo Commands")
    numButtons = 0
    local sortedGoods = {}
    for name, good in pairs(goods) do
        table.insert(sortedGoods, good)
    end

    stolenCargoCheckBox = tab:createCheckBox(Rect(vec2(150, 25)), "Stolen", "onStolenChecked")
    local organizer = UIOrganizer(Rect(tabbedWindow.size))

    organizer:placeElementTopRight(stolenCargoCheckBox)

    local button = MakeButton(tab, ButtonRect(40, 40, nil, tab.height), "C", "onClearCargoButtonPressed")
    button.tooltip = "Clear Cargo Bay"

    function goodsByName(a, b) return a.name < b.name end
    table.sort(sortedGoods, goodsByName)

    for _, good in pairs(sortedGoods) do
        local rect = ButtonRect(40, 40, nil, tab.height)

        rect.upper = rect.lower + vec2(rect.size.y, rect.size.y)

        local button = MakeButton(tab, rect, "", "onGoodsButtonPressed")
        button.icon = good.icon
        button.tooltip = good.name
    end
    local button = MakeButton(tab, ButtonRect(40, 40, nil, tab.height), "FS", "onFreedSlavesButtonPressed")



    local topLevelTab = tabbedWindow:createTab("", "data/textures/icons/player.png", "Player Commands")
    local window = topLevelTab:createTabbedWindow(Rect(topLevelTab.rect.size))
    local tab = window:createTab("", "data/textures/icons/player.png", "General")

    numButtons = 0
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Player Scripts", "onPlayerScriptsButtonPressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Player Values", "onPlayerValuesButtonPressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Cleanup Map", "onClearUnknownSectorsButtonPressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Refresh Map", "onRefreshMapButtonPressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Disable Events", "onDisableEventsButtonPressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Clear Inventory", "onClearInventoryButtonPressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Reset Money", "onResetMoneyButtonPressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Guns", "onGunsButtonPressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Guns Guns Guns", "onGunsGunsGunsButtonPressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "CoAx Guns Guns Guns", "onCoaxialGunsButtonPressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Gimme Systems", "onSystemsButtonPressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Quest Reward", "onQuestRewardButtonPressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Chat Greetings", "onLanguageGreetingsButtonPressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Owns BlackMarket DLC", "onOwnsBMDLCButtonPressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Reset Building Knowledge", "onResetKnowledgePressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Unlock Building Knowledge", "onUnlockKnowledgePressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Reset Milestones", "onResetMilestonesPressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Unlock Milestones", "onUnlockAllMilestonesPressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Show Encyclopedia", "onShowEncyclopediaPressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Clear Encyclopedia Popups", "onClearEncyclopediaPopUpsPressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Spawn BGS Appearance", "onSpawnBGSPressed")

    local tab = window:createTab("Turrets", "data/textures/icons/turret.png", "Turrets")
    numButtons = 0
    MakeButton(tab, ButtonRect(), "Clear Inventory", "onClearInventoryButtonPressed")

    for _, wp in pairs(WeaponTypes) do
        local button = MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), wp.name, "onGiveWeaponsButtonPressed")
        wp.buttonIndex = button.index
    end

    -- no spoilers, sorry :P
    BlackMarketDbg.buildLegendaryTurretsTab(window)

    local tab = window:createTab("Subsystems", "data/textures/icons/circuitry.png", "Subsystems")
    numButtons = 0

    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Clear Inventory", "onClearInventoryButtonPressed")

    systemButtons = {}

    local sortedScripts = BlackMarketDbg.getUpgrades()

    for script, _ in pairs(UpgradeGenerator().scripts) do
        table.insert(sortedScripts, script)
    end
    table.sort(sortedScripts)

    for _, script in pairs(sortedScripts) do
        local parts = script:split("/")
        local name = parts[#parts]:split(".")[1]
        local button = MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), name, "onSystemUpgradeButtonPressed")
        table.insert(systemButtons, {button = button, script = script});
    end

    local tab = window:createTab("Story Subsystems & Misc", "data/textures/icons/recall-device.png", "Story Subsystems & Misc")
    numButtons = 0

    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Clear Inventory", "onClearInventoryButtonPressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Mission Subsystems", "onKeysButtonPressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Energy Suppressor", "onEnergySuppressorButtonPressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Reconstruction Kit", "onReconstructionKitButtonPressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Empty Reconstruction Kit", "onEmptyReconstructionKitButtonPressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Reinforcements Transmitter", "onReinforcementsCallerItemButtonPressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Merchant Caller", "onMerchantCallerItemButtonPressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Renaming Beacon Spawner", "onRenamingBeaconSpawnerButtonPressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Message Beacon Spawner", "onMessageBeaconSpawnerButtonPressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Jumper Caller", "onJumperCallerItemButtonPressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Staff Pager", "onStaffCallerItemButtonPressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "AI Map", "onAIMapItemButtonPressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Corrupted AI Map", "onCorruptedAIMapItemButtonPressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Qadrant Map", "onQuadrantMapButtonPressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Faction Map", "onFactionMapButtonPressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Recall Device", "onRecallButtonPressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Building Knowledge", "onBuildingKnowledgePressed")

    local sortedScripts = {
        "data/scripts/systems/teleporterkey1.lua",
        "data/scripts/systems/teleporterkey2.lua",
        "data/scripts/systems/teleporterkey3.lua",
        "data/scripts/systems/teleporterkey4.lua",
        "data/scripts/systems/teleporterkey5.lua",
        "data/scripts/systems/teleporterkey6.lua",
        "data/scripts/systems/teleporterkey7.lua",
        "data/scripts/systems/teleporterkey8.lua",
    }

    table.sort(sortedScripts)

    for _, script in pairs(sortedScripts) do
        local parts = script:split("/")
        local name = parts[#parts]:split(".")[1]
        local button = MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), name, "onSystemUpgradeButtonPressed")
        table.insert(systemButtons, {button = button, script = script});
    end


    local tab = tabbedWindow:createTab("Sector", "data/textures/icons/sector.png", "Sector Commands")
    numButtons = 0
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Sector Scripts", "onSectorScriptsButtonPressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Sector Values", "onSectorValuesButtonPressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Galaxy Scripts", "onGalaxyScriptsButtonPressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Server Values", "onServerValuesButtonPressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Clear Sector", "onClearButtonPressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "XsotanBeGone", "onClearEncountersPressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Clear Fighters", "onClearFightersButtonPressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Clear Torpedos", "onClearTorpedosButtonPressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Clear Loot", "onClearLootButtonPressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Infect Asteroids", "onInfectAsteroidsButtonPressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Align", "onAlignButtonPressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Condense Entities", "onCondenseSectorButtonPressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Resolve Intersections", "onResolveIntersectionsButtonPressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Respawn Asteroids", "onRespawnAsteroidsButtonPressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Touch all Objects", "onTouchAllObjectsButtonPressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Touch all Objects [Client]", "onTouchAllObjectsOnClientButtonPressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Custom Sector Name", "onCustomSectorNameButtonPressed")


    local topLevelTab = tabbedWindow:createTab("Spawn", "data/textures/icons/slow-blob.png", "Spawn")
    local window = topLevelTab:createTabbedWindow(Rect(topLevelTab.rect.size))
    local tab = window:createTab("Asteroids", "data/textures/icons/rock.png", "Asteroids")

    numButtons = 0
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Clear Sector", "onClearButtonPressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Infected Asteroid", "onCreateInfectedAsteroidPressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Big Infected Asteroid", "onCreateBigInfectedAsteroidPressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Claimable Asteroid", "onCreateOwnableAsteroidPressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Big Asteroid", "onCreateBigAsteroidButtonPressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Asteroid Field", "onCreateAsteroidFieldButtonPressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Empty Asteroid Field", "onCreateEmptyAsteroidFieldButtonPressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Rich Asteroid Field", "onCreateRichAsteroidFieldButtonPressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Asteroid Field With Tinies", "onCreateAsteroidFieldWithTinyAsteroidsButtonPressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Spiral Asteroid Field", "onCreateSpiralAsteroidFieldButtonPressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Ring Asteroid Field", "onCreateRingAsteroidFieldButtonPressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Forest Asteroid Field", "onCreateForestAsteroidFieldButtonPressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Ball Asteroid Field", "onCreateBallAsteroidFieldButtonPressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Iron Asteroid Field", "onCreateIronAsteroidFieldButtonPressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Titanium Asteroid Field", "onCreateTitaniumAsteroidFieldButtonPressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Naonite Asteroid Field", "onCreateNaoniteAsteroidFieldButtonPressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Trinium Asteroid Field", "onCreateTriniumAsteroidFieldButtonPressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Xanion Asteroid Field", "onCreateXanionAsteroidFieldButtonPressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Ogonite Asteroid Field", "onCreateOgoniteAsteroidFieldButtonPressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Avorion Asteroid Field", "onCreateAvorionAsteroidFieldButtonPressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Resource Asteroid", "onCreateResourceAsteroidButtonPressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Hidden Treasure Asteroid", "onCreateHiddenTreasureAsteroidButtonPressed")


    local tab = window:createTab("Pirates", "data/textures/icons/domino-mask.png", "Pirates")
    numButtons = 0

    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Pirate", "onCreatePirateButtonPressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Raiders", "onPersecutorsButtonPressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "LootGoon", "onLootGoonButtonPressed")

    local tab = window:createTab("Ships", "data/textures/icons/ship.png", "Ships")
    numButtons = 0

    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Military Ship", "onSpawnMilitaryShipButtonPressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Carrier", "onSpawnCarrierButtonPressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Flagship", "onSpawnFlagshipButtonPressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Persecutor", "onSpawnPersecutorButtonPressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Blocker", "onSpawnBlockerButtonPressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Disruptor", "onSpawnDisruptorButtonPressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "CIWS", "onSpawnCIWSButtonPressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Torpedoboat", "onSpawnTorpedoBoatButtonPressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Trader", "onSpawnTraderButtonPressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Freighter", "onSpawnFreighterButtonPressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Miner", "onSpawnMinerButtonPressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Xsotan Squad", "onSpawnXsotanSquadButtonPressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Xsotan Carrier", "onSpawnXsotanCarrierButtonPressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Quantum Xsotan", "onSpawnQuantumXsotanButtonPressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Xsotan Summoner", "onSpawnXsotanSummonerButtonPressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Defenders", "onSpawnDefendersButtonPressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Battle", "onSpawnBattleButtonPressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Deferred Battle", "onSpawnDeferredBattleButtonPressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Fleet", "onSpawnFleetButtonPressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Crew Transport", "onCrewTransportButtonPressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Distri Group", "onCreateDistriButtonPressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Adventurer", "onCreateAdventurerPressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Travelling Merchant", "onCreateMerchantPressed")

    local tab = window:createTab("Objects", "data/textures/icons/satellite.png", "Objects")
    numButtons = 0

    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Claimable Wreckage", "onCreateClaimableWreckagePressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Beacon", "onCreateBeaconButtonPressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Stash", "onCreateStashButtonPressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Container Field", "onCreateContainerFieldButtonPressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Wreckage", "onCreateWreckagePressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Hackable Container", "onHackableContainerPressed")


    local tab = window:createTab("Station", "data/textures/icons/station.png", "Spawn Station")
    numButtons = 0
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Resistance Outpost", "onCreateResistanceOutpostPressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Smuggler's Market", "onCreateSmugglersMarketPressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Headquarters", "onCreateHeadQuartersPressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Research Station", "onCreateResearchStationPressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Consumer", "onCreateConsumerButtonPressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Shipyard", "onCreateShipyardButtonPressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Repair Dock", "onCreateRepairDockButtonPressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Equipment Dock", "onCreateEquipmentDockButtonPressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Turret Merchant", "onCreateTurretMerchantButtonPressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Turret Factory", "onCreateTurretFactoryButtonPressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Turret Factory Supplier", "onCreateTurretFactorySupplierButtonPressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Fighter Merchant", "onCreateFighterMerchantButtonPressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Fighter Factory", "onCreateFighterFactoryButtonPressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Torpedo Merchant", "onCreateTorpedoMerchantButtonPressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Trading Post", "onCreateTradingPostButtonPressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Planetary Trading Post", "onCreatePlanetaryTradingPostButtonPressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Resource Depot", "onCreateResourceDepotButtonPressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Scrapyard", "onCreateScrapyardButtonPressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Military Outpost", "onCreateMilitaryOutpostPressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Travel Hub", "onCreateTravelHubButtonPressed")


    local tab = window:createTab("Factory Spawn", "data/textures/icons/cog.png", "Spawn Factory")
    numButtons = 0

    factoryButtons = {}
    for i, production in pairs(productions) do
        local button = MakeButton(tab, ButtonRect(190, 20, 3, tab.height), getTranslatedFactoryName(production, ""), "onGenerateFactoryButtonPressed")
        table.insert(factoryButtons, {button = button, production = production});
        button.maxTextSize = 10
    end

    local tab = tabbedWindow:createTab("Generate Sectors", "data/textures/icons/gears.png", "Generator Scripts")
    numButtons = 0

    local specs = SectorSpecifics(0, 0, Seed());
    specs:addTemplates()
    specs:addTemplate("startsector")

    templateButtons = {}
    for i, template in pairs(specs.templates) do
        local parts = template.path:split("/")
        local button = MakeButton(tab, ButtonRect(), parts[2], "onGenerateTemplateButtonPressed")
        table.insert(templateButtons, {button = button, template = template});
    end

    local tab = tabbedWindow:createTab("Music", "data/textures/icons/g-clef.png", "Music")
    numButtons = 0

    MakeButton(tab, ButtonRect(), "Stop Music", "onCancelMusicButtonPressed")

    local specs = SectorSpecifics(0, 0, Seed());
    specs:addTemplates()

    musicButtons = {}
    for i, template in pairs(specs.templates) do
        local parts = template.path:split("/")
        local button = MakeButton(tab, ButtonRect(), parts[2], "onSectorMusicButtonPressed")
        table.insert(musicButtons, {button = button, template = template});
    end


    local topLevelTab = tabbedWindow:createTab("Missions", "data/textures/icons/treasure-map.png", "Missions")
    local window = topLevelTab:createTabbedWindow(Rect(topLevelTab.rect.size))

    local tab = window:createTab("Events & Utility", "data/textures/icons/missions-tab.png", "Events & Utility")
    numButtons = 0
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Distress Call", "onDistressCallButtonPressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Fake Distress Call", "onFakeDistressCallButtonPressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Pirate Attack", "onPirateAttackButtonPressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Faction Attacks Smuggler", "onFactionAttackSmugglerButtonPressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Trader Attacked by Pirates", "onTraderAttackedByPiratesButtonPressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "(SDK) Xsotan Attack Level 1", "onAlienAttackButtonPressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "(SDK) Xsotan Attack Level 2", "onAlienAttackButtonPressed1")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "(SDK) Xsotan Attack Level 3", "onAlienAttackButtonPressed2")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "(SDK) Xsotan Attack Level 4", "onAlienAttackButtonPressed3")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Xsotan Swarm", "onXsotanSwarmButtonPressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Cancel Xsotan Swarm", "onXsotanSwarmEndButtonPressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Headhunter Attack", "onHeadhunterAttackButtonPressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Search and Rescue Call", "onSearchAndRescueButtonPressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Progress Brakers", "onProgressBrakersButtonPressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Smuggler Retaliation", "onSmugglerRetaliationButtonPressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Exodus Beacon", "onExodusBeaconButtonPressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Exodus Corner Points", "onExodusPointsButtonPressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Exodus Final Beacon", "onExodusFinalBeaconButtonPressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Research Satellite", "onResearchSatelliteButtonPressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Pirate Delivery", "onPirateDeliveryPressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "LaserBoss Location","onLaserBossLocationPressed")


    local tab = window:createTab("Bosses", "data/textures/icons/key1.png", "Bosses")
    numButtons = 0
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Swoks", "onSpawnSwoksButtonPressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "The AI", "onSpawnTheAIButtonPressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "BigAI", "onSpawnBigAIButtonPressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Corrupted AI", "onSpawnBigAICorruptedButtonPressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Smuggler", "onSpawnSmugglerButtonPressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Scientist", "onSpawnScientistButtonPressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "The 4", "onSpawnThe4ButtonPressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Guardian", "onSpawnGuardianButtonPressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "LaserBoss", "onSpawnLaserBossButtonPressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "AsteroidShield", "onAsteroidShieldBossPressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Jumper", "onJumperBossPressed")


    local tab = window:createTab("Tutorials", "data/textures/icons/graduate-cap.png", "Tutorials")
    numButtons = 0
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "R-Mining", "onRMiningButtonPressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Torpedoes", "onTorpedoesButtonPressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Fighter", "onFighterButtonPressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "StrategyCommands", "onStrategyCommandButtonPressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Found Station", "onStationTutorialButtonPressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Boarding", "onBoardingTutorialButtonPressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Trading", "onTradingTutorialButtonPressed")

    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Recall Device Mail", "onRecallDeviceMailButtonPressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Pirate Raid Mission", "onPirateRaidMissionButtonPressed")

    -- story missions
    local tab = window:createTab("Base Story", "data/textures/icons/story-mission.png", "Base Story")
    numButtons = 0

    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Full Story", "onStartStoryButtonPressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Swoks", "onStorySwoksButtonPressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Hermit", "onStoryHermitButtonPressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Buy", "onStoryBuyPressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Bottan", "onStoryBottanPressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "AI", "onStoryAIPressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Research", "onStoryResearchPressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Scientist", "onStoryScientistPressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Exodus", "onStoryExodusPressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "The 4", "onStoryBrotherhoodPressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Barrier", "onStoryCrossBarrierPressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Guardian", "onStoryKillGuardianPressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Bottan Goods", "onBottanGoodsPressed")
    MakeButton(tab, ButtonRect(nil, nil, nil, tab.height), "Roll Credits", "onRollCreditsButtonPressed")

    -- no spoilers, sorry :P
    BlackMarketDbg.buildStoryTab(window)

    local tab = tabbedWindow:createTab("Waveencounters", "data/textures/icons/firing-ship.png", "Wave Encounters")
    numButtons = 0
    MakeButton(tab, ButtonRect(), "Cancel Encounter", "onCancelWavesPressed")
    MakeButton(tab, ButtonRect(), "Fake Stash", "onFakeStashWavesPressed")
    MakeButton(tab, ButtonRect(), "Hidden Treasure", "onHiddenTreasurePressed")
    MakeButton(tab, ButtonRect(), "Mothership", "onMothershipWavesPressed")
    MakeButton(tab, ButtonRect(), "Ambush Preparation", "onAmbushPreperationPressed")
    MakeButton(tab, ButtonRect(), "Pirateasteroid", "onPirateAsteroidWavesPressed")
    MakeButton(tab, ButtonRect(), "Pirate Initiation", "onPirateInitiationPressed")
    MakeButton(tab, ButtonRect(), "Pirate King", "onPirateKingPressed")
    MakeButton(tab, ButtonRect(), "Pirate Meeting", "onPirateMeetingPressed")
    MakeButton(tab, ButtonRect(), "Pirateprovocation", "onPirateProvocationWavesPressed")
    MakeButton(tab, ButtonRect(), "Pirateshidingtreasure", "onPiratesHidingTreasurePressed")
    MakeButton(tab, ButtonRect(), "Piratestation", "onPiratestationWavesPressed")
    MakeButton(tab, ButtonRect(), "Treasure Hunt", "onTreasureHuntPressed")
    MakeButton(tab, ButtonRect(), "Pirate Traitor", "onPirateTraitorPressed")
    MakeButton(tab, ButtonRect(), "Wreckage", "onPiratesWreackagePressed")
    MakeButton(tab, ButtonRect(), "Trader Ambushed", "onTraderAmbushedPressed")



    local tab = tabbedWindow:createTab("Turret Analysis", "data/textures/icons/turret.png", "Turret Analysis")
    BuildTurretAnalysisUI(tab)

    local tab = tabbedWindow:createTab("Orientation", "data/textures/icons/swipe-y-right.png", "Orientation")
    numButtons = 0
    MakeButton(tab, ButtonRect(40), "+x", "onMoveXP")
    MakeButton(tab, ButtonRect(40), "+y", "onMoveYP")
    MakeButton(tab, ButtonRect(40), "+z", "onMoveZP")

    numButtons = 13
    MakeButton(tab, ButtonRect(40), "-x", "onMoveXN")
    MakeButton(tab, ButtonRect(40), "-y", "onMoveYN")
    MakeButton(tab, ButtonRect(40), "-z", "onMoveZN")

    numButtons = 13 * 3
    MakeButton(tab, ButtonRect(40), "-r", "onMoveRN")
    MakeButton(tab, ButtonRect(40), "-u", "onMoveUN")
    MakeButton(tab, ButtonRect(40), "-l", "onMoveLN")

    numButtons = 13 * 4
    MakeButton(tab, ButtonRect(40), "+r", "onMoveRP")
    MakeButton(tab, ButtonRect(40), "+u", "onMoveUP")
    MakeButton(tab, ButtonRect(40), "+l", "onMoveLP")

    numButtons = 4
    MakeButton(tab, ButtonRect(40), "", "onRotateXRight").icon = "data/textures/icons/swipe-x-up.png"
    MakeButton(tab, ButtonRect(40), "", "onRotateYRight").icon = "data/textures/icons/swipe-y-right.png"
    MakeButton(tab, ButtonRect(40), "", "onRotateZRight").icon = "data/textures/icons/swipe-z-right.png"

    numButtons = 4 + 14
    MakeButton(tab, ButtonRect(40), "R", "onResetRotation").tooltip = "Reset Rotation"

    numButtons = 4 + 26
    MakeButton(tab, ButtonRect(40), "", "onRotateXLeft").icon = "data/textures/icons/swipe-x-down.png"
    MakeButton(tab, ButtonRect(40), "", "onRotateYLeft").icon = "data/textures/icons/swipe-y-left.png"
    MakeButton(tab, ButtonRect(40), "", "onRotateZLeft").icon = "data/textures/icons/swipe-z-left.png"



    local tab = tabbedWindow:createTab("System", "data/textures/icons/bypass.png", "System")
    numButtons = 0
    MakeButton(tab, ButtonRect(), "Crash Script", "onCrashButtonPressed")
    MakeButton(tab, ButtonRect(), "Client Log", "onPrintClientLogButtonPressed")
    MakeButton(tab, ButtonRect(), "Server Log", "onPrintServerLogButtonPressed")
    MakeButton(tab, ButtonRect(), "Client Sleep", "onClientSleepButtonPressed")
    MakeButton(tab, ButtonRect(), "Server Sleep", "onServerSleepButtonPressed")
    MakeButton(tab, ButtonRect(), "Hint", "onHintButtonPressed")

    BlackMarketDbg.addSystemButtons(tab, 28)

    -- scripts window
    local size = vec2(800, 500)
    scriptsWindow = menu:createWindow(Rect(res * 0.5 - size * 0.5, res * 0.5 + size * 0.5))
    scriptsWindow.visible = false
    scriptsWindow.caption = "Scripts"
    scriptsWindow.showCloseButton = 1
    scriptsWindow.moveable = 1
    scriptsWindow.closeableWithEscape = 1

    local hsplit = UIHorizontalSplitter(Rect(vec2(0, 0), size), 10, 10, 0.5)
    hsplit.bottomSize = 80

    scriptList = scriptsWindow:createListBox(hsplit.top)

    local hsplit = UIHorizontalSplitter(hsplit.bottom, 10, 0, 0.5)
    hsplit.bottomSize = 35

    scriptTextBox = scriptsWindow:createTextBox(hsplit.top, "")

    local vsplit = UIVerticalSplitter(hsplit.bottom, 10, 0, 0.5)

    addScriptButton = scriptsWindow:createButton(vsplit.left, "Add", "")
    removeScriptButton = scriptsWindow:createButton(vsplit.right, "Remove", "")


    -- values window
    local size = vec2(1000, 700)
    valuesWindow = menu:createWindow(Rect(res * 0.5 - size * 0.5, res * 0.5 + size * 0.5))
    valuesWindow.visible = false
    valuesWindow.caption = "Values"
    valuesWindow.showCloseButton = 1
    valuesWindow.moveable = 1
    valuesWindow.closeableWithEscape = 1

    valuesLines = {}

    local horizontal = 2
    local vertical = 19

    local vsplit = UIVerticalMultiSplitter(Rect(size), 5, 0, horizontal - 1)


    local previous = nil
    for x = 1, horizontal do
        local hsplit = UIHorizontalMultiSplitter(vsplit:partition(x - 1), 5, 10, vertical - 1)

        for y = 1, vertical do
            local vsplit = UIVerticalSplitter(hsplit:partition(y - 1), 5, 0, 0.5)

            local vsplit2 = UIVerticalSplitter(vsplit.right, 5, 0, 0.5)
            local vsplit3 = UIVerticalSplitter(vsplit2.right, 5, 0, 0.5)


            local key = valuesWindow:createTextBox(vsplit.left, "")
            local value = valuesWindow:createTextBox(vsplit2.left, "")

            local set = valuesWindow:createButton(vsplit3.left, "set", "onSetValuePressed")
            local delete = valuesWindow:createButton(vsplit3.right, "X", "onDeleteValuePressed")

            key.tabTarget = value

            if previous then previous.tabTarget = key end
            previous = value

            table.insert(valuesLines, {key = key, value = value, set = set, delete = delete})
        end
    end

end

function onAlienAttackButtonPressed()
    if onClient() then
        invokeServerFunction("onAlienAttackButtonPressed")
        return
    end

    Player():addScript("events/SDKAlienAttack.lua")
end callable(nil, "onAlienAttackButtonPressed")

function onAlienAttackButtonPressed1()
    if onClient() then
        invokeServerFunction("onAlienAttackButtonPressed1")
        return
    end

    Player():addScript("events/SDKAlienAttack.lua", 1)
end callable(nil, "onAlienAttackButtonPressed1")

function onAlienAttackButtonPressed2()
    if onClient() then
        invokeServerFunction("onAlienAttackButtonPressed2")
        return
    end

    Player():addScript("events/SDKAlienAttack.lua", 2)
end callable(nil, "onAlienAttackButtonPressed2")

function onAlienAttackButtonPressed3()
    if onClient() then
        invokeServerFunction("onAlienAttackButtonPressed3")
        return
    end

    Player():addScript("events/SDKAlienAttack.lua", 3)
end callable(nil, "onAlienAttackButtonPressed3")