package.path = package.path .. ";data/scripts/lib/?.lua"
package.path = package.path .. ";data/scripts/?.lua"

local Logging = include("SDKDebugLogging")
local Chat = include("SDKUtilityMessenger")
Logging.ModName = "Messenger Utility"
Logging.Debugging = 0

SDKChatSensors = {}

SDKChatSensors.Log = Logging

-- Working Variables
SDKChatSensors.TargetPlayer = nil
SDKChatSensors.TargetSector = nil

-- Variable Keywords
SDKChatSensors.Key0 = {"detected", "identified", "logged", "recorded"}
SDKChatSensors.Key1 = {"short", "small", "slight", "minor"}
SDKChatSensors.Key2 = {"signals", "noise", "disturbance"}
SDKChatSensors.Key3 = {"unknown", "irregular", "abnormal", "anomolous", "anomalous", "atypical"}
SDKChatSensors.Key4 = {"caution", "warning", "attention", "alert"}
SDKChatSensors.Key5 = {"large", "massive", "enormous", "vast", "huge", "immense"}
SDKChatSensors.Key6 = {"growing", "increaseing", "elevating"}

function SDKChatSensors.Name() return "[Sensors]" end

--[[
    Sets the target.
    e = (Entity) Player Target
]]
function SDKChatSensors.TargetPlayer(e)
    if not e then return end
    if not valid(e) then return end
    SDKChatSensors.TargetPlayer = e
end

function SDKChatSensors.ClearPlayer()
    SDKChatSensors.TargetPlayer = nil
end

--[[
    Sets the target.
    e = (Entity) Sector Target
]]
function SDKChatSensors.TargetSector(e)
    if not e then return end
    if not valid(e) then return end
    SDKChatSensors.TargetPlayer = e
end

function SDKChatSensors.ClearSector()
    SDKChatSensors.TargetSector = nil
end

--[[
    Selects a Variable Keywork from a list of words.
    K = (Keyworkds) A list of keywords
    U = (Uppercase) true = first letter to uppercase
]]
function SDKChatSensors.Key(K, U)
    local _Max = Chat.TableLegnth(K)
    if _Max > 0 then 
        local _Text = K[Chat.Rand.Int(1, _Max)]         -- Pick Random Key from table
            if U then _Text = Chat.FirstToUpper(_Text)  -- Upper Case the first Letter
        end return _Text                                -- Return Text
    end return "(No Key Returned)"                      -- Something went Wrong
end

-- Message List
function SDKChatSensors.ShortBurst()
    local s = Chat.Rand.Int(1, 4) -- Randomly Pick One
    if s == 1 then       return "[Sensors] " .. SDKChatSensors.Key(SDKChatSensors.Key1, true) .. " bursts of subspace " .. SDKChatSensors.Key(SDKChatSensors.Key2) .. " " .. SDKChatSensors.Key(SDKChatSensors.Key0) .. "."
    elseif s == 2 then   return "[Sensors] " .. SDKChatSensors.Key(SDKChatSensors.Key1, true) .. " subspace " .. SDKChatSensors.Key(SDKChatSensors.Key2) .. " " .. SDKChatSensors.Key(SDKChatSensors.Key0) .. "."
    elseif s == 3 then   return "[Sensors] " .. SDKChatSensors.Key(SDKChatSensors.Key1, true) .. " " ..  SDKChatSensors.Key(SDKChatSensors.Key3) .. " subspace " .. SDKChatSensors.Key(SDKChatSensors.Key2) .. " " .. SDKChatSensors.Key(SDKChatSensors.Key0) .. "."
    else                 return "[Sensors] " .. SDKChatSensors.Key(SDKChatSensors.Key3, true) .. " " .. " subspace " .. SDKChatSensors.Key(SDKChatSensors.Key2) .. " " .. SDKChatSensors.Key(SDKChatSensors.Key0) .. "."
    end
end

function SDKChatSensors.SignalGrowing()
    local s = Chat.Rand.Int(1, 3) -- Randomly Pick One
    if s == 1 then       return "[Sensors] " .. "Subspace " .. SDKChatSensors.Key(SDKChatSensors.Key2) .. " " .. SDKChatSensors.Key(SDKChatSensors.Key6) .. "."
    elseif s == 2 then   return "[Sensors] " .. SDKChatSensors.Key(SDKChatSensors.Key6, true) .. " " .. SDKChatSensors.Key(SDKChatSensors.Key3) .. " subspace " .. SDKChatSensors.Key(SDKChatSensors.Key2) .. " " .. SDKChatSensors.Key(SDKChatSensors.Key0) .. "."
    else                 return "[Sensors] " .. SDKChatSensors.Key(SDKChatSensors.Key3, true) .. " " .. " subspace " .. SDKChatSensors.Key(SDKChatSensors.Key2) .. " " .. SDKChatSensors.Key(SDKChatSensors.Key6) .. "."
    end
end

function SDKChatSensors.SignalWarning()
    return "[Sensors] " .. SDKChatSensors.Key(SDKChatSensors.Key5, true) .. " " .. " subspace " .. SDKChatSensors.Key(SDKChatSensors.Key2) .. " " .. SDKChatSensors.Key(SDKChatSensors.Key0) .. "."
end

function SDKChatSensors.SignalWarningAlert()
    return "[Sensors] " .. SDKChatSensors.Key(SDKChatSensors.Key4, true) .. " " .. SDKChatSensors.Key(SDKChatSensors.Key5) .. " " .. " subspace " .. SDKChatSensors.Key(SDKChatSensors.Key2) .. " " .. SDKChatSensors.Key(SDKChatSensors.Key0) .. "."
end

function SDKChatSensors.XsotanGroupSmall()
    return "[Sensors] " .. "Small group of Unknown ships have dropped out of Subspace!"
end

function SDKChatSensors.XsotanGroupMed()
    return "[Sensors] " .. "Group of Unknown ships have dropped out of Subspace!"
end

function SDKChatSensors.XsotanGroupLarge()
    return "[Sensors] " .. "Large group of Unknown ships have dropped out of Subspace!"
end

function SDKChatSensors.XsotanGroupHuge()
    return "[Sensors] " .. "Danger! Large fleet of Unknown ships have dropped out of Subspace!"
end

return SDKChatSensors