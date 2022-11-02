
package.path = package.path .. ";data/scripts/lib/?.lua"

include ("randomext")
Balancing = include("galaxy")

-- Don't remove or alter the following comment, it tells the game the namespace this script lives in. If you remove it, the script will break.
-- namespace XsotanBehaviour
XsotanBehaviour = {}

local provoked = nil

if onServer() then

function XsotanBehaviour.initialize()
    Sector():registerCallback("onTorpedoLaunched", "onSetToAggressive")
    Sector():registerCallback("onStartFiring", "onSetToAggressive")
    Sector():registerCallback("onDestroyed", "onXsotanDestroyed")
    Entity():registerCallback("onDestroyed", "onSelfDestroyed")
    Entity():registerCallback("onCollision", "onCollision")

    XsotanBehaviour.despawnSoon()
end

function XsotanBehaviour.despawnSoon()
    -- they don't despawn inside the ring
    local x, y = Sector():getCoordinates()
    if Balancing_InsideRing(x, y) then return end

    provoked = false
    deferredCallback(60 + math.random() * 4, "tryDespawn")
end

function XsotanBehaviour.tryDespawn()
    if provoked then
        XsotanBehaviour.despawnSoon()
    else
        Entity():addScriptOnce("deletejumped.lua")
    end
end

function XsotanBehaviour.onSetToAggressive(entityId)
    local entity = Entity(entityId)
    if not valid(entity) then return end

    local entityFaction = entity.factionIndex or 0
    if entityFaction <= 0 then return end

    local self = Entity()
    if entityFaction ~= self.factionIndex then
        ShipAI():registerEnemyFaction(entityFaction)
    end

    provoked = true
end

function XsotanBehaviour.onCollision(selfId, other, dmgA, dmgB, steererA, steererB)
    XsotanBehaviour.onSetToAggressive(steererB)
end

function XsotanBehaviour.onXsotanDestroyed(destroyedId, lastDamageInflictor)
    local entity = Entity(lastDamageInflictor)
    if not entity then return end

    local entityFaction = entity.factionIndex or 0
    if entityFaction <= 0 then return end

    local self = Entity()
    if entityFaction ~= self.factionIndex then
        ShipAI():registerEnemyFaction(entityFaction)
    end

    provoked = true
end

function XsotanBehaviour.onSelfDestroyed()
    local position = vec2(Sector():getCoordinates())

    if length2(position) < Balancing.BlockRingMin2 then
        if random():getInt(1, 3) == 1 then

            local entity = Entity()
            Sector():dropUpgrade(
                entity.translationf,
                nil,
                nil,
                SystemUpgradeTemplate("data/scripts/systems/wormholeopener.lua", Rarity(RarityType.Rare), Seed(0)))
        end
    end
end


end
