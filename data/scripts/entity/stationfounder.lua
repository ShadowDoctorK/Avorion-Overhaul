
function InsertStationData(station)
    local index = -1
    for k, v in pairs(StationFounder.stations) do
        --print("K: " .. tostring(k) .. " V:" .. tostring(v.name))
        if v.name == station.name then index = k break end
    end

    if index == -1 then 
        --print("Inserting Station: " .. tostring(station.name))
        index = #StationFounder.stations + 1 
    else
        --print("Overriding Station: " .. tostring(station.name))
    end

    --print("Index: " .. tostring(index))
    StationFounder.stations[index] = station
end

-- Insert Shipyard
InsertStationData({
    name = "Scrapyard"%_t,
    tooltip = "Buys and sells salvaging turrets. The owner of the shipyard will not have to purchase a license to salvage any wreckages in the sector as long as they control the sector."%_t .. "\n\n" ..
              "Scrap tugs will bring scrap to the scrapyard field from various places. This station will attract NPC salvagers."%_t,
    scripts = {
        {script = "data/scripts/entity/merchants/scrapyard.lua"},
        {script = "data/scripts/entity/merchants/SDKMerchSalvageTurret.lua"}, -- Custom script to add a merch only selling Salvage Turrets.
    },
    getPrice = function()
        return 25000000 -- Consider changing this to balance out resrouces values and distance from core.
        -- Also consider adding a new function where 10% of the salvage done by a player or NPC goes to the owner.
        -- then make the owner "pay" for new wrecks that enter the space to be sold to the shipyard.
    end
})

-- Override Resource Depot
InsertStationData({
    name = "Resource Depot"%_t,
    tooltip = "Sells and buys resources such as Iron or Titanium and the like. The owner gets 20% of every transaction, as well as cheaper prices. This version also sells mining turrets. "%_t,
    scripts = {
        {script = "data/scripts/entity/merchants/resourcetrader.lua"},
        {script = "data/scripts/entity/merchants/SDKMerchMiningTurret.lua"}
    },
    price = 15000000
})

-- Override Equipment Dock
InsertStationData({
    name = "Equipment Dock"%_t,
    tooltip = "Buys and sells upgrades, turrets and fighters. The owner of the equipment dock gets 20% of the money of every transaction, as well as cheaper prices."%_t .. "\n\n" ..
              "The population on this station buys and consumes a range of technological goods. These goods can be picked up for free by the owner of the station. Attracts NPC traders."%_t,
    scripts = {
        {script = "data/scripts/entity/merchants/equipmentdock.lua"},
        {script = "data/scripts/entity/merchants/SDKMerchTurretLocal1.lua"},  -- Allows Modded items
        {script = "data/scripts/entity/merchants/SDKMerchTurretLocal2.lua"},  -- Allows Modded items
        {script = "data/scripts/entity/merchants/SDKMerchTurretPDC.lua"},
        {script = "data/scripts/entity/merchants/SDKMerchTurretPDL.lua"},
        {script = "data/scripts/entity/merchants/SDKMerchTurretBolter.lua"},
        {script = "data/scripts/entity/merchants/SDKMerchTurretPlasma.lua"},
        {script = "data/scripts/entity/merchants/SDKMerchTurretPulseCannon.lua"},
        {script = "data/scripts/entity/merchants/SDKMerchTurretRocket.lua"},
        {script = "data/scripts/entity/merchants/SDKMerchTurretRailgun.lua"},
        {script = "data/scripts/entity/merchants/SDKMerchTurretLightning.lua"},
        {script = "data/scripts/entity/merchants/SDKMerchTurretCannon.lua"},
        {script = "data/scripts/entity/merchants/fightermerchant.lua"},
        {script = "data/scripts/entity/merchants/torpedomerchant.lua"},
        {script = "data/scripts/entity/merchants/utilitymerchant.lua"},
        {script = "data/scripts/entity/merchants/consumer.lua", args = {"Equipment Dock"%_t, unpack(ConsumerGoods.EquipmentDock())}},
    },
    getPrice = function()
        return 25000000 +
            StationFounder.calculateConsumerValue({"Equipment Dock"%_t, unpack(ConsumerGoods.EquipmentDock())})
    end
})


