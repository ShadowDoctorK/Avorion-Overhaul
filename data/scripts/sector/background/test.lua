package.path = package.path .. ";data/scripts/?.lua"
package.path = package.path .. ";data/scripts/lib/?.lua"

local AsyncFleetGenerator = include("asyncfleetgenerator")
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



-- function Test.getUpdateInterval()
--     return 10
-- end

-- function Test.onRestoredFromDisk(time)
--     Test.updateServer(time)
-- end

function Test.initialize()
    if onServer() then
        
        print("Test Spawn: Starting Initialize")

        local resolveIntersections = function(ships)
            Placer.resolveIntersections(ships)
            print("Test Spawn: Final Callback") 
        end

        local eachShipCallback = function(ship)
            ship:addScriptOnce("ai/patrol.lua")
            print("Test Spawn: Callback For Ship -" .. tostring(ship.name)) 
        end
    
        
        local dir = random():getDirection()
        local matrix = MatrixLookUpPosition(-dir, vec3(0,1,0), dir * 2000)
        local faction = Galaxy():getNearestFaction(Sector():getCoordinates())
        

        -- local generator = AsyncFleetGenerator(Test, resolveIntersections ,{"Default","Carrier","Defender"})
        local generator = AsyncFleetGenerator(Test, resolveIntersections ,{
            "Blocker","Carrier","CIWS","Default","Defender","Disrupter","Flagship","Freighter","Miner","Persecutor","Torpedo","Tradeship"
        })

        -- generator:queueShip("Miner", faction, matrix, 5000, { } , eachShipCallback)
        -- generator:queueShip("Defender", faction, matrix, 5000, { volumeAmp = 7.5, damageAmp = 20 } , eachShipCallback)
        -- generator:queueShip("Carrier", faction, matrix, 10000, { fighters = 21 } , eachShipCallback)

        generator:queueRandomShips(5, faction, matrix, nil, { } , eachShipCallback)
        -- generator:queueRandomShips(5, faction, matrix, 10000, { fighters = 21, damageAmp = 10 } , eachShipCallback)

        generator:Build()        
    end
end


-- function Test.updateServer(timeStep)

-- end
