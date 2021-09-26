--[[
    Developer Notes:
    This whole file change is meant to redirect the default vanilla game functions to the new Ship Generator.
    It also stores the old vanilla functions in case they are required for use later.
]]

package.path = package.path .. ";data/scripts/lib/?.lua"
package.path = package.path .. ";data/scripts/?.lua"

--include ("galaxy")
--include ("utility")
--include ("defaultscripts")
--include ("goods")
--local PlanGenerator = include ("plangenerator")
--local ShipUtility = include ("shiputility")
--local SectorFighterGenerator = include("sectorfightergenerator")

--local ShipGenerator = {}

local Gen = include("SDKGlobalDesigns - Generator Ships")

-- Saved Vanilla Function
ShipGenerator.old_createShip = ShipGenerator.createShip
ShipGenerator.old_createDefender = ShipGenerator.createDefender
ShipGenerator.old_createCarrier = ShipGenerator.createCarrier
ShipGenerator.old_createMilitaryShip = ShipGenerator.createMilitaryShip
ShipGenerator.old_createTradingShip = ShipGenerator.createTradingShip
ShipGenerator.old_createFreighterShip = ShipGenerator.createFreighterShip
ShipGenerator.old_createMiningShip = ShipGenerator.createMiningShip


function ShipGenerator.createShip(faction, position, volume)
    return Gen.Ship(faction, position)
end

function ShipGenerator.createDefender(faction, position)
    return Gen.Defender(faction, position)
end

function ShipGenerator.createCarrier(faction, position, fighters)
    return Gen.Carrier(faction, position)
end

function ShipGenerator.createMilitaryShip(faction, position, volume)
    return Gen.Military(faction, position)
end

function ShipGenerator.createTradingShip(faction, position, volume)
    return Gen.Trader(faction, position)
end

function ShipGenerator.createFreighterShip(faction, position, volume)
    return Gen.Freighter(faction, position)
end

function ShipGenerator.createMiningShip(faction, position, volume)
    return Gen.Miner(faction, position)
end

--return ShipGenerator