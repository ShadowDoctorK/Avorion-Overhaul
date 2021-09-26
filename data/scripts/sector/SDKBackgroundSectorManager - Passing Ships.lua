
--[[
package.path = package.path .. ";data/scripts/lib/?.lua"
package.path = package.path .. ";data/scripts/?.lua"
package.path = package.path .. ";?"

include ("galaxy")
include ("randomext")
include ("stringutility")
local AsyncShipGenerator = include ("asyncshipgenerator")
local Placer = include ("placer")
local ShipUtility = include ("shiputility")
local PlanGenerator = include ("plangenerator")

--!! DELETED NAMESPACE !!

PassingShips = {}

-- ships passing through
local passThroughCreationCounter = 0
local PassingShipType =
{
    Trader = 1,
    CruiseShip = 2,
    PartyShip = 3,
    PrisonTransport = 4,
    SnackBar = 5,
    FactoryCommute = 6,
    TowBoat = 7
}


if onServer() then

-- for unit tests - set to true to only spawn traders
-- (Needed for PassingShips_IllegalNumbers)
local spawnOnlyTraders = false

function PassingShips.getUpdateInterval()
    return 175 + random():getFloat(0, 5)
end

function PassingShips.update(timeStep)

    local sector = Sector()

    -- don't create server load when there are no players to witness it
    if sector.numPlayers == 0 then return end

    -- don't spawn helpless ships in war zones
    if sector:getValue("war_zone") then return end

    -- not too many passing ships at one time
    local sector = Sector()
    local stations = {sector:getEntitiesByType(EntityType.Station)}

    local maxPassThroughs = #stations * 0.5 + 1

    local passingShips = {Sector():getEntitiesByScriptValue("passing_ship", true)}
    if tablelength(passingShips) >= maxPassThroughs then return end

    -- determine faction (same for all passingships)
    local galaxy = Galaxy()
    local x, y = sector:getCoordinates()

    local faction = galaxy:getNearestFaction(x + math.random(-15, 15), y + math.random(-15, 15))

    -- outer regions spawn only half as many passing ships
    if not galaxy:isCentralFactionArea(x, y, faction.index) then
        if random():test(0.5) then
            return
        end
    end

    -- for PassingShips_IllegalNumbers unit test
    if spawnOnlyTraders then
        PassingShips.createPassingTrader(faction)
        return
    end

    -- spawn random passing ship
    local typeToSpawn = random():getInt(1, 7)
    if random():test(0.75) then typeToSpawn = PassingShipType.Trader end

    if typeToSpawn == PassingShipType.Trader then
        PassingShips.createPassingTrader(faction)
    elseif typeToSpawn == PassingShipType.CruiseShip then
        PassingShips.createPassingCruiseShip(faction)
    elseif typeToSpawn == PassingShipType.PartyShip then
        PassingShips.createPassingPartyShip(faction)
    elseif typeToSpawn == PassingShipType.PrisonTransport then
        PassingShips.createPassingPrisonTransport(faction)
    elseif typeToSpawn == PassingShipType.SnackBar then
        PassingShips.createPassingSnackBarShip(faction)
    elseif typeToSpawn == PassingShipType.TowBoat then
        PassingShips.createPassingTowBoat(faction)
    else
        PassingShips.createPassingFactoryCommuteShuttle(faction)
    end
end

-- trader or trader convoy - fly through sector without docking then despawn
function PassingShips.createPassingTrader(faction)

    -- this is the position where the trader spawns
    local dir = random():getDirection()
    local pos = dir * 1500

    -- this is the position where the trader will jump into hyperspace
    local destination = -pos + vec3(math.random(), math.random(), math.random()) * 1000
    destination = normalize(destination) * 1500

    -- create a single trader or a convoy
    local numTraders = 1
    if math.random() < 0.1 then
        numTraders = 6
    end

    local onFinished = function(ships)
        for _, ship in pairs(ships) do
            if random():test(0.8) then
                local addIllegalCargo = random():test(0.05)
                if addIllegalCargo then
                    ShipUtility.addIllegalCargoToCraft(ship)
                else
                    ShipUtility.addCargoToCraft(ship)
                end

                -- add control option for player
                ship:addScriptOnce("entity/playercontrol.lua")
            end

            ship:addScriptOnce("ai/passsector.lua", destination)
            ship:setValue("passing_ship", true)
        end

        Placer.resolveIntersections(ships)
    end

    local generator = AsyncShipGenerator(PassingShips, onFinished)
    generator:startBatch()

    for i = 1, numTraders do
        pos = pos + dir * 200
        local matrix = MatrixLookUpPosition(-dir, vec3(0, 1, 0), pos)

        local ship
        if math.random() < 0.5 then
            generator:createTradingShip(faction, matrix)
        else
            generator:createFreighterShip(faction, matrix)
        end
    end

    generator:endBatch()
end

-- cruise ship - fly through sector without docking, despawn
function PassingShips.createPassingCruiseShip(faction)

    -- this is the position where the trader spawns
    local dir = random():getDirection()
    local pos = dir * 1500

    -- this is the position where the trader will jump into hyperspace
    local destination = -pos + vec3(math.random(), math.random(), math.random()) * 1000
    destination = normalize(destination) * 1500

    -- ship name candidates
    local names =
    {
        "Diamond Cruises"%_T,
        "Lake Pearl Cruise"%_T,
        "Brilliance of the Galaxy Cruise"%_T,
        "Celestial Olympia"%_T,
        "Celestial Tours"%_T
    }

    -- create a single large cruise ship
    local matrix = MatrixLookUpPosition(-dir, vec3(0, 1, 0), pos)
    local sector = Sector()
    local x, y = sector:getCoordinates()
    local probabilities = Balancing_GetMaterialProbability(x, y)
    local material = Material(getValueFromDistribution(probabilities))
    local volume = Balancing_GetSectorShipVolume(x, y) * 5

    local plan = PlanGenerator.makeShipPlan(faction, volume, nil, material)

    -- exchange most cargo blocks to crew quarters and some to generators and engines as housing is a lot denser
    for _, index in pairs({plan:getBlockIndices()}) do
        local blocktype = plan:getBlockType(index)

        if blocktype == BlockType.CargoBay then
            if random():test(0.7) then
                plan:setBlockType(index, BlockType.Quarters)
            else
                if random():test(0.5) then
                    plan:setBlockType(index, BlockType.Generator)
                else
                    plan:setBlockType(index, BlockType.Engine)
                end
            end
        end
    end

    local ship = sector:createShip(faction, "", plan, matrix)

    -- finalize ship
    ship:addScriptOnce("ai/passsector.lua", destination)
    ship:setValue("passing_ship", true)
    ship:setValue("is_civil", true)
    ship:addScript("icon.lua", "data/textures/icons/pixel/civil-ship.png")

    ship:setTitle("Cruise Ship"%_T, {})
    ship.name = randomEntry(random(), names)

    local lines = PassingShips.getChatterLinesByShipType(PassingShipType.CruiseShip)
    ship:addScriptOnce("data/scripts/entity/utility/radiochatter.lua", lines, 65, 85, random():getInt(5, 45), true)
end

-- party ship - fly through sector without docking, despawn
function PassingShips.createPassingPartyShip(faction)

    -- this is the position where the trader spawns
    local dir = random():getDirection()
    local pos = dir * 1500

    -- this is the position where the trader will jump into hyperspace
    local destination = -pos + vec3(math.random(), math.random(), math.random()) * 1000
    destination = normalize(destination) * 1500

    -- ship name and title candidates
    local names =
    {
        "Party Decker"%_T,
        "Galactic Birthdays"%_T,
        "Party Rocker"%_T,
        "Festival Cruiser"%_T
    }

    local titles =
    {
        "Party Bus"%_T,
        "Festival Cruise"%_T
    }

    -- create a single party ship
    local sector = Sector()
    local x, y = sector:getCoordinates()
    local probabilities = Balancing_GetMaterialProbability(x, y)
    local material = Material(getValueFromDistribution(probabilities))
    local volume = Balancing_GetSectorShipVolume(x, y)
    local matrix = MatrixLookUpPosition(-dir, vec3(0, 1, 0), pos)

    local plan = PlanGenerator.makeShipPlan(faction, volume, nil, material)

    -- exchange most cargo blocks to crew quarters and some to generators and engines as housing is a lot denser
    for _, index in pairs({plan:getBlockIndices()}) do
        local blocktype = plan:getBlockType(index)

        if blocktype == BlockType.CargoBay then
            if random():test(0.7) then
                plan:setBlockType(index, BlockType.Quarters)
            else
                if random():test(0.5) then
                    plan:setBlockType(index, BlockType.Generator)
                else
                    plan:setBlockType(index, BlockType.Engine)
                end
            end
        end
    end

    local ship = sector:createShip(faction, "", plan, matrix)

    -- finalize ship
    ship:addScriptOnce("ai/passsector.lua", destination)
    ship:setValue("passing_ship", true)
    ship:setValue("is_civil", true)
    ship:addScript("icon.lua", "data/textures/icons/pixel/civil-ship.png")

    ship:setTitle(randomEntry(random(), titles), {})
    ship.name = randomEntry(random(), names)

    local lines = PassingShips.getChatterLinesByShipType(PassingShipType.PartyShip)
    ship:addScriptOnce("data/scripts/entity/utility/radiochatter.lua", lines, 65, 85, random():getInt(5, 45), true)
end

-- prison transport - fly through to a station and dock, then undock and fly away, despawn
function PassingShips.createPassingPrisonTransport(faction)

    -- this is the position where the trader spawns
    local dir = random():getDirection()
    local pos = dir * 1500

    -- this is the position where the trader will jump into hyperspace
    local destination = -pos + vec3(math.random(), math.random(), math.random()) * 1000
    destination = normalize(destination) * 1500

    -- ship title candidates
    local numbers = "0123456789"
    local letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"

    local c = random():getInt(1, #letters)
    local n1 = random():getInt(1, #numbers)
    local n2 = random():getInt(1, #numbers)
    local combination = "" .. letters:sub(c, c) .. "-" .. numbers:sub(n1, n1) .. numbers:sub(n2, n2)

    -- create prison transport - heavily armed trade ship with housing instead of cargo bay
    local matrix = MatrixLookUpPosition(-dir, vec3(0, 1, 0), pos)

    local sector = Sector()
    local x, y = sector:getCoordinates()
    local probabilities = Balancing_GetMaterialProbability(x, y)
    local material = Material(getValueFromDistribution(probabilities))
    local volume = Balancing_GetSectorShipVolume(x, y) * 5

    local plan = PlanGenerator.makeFreighterPlan(faction, volume, nil, material)

    -- exchange most cargo blocks to crew quarters and some to generators and engines as housing is a lot denser
    for _, index in pairs({plan:getBlockIndices()}) do
        local blocktype = plan:getBlockType(index)

        if blocktype == BlockType.CargoBay then
            if random():test(0.7) then
                plan:setBlockType(index, BlockType.Quarters)
            else
                if random():test(0.5) then
                    plan:setBlockType(index, BlockType.Generator)
                else
                    plan:setBlockType(index, BlockType.Engine)
                end
            end
        end
    end

    local ship = sector:createShip(faction, "", plan, matrix)

    -- finalize ship
    -- add weapons
    local turrets = Balancing_GetEnemySectorTurrets(x, y)
    ShipUtility.addArmedTurretsToCraft(ship, turrets)

    ship:addScriptOnce("ai/passsector.lua", destination)
    ship:setValue("passing_ship", true)
    ship:addScript("civilship.lua")
    ship:addScript("dialogs/storyhints.lua")

    -- this ship is a transport and is considered civil
    ship:setValue("is_civil", true)
    ship:addScript("icon.lua", "data/textures/icons/pixel/civil-ship.png")

    ship:setTitle("Prison Transport ${idstring}"%_T, {idstring = combination})

    local lines = PassingShips.getChatterLinesByShipType(PassingShipType.PrisonTransport)
    ship:addScriptOnce("data/scripts/entity/utility/radiochatter.lua", lines, 65, 85, random():getInt(5, 45), true)
end

-- flying snack bar - fly through to a station and dock, then undock and fly away, despawn
function PassingShips.createPassingSnackBarShip(faction)

    -- this is the position where the trader spawns
    local dir = random():getDirection()
    local pos = dir * 1500

    -- this is the position where the trader will jump into hyperspace
    local destination = -pos + vec3(math.random(), math.random(), math.random()) * 1000
    destination = normalize(destination) * 1500


    -- ship name and title candidates
    local names =
    {
        "Dino Snacks"%_T,
        "Chicken & Egg"%_T,
        "Toro Burgers"%_T,
        "Veggie Shack"%_T,
        "Chip Shop"%_T
    }

    local titles =
    {
        "Mobile Snack Bar"%_T,
        "Mobile Food Service"%_T,
        "Meals on Rocket Engines"%_T,
        "Food Runner"%_T,
        "Rocket Propelled Meals"%_T
    }

    -- create a single snack bar ship
    local onFinished = function(ship)
        -- finalize ship
        ship:addScriptOnce("ai/passsector.lua", destination)

        ship:setValue("passing_ship", true)
        ship:setTitle(randomEntry(random(), titles), {})
        ship.name = randomEntry(random(), names)

        local lines = PassingShips.getChatterLinesByShipType(PassingShipType.SnackBar)
        ship:addScriptOnce("data/scripts/entity/utility/radiochatter.lua", lines, 65, 85, random():getInt(5, 45), true)
    end

    local matrix = MatrixLookUpPosition(-dir, vec3(0, 1, 0), pos)

    local generator = AsyncShipGenerator(PassingShips, onFinished)
    local sector = Sector()
    local volume = Balancing_GetSectorShipVolume(sector:getCoordinates())

    pos = pos + dir * 200
    local matrix = MatrixLookUpPosition(-dir, vec3(0, 1, 0), pos)
    generator:createTradingShip(faction, matrix)
end

-- tow boat
function PassingShips.createPassingTowBoat(faction)

    -- this is the position where the trader spawns
    local dir = random():getDirection()
    local pos = dir * 1500

    -- this is the position where the trader will jump into hyperspace
    local destination = -pos + vec3(math.random(), math.random(), math.random()) * 1000
    destination = normalize(destination) * 1500

    -- ship title candidates
    local titles =
    {
        "Towing Service"%_T,
        "Mobile Towing Services"%_T,
        "Tug Boat"%_T,
    }

    local names =
    {
        "Tuggy Boat"%_T,
        "Bob's Power Tow"%_T,
        "Wreck & Recovery"%_T,
        "Day Savers Towing"%_T,
        "To The Rescue Towing"%_T,
    }

    -- create ship
    local onFinished = function(ship)
        -- finalize ship
        ship:addScriptOnce("ai/passsector.lua", destination)

        ship:setValue("passing_ship", true)
        ship:setTitle(randomEntry(random(), titles), {})
        ship.name = randomEntry(random(), names)

        local lines = PassingShips.getChatterLinesByShipType(PassingShipType.TowBoat)
        ship:addScriptOnce("data/scripts/entity/utility/radiochatter.lua", lines, 65, 85, random():getInt(5, 45), true)
    end

    local matrix = MatrixLookUpPosition(-dir, vec3(0, 1, 0), pos)

    local generator = AsyncShipGenerator(PassingShips, onFinished)
    local sector = Sector()
    local volume = Balancing_GetSectorShipVolume(sector:getCoordinates())

    pos = pos + dir * 200
    local matrix = MatrixLookUpPosition(-dir, vec3(0, 1, 0), pos)
    generator:createTradingShip(faction, matrix)
end

-- factory commute shuttle - fly to a station and dock, then undock and fly away, despawn
function PassingShips.createPassingFactoryCommuteShuttle(faction)

    -- this is the position where the trader spawns
    local dir = random():getDirection()
    local pos = dir * 1500

    -- this is the position where the trader will jump into hyperspace
    local destination = -pos + vec3(math.random(), math.random(), math.random()) * 1000
    destination = normalize(destination) * 1500

    -- ship title candidates
    local titles =
    {
        "Galactic Commute Shuttle"%_T,
        "Intersector Shuttles"%_T,
        "Express Shuttle Service"%_T,
        "People Delivery Service"%_T
    }

    local names =
    {
        "Trusty Commuter"%_T,
        "Cheetah Commutes"%_T,
        "Gazelle Ferry"%_T,
        "Antilope Transports"%_T
    }

    -- create ship
    local matrix = MatrixLookUpPosition(-dir, vec3(0, 1, 0), pos)

    local sector = Sector()
    local x, y = sector:getCoordinates()
    local probabilities = Balancing_GetMaterialProbability(x, y)
    local material = Material(getValueFromDistribution(probabilities))
    local volume = Balancing_GetSectorShipVolume(x, y)

    local plan = PlanGenerator.makeShipPlan(faction, volume, nil, material)

    -- exchange most cargo blocks to crew quarters and some to generators and engines as housing is a lot denser
    for _, index in pairs({plan:getBlockIndices()}) do
        local blocktype = plan:getBlockType(index)

        if blocktype == BlockType.CargoBay then
            if random():test(0.7) then
                plan:setBlockType(index, BlockType.Quarters)
            else
                if random():test(0.5) then
                    plan:setBlockType(index, BlockType.Generator)
                else
                    plan:setBlockType(index, BlockType.Engine)
                end
            end
        end
    end

    local ship = sector:createShip(faction, "", plan, matrix)

    ship:addScriptOnce("ai/passsector.lua", destination)
    ship:setValue("passing_ship", true)
    ship:addScript("civilship.lua")
    ship:addScript("dialogs/storyhints.lua")
    ship:setValue("is_civil", true)
    ship:addScript("icon.lua", "data/textures/icons/pixel/civil-ship.png")

    ship:setTitle(randomEntry(random(), titles), {})
    ship.name = randomEntry(random(), names)

    local lines = PassingShips.getChatterLinesByShipType(PassingShipType.FactoryCommute)
    ship:addScriptOnce("data/scripts/entity/utility/radiochatter.lua", lines, 120, 300, random():getInt(5, 45), true)
end

function PassingShips.getChatterLinesByShipType(type)
    local result = {}

    if type == PassingShipType.CruiseShip then
        result =
        {
            "You urgently need a holiday? Then you've come to the right place!"%_T,
            "New destinations, new adventures, best holiday feeling!"%_T,
            "Only today: 20% discount on our most popular holiday destinations!"%_T,
            "Next stop: The Nebulon Rift!"%_T,
            "Discover fascinating worlds and bask in luxury!"%_T,
        }
    elseif type == PassingShipType.PartyShip then
        result =
        {
            "Are you ready? Paaaartyyy .. unz, unz, unz ..."%_T,
            "Looking for a location for your party? Book us and have the best party of your life!"%_T,
        }
    elseif type == PassingShipType.PrisonTransport then
        result =
        {
            "Alert! Breach in cellblock G-34-7!"%_T,
            "Camera in cellblock H-08-02 is malfunctioning. Repair crew dispatched."%_T,
            "Everything is nice and quiet. Let's hope it stays that way."%_T,
            "Don't worry, this ship is equipped with the best security measures. The cells are absolutely escape-proof."%_T,
        }
    elseif type == PassingShipType.SnackBar then
        result =
        {
            "Special offer! Buy three lunches, get drinks for free!"%_T,
            "The best snack with the best music! Only here your lunch becomes an experience!"%_T,
            "Best burger in the galaxy only here! Get it now!"%_T,
            "Tired, but you have to work? Maxodon's Energy Shots will help you get back on your feet! And that without any natural ingredients!"%_T,
            "Looking for the perfect sandwich? We've got it and much more!"%_T,
        }
    elseif type == PassingShipType.FactoryCommute then
        result =
        {
            "Another day of work ... I need a vacation."%_T,
            "This commute is getting worse every day!"%_T,
            "I should be looking for a new job. This commute drives me insane."%_T,
        }
    elseif type == PassingShipType.TowBoat then
        result =
        {
            "We are the tow from duty! Towing at unbeatable prices!"%_T,
            "Tow, tow, tow your boat, gently through the galaxy. Merrily, merrily, merrily, merrily, and ready for repairs!"%_T,
            "Having a bad day? In the middle of nowhere and your engines won't start? Call us, and get a Tow-Tow-Towing!"%_T,
            "Most times everything goes to plan, other times - not so much. Call us! We will get you out of your pickle!"%_T,
            "Your tow. Anywhere. Anytime."%_T,
            "We won’t tow you away from your favorite spot. Promised. But if you need a tug - call us!"%_T,
        }
    else
        result = {} -- no special chatter lines needed for trader ships
    end

    return result
end

end

]]
