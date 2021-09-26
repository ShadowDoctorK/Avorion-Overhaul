--[[
    Developer Note:
    Commented out this whole script to prevent log errors. It will be phased out and removed in the next update.
]]

--[[
package.path = package.path .. ";data/scripts/lib/?.lua"
package.path = package.path .. ";data/scripts/?.lua"
package.path = package.path .. ";?"

include("randomext")
include("galaxy")
local ShipUtility = include ("shiputility")
local Rand = include("SDKUtilityRandom")
local PlanGen = include("plangenerator")
local Deisgns = include("SDKGlobalDesigns")
local Plan = include("SDKUtilityBlockPlan")
local Log = include("SDKDebugLogging")
Log.ModName = "SDK Scrapyard Extension"
Log.Debugging = 0

-- Don't remove or alter the following comment, it tells the game the namespace this script lives in. If you remove it, the script will break.
-- namespace SDKScrapyardExtension
SDKScrapyardExtension = {}
local self = SDKScrapyardExtension

self.StationsTypes = {
    "RepairDock",      
    "ResourceDepot",   
    "TradingPost",     
    "EquipmentDock",   
    "SmugglersMarket", 
    "Scrapyard",       
    "Mine",            
    "Factory",         
    "FighterFactory",  
    "TurretFactory",   
    "SolarPowerPlant", 
    "Farm",            
    "Ranch",           
    "Collector",       
    "Biotope",         
    "Casino",          
    "Habitat",         
    "MilitaryOutpost", 
    "Headquarters",    
    "ResearchStation", 
    "Default",  
}

if onServer() then

    self.UpdateInterval = 5
    self.MaxSpawnDistance = 2500

    self.MaxThreshold = 120
    self.QuickSpawnThreshold = 30
    self.NextSpawn = 0
    self.NextClean = 60

    self.CheckIsDagnerous = 0

    function SDKScrapyardExtension.getUpdateInterval()
        return self.UpdateInterval
    end

    function SDKScrapyardExtension.initialize() local _Method = "Initializing"
        
        Log.Debug(_Method, "Starting...", 1)       
        local _Sector = Sector()

    end

    function SDKScrapyardExtension.CleanUp(_TimeStep) local _Method = "Clean Up"
        
        --print("Cleaning Time: " .. tostring(self.NextClean))
        self.NextClean = self.NextClean - _TimeStep
        if self.NextClean > 0 then return end

        local _Sector = Sector()
        for _, v in pairs({_Sector:getEntitiesByType(EntityType.Wreckage)}) do
            -- Clean up small particle wreckages
            if v.volume <= 100 then 
                --print("Clearing Junk...")
                _Sector:deleteEntity(v) 
            end
        end 

        self.NextClean = 60 -- Clean Up Sector every 60 seconds

    end

    function SDKScrapyardExtension.updateServer(_TimeStep) local _Method = "Update Server"
                
        Log.Debug(_Method, "Time Step: " .. tostring(_TimeStep))

        self.Despawn(_TimeStep) -- Update Despawning Temp Tugs Marked with "SDKLifeTime"
        self.CleanUp(_TimeStep) -- Update the particle/small wreckage clean up.

        -- Don't execute while there is no scrapyard
        -- Wait for a new scrapyard then start bring in salvage again.
        local _Exist, _Location, _ScrapyardFaction = self.Scrapyard() if not _Exist then 
            self.UpdateInterval = 15 * 60 
            Log.Warning(_Method, "No Scrapyard Detected, Putting Scrapyard Script To Sleep For 15 Mins") return 
        end if self.UpdateInterval == 15 * 60 then self.UpdateInterval = 5 end

        -- Update Spawn Counter
        self.NextSpawn = self.NextSpawn - _TimeStep
        if self.NextSpawn < -5 then self.NextSpawn = -5 end
                
        --Log.Debug(_Method, "Next Spawn Wait Time: " .. tostring(self.NextSpawn))
        --Log.Debug(_Method, "Wrecks: " .. tostring(_Wrecks))
        --Log.Debug(_Method, "Threshold: " .. tostring(self.MaxThreshold))

        -- Check is Spawn Is Ready
        if self.NextSpawn <= 0 then

            -- Don't Spawn If Dangerous
            if self.Dangerous() then Log.Debug(_Method, "Sector Is Dangerous, Waiting...") return end

            -- Spawn Wrecks When Below Threshold
            local _Wrecks = self.Wreckages() 
            if not _Wrecks then return end

            if _Wrecks >= self.MaxThreshold then 
                self.UpdateInterval = 30 return      -- Check every 30 seconds if we can spawn next wreck
            elseif _Wrecks < self.MaxThreshold then
                self.UpdateInterval = 5              -- Restore Normal checks
            end

            local _TugFaction = _ScrapyardFaction

            -- Only use AI tugs
            if not _TugFaction.isAIFaction then -- Check if Scrapyard was Player Owned                    
                -- Set to Nearest AI Faction or the Local Controlling Faction
                _TugFaction = Galaxy():getLocalFaction(_X, _Y) or Galaxy():getNearestFaction(_X, _Y)                                
            end    
                
            -- Check Tug Faction isn't at War with any other factions... We aren't trying to creat a war.
            local _PresentFactions = {self.GetAllFactions()} for k, v in pairs(_PresentFactions) do
                if _TugFaction:getRelationStatus(v) == RelationStatus.War then
                    _TugFaction = self.CivilianFaction() break
                end
            end

            if not _TugFaction then return end

            -- Spawn Scrap Hauler and Wreckage
            local _SalvagerMatrix = self.PositionAround(_Location, nil, 0.25)
            local _WreckageMatrix = self.PositionAround(_SalvagerMatrix.pos, 100)

            local _Salvager = self.Salvager(_TugFaction, _SalvagerMatrix)
            local _Wreckage = self.Wreckage(_TugFaction, nil, _WreckageMatrix)

            -- Set next spawn time
            if _Wrecks < self.QuickSpawnThreshold then
                 self.NextSpawn = self.NextSpawn + math.random(10, 45)
            else self.NextSpawn = self.NextSpawn + math.random(10, 120) end

            if _Salvager then 
                local _Life = Rand.Int(20, 45) _Salvager:setValue("SDKLifeTime", _Life) _Salvager:setValue("SDKShipType", "SDKSalvager")
                --Log.Debug(_Method, "Scheduling Despawn: [" .. tostring(_Life) .. " Seconds] " .. tostring(_Salvager.type) .. " - " .. tostring(_Salvager.name))                    
            end                

        end  
 
    end

    function SDKScrapyardExtension.GetAllFactions()
        return Sector():getPresentFactions()
    end

    function SDKScrapyardExtension.CivilianFaction()
        local name = "Civilian Pilot"%_T
    
        local galaxy = Galaxy()
        local faction = galaxy:findFaction(name)
        if faction == nil then
            faction = galaxy:createFaction(name, 0, 0)
            faction.initialRelations = 70000
            faction.initialRelationsToPlayer = 70000
            faction.staticRelationsToAll = true
    
            for trait, value in pairs(faction:getTraits()) do
                faction:setTrait(trait, 0) -- completely neutral / unknown
            end
        end
    
        faction.initialRelationsToPlayer = 70000
        faction.initialRelations = 70000
        faction.staticRelationsToAll = true
        faction.homeSectorUnknown = true
    
        return faction
    
    end

    -- Checks for Number of Wrecks
    function SDKScrapyardExtension.Wreckages() local _Method = "Wrecakges"
        local Wrecks = 0 
        for _, v in pairs({Sector():getEntitiesByType(EntityType.Wreckage)}) do
            if v.volume > 100 and v:getValue("SDKScrapyardWreckage") == true then
                Wrecks = Wrecks + 1
            end
        end 

        -- Log.Debug(_Method, "Total: " .. tostring(Wrecks)) 
        return Wrecks
    end

    -- Checks for Scrapyard
    function SDKScrapyardExtension.Scrapyard()
        for _, v in pairs({Sector():getEntitiesByScript("data/scripts/entity/merchants/scrapyard.lua")}) do            
            return true, v.translationf, Faction(v.factionIndex) -- Return first one in the list.
        end return false, nil, nil
    end

    -- Checks for Dangerous Conditions
    function SDKScrapyardExtension.Dangerous()

        for _, _Ship in pairs({Sector():getEntitiesByType(EntityType.Ship)}) do

            local _Faction = Faction(_Ship.factionIndex)

            if _Faction then

                Log.Debug(_Method, "Faction: " .. tostring(_Faction.name))

                -- Check for Pirates & Xsotan
                if string.match(_Faction.name, "Pirate") or string.match(_Faction.name, "Xsotan") then            
                    if not string.match(_Faction.name, "This refers to factions, such as") then
                        self.CheckIsDagnerous = self.CheckIsDagnerous + 1
                        return true
                    end  
                end
                
                -- Check for Ships At War With Faction
                if _Faction:getRelationStatus(_Ship.factionIndex) == RelationStatus.War then
                    self.CheckIsDagnerous = self.CheckIsDagnerous + 1
                    return true
                end  

            end

        end 

        self.CheckIsDagnerous = 0
        return false

    end

    function SDKScrapyardExtension.Despawn(_TimeStep) local _Method = "Despawn"
        for _, _Ship in pairs({Sector():getEntitiesByScriptValue("SDKShipType", "SDKSalvager")}) do

            -- Despawn All Tugs When Dagnerous...
            if self.CheckIsDagnerous >= 2 then
                Log.Debug(_Method, "Danger Area Despawn: " .. tostring(_Ship.type) .. " - " .. tostring(_Ship.name)) 
                Sector():deleteEntityJumped(_Ship)
            else

                local _Time = tonumber(_Ship:getValue("SDKLifeTime")) if _Time then -- Don't Delete Passive Salvagers Clearing Wrecks

                    -- Test Life Time / Delete Entity
                    _Time = _Time - _TimeStep  if _Time <= 0 then 
                        Log.Debug(_Method, "Despawn: " .. tostring(_Ship.type) .. " - " .. tostring(_Ship.name))  
                         Sector():deleteEntityJumped(_Ship)
                    else _Ship:setValue("SDKLifeTime", _Time)  end
    
                end
            end
        end 
    end

    -- DON'T USE DEFERED CALLBACKS... THEY WILL EVENTUALLY CRASH THE GAME!!!
    
    --function SDKScrapyardExtension.Despawn(_Ship) local _Method = "Despawn"
    --    Log.Debug(_Method, "Despawning: " .. tostring(_Ship.type) .. " - " .. tostring(_Ship.name), 1)
    --    if _Ship then Sector():deleteEntityJumped(_Ship) end        
    --end
    

    function SDKScrapyardExtension.Station()
        return self.StationsTypes[Rand.Int(1, #self.StationsTypes)]
    end

    -- Pick a random distance between the threshold area
    function SDKScrapyardExtension.PositionAdjustment(_Posit, _MaxDist)

        -- Adjust Random Spawn Distance From Position
        _Posit.x = _Posit.x + Rand.Float(0, 1) * Rand.Float(-_MaxDist, _MaxDist)
        _Posit.y = _Posit.y + Rand.Float(0, 1) * Rand.Float(-_MaxDist, _MaxDist)
        _Posit.z = _Posit.z + Rand.Float(0, 1) * Rand.Float(-_MaxDist, _MaxDist)

        return _Posit
    end

    -- Fucntion wil be used in a future update
    function SDKScrapyardExtension.CheckDistance(_Ref, _Pos, _Threshold)
        local x = (_Ref.x - _Pos.x)^2
        local y = (_Ref.y - _Pos.y)^2
        local z = (_Ref.z - _Pos.z)^2

        if math.sqrt(x + y + z) < _Threshold then return false end 

        return true
    end

    -- Position items around the scrapyard
    function SDKScrapyardExtension.PositionAround(_Position, _MaxDist, _Standoff) local _Method = "Postition Around"

        _Standoff = _Standoff or 0.25
        _MaxDist = _MaxDist or self.MaxSpawnDistance
        
        -- Gives it a buffer from the Scrapyard
        _Position.x = _Position.x + _Standoff
        _Position.y = _Position.y + _Standoff
        _Position.z = _Position.z + _Standoff

        --Log.Debug(_Method, "Location: " .. tostring(_Position.x) .. ", " .. tostring(_Position.y) .. ", " .. tostring(_Position.z))
        --Log.Debug(_Method, "Max Distance: " .. tostring(_MaxDist))
    
        local _SpawnPosit = self.PositionAdjustment(_Position, _MaxDist)

        --Log.Debug(_Method, "Spawn Point: " .. tostring(_SpawnPosit.x) .. ", " .. tostring(_SpawnPosit.y) .. ", " .. tostring(_SpawnPosit.z))

        -- create a random up vector
        local _Up = vec3(math.random(), math.random(), math.random())
        
        -- create a random look vector
        local _Look = vec3(math.random(), math.random(), math.random())

        -- create the look vector from them
        local _Matrix = MatrixLookUp(_Look, _Up)
        _Matrix.pos = _Position
    
        return _Matrix
    end

    function SDKScrapyardExtension.Salvager(_Faction, _Position)
        _Position = _Position or Matrix()
        
        local _Table = Deisgns.Get("MediumSalvagers")       
        local _TargetDesign = _Table[Rand.Int(1, #_Table)]

        Log.Debug(_Method, "Total Designs: " .. tostring(#_Table))
        Log.Debug(_Method, "Target Design: " .. tostring(_TargetDesign))

        if Plan.Load(_TargetDesign) then
            Plan.Material()
        else Log.Warning(_Method, "No Salvager Plan Was Loaded, Returning nil...") return end        
        
        local _Ship = Sector():createShip(_Faction, "", Plan.Get(), _Position, EntityArrivalType.Jump)
    
        _Ship.shieldDurability = _Ship.shieldMaxDurability
        _Ship.crew = _Ship.idealCrew
    
        AddDefaultShipScripts(_Ship)
        
        local _Turrets = Balancing_GetEnemySectorTurrets(Sector():getCoordinates())
        ShipUtility.addArmedTurretsToCraft(_Ship, _Turrets)
    
        _Ship.crew = _Ship.idealCrew
        _Ship.title = "Scrapyard Tug"
           
        _Ship:addScriptOnce("civilship.lua")
        _Ship:addScriptOnce("ai/patrol.lua")
        _Ship:setValue("is_civil", 1)
        _Ship:setValue("npc_chatter", true)
        _Ship:addScriptOnce("icon.lua", "data/textures/icons/pixel/civil-ship.png")
    
        return _Ship
    end

    function SDKScrapyardExtension.Wreckage(_Faction, _Plan, _Position, _Breaks, _Strip)

        local _X, _Y = Sector():getCoordinates()
        _Faction = _Faction or Galaxy():getLocalFaction(_X, _Y) or Galaxy():getNearestFaction(_X, _Y)
        _Strip = _Strip or Rand.Truth(0.75)
        _Breaks = _Breaks or 0

        -- Added Very Very Small chance for station wrecks to spawn.
        if not _Plan then local _Dice = Rand.Float(0, 1)
            if _Dice < 0.005 then       _Plan = PlanGen.makeFreighterPlan(_Faction) -- PlanGen.makeStationPlan(_Faction, self.Station())
            elseif _Dice < 0.40 then    _Plan = PlanGen.makeShipPlan(_Faction)
            else                        _Plan = PlanGen.makeFreighterPlan(_Faction) end
        end
    
        -- Adjust Material
        Plan.Obj = _Plan
        Plan.Material()

        local _Wreckage = Sector():createWreckage(Plan.Get(), _Position)
        _Wreckage:setValue("SDKScrapyardWreckage", true)
        --broadcastInvokeClientFunction("Animation", _Wreckage)
        return _Wreckage
        
    end

    
    --function SDKScrapyardExtension.BreaksByVolume(_Volume)
    --    local _Breaks = math.floor(_volume / 7000)
    --    return _Breaks
    --end
    
end
]]
