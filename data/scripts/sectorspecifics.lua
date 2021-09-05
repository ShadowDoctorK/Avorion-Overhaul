--[[
function SectorSpecifics:addTemplate(path)
    local template = include(path)
    template.path = path

    table.insert(self.templates, template)
end
]]

function SectorSpecifics:addTemplates()

    if self.templates then return end
    self.templates = {}

    self:addBaseTemplates()
    self:addMoreTemplates()

    -- Add Custom Sectors
    self:addTemplate("sectors/SDKLoneScrapyard")
    self:addTemplate("sectors/SDKAsteroidMegaFieldMiner")
    self:addTemplate("sectors/SDKMilitaryStronghold")
end

function SectorSpecifics:addBaseTemplates()
    -- first position is reserved, it's used for faction's home sectors. don't change this
    self:addTemplate("sectors/colony")
    self:addTemplate("sectors/asteroidfieldminer")
    self:addTemplate("sectors/loneconsumer")
    -- self:addTemplate("sectors/lonescrapyard")
    self:addTemplate("sectors/loneshipyard")
    self:addTemplate("sectors/lonetrader")
    self:addTemplate("sectors/lonetradingpost")
    self:addTemplate("sectors/lonewormhole")
    self:addTemplate("sectors/factoryfield")
    self:addTemplate("sectors/miningfield")
    self:addTemplate("sectors/gates")
    self:addTemplate("sectors/ancientgates")
    self:addTemplate("sectors/neutralzone")

    self:addTemplate("sectors/pirateasteroidfield")
    self:addTemplate("sectors/piratefight")
    self:addTemplate("sectors/piratestation")

    self:addTemplate("sectors/asteroidfield")
    self:addTemplate("sectors/containerfield")
    self:addTemplate("sectors/massivecontainerfield")
    self:addTemplate("sectors/smallasteroidfield")
    self:addTemplate("sectors/wreckagefield")
    self:addTemplate("sectors/stationwreckage")
    self:addTemplate("sectors/smugglerhideout")
    self:addTemplate("sectors/cultists")
    self:addTemplate("sectors/wreckageasteroidfield")
    self:addTemplate("sectors/researchsatellite")
    self:addTemplate("sectors/functionalwreckage")
    self:addTemplate("sectors/asteroidshieldboss")

    self:addTemplate("sectors/xsotanasteroids")
    self:addTemplate("sectors/xsotantransformed")
    self:addTemplate("sectors/xsotanbreeders")
    self:addTemplate("sectors/resistancecell")

    self:addTemplate("sectors/teleporter")
end