--[[
StationFounder.stations =
{
    {
        name = "Biotope"%_t,
        tooltip = "The population on this station buys and consumes a range of organic goods. These goods can be picked up for free by the owner of the station. Attracts NPC traders."%_t,
        scripts = {{script = "data/scripts/entity/merchants/biotope.lua"}},
        getPrice = function()
            return StationFounder.calculateConsumerValue({"Food", "Food Bar", "Fungus", "Wood", "Glass", "Sheep", "Cattle", "Wheat", "Corn", "Rice", "Vegetable", "Water", "Coal"})
        end
    },
    {
        name = "Casino"%_t,
        tooltip = "The population on this station buys and consumes a range of luxury goods. These goods can be picked up for free by the owner of the station. Attracts NPC traders."%_t,
        scripts = {{script = "data/scripts/entity/merchants/casino.lua"}},
        getPrice = function()
            return StationFounder.calculateConsumerValue({"Beer", "Wine", "Liquor", "Food", "Luxury Food", "Water", "Medical Supplies"})
        end
    },
    {
        name = "Habitat"%_t,
        tooltip = "The population on this station buys and consumes a range of common day-to-day goods. These goods can be picked up for free by the owner of the station. Attracts NPC traders."%_t,
        scripts = {{script = "data/scripts/entity/merchants/habitat.lua"}},
        getPrice = function()
            return StationFounder.calculateConsumerValue({"Beer", "Wine", "Liquor", "Food", "Tea", "Luxury Food", "Spices", "Vegetable", "Fruit", "Cocoa", "Coffee", "Wood", "Meat", "Water"})
        end
    },
    {
        name = "Equipment Dock"%_t,
        tooltip = "Buys and sells upgrades, turrets and fighters. The owner of the equipment dock gets 20% of the money of every transaction, as well as cheaper prices."%_t .. "\n\n" ..
                  "The population on this station buys and consumes a range of technological goods. These goods can be picked up for free by the owner of the station. Attracts NPC traders."%_t,
        scripts = {
            {script = "data/scripts/entity/merchants/equipmentdock.lua"},
            {script = "data/scripts/entity/merchants/turretmerchant.lua"},
            {script = "data/scripts/entity/merchants/fightermerchant.lua"},
            {script = "data/scripts/entity/merchants/torpedomerchant.lua"},
            {script = "data/scripts/entity/merchants/utilitymerchant.lua"},
            {script = "data/scripts/entity/merchants/consumer.lua", args = {"Equipment Dock"%_t, unpack(ConsumerGoods.EquipmentDock())}},
        },
        getPrice = function()
            return 25000000 +
                StationFounder.calculateConsumerValue({"Equipment Dock"%_t, unpack(ConsumerGoods.EquipmentDock())})
        end
    },
    {
        name = "Fighter Factory"%_t,
        tooltip = "Produces custom fighters. The owner of the factory gets 20% of the money of every transaction, as well as cheaper prices."%_t,
        scripts = {{script = "data/scripts/entity/merchants/fighterfactory.lua"}},
        price = 35000000
    },
    -- {
    --     name = "Headquarters"%_t,
    --     tooltip = "Can be used as headquarters for an alliance. [Not yet implemented.]"%_t,
    --     scripts = {{script = "data/scripts/entity/merchants/headquarters.lua"}},
    --     price = 5000000
    -- },
    {
        name = "Research Station"%_t,
        tooltip = "Upgrades and turrets can be researched here to get better upgrades and turrets."%_t .. "\n\n" ..
                  "The population of this station buys and consumes a range of science goods. These goods can be picked up for free by the owner of the station. Attracts NPC traders."%_t,
        scripts = {
            {script = "data/scripts/entity/merchants/researchstation.lua"},
            {script = "data/scripts/entity/merchants/consumer.lua", args = {"Research Station"%_t, unpack(ConsumerGoods.ResearchStation())}},
        },
        getPrice = function()
            return 5000000 +
                    StationFounder.calculateConsumerValue({"Research Station"%_t, unpack(ConsumerGoods.ResearchStation())})
        end
    },
    {
        name = "Resource Depot"%_t,
        tooltip = "Sells and buys resources such as Iron or Titanium and the like. The owner gets 20% of every transaction, as well as cheaper prices."%_t,
        scripts = {{script = "data/scripts/entity/merchants/resourcetrader.lua"}},
        price = 15000000
    },
    {
        name = "Smuggler's Market"%_t,
        tooltip = "Sells and buys stolen and other illegal goods. The owner gets 20% of every transaction, as well as cheaper prices."%_t,
        scripts = {{script = "data/scripts/entity/merchants/smugglersmarket.lua"}},
        price = 25000000
    },
    {
        name = "Trading Post"%_t,
        tooltip = "Sells and buys a random range of goods. The owner gets 20% of every transaction, as well as cheaper prices. Attracts NPC traders."%_t,
        scripts = {{script = "data/scripts/entity/merchants/tradingpost.lua"}},
        price = 25000000
    },
    {
        name = "Turret Factory"%_t,
        tooltip = "Produces customized turrets and sells turret parts for high prices. The owner gets 20% of every transaction, as well as cheaper prices."%_t,
        scripts = {
            {script = "data/scripts/entity/merchants/turretfactory.lua"},
            {script = "data/scripts/entity/merchants/turretfactoryseller.lua", args = {"Turret Factory"%_t, unpack(ConsumerGoods.TurretFactory())}}

        },
        price = 30000000
    },
    {
        name = "Military Outpost"%_t,
        tooltip = "Provides combat missions to players."%_t .. "\n\n" ..
                  "The population on this station buys and consumes a range of military goods. These goods can be picked up for free by the owner of the station. Attracts NPC traders."%_t,
        scripts = {
            {script = "data/scripts/entity/merchants/militaryoutpost.lua"},
            {script = "data/scripts/entity/merchants/consumer.lua", args = {"Military Outpost"%_t, unpack(ConsumerGoods.MilitaryOutpost())}},
        },
        getPrice = function()
            return StationFounder.calculateConsumerValue({"Military Outpost"%_t, unpack(ConsumerGoods.MilitaryOutpost())})
        end
    },
    {
        name = "Shipyard"%_t,
        tooltip = "Builds ships. The owner gets the production fee paid by other players. Production fee is free for the owner of the shipyard."%_t .. "\n\n" ..
                  "The population on this station buys and consumes a range of technological goods. These goods can be picked up for free by the owner of the station. Attracts NPC traders."%_t,
        scripts = {
            {script = "data/scripts/entity/merchants/shipyard.lua"},
            {script = "data/scripts/entity/merchants/repairdock.lua"},
            {script = "data/scripts/entity/merchants/consumer.lua", args = {"Shipyard"%_t, unpack(ConsumerGoods.Shipyard())}},
        },
        getPrice = function()
            return 2500000 +
                    StationFounder.calculateConsumerValue({"Shipyard"%_t, unpack(ConsumerGoods.Shipyard())})
        end
    },
    {
        name = "Repair Dock"%_t,
        tooltip = "Repairs ships. The owner gets 20% of every transaction, as well as cheaper prices."%_t .. "\n\n" ..
                  "The population on this station buys and consumes a range of technological goods. These goods can be picked up for free by the owner of the station. Attracts NPC traders."%_t,
        scripts = {
            {script = "data/scripts/entity/merchants/repairdock.lua"},
            {script = "data/scripts/entity/merchants/consumer.lua", args = {"Repair Dock"%_t, unpack(ConsumerGoods.RepairDock())}},
        },
        getPrice = function()
            return 2500000 +
                    StationFounder.calculateConsumerValue({"Repair Dock"%_t, unpack(ConsumerGoods.RepairDock())})
        end
    },
    
}
]]