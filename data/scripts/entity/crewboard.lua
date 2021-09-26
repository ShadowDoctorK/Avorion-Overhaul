--[[
    Dev Notes:
    Changed the normal Async Ship Generator to my custom one to allow targeting Crew Transport designs.
]]

-- Unmodified Code
  --[[
    package.path = package.path .. ";data/scripts/lib/?.lua"
    include ("galaxy")
    include ("utility")
    include ("stringutility")
    include ("faction")
    include ("player")
    include ("merchantutility")
    include ("callable")
    include ("randomext")
    local AsyncShipGenerator = include("asyncshipgenerator")
    local CaptainGenerator = include("captaingenerator")
    local CaptainUtility = include("captainutility")
    local Placer = include ("placer");

    !! DELETED THE NAME SPACE LINE !!

    CrewBoard = {}

    local uiGroups = {}
    local captainProfile
    local noCaptainLabel
    local captainPriceLabel
    local captainHireButton
    local requestTransportButton
    local transportPriceLabel
    local transportETALabel
    local uiInitialized
    local workforceUI = {}
    local currentCrewLabel

    local transportData

    local availableCaptain = nil
    local availableCrew = {}

    local requiredRelations = {}
    requiredRelations[CrewProfessionType.None] = nil
    requiredRelations[CrewProfessionType.Engine] = nil
    requiredRelations[CrewProfessionType.Repair] = nil
    requiredRelations[CrewProfessionType.Gunner] = nil
    requiredRelations[CrewProfessionType.Miner] = nil
    requiredRelations[CrewProfessionType.Pilot] = 15000
    requiredRelations[CrewProfessionType.Security] = 15000
    requiredRelations[CrewProfessionType.Attacker] = 15000


    -- if this function returns false, the script will not be listed in the interaction window on the client,
    -- even though its UI may be registered
    function CrewBoard.interactionPossible(playerIndex, option)
        local player = Player(playerIndex)
        local ship = player.craft
        if not ship then return false end
        if not ship:hasComponent(ComponentType.Crew) then return false end

        return CheckFactionInteraction(playerIndex, -25000)
    end

    -- this function gets called on creation of the entity the script is attached to, on client and server
    function CrewBoard.initialize()
        if not onServer() then return end

        local scaling = 1
        if Server().infiniteResources then
            scaling = 50
        else
            local x, y = Sector():getCoordinates()

            local d = length(vec2(x, y))
            scaling = 1 + ((1 - (d / 450)) * 5)
        end

        scaling = math.max(1, scaling)

        local probabilities = {}
        table.insert(probabilities, {profession = CrewProfessionType.None, probability = 1.0, number = math.floor(random():getInt(30, 40) * scaling)})
        table.insert(probabilities, {profession = CrewProfessionType.Engine, probability = 0.5, number = math.floor(random():getInt(5, 15) * scaling)})
        table.insert(probabilities, {profession = CrewProfessionType.Repair, probability = 0.5, number = math.floor(random():getInt(5, 15) * scaling)})
        table.insert(probabilities, {profession = CrewProfessionType.Gunner, probability = 0.5, number = math.floor(random():getInt(5, 10) * scaling)})
        table.insert(probabilities, {profession = CrewProfessionType.Miner, probability = 0.5, number = math.floor(random():getInt(5, 10) * scaling)})
        table.insert(probabilities, {profession = CrewProfessionType.Pilot, probability = 0.5, number = math.floor(random():getInt(3, 10) * scaling)})
        table.insert(probabilities, {profession = CrewProfessionType.Security, probability = 0.5, number = math.floor(random():getInt(3, 10) * scaling)})
        table.insert(probabilities, {profession = CrewProfessionType.Attacker, probability = 0.25, number = math.floor(random():getInt(3, 10) * scaling)})

        local station = Entity()
        -- crew for specific stations
        if station:hasScript("shipyard.lua") or
                station:hasScript("repairdock.lua") then
            CrewBoard.setProbability(probabilities, CrewProfessionType.Repair)
            CrewBoard.setProbability(probabilities, CrewProfessionType.Engine)
        --military outpost only generates military, officers and non-specified crew
        elseif station:hasScript("militaryoutpost.lua") then
            CrewBoard.setProbability(probabilities, CrewProfessionType.Engine, 0)
            CrewBoard.setProbability(probabilities, CrewProfessionType.Repair, 0)
            CrewBoard.setProbability(probabilities, CrewProfessionType.Gunner, 0.5)
            CrewBoard.setProbability(probabilities, CrewProfessionType.Miner, 0)
            CrewBoard.setProbability(probabilities, CrewProfessionType.Pilot, 0.5)
            CrewBoard.setProbability(probabilities, CrewProfessionType.Security, 0.5)
            CrewBoard.setProbability(probabilities, CrewProfessionType.Attacker, 0.5)
        elseif station:hasScript("researchstation.lua") or
                station:hasScript("turretfactory.lua") or
                station:hasScript("fighterfactory.lua") then
            CrewBoard.setProbability(probabilities, CrewProfessionType.Engine)
            CrewBoard.setProbability(probabilities, CrewProfessionType.Gunner)

            if station:hasScript("fighterfactory.lua") then
                CrewBoard.setProbability(probabilities, CrewProfessionType.Pilot)
            end
        elseif station:hasScript("headquarters.lua") then
            CrewBoard.setProbability(probabilities, CrewProfessionType.Engine, 0)
            CrewBoard.setProbability(probabilities, CrewProfessionType.Repair, 0)
            CrewBoard.setProbability(probabilities, CrewProfessionType.Miner, 0)
            CrewBoard.setProbability(probabilities, CrewProfessionType.Attacker, 0.4)
        elseif station:hasScript("planetarytradingpost.lua") then
            CrewBoard.setProbability(probabilities, CrewProfessionType.Pilot)
        elseif station:hasScript("tradingpost.lua") then
            CrewBoard.setProbability(probabilities, CrewProfessionType.None)
            CrewBoard.setProbability(probabilities, CrewProfessionType.Security)
        elseif station:hasScript("equipmentdock.lua") then
            CrewBoard.setProbability(probabilities, CrewProfessionType.Gunner)
            CrewBoard.setProbability(probabilities, CrewProfessionType.Miner)
            CrewBoard.setProbability(probabilities, CrewProfessionType.Pilot)
        elseif station:hasScript("smugglersmarket.lua") then
            CrewBoard.setProbability(probabilities, CrewProfessionType.Security)
            CrewBoard.setProbability(probabilities, CrewProfessionType.Attacker, 0.5)
        elseif station:getValue("factory_type") == "mine" then
            CrewBoard.setProbability(probabilities, CrewProfessionType.Miner)
        end

        -- first insert all with probability >= 1
        for _, crew in pairs(probabilities) do
            if crew.probability >= 1.0 and #availableCrew < 6 then
                table.insert(availableCrew, crew)
            end
        end

        for _, crew in pairs(probabilities) do
            if crew.probability < 1.0 and random():test(crew.probability) and #availableCrew < 6 then
                table.insert(availableCrew, crew)
            end
        end

        -- generate a captain
        availableCaptain = nil
        if random():test(0.35) then
            local tiers = {}
            tiers[0] = 0.5
            tiers[1] = 0.3
            tiers[2] = 0.2

            local tier = selectByWeight(random(), tiers)
            local primary = nil
            if tier > 0 then
                if station:hasScript("militaryoutpost.lua") then
                    primary = CaptainUtility.ClassType.Commodore
                elseif station:hasScript("researchstation.lua") or station:hasScript("travelhub.lua") then
                    primary = CaptainUtility.ClassType.Explorer
                elseif station:hasScript("scrapyard.lua") then
                    primary = CaptainUtility.ClassType.Scavenger
                elseif station:hasScript("smugglersmarket.lua") then
                    primary = CaptainUtility.ClassType.Smuggler
                elseif station:hasScript("tradingpost.lua") then
                    primary = CaptainUtility.ClassType.Merchant
                elseif station:getValue("factory_type") == "mine" then
                    primary = CaptainUtility.ClassType.Miner
                end
            end

            availableCaptain = CaptainGenerator():generate(tier, nil, primary)
        end
    end

    function CrewBoard.setProbability(probabilities, profession, p)
        if not p then p = 1 end

        for _, crew in pairs(probabilities) do
            if crew.profession == profession then
                crew.probability = p
                return
            end
        end
    end

    -- this function gets called on creation of the entity the script is attached to, on client only
    -- AFTER initialize above
    -- create all required UI elements for the client side
    function CrewBoard.initUI()

        local res = getResolution()

        local size = vec2(770, 580)

        local menu = ScriptUI()
        local window = menu:createWindow(Rect(size));
        menu:registerWindow(window, "Hire Crew"%_t, 4);

        window.caption = "Hire Crew"%_t
        window.showCloseButton = 1
        window.moveable = 1
        window:center()

        local chsplit = UIHorizontalSplitter(Rect(vec2(0, 10), size), 20, 10, 0.8)
        chsplit.topSize = 90
        chsplit.marginTop = 0

        local vsplit = UIVerticalSplitter(chsplit.top, 10, 0, 0.5)
        vsplit.rightSize = 150
        captainProfile = window:createCaptainProfile(vsplit.left)

        local organizer = UIOrganizer(chsplit.top)
        organizer.marginLeft = 150
        organizer.marginRight = 200
        organizer.marginTop = 40
        noCaptainLabel = window:createLabel(organizer.inner, "There are currently no captains looking for work at this station."%_t, 12)
        noCaptainLabel:setTopAligned()
        noCaptainLabel.wordBreak = true
        noCaptainLabel.color = ColorRGB(0.75, 0.75, 0.75)

        local hsplit = UIHorizontalSplitter(vsplit.right, 10, 0, 0.5)
        hsplit.bottomSize = 30
        captainHireButton = window:createButton(hsplit.bottom, "Hire"%_t, "onHireCaptainButtonPressed")
        captainPriceLabel = window:createLabel(hsplit.top, "", 16)
        captainPriceLabel:setBottomAligned();

        captainHireButton.active = false

        local hsplit = UIHorizontalSplitter(chsplit.bottom, 10, 0, 0.8)
        local lister = UIVerticalLister(hsplit.top, 10, 10)

        local padding = 10
        local iconSize = 30
        local barSize = 200
        local sliderSize = 210
        local amountBoxSize = 50
        local priceSize = 60
        local buttonSize = 140

        local iconX = 15
        local barX = iconX + iconSize + padding
        local sliderX = barX + barSize + padding
        local amountBoxX = sliderX + sliderSize + padding
        local priceX = amountBoxX + amountBoxSize + padding
        local buttonX = priceX + priceSize + padding

        for i = 0, 5 do
            local rect = lister:nextRect(30)

            local pic = window:createPicture(Rect(iconX, rect.lower.y, iconX + iconSize, rect.upper.y), "")
            local bar = window:createCrewBar(Rect(barX, rect.lower.y, barX + barSize, rect.upper.y))
            bar.visiblePerCategory = 2
            local slider = window:createSlider(Rect(sliderX, rect.lower.y, sliderX + sliderSize, rect.upper.y), 0, 15, 15, "", "onSliderChanged")
            slider.showMaxValue = true
            local box = window:createTextBox(Rect(amountBoxX, rect.lower.y, amountBoxX + amountBoxSize, rect.upper.y), "onAmountEntered")
            box.allowedCharacters = "0123456789"
            box.text = slider.value
            local label = window:createLabel(Rect(priceX, rect.lower.y, priceX + priceSize, rect.upper.y), "", 16)
            label:setRightAligned()
            label.fontSize = 12
            local button = window:createButton(Rect(buttonX, rect.lower.y, buttonX + buttonSize, rect.upper.y), "Hire"%_t, "onHireButtonPressed")
            button.textSize = 14

            local hide = function (self)
                self.bar:hide()
                self.pic:hide()
                self.slider:hide()
                self.box:hide()
                self.label:hide()
                self.button:hide()
            end

            local show = function (self)
                self.bar:show()
                self.pic:show()
                self.slider:show()
                self.box:show()
                self.label:show()
                self.button:show()
            end

            table.insert(uiGroups, {pic=pic, bar=bar, slider=slider, box=box, label=label, button=button, show=show, hide=hide})
        end

        -- current workforce
        currentCrewLabel = window:createLabel(lister:nextRect(25), "", 14)
        currentCrewLabel:setBottomLeftAligned()

        for row = 0, 1 do
            local workforceSplit = UIVerticalMultiSplitter(lister:nextRect(25), 10, 0, 3)

            for i = 0, 3 do
                local professionIndex = i + row * 4

                local profession = CrewProfession(professionIndex)
                local split = UIVerticalSplitter(workforceSplit:partition(i), 10, 0, 0.5)
                split:setLeftQuadratic()

                local picture = window:createPicture(split.left, profession.icon)
                picture.isIcon = true
                local label = window:createLabel(split.right, "", 14)
                label:setLeftAligned()

                workforceUI[professionIndex] = {picture = picture, label = label}
            end
        end

        window:createLine(hsplit.top.bottomLeft, hsplit.top.bottomRight)

        -- crew transport
        local hsplit2 = UIHorizontalSplitter(hsplit.bottom, 10, 0, 0.4)
        local vmsplit = UIVerticalMultiSplitter(hsplit2.bottom, 10, 0, 2)

        requestTransportButton = window:createButton(vmsplit:partition(2), "Request Transport"%_t, "onRequestTransportButtonPressed")

        local label = window:createLabel(hsplit2.top, "You can request a crew transport ship here containing a complete crew for your current ship.\nOnly possible if your ship needs at least 100 more crew members."%_t, 12)
        label.font = FontType.Normal
        label.wordBreak = true

        transportPriceLabel = window:createLabel(vmsplit:partition(1), "", 14)
        transportPriceLabel.centered = true
        transportPriceLabel.position = transportPriceLabel.position + vec2(0, 10)

        transportETALabel = window:createLabel(vmsplit:partition(0), "", 14)
        transportETALabel.centered = true
        transportETALabel.position = transportETALabel.position + vec2(0, 10)

        CrewBoard.sync()

        uiInitialized = true
    end

    function CrewBoard.onSliderChanged(slider)
        local stationFaction = Faction()
        local buyer = Player()
        local playerCraft = buyer.craft
        if playerCraft.factionIndex == buyer.allianceIndex then
            buyer = buyer.alliance
        end

        for i, group in pairs(uiGroups) do
            if group.slider.index == slider.index and availableCrew[i] then
                group.box.text = slider.value

                local profession = CrewProfession(availableCrew[i].profession)
                local price = CrewBoard.getPriceAndTax(profession, group.slider.value, stationFaction, buyer)
                group.label.caption = "¢${price}"%_t % {price = createMonetaryString(price)}
            end
        end
    end

    function CrewBoard.onAmountEntered(box)
        local stationFaction = Faction()
        local buyer = Player()
        local playerCraft = buyer.craft
        if playerCraft.factionIndex == buyer.allianceIndex then
            buyer = buyer.alliance
        end

        for i, group in pairs(uiGroups) do
            if group.box.index == box.index and availableCrew[i] then
                group.slider.value = box.text

                local profession = CrewProfession(availableCrew[i].profession)
                local price = CrewBoard.getPriceAndTax(profession, group.slider.value, stationFaction, buyer)
                group.label.caption = "¢${price}"%_t % {price = createMonetaryString(price)}
            end
        end
    end


    -- called on client
    function CrewBoard.refreshUI(lineToReset)
        if not uiInitialized then return end

        if availableCaptain then
            captainPriceLabel.caption = "¢${price}"%_t % {price = createMonetaryString(availableCaptain.hiringPrice)}
        end

        captainProfile:setCaptain(availableCaptain)
        captainPriceLabel.visible = (availableCaptain ~= nil)
        captainHireButton.active = (availableCaptain ~= nil)
        noCaptainLabel.visible = (availableCaptain == nil)

        local ship = Player().craft

        if ship.maxCrewSize == nil or ship.crewSize == nil then
            return
        end

        local placesOnShip = ship.maxCrewSize - ship.crewSize

        for _, group in pairs(uiGroups) do
            group:hide()
        end

        local faction = Faction(ship.factionIndex)
        local ownFaction = Faction()
        if not valid(ownFaction) or not valid(faction) then return end

        for i, pair in pairs(availableCrew) do
            local profession = CrewProfession(pair.profession)
            local number = pair.number

            local group = uiGroups[i]
            if not group then break end

            group:show()

            group.pic.isIcon = 1
            group.pic.picture = profession.icon
            group.pic.tooltip = profession:name(number) .. "\n" .. profession.description

            local specialist = profession.value ~= CrewProfessionType.None
            local crewman = CrewMan(profession, specialist, 1)
            group.bar:setCrewmen(crewman, number)

            if i == lineToReset then
                group.slider:setValueNoCallback(0)
            end
            group.slider.min = 0
            group.slider.max = math.max(0, number)
            group.slider.segments = math.max(0, number)

            local color = profession.color
            color.value = color.value * 0.75
            group.slider.color = color

            color.saturation = color.saturation * 0.9
            group.slider.glowColor = color

            local canHire, msg, args = CrewBoard.canHireCrew(ship, i)
            if canHire then
                group.button.active = true
                group.button.tooltip = nil
            else
                group.button.active = false
                group.button.tooltip = Format(msg, unpack(args)):evaluate()
            end
        end

        -- current workforce
        local crew = ship.crew
        local currentWorkforce = {}
        for profession, amount in pairs(ship.crew:getWorkforce()) do
            currentWorkforce[profession.value] = amount
        end

        local minCrew = ship.idealCrew
        local minWorkforce = {}
        for profession, amount in pairs(minCrew:getWorkforce()) do
            minWorkforce[profession.value] = amount
        end

        currentCrewLabel.caption = "CURRENT CREW (${current}/${max})"%_t % {current = crew.size, max = crew.maxSize}

        for professionIndex, data in pairs(workforceUI) do
            local required = minWorkforce[professionIndex] or 0
            local available = currentWorkforce[professionIndex] or 0
            if required == 0 then
                data.label.caption = available
            else
                data.label.caption = "${workforce}/${required}"%_t % {workforce = available, required = required}
            end

            if required > available then
                data.label.color = ColorRGB(1, 1, 0)
            else
                data.label.color = ColorRGB(1, 1, 1)
            end

            data.picture.tooltip = CrewProfession(professionIndex):name(available)
        end

        -- crew transport
        local requestButtonActive = true

        local tooltip
        if minCrew.size - ship.crewSize < 100 then
            local amount = math.max(0, minCrew.size - ship.crewSize)

            requestButtonActive = false
            tooltip = "We don't require more than 100 additional crew members. Additionally required crew members: ${amount}"%_t % {amount = amount}
        elseif transportData then
            requestButtonActive = false
            tooltip = "There's already a transport on the way."%_t
        end

        requestTransportButton.active = requestButtonActive

        requestTransportButton.tooltip = tooltip

        local price = CrewBoard.getTransportPrice(Player(), Player().craft)
        transportPriceLabel.caption = "Price: ¢${price}"%_t % {price = createMonetaryString(price)}

    end

    function CrewBoard.onHireCaptainButtonPressed()
        invokeServerFunction("hireCaptain")
    end

    function CrewBoard.onHireButtonPressed(button)
        for i, group in pairs(uiGroups) do
            if group.button.index == button.index then
                local num = group.slider.value
                invokeServerFunction("hireCrew", i, num)
            end
        end
    end

    function CrewBoard.onRequestTransportButtonPressed(button)
        if onClient() then
            invokeServerFunction("onRequestTransportButtonPressed")
            return
        end

        local buyer, ship, player = getInteractingFaction(callingPlayer, AlliancePrivilege.SpendResources)
        if not buyer then return end

        local station = Entity()

        if not CheckFactionInteraction(player.index, 60000) then
            local sender = NamedFormat(station.title or "", station:getTitleArguments() or {})
            player:sendChatMessage(sender, ChatMessageType.Normal, "We only offer these kinds of services to people we have Excellent or better relations with."%_t)
            player:sendChatMessage("", ChatMessageType.Error, "Your relations with that faction aren't good enough."%_t)
            return
        end

        local costs, tax, missing = CrewBoard.getTransportPrice(buyer, ship)

        local canPay, msg, args = buyer:canPay(costs)
        if not canPay then
            local sender = NamedFormat(station.title or "", station:getTitleArguments() or {})
            player:sendChatMessage(sender, 1, msg, unpack(args))
            return
        end

        receiveTransactionTax(station, tax)
        buyer:pay("Paid %1% Credits to request a crew transport."%_T, costs);

        transportData = {}
        transportData.crew = missing
        transportData.craft = ship.id

        deferredCallback(30.0, "onCrewTransportTimerOver")
        local sender = NamedFormat(station.title or "", station:getTitleArguments() or {})
        player:sendChatMessage(sender, ChatMessageType.Normal, "Your crew transport is on the way and will be here in about 30 seconds."%_t)

        CrewBoard.sync()
    end
    callable(CrewBoard, "onRequestTransportButtonPressed")

    -- this function gets called every time the window is shown on the client, ie. when a player presses F and if interactionPossible() returned 1
    function CrewBoard.onShowWindow()
        local craft = Player().craft
        if craft then
            craft:registerCallback("onCrewChanged", "onCrewChanged")
        end

        CrewBoard.sync()
    end

    ---- this function gets called every time the window is closed on the client
    function CrewBoard.onCloseWindow()
        local craft = Player().craft
        if craft then
            craft:unregisterCallback("onCrewChanged", "onCrewChanged")
        end
    end

    function CrewBoard.onCrewChanged()
        CrewBoard.refreshUI()
    end


    function CrewBoard.sync(available, captain, transport, lineToReset)
        if onClient() then
            if not available then
                invokeServerFunction("sync");
            else
                availableCrew = available
                availableCaptain = captain
                transportData = transport
                CrewBoard.refreshUI(lineToReset)
            end
        else
            local transport
            if transportData then transport = {} end

            if callingPlayer then
                local player = Player(callingPlayer)
                invokeClientFunction(player, "sync", availableCrew, availableCaptain, transport)
            else
                broadcastInvokeClientFunction("sync", availableCrew, availableCaptain, transport)
            end
        end
    end
    callable(CrewBoard, "sync")

    function CrewBoard.hireCrew(i, num)
        if anynils(i, num) then return end

        local buyer, ship, player = getInteractingFaction(callingPlayer, AlliancePrivilege.SpendResources)
        if not buyer then return end

        local pair = availableCrew[i]
        if not pair then return end

        local profession = CrewProfession(pair.profession)
        num = math.min(num, pair.number)
        if num <= 0 then return end

        local station = Entity()
        local stationFaction = Faction()

        local costs, tax = CrewBoard.getPriceAndTax(profession, num, stationFaction, buyer)

        local canHire, msg, args = CrewBoard.canHireCrew(ship, i)
        if not canHire then
            local sender = NamedFormat(station.title or "", station:getTitleArguments() or {})
            player:sendChatMessage(sender, 1, msg, unpack(args))
            return
        end

        local canPay, msg, args = buyer:canPay(costs)
        if not canPay then
            local sender = NamedFormat(station.title or "", station:getTitleArguments() or {})
            player:sendChatMessage(sender, 1, msg, unpack(args))
            return
        end

        local canHire, msg, args = ship:canAddCrew(num, pair.profession, 0)
        if not canHire then
            local sender = NamedFormat(station.title or "", station:getTitleArguments() or {})
            player:sendChatMessage(sender, 1, msg, unpack(args))
            return
        end

        local errors = {}
        errors[EntityType.Station] = "You must be docked to the station to hire crew members."%_T
        errors[EntityType.Ship] = "You must be closer to the ship to hire crew members."%_T
        if not CheckPlayerDocked(player, station, errors) then
            return
        end

        receiveTransactionTax(station, tax)

        buyer:pay("Paid %1% Credits to hire crew."%_T, costs);

        ship:addCrew(num, CrewMan(profession, profession ~= CrewProfessionType.None, 1));

        pair.number = math.max(0, pair.number - num)

        invokeClientFunction(player, "sync", availableCrew, availableCaptain, nil, i)
    end
    callable(CrewBoard, "hireCrew")

    function CrewBoard.hireCaptain()
        if not availableCaptain then return end

        local buyer, ship, player = getInteractingFaction(callingPlayer, AlliancePrivilege.SpendResources)
        if not buyer then return end
        if not ship:hasComponent(ComponentType.Crew) then return end

        local station = Entity()
        local stationFaction = Faction()

        local costs, tax = CrewBoard.getCaptainPriceAndTax(availableCaptain, stationFaction, buyer)

        local canPay, msg, args = buyer:canPay(costs)
        if not canPay then
            local sender = NamedFormat(station.title or "", station:getTitleArguments() or {})
            player:sendChatMessage(sender, 1, msg, unpack(args))
            return
        end

        local crewComponent = CrewComponent(ship)
        if ship:getCaptain() then
            local canHire, msg, args = crewComponent:canAddPassenger(availableCaptain)
            if not canHire then
                local sender = NamedFormat(station.title or "", station:getTitleArguments() or {})
                player:sendChatMessage(sender, 1, msg, unpack(args))
                return
            end
        end

        local errors = {}
        errors[EntityType.Station] = "You must be docked to the station to hire crew members."%_T
        errors[EntityType.Ship] = "You must be closer to the ship to hire crew members."%_T
        if not CheckPlayerDocked(player, station, errors) then
            return
        end

        receiveTransactionTax(station, tax)

        buyer:pay("Paid %1% Credits to hire a captain."%_T, costs);

        if ship:getCaptain() then
            crewComponent:addPassenger(availableCaptain)
        else
            crewComponent:setCaptain(availableCaptain)
        end

        availableCaptain = nil

        CrewBoard.sync()
    end
    callable(CrewBoard, "hireCaptain")

    function CrewBoard.canHireCrew(ship, i)
        if anynils(ship, i) then return false, "" end

        local pair = availableCrew[i]

        local stationFaction = Faction()
        local shipFaction = Faction(ship.factionIndex)
        local minRelations = requiredRelations[pair.profession] or -1000000
        if shipFaction:getRelations(stationFaction.index) < minRelations then

            local name = "Neutral"%_t
            if minRelations >= 80000 then
                name = "Admired"%_t
            elseif minRelations >= 60000 then
                name = "Excellent"%_t
            elseif minRelations >= 30000 then
                name = "Good"%_t
            elseif minRelations >= 15000 then
                name = "Friendly"%_t
            end

            return false, "You need relations of at least '%s' to this faction to hire these crew members."%_t, {name}
        end

        return true, ""
    end

    function CrewBoard.getPriceAndTax(profession, num, stationFaction, buyerFaction)
        local price = profession.price * num * (1 + GetFee(stationFaction, buyerFaction))
        local tax = round(price * 0.2)

        if stationFaction.index == buyerFaction.index then
            price = price - tax
            -- don't pay out for the second time
            tax = 0
        end

        return price, tax
    end

    function CrewBoard.getCaptainPriceAndTax(captain, stationFaction, buyerFaction)
        local price = captain.hiringPrice
        local tax = round(price * 0.2)

        if stationFaction.index == buyerFaction.index then
            price = price - tax
            -- don't pay out for the second time
            tax = 0
        end

        return price, tax
    end

    function CrewBoard.getTransportPrice(buyer, ship)
        local missing = CrewBoard.calculateMissingCrew(ship)

        local totalPrice = 0
        local totalTax = 0

        local stationFaction = Faction()
        for profession, amount in pairs(missing) do
            local price, tax = CrewBoard.getPriceAndTax(profession, amount, stationFaction, buyer)

            totalPrice = totalPrice + price
            totalTax = totalTax + tax
        end

        totalPrice = totalPrice * 1.3 + 100000
        totalTax = totalTax * 1.3 + 20000

        return totalPrice, totalTax, missing
    end

    function CrewBoard.getAvailableCaptainTest()
        return availableCaptain
    end

    function CrewBoard.getTransportPriceTest()
        local craft = Player(callingPlayer).craft
        local buyer = Faction(craft.factionIndex)
        local price, tax = CrewBoard.getTransportPrice(buyer, craft)
        return price, tax
    end

    function CrewBoard.getMissingCrewTest()
        local craft = Player(callingPlayer).craft
        local buyer = Faction(craft.factionIndex)
        local price, tax, missing = CrewBoard.getTransportPrice(buyer, craft)
        return missing
    end

    function CrewBoard.calculateMissingCrew(craft)
        -- calculate required crew
        local crew = craft.crew
        local minCrew = craft.idealCrew

        local missing = {}
        local workforce = {}

        for profession, amount in pairs(crew:getWorkforce()) do
            workforce[profession.value] = amount
        end

        local minWorkforce = minCrew:getWorkforce()

        for profession, amount in pairs(minWorkforce) do
            local have = workforce[profession.value] or 0
            local need = amount

            if have < need then
                -- round up, required crew can have a fractional part because of specialists with 1.5 workforce
                missing[profession] = math.ceil(need - have)
            end
        end

        return missing
    end
    ]]
