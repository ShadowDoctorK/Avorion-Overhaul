package.path = package.path .. ";data/scripts/lib/?.lua"

include ("randomext")

-- Don't remove or alter the following comment, it tells the game the namespace this script lives in. If you remove it, the script will break.
-- namespace Quantum
Quantum = {}
local self = Quantum

self.FallbackJump = true
self.FallBackCounter = 0
self.OverCharge = 0
self.OverLimit = 5
self.CascadeCharge = 0
self.CascadeLimit = 0
self.ChargeCounter = 0
self.ChargeLimit = 0
self.TryJump = false

function Quantum.initialize()
    if onServer() then
        self.Limits()
        local entity = Entity()
        entity:registerCallback("onHullHit", "onHit")
        entity:registerCallback("onShieldHit", "onHit")
    end
end

function Quantum.Limits()
    local _ChargeLimit = 10
    local _CascadeLimit = 2

    -- Adjust based on Difficulty
    local _Settings = GameSettings()
    if _Settings.difficulty == Difficulty.Insane then 
        _CascadeLimit = 6 _ChargeLimit = 8
    elseif _Settings.difficulty == Difficulty.Hardcore then 
        _CascadeLimit = 5 _ChargeLimit = 9
    elseif _Settings.difficulty == Difficulty.Expert then 
        _CascadeLimit = 4 _ChargeLimit = 10
    elseif _Settings.difficulty == Difficulty.Veteran then 
        _CascadeLimit = 3 _ChargeLimit = 11
    elseif _Settings.difficulty == Difficulty.Normal then 
        _CascadeLimit = 3 _ChargeLimit = 12
    elseif _Settings.difficulty == Difficulty.Easy then 
        _CascadeLimit = 3 _ChargeLimit = 13
    end
    self.CascadeLimit = _CascadeLimit
    self.ChargeLimit = _ChargeLimit   
    -- Set Initial Charges 
    self.CascadeCharge = _CascadeLimit
end

function Quantum.getUpdateInterval()
    if self.CascadeCharge <= 1 then     return random():getFloat(0.5, 3)
    elseif self.CascadeCharge <= 2 then  return random():getFloat(3, 5) end
    return random():getFloat(5, 7)
end

function Quantum.updateServer(timeStep)

    --print("Quantum Timestep: " .. tostring(timeStep))
    --print("Quantum Charge Counter: " .. tostring(self.ChargeCounter))
    --print("Quantum Cascade Charges: " .. tostring(self.CascadeCharge))
    --print("Quantum Over Charges: " .. tostring(self.OverCharge))

    self.FallBackCounter = self.FallBackCounter + timeStep
    if self.FallBackCounter >= 30 then self.FallbackJump = true self.FallBackCounter = 0 end

    -- Accumulate the variable Charge Count based on the Update Interval
    self.ChargeCounter = self.ChargeCounter + timeStep  

    -- See if we earned a new Cascade Charge
    if self.ChargeCounter >= self.ChargeLimit then
        self.ChargeCounter = self.ChargeCounter - self.ChargeLimit

        -- Add charges up to the limit for the difficulty
        if self.CascadeCharge < self.CascadeLimit then
            self.CascadeCharge = self.CascadeCharge + 1
        elseif self.OverCharge < self.OverLimit then
            self.OverCharge = self.OverCharge + 1
        end        

    end
    
    if self.TryJump then self.TryJump = false

        -- No Charges, Cant Jump
        if self.CascadeCharge <= 0 then return end
        self.CascadeCharge = self.CascadeCharge - 1
        --print("Jumping Via Update Server...")
        self.Jump()
    end    

end

function Quantum.Jump()
    local entity = Entity()
    local distance = entity.radius * (2 + random():getFloat(0, 3))
    local direction = random():getDirection()

    broadcastInvokeClientFunction("animation", direction)

    entity.translation = dvec3(entity.translationf + direction * distance)
end

function Quantum.animation(direction)
    Sector():createHyperspaceAnimation(Entity(), direction, ColorRGB(0.6, 0.5, 0.3), 0.2)
end

function Quantum.onHit()
    self.TryJump = true
    if self.CascadeCharge > 0 then
        deferredCallback(random():getFloat(0, 1.5), "updateServer", 0)
    end

    if self.OverCharge > 0 and random():test(0.5) then
        --print("Jumping Via Over Charge Chance...")
        self.cascade(self.OverCharge)
        self.OverCharge = 0
    elseif self.FallbackJump and random():test(0.005) then
        --print("Jumping Via Fall Back Chance...")
        self.cascade(3)
        self.FallbackJump = false
    end
end

function Quantum.cascade(amount)
    if amount < 0 then return end
    deferredCallback(0.4, "cascade", amount - 1)
    self.Jump()
end
