SDKAsyncUtility = {}

SDKAsyncUtility.Ship         = "SDKAsyncGeneratedShip"
SDKAsyncUtility.Defender     = "SDKAsyncGeneratedDefender"
SDKAsyncUtility.Carrier      = "SDKAsyncGeneratedCarrier"
SDKAsyncUtility.Military     = "SDKAsyncGeneratedMilitary"
SDKAsyncUtility.Trader       = "SDKAsyncGeneratedTrader"
SDKAsyncUtility.Miner        = "SDKAsyncGeneratedMiner"
SDKAsyncUtility.Salvager     = "SDKAsyncGeneratedSalvager"
SDKAsyncUtility.Civilian     = "SDKAsyncGeneratedCivilian"
SDKAsyncUtility.Drone        = "SDKAsyncGeneratedDrone"
SDKAsyncUtility.CrewTransport = "SDKAsyncGeneratedCrewTransport"

--[[
    Settings Object that is passed to the Generate() function configuring the ship
    that is being built.

    sn = Style Name
    vl = Volume
    mt = Material
    ti = Ships Title
    at = Arrival Type
    cb = Callback Function

    Returns a configured Settings Object 
]]
function SDKAsyncUtility.Settings(sn, vl, mt, ti, at, cb)
    local o = {}
    o.style = sn
    o.volume = vl
    o.material = mt
    o.title = ti
    o.arrival = at
    o.callback = cb
    return o
end

return SDKAsyncUtility