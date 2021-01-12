package.path = package.path .. ";data/scripts/?.lua"
package.path = package.path .. ";data/scripts/lib/?.lua"

local AsyncShipGenerator = include ("asyncshipgenerator")
local Placer = include ("placer")
local SpawnUtility = include("spawnutility")

-- Don't remove or alter the following comment, it tells the game the namespace this script lives in. If you remove it, the script will break.
-- namespace Test
Test = {}


local defenderFactionIndex
local numDefenders
local specialHandling
local missingLastTick
local updateTimer

function Test.secure()
    return
    {

    }
end

function Test.restore(data)

end



function Test.getUpdateInterval()
    return 15
end

-- function Test.onRestoredFromDisk(time)
--     Test.updateServer(time)
-- end


function Test.initialize()
    -- if onServer() then
    --     Sector():registerCallback("onRestoredFromDisk", "onRestoredFromDisk")
    -- end
end


function Test.updateServer(timeStep)
    print("Test Spawn: Starting Update Tick")

    local resolveIntersections = function(ships)
        Placer.resolveIntersections(ships)
        print("Test Spawn: Callback Hit") 
    end

    local generator = AsyncShipGenerator(Test, resolveIntersections)

    local dir = random():getDirection()
    local matrix = MatrixLookUpPosition(-dir, vec3(0,1,0), dir * 2000)

    local faction = Galaxy():getNearestFaction(Sector():getCoordinates())


    generator:startBatch()
    generator:createShipByClass("Default", faction, matrix)
    generator:createShipByClass("Carrier", faction, matrix, nil, { fighters = 21 } )
    generator:endBatch()

end