--

local Class = include("SDKGlobalDesigns - Classes")
local Volume = include("SDKGlobalDesigns - Volumes")
local AsyncShips = include("SDKGlobalDesigns - Generator Ships Async")
local Call = include("SDKGlobalDesigns - Generator Ships Async Utility")

-- Store Vanilla Funciton and Overwrite
CrewBoard.old_onCrewTransportTimerOver = CrewBoard.onCrewTransportTimerOver
function CrewBoard.onCrewTransportTimerOver()

    local Settings = Call.Settings(Class.CrewTransport, Volume.Get(8, 10), nil, nil, nil, Call.CrewTransport)
    local Build = AsyncShips(CrewBoard, CrewBoard.finalizeCrewTransport)
    
    local Fac = Galaxy():getNearestFaction(Sector():getCoordinates())
    local dir = random():getDirection()
    local P = MatrixLookUpPosition(-dir, random():getDirection(), dir * 3000)
    
    Build:Generate(Fac, P, Settings)        
end

-- Unmodified Code
    --[[
        
    function CrewBoard.finalizeCrewTransport(ship)
        transportData = transportData or {}

        ship:addScriptOnce("crewtransport.lua", transportData.craft or Uuid(), transportData.crew or {})

        transportData = nil
        CrewBoard.sync()
    end

    function CrewBoard.getAvailableCrewAndCaptain()
        CrewBoard.sync()

        return availableCrew, availableCaptain
    end

    function CrewBoard.getHireButtonRect(profession)
        for i, group in pairs(uiGroups) do
            if group.profession == profession then
                return group.button.rect
            end
        end
    end

    ---- this function gets called each tick, on client and server
    --function update(timeStep)
    --
    --end
    --
    ---- this function gets called each tick, on client only
    --function updateClient(timeStep)
    --
    --end
    --
    ---- this function gets called each tick, on server only
    --function updateServer(timeStep)
    --
    --end
    --
    ---- this function gets called whenever the ui window gets rendered, AFTER the window was rendered (client only)
    --function renderUI()
    --
    --end
    ]]
--
