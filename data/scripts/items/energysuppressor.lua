package.path = package.path .. ";data/scripts/lib/?.lua"
package.path = package.path .. ";data/scripts/?.lua"

local PlanGenerator = include("plangenerator")
include("stringutility")

-- Modified the tooptip lines
function create(item, rarity)

    rarity = Rarity(RarityType.Exceptional)

    item.stackable = true
    item.depleteOnUse = true
    item.name = "Energy Suppressor Satellite"%_T
    item.price = 100000
    item.icon = "data/textures/icons/satellite.png"
    item.rarity = rarity
    item:setValue("subtype", "EnergySuppressor")

    local tooltip = Tooltip()
    tooltip.icon = item.icon
    tooltip.rarity = rarity

    local title = "Energy Suppression Satellite"%_T

    local headLineSize = 25
    local headLineFontSize = 15
    local line = TooltipLine(headLineSize, headLineFontSize)
    line.ctext = title
    line.ccolor = rarity.tooltipFontColor
    tooltip:addLine(line)

    -- empty line
    local line = TooltipLine(14, 14)
    tooltip:addLine(line)

    local line = TooltipLine(18, 14)
    line.ltext = "Time"%_t
    line.rtext = "10h"%_t
    line.icon = "data/textures/icons/recharge-time.png"
    line.iconColor = ColorRGB(0.8, 0.8, 0.8)
    tooltip:addLine(line)

    -- empty line
    local line = TooltipLine(14, 14)
    tooltip:addLine(line)

    local line = TooltipLine(18, 14)
    line.ltext = "Deployable Object"%_T
    line.lcolor = ColorRGB(0.1, 0.75, 0.75)
    tooltip:addLine(line)

    local line = TooltipLine(14, 14)
    tooltip:addLine(line)

    local line = TooltipLine(18, 14)
    line.ltext = "Deploy this satellite in a sector to"%_T
    tooltip:addLine(line)

    local line = TooltipLine(18, 14)
    line.ltext = "suppress energy signatures and hide"%_T
    tooltip:addLine(line)

    local line = TooltipLine(18, 14)
    line.ltext = "activity from anyone outside the area."%_T
    tooltip:addLine(line)

    local line = TooltipLine(14, 14)
    tooltip:addLine(line)

    local line = TooltipLine(14, 14)
    line.ltext = "ArcTech Inc. Products ~ Shadow Doctor K"%_t
    line.lcolor = ColorRGB(0.811, 0.145, 0.913)
    tooltip:addLine(line)

    item:setTooltip(tooltip)

    return item
end

local function getPositionInFront(craft, distance)

    local position = craft.position
    local right = position.right
    local dir = position.look
    local up = position.up
    local position = craft.translationf

    local pos = position + dir * (craft.radius + distance)

    return MatrixLookUpPosition(right, up, pos)
end

-- Modified Plan Section
function activate(item)

    local craft = Player().craft
    if not craft then return false end

    local desc = EntityDescriptor()
    desc:addComponents(
       ComponentType.Plan,
       ComponentType.BspTree,
       ComponentType.Intersection,
       ComponentType.Asleep,
       ComponentType.DamageContributors,
       ComponentType.BoundingSphere,
       ComponentType.BoundingBox,
       ComponentType.Velocity,
       ComponentType.Physics,
       ComponentType.Scripts,
       ComponentType.ScriptCallback,
       ComponentType.Title,
       ComponentType.Owner,
       ComponentType.Durability,
       ComponentType.PlanMaxDurability,
       ComponentType.InteractionText,
       ComponentType.EnergySystem
       )

    local faction = Faction(craft.factionIndex)
    
    local Plan = PlanGenerator.GetBlockPlan()
    local Volume = PlanGenerator.GetVolume()
    
    if Plan.Pick(PlanGenerator.GlobalSataliteTable()) then
        Plan.Material(MaterialType.Iron, "Force")
        Plan.Scale(Volume.Get(2, 2))
        Plan.AccumulatingHealth(true)
    else
        print("Failed to Load Satalite Plan...")
    end

    desc.position = getPositionInFront(craft, 30)
    desc:setMovePlan(Plan.Get())
    desc.factionIndex = faction.index

    local satellite = Sector():createEntity(desc)
    satellite:addScript("entity/energysuppressor.lua")

    return true
end
