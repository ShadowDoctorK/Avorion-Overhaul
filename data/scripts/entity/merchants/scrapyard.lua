
function Scrapyard.Exempt(id)
    local Station = Entity()
    local Other = Entity(id)
    local StationMemebers = {}

    if Station.allianceOwned then
        StationMemebers = Scrapyard.AllianceMembers(Station.factionIndex)
    end

    -- Player Owned
    if not Other.aiOwned then

        -- Alliance Station / Alliance Ship
        if Station.allianceOwned and Other.allianceOwned then
            if Station.factionIndex == Other.factionIndex then
                return true
            end

        -- Alliance Station / Non-Alliance Ship
        elseif Station.allianceOwned and not Other.allianceOwned then
            for k, v in pairs(StationMemebers) do
                if v == Other.factionIndex then return true end
            end

        -- Non-Alliance Staton / Non-Alliance Ship
        elseif not Station.allianceOwned and not Other.allianceOwned then
            if Station.factionIndex == Other.factionIndex then
                return true
            end
        end               

    else
        if Station.factionIndex == Other.factionIndex then
            return true
        end
    end

    return false

end

function Scrapyard.AllianceMembers(id)
    return {Alliance(id):getMembers()}
end

-- Replace the old function with the new one adding the sector level scrap spawning for the backgroud sim.
Scrapyard.old_initializationFinished = Scrapyard.initializationFinished
function Scrapyard.initializationFinished()

    -- use the initilizationFinished() function on the client since in initialize() we may not be able to access Sector scripts on the client
    if onClient() then
        local ok, r = Sector():invokeFunction("radiochatter", "addSpecificLines", Entity().id.string,
        {
            "Get a salvaging license now and try your luck with the wreckages!"%_t,
            "Easy salvage, easy profit! Salvaging licenses for sale!"%_t,
            "I'd like to see something brand new for once."%_t,
            "Don't like your ship anymore? We'll turn it into scrap and even give you some Credits for it!"%_t,
            "Brand new offer: We now dismantle turrets into parts!"%_t,
            "We don't take any responsibility for any lost limbs while using the turret dismantler."%_t,
        })
    end

    -- Adding this here so the Scrapyard extension will start spawning scrap AFTER the station is built.
    if onServer() then
        Sector():addScriptOnce("data/scripts/sector/SDKScrapyardExtension.lua")
    end

    -- This is dirty, adding it here till I get individual station types set up in the generator
    Entity():addScriptOnce("data/scripts/entity/merchants/SDKMerchSalvageTurret.lua")

end

function Scrapyard.onHullHit(objectIndex, block, shootingCraftIndex, damage, position)
    -- don't count hits that were inflicted shortly after destruction of a relevant entity
    if Scrapyard.entityDestructionCounter < Scrapyard.maxDestructionCounter then return end

    local sector = Sector()
    local shooter = sector:getEntity(shootingCraftIndex)
    if not shooter then return end
    if Scrapyard.Exempt(shootingCraftIndex) then return end
    
    local object = sector:getEntity(objectIndex)
    if object and object.isWreckage then
        if shooter then
            local faction = Faction(shooter.factionIndex)
            if not faction.isAIFaction and licenses[faction.index] == nil then
                Scrapyard.unallowedDamaging(shooter, faction, damage)
            end
        end
    end
end

function Scrapyard.onEntityCreated(id)
    -- only count wreckages that were created shortly after destruction of a relevant entity
    if Scrapyard.entityDestructionCounter >= Scrapyard.maxDestructionCounter then return end

    local entity = Entity(id)
    if entity.type == EntityType.Wreckage then
        allowedWreckages[id.string] = 0
        entity:setValue("SDKScrapyardWreckage", true)
    end
end

function Scrapyard.onEntityDocked(parentId, childId)
    local wreckage = Entity(childId)
    if not valid(wreckage) or not wreckage.isWreckage then return end

    if Scrapyard.Exempt(parentId) then return end

    Sector():broadcastChatMessage(Entity(), ChatMessageType.Normal, "Docking and stealing wreckages is not permitted!"%_T)

    changeRelations(Faction(), parentId, -2500, RelationChangeType.GeneralIllegal)

    dockedWreckages[childId.string] = true

    Scrapyard.cleanUpDockedWreckages()
end

function Scrapyard.onEntityJump(id)
    if not dockedWreckages[id.string] then return end
    dockedWreckages[id.string] = nil
    Scrapyard.cleanUpDockedWreckages()

    local wreckage = Entity(id)
    if not valid(wreckage) or not wreckage.isWreckage then return end
       
    local parentId = wreckage.dockingParent
    if not parentId then return end

    if Scrapyard.Exempt(parentId) then return end

    changeRelations(Faction(), parentId, -10000, RelationChangeType.GeneralIllegal)
end