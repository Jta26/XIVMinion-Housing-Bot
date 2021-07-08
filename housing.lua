local ffxiv_task_check_housing = {}
local HousingBot = {}
HousingBot.currentlySelectedLocale = nil;
HousingBot.aetherytePositions = {
    ["limsa"] = {name = "Mist", id = 8, mapid = 129, x = -80.80, y = 18.80, z = -5.61},
    ["gridania"] = {name = "Lavendar Beds", id = 2, mapid = 132, x = 28.93, y = 1.20, z = 34.26},
    ["uldah"] = {name = "Goblet", id = 9, mapid = 130, x = -138.7, y = -3.15, z = -169.1},
    ["kugane"] = {name = "Shirogane", id = 111, mapid = 628, x = 48.36, y = 4.55, z = -43.36}
}

local gilPattern = "%d+,%d+,%d+ Gil"

local largeSignature =  "238130131238129189272213238129188"
local mediumSignature = "238130131272213238129189272263238129188272213"
local smallSignature =  "238130131238129189238129188"

function HousingBot.HouseSizeSignature(stringBytes)
    local signature = ""
    for i=1,string.len(stringBytes) do 
        signature = signature .. tostring(string.byte(stringBytes,i))
    end
    return signature

end

function HousingBot.ResolveHouseSignature(signature)
    if (signature == smallSignature) then
        return "Small"
    elseif (signature == mediumSignature) then
        return "Medium"
    elseif (signature == largeSignature) then
        return "Large"
    else
        return "Unknown"
    end
end



function HousingBot.ModuleInit()
    ffxivminion.AddMode("CheckHousing", ffxiv_task_check_housing)
end

function HousingBot.OnUpdate()
    if (FFXIV_Common_BotRunning == true) then
        if (ml_task_hub:CurrentTask()) then
            
            if (IsControlOpen('HousingSelectBlock')) then
                
            else


            end
        end
    end
end

ffxiv_task_check_housing = inheritsFrom(ml_task)
ffxiv_task_check_housing.name = "CHECK_HOUSING"
function ffxiv_task_check_housing.Create()
    local newinst = inheritsFrom(ffxiv_task_check_housing)
    newinst.valid = true
    newinst.completed = false
    newinst.subtask = nil
    newinst.auxiliary = false
    newinst.process_elements = {}
    newinst.overwatch_elements = {}

    newinst.name = "CHECK_HOUSING"
        -- newinst.delay = 0
        -- newinst.awaitingWin = false
        -- newinst.catchWin = false
        -- newinst.randomizeTimer = Now()
        -- newinst.lastRest = Now()
        -- newinst.invalidState = 0
        -- these are variables relating to mini games
        newinst.localesChecked = {}
        newinst.currentLocale = {}
        newinst.checkingHouses = false

    return newinst
end

function ffxiv_task_check_housing:UIInit()
    -- get the housing settings here
    gCHLimsa = ffxivminion.GetSetting('gCHLimsa', true)
    gCHGridania = ffxivminion.GetSetting('gCHGridania', true)
    gCHUldah = ffxivminion.GetSetting('gCHUldah', true)
    gCHKugane = ffxivminion.GetSetting('gCHKugane', true)
    gCHReportSmalls = ffxivminion.GetSetting('gCHReportSmalls', true)
    gCHScanSpeed = ffxivminion.GetSetting('gCHScanSpeed', 750)
    CHRandomIdle = ffxivminion.GetSetting('CHRandomIdle', true)
    self.GUI.main_tabs = GUI_CreateTabs("Options",false)
end

ffxiv_task_check_housing.GUI = {
    x = 0,
    y = 0,
    height = 0,
    width = 0
}

function ffxiv_task_check_housing:Draw()
    local fontSize = GUI:GetWindowFontSize()
	local windowPaddingY = GUI:GetStyle().windowpadding.y
	local framePaddingY = GUI:GetStyle().framepadding.y
	local itemSpacingY = GUI:GetStyle().itemspacing.y

    GUI_DrawTabs(self.GUI.main_tabs)
    local tabs = self.GUI.main_tabs

    if (tabs.tabs[1].isselected) then
        GUI:BeginChild("##header-options", 0, GUI_GetFrameHeight(5), true)
        GUI:Text("Select the housing locales you want to search.")
        GUI:Columns(2)
        GUI:AlignFirstTextHeightToWidgets() GUI:Text("Mist")
        if (GUI:IsItemHovered()) then GUI:SetTooltip("Check to make the bot look for houses in The Mist") end
        GUI:AlignFirstTextHeightToWidgets() GUI:Text("Lavendar Beds")
        if (GUI:IsItemHovered()) then GUI:SetTooltip("Check to make the bot look for houses in The Lavendar Beds") end
        GUI:AlignFirstTextHeightToWidgets() GUI:Text("Goblet")
        if (GUI:IsItemHovered()) then GUI:SetTooltip("Check to make the bot look for houses in The Goblet") end
        GUI:AlignFirstTextHeightToWidgets() GUI:Text("Shirogane")
        if (GUI:IsItemHovered()) then GUI:SetTooltip("Check to make the bot look for houses in Shirogane") end
        GUI:NextColumn()
        GUI_Capture(GUI:Checkbox("##CHLimsa",gCHLimsa),"gCHLimsa")
        GUI_Capture(GUI:Checkbox("##CHGridania",gCHGridania),"gCHGridania")
        GUI_Capture(GUI:Checkbox("##CHUldah",gCHUldah),"gCHUldah")
        GUI_Capture(GUI:Checkbox("##CHKugane",gCHKugane),"gCHKugane")
        GUI:Columns()
        GUI:EndChild()
        GUI:Text("Report Smalls?")
        GUI_Capture(GUI:Checkbox("##CHReportSmalls",gCHReportSmalls),"gCHReportSmalls")
        GUI:Columns(2)
        GUI:AlignFirstTextHeightToWidgets() GUI:Text("Teleport to random hub aetheryte when scan complete.")
        GUI:NextColumn()
        GUI_Capture(GUI:Checkbox("##CHRandomIdle",CHRandomIdle),"CHRandomIdle")
    end


end

function ffxiv_task_check_housing:Init()


    local ke_scanHousingWards = ml_element:create("ScanHousingWards", c_scanhousingwards, e_scanhousingwards, 50)
    self:add(ke_scanHousingWards, self.process_elements)

    local ke_selectHousingString = ml_element:create("SelectHousingString", c_selecthousingstring, e_selecthousingstring, 40)
    self:add(ke_selectHousingString, self.process_elements)

    local ke_targetAetheryte = ml_element:create("TargetAetheryte", c_targetaetheryte, e_targetaetheryte, 30)
    self:add(ke_targetAetheryte, self.process_elements)

    local ke_moveToAetheryteArea = ml_element:create("MoveToAetheryteArea", c_moveaetherytearea, e_moveaetherytearea, 20)
    self:add(ke_moveToAetheryteArea, self.process_elements)

    self:AddTaskCheckCEs()

end

function ffxiv_task_check_housing:task_complete_eval()
    local locales = HousingBot.aetherytePositions
    local checkedLocalesLength = table.getn(ml_task_hub:CurrentTask().localesChecked)
    if (checkedLocalesLength == 0) then
        if (gCHLimsa == true) then
            -- if the user has "Mist" checked, then set it, otherwise skip it.
            ml_task_hub:CurrentTask().currentLocale = locales.kugane
        else
            table.insert(ml_task_hub:CurrentTask().localesChecked, locales.kugane)
        end
    elseif (checkedLocalesLength == 1) then
        if (gCHGridania == true) then
            ml_task_hub:CurrentTask().currentLocale = locales.gridania
        else
            table.insert(ml_task_hub:CurrentTask().localesChecked, locales.gridania)
        end
    elseif (checkedLocalesLength == 2) then
        if (gCHUldah == true) then
            ml_task_hub:CurrentTask().currentLocale = locales.limsa
        else
            table.insert(ml_task_hub:CurrentTask().localesChecked, locales.limsa)
        end
    elseif (checkedLocalesLength == 3) then
        if (gCHKugane == true) then
            -- if the user has "Mist" checked, then set it, otherwise skip it.
            ml_task_hub:CurrentTask().currentLocale = locales.uldah
        else
            table.insert(ml_task_hub:CurrentTask().localesChecked, locales.uldah)
        end
    elseif (checkedLocalesLength == 4) then
        -- if we have checked all 4 mark the task complete, and run task_complete_execute
        return true
    else
        return false
    end
end

function ffxiv_task_check_housing:task_complete_execute()
    -- turns off the bot, stopping the task.
    -- could probably bring up a popup that says "housing scan complete" or something.
    d('[FayeHousing]: Housing Scan Complete')
    if (CHRandomIdle) then
        local randomTeleport = math.random(1,4)
        local locales = HousingBot.aetherytePositions
        if (randomTeleport == 1) then
            if (Player.locamapid ~= locales.limsa.id) then
                Player:Teleport(locales.limsa.id) 
            end
        elseif (randomTeleport == 2) then
            if (Player.locamapid ~= locales.gridania.id) then
                Player:Teleport(locales.gridania.id) 
            end
        elseif (randomTeleport == 3) then
            if (Player.locamapid ~= locales.uldah.id) then
                Player:Teleport(locales.uldah.id) 
            end
        elseif (randomTeleport == 4) then
            if (Player.locamapid ~= locales.kugane.id) then
                Player:Teleport(locales.kugane.id) 
            end
        end
    end

    if (FFXIV_Common_BotRunning == true) then
		ml_global_information:ToggleRun()
	end
end

c_moveaetherytearea = inheritsFrom(ml_cause)
e_moveaetherytearea = inheritsFrom(ml_effect)
c_moveaetherytearea.pos = {}
c_moveaetherytearea.shouldTeleport = false
function c_moveaetherytearea:evaluate()
    -- if the player is not in the current locale
    local currentLocale = ml_task_hub:CurrentTask().currentLocale
    if (Player.localmapid ~= currentLocale.mapid) then
        c_moveaetherytearea.shouldTeleport = true
        c_moveaetherytearea.pos = { x = currentLocale.x, y = currentLocale.y, z = currentLocale.z} 
        d("Moving to the aetheryte")
        return true
    
    end
    -- if the player is in the current locale, but not in range of the aetheryte.
    local targetAetheryte = EntityList("maxdistance=10,contentid="..tostring(currentLocale.id))
    if (ValidTable(targetAetheryte) == false and Player.localmapid == currentLocale.mapid) then
        c_moveaetherytearea.shouldTeleport = false
        c_moveaetherytearea.pos = { x = currentLocale.x, y = currentLocale.y, z = currentLocale.z} 
        return true
    end

    return false

end

function e_moveaetherytearea:execute()
    local currentLocale = ml_task_hub:CurrentTask().currentLocale
    if (c_moveaetherytearea.shouldTeleport and ActionIsReady(7,5) and not Busy()) then
        d('teleporting to next aetheryte')
        Player:Teleport(currentLocale.id)
    elseif (not Busy() and Player.localmapid == currentLocale.mapid) then
        d('walking to next aetheryte')
        Player:MoveTo(c_moveaetherytearea.pos.x, c_moveaetherytearea.pos.y, c_moveaetherytearea.pos.z)
    end

end

c_targetaetheryte = inheritsFrom(ml_cause)
e_targetaetheryte = inheritsFrom(ml_effect)
c_targetaetheryte.aetheryte = {}
function c_targetaetheryte:evaluate()
    local currentLocale = ml_task_hub:CurrentTask().currentLocale
    c_targetaetheryte.aetheryte = EntityList("maxdistance=10,contentid="..tostring(currentLocale.id))
    if (Player.localmapid == currentLocale.mapid and ValidTable(c_targetaetheryte.aetheryte) and ml_task_hub:CurrentTask().checkingHouses == false and Player:IsMoving() == false) then
        d('targeting Aetheryte')
        return true
    end
    return false
end

function e_targetaetheryte:execute()
    if (c_targetaetheryte.aetheryte) then
        local i,e = next(c_targetaetheryte.aetheryte)
        if (i ~= nil and e ~= nil) then
            Player:Interact(i)
        end

    end

end

c_selecthousingstring = inheritsFrom(ml_cause)
e_selecthousingstring = inheritsFrom(ml_effect)
function c_selecthousingstring:evaluate()
    local currentLocale = ml_task_hub:CurrentTask().currentLocale
    if (Player.localmapid == currentLocale.mapid and ValidTable(c_targetaetheryte.aetheryte) and IsControlOpen("SelectString")) then
        d('Selecting String')
        return true
    else
        return false
    end
end

-- 1 is the conveniently the correct index to move through both SelectString menus
function e_selecthousingstring:execute()
    SelectConversationLine(1)
    ml_global_information.Await(500,2000, function () return not IsControlOpen("SelectString") end)
end

c_scanhousingwards = inheritsFrom(ml_cause)
e_scanhousingwards = inheritsFrom(ml_effect)
c_scanhousingwards.currentWard = 1
c_scanhousingwards.housingBlock = nil
c_scanhousingwards.currentWardData = nil
function c_scanhousingwards:evaluate()
    if (IsControlOpen("HousingSelectBlock") and c_scanhousingwards.currentWard <= 24) then
        c_scanhousingwards.housingBlock = GetControl("HousingSelectBlock")
        if (c_scanhousingwards.housingBlock) then
            c_scanhousingwards.currentWardData = c_scanhousingwards.housingBlock:GetRawData()
            ml_task_hub:CurrentTask().checkingHouses = true
            if (c_scanhousingwards.currentWardData ~= nil) then
               -- 255 check here because sometimes the framerate (I think) causes the first ward data (for ward 1) to be 255 as the first value in the raw data table.
                if (c_scanhousingwards.currentWardData[2].value + 1 == c_scanhousingwards.currentWard and (c_scanhousingwards.currentWardData[1].value == 4 or c_scanhousingwards.currentWardData[1].value == 255)) then
                    -- "travel" to the current ward
                    d("[FayeHousing]: Checking ward "..tostring(c_scanhousingwards.currentWard))
                    return true
                else
                    return false
                end
            end
        end
    else
        ml_task_hub:CurrentTask().checkingHouses = false
        c_scanhousingwards.currentWard = 1
        return false
    end
    return false
end

function e_scanhousingwards:execute()
    local openHouses = {}
    local currentLocale = ml_task_hub:CurrentTask().currentLocale
    if (c_scanhousingwards.housingBlock) then
        -- 5 second timeout on the network request for the
        -- might be useless with the check in the eval.
        local wardNumber = c_scanhousingwards.currentWardData[2].value + 1
        local flavorText = c_scanhousingwards.currentWardData[3].value
        for i, house in pairs(c_scanhousingwards.currentWardData) do
            local isMatch = string.match(house.value, gilPattern)
            if (isMatch) then
                d('found match')
                local houseNumberData = c_scanhousingwards.currentWardData[i - 1].value
                plotChunks = {}
                for token in string.gmatch(houseNumberData, "[^%s]+") do
                    table.insert(plotChunks, token)
                end
                local plotNumber = plotChunks[1]
                local plotSizeBytes = plotChunks[2]
                local houseSignature = HousingBot.HouseSizeSignature(plotSizeBytes)
                local plotSize = HousingBot.ResolveHouseSignature(houseSignature)
                local totalHouseData = {locale = currentLocale.name, wardNumber = wardNumber, plotNumber = plotNumber, plotSize = plotSize, price = house.value}
                local textmsg = "Open House Found:\nLocale: "..totalHouseData.locale.."\nSize: "..totalHouseData.plotSize.."\nWard: "..totalHouseData.wardNumber.."\nPlot: "..totalHouseData.plotNumber.."\nPrice: "..totalHouseData.price
                d(textmsg)
                if (gCHReportSmalls) then
                    HousingBotNetwork.SendDiscordMessage(textmsg)
                end
                HousingBotNetwork.AddHouse(totalHouseData)
                table.insert(openHouses, totalHouseData)
            end
        end
        d('Scanned Ward '..tostring(c_scanhousingwards.currentWard))
        c_scanhousingwards.currentWard = c_scanhousingwards.currentWard + 1
        if (c_scanhousingwards.currentWard == 25) then
            -- close the control
            if (IsControlOpen("HousingSelectBlock")) then
                c_scanhousingwards.housingBlock:Destroy()
                c_scanhousingwards.housingBlock = nil
            end
            -- if we have reached ward 24, then change to the next locale (or if this is the last the task_complete_eval will stop the bot.)
            table.insert(ml_task_hub:CurrentTask().localesChecked, ml_task_hub:CurrentTask().currentLocale)
        else
            --move to the next ward
            UseControlAction("HousingSelectBlock","Travel", c_scanhousingwards.currentWard)
            ml_global_information.Await(gCHScanSpeed * .33333, function() return IsControlOpen("SelectYesno") end, function() 
                PressYesNo(false)
            end) 
        end
    end
end

c_closehousingcontrols = inheritsFrom(ml_cause)
e_closehousingcontrols = inheritsFrom(ml_effect)
function c_closehousingcontrols:evaluate()
    if (IsControlOpen("HousingSelectBlock") or IsControlOpen("SelectString")) then
        return true
    end
end

function e_closehousingcontrols:execute()
    if (IsControlOpen("HousingSelectBlock")) then
        GetControl("HousingSelectBlock"):Close()
    elseif (IsControlOpen("SelectString")) then
        GetControl("SelectString"):Close()
    end
end


RegisterEventHandler("Module.Initalize",HousingBot.ModuleInit,"HousingBot.ModuleInit")
RegisterEventHandler("Gameloop.Update",HousingBot.OnUpdate,"HousingBot.OnUpdate")