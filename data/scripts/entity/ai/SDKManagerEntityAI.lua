local Logging = include("SDKDebugLogging")
Logging.Debugging = 0
Logging.ModName = "SDK Background Sector Manager"

-- namespace SDKManagerEntityAI
SDKManagerEntityAI = {} local self = SDKManagerEntityAI
self.Log = Logging

-- Order States
self._None = 0

-- Working Data
self.Data = {}
self.Data.OrderCurrent = self._None
self.Data.OrderStored = self._None
self.DangerStandoff = 0                 -- 0km Default

-- Save / Load Data
function ArtifactShip.secure() return self.Data end
function ArtifactShip.restore(_Data) self.Data = _Data end

function SDKManagerEntityAI.initialize(_Order, _ResumeOld) local _Method = "Initialize"

end

function SDKManagerEntityAI.update(_TimeStep) local _Method = "Update"
    
    if onServer() then

    end

    if onClient() then

    end

end