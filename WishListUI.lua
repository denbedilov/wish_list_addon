-- WishListUI.lua
local function getIcon(slotName)
    -- Set item icon for slots if present in personal wishlist
    if WishListDB and WishListDB.personalWishList then
            local itemID = WishListDB.personalWishList[slotName:lower():gsub("slot$", "")]
            if itemID then
                local icon = GetItemIcon(itemID)
                if icon then
                    return icon
                else
                    return nil
                end
            end
    end
end

function WishListAddon:CreateMainFrame()
    local WishListFrame = CreateFrame("Frame", "WishListFrame", UIParent, "BasicFrameTemplateWithInset")
    WishListFrame:SetSize(338, 424)
    WishListFrame:SetPoint("CENTER", UIParent, "CENTER", -200, 0)
    WishListFrame:SetMovable(true)
    WishListFrame:EnableMouse(true)
    WishListFrame:RegisterForDrag("LeftButton")
    WishListFrame:SetScript("OnDragStart", WishListFrame.StartMoving)
    WishListFrame:SetScript("OnDragStop", WishListFrame.StopMovingOrSizing)

    WishListFrame:SetFrameStrata("DIALOG")
    WishListFrame:SetFrameLevel(5)

    -- Добавляем возможность закрытия по ESC
    tinsert(UISpecialFrames, "WishListFrame")

    WishListFrame.title = WishListFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    WishListFrame.title:SetPoint("LEFT", WishListFrame.TitleBg, "LEFT", 5, 0)
    WishListFrame.title:SetText("WishList v" .. (WISHLIST_VERSION or "x_x"))

    -- Player nickname above model
    local playerName = UnitName("player")
    local nameFont = WishListFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    nameFont:SetPoint("TOP", WishListFrame, "TOP", 0, -40)
    nameFont:SetText(playerName or "Player")
    WishListFrame.playerNameFont = nameFont

    -- Player model (centered)
    local model = CreateFrame("PlayerModel", nil, WishListFrame)
    model:SetSize(180, 320)
    model:SetPoint("CENTER", WishListFrame, "CENTER", 0, -10)
    model:SetUnit("player")
    WishListFrame.model = model

    -- Gear slot positions (adjusted)
    local slots = {
        -- Left slots
        {name = "HEAD", x = 30, y = -50, label = "Head"},
        {name = "NECK", x = 30, y = -90, label = "Neck"},
        {name = "SHOULDER", x = 30, y = -130, label = "Shoulder"},
        {name = "BACK", x = 30, y = -170, label = "Back"},
        {name = "CHEST", x = 30, y = -210, label = "Chest"},
        {name = "SHIRT", x = 30, y = -250, label = "Shirt"},
        {name = "TABARD", x = 30, y = -290, label = "Tabard"},
        {name = "WRIST", x = 30, y = -330, label = "Wrist"},
        -- Right slots
        {name = "HANDS", x = 270, y = -50, label = "Hands"},
        {name = "WAIST", x = 270, y = -90, label = "Waist"},
        {name = "LEGS", x = 270, y = -130, label = "Legs"},
        {name = "FEET", x = 270, y = -170, label = "Feet"},
        {name = "FINGER1", x = 270, y = -210, label = "Finger 1"},
        {name = "FINGER2", x = 270, y = -250, label = "Finger 2"},
        {name = "TRINKET1", x = 270, y = -290, label = "Trinket 1"},
        {name = "TRINKET2", x = 270, y = -330, label = "Trinket 2"},
        -- Main/Off hand slots 
        {name = "MAINHAND", x = 130, y = -370, label = "Main Hand"},
        {name = "OFFHAND", x = 172, y = -370, label = "Off Hand"},
    }

    WishListFrame.slots = {}
    for _, slot in ipairs(slots) do
        local btn = CreateFrame("Button", nil, WishListFrame, "ItemButtonTemplate")
        btn:SetSize(36, 36)
        btn:SetPoint("TOPLEFT", WishListFrame, "TOPLEFT", slot.x, slot.y)
        btn.slotName = slot.name
        btn.slotLabel = slot.label

        -- Получаем itemId для этого слота из WishListDB.personalwishlist
        local slotKey = slot.name:lower()
        local itemData = WishListDB.personalwishlist and WishListDB.personalwishlist[slotKey]
        local itemID = itemData and itemData.itemId

        -- Устанавливаем иконку если есть itemID
        if itemID then
            local icon = GetItemIcon(itemID)
            if icon then
                btn.icon:SetTexture(icon)
            else
                btn.icon:SetTexture(nil)
            end
        else
            btn.icon:SetTexture(nil)
        end

        btn:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText(self.slotLabel, 1,1,1)
            -- Показываем itemID и список игроков для этого предмета
            local itemData = WishListDB.personalwishlist and WishListDB.personalwishlist[slotKey]
            if itemData and itemData.itemId then
                GameTooltip:SetItemByID(itemData.itemId)
            end
            GameTooltip:Show()
        end)
        btn:SetScript("OnLeave", function() GameTooltip:Hide() end)
        WishListFrame.slots[slot.name] = btn
    end

    -- Логика поднятия окна по клику
    WishListFrame:SetScript("OnMouseDown", function()
        WishListFrame:SetFrameLevel(10)
        if self.SettingsFrame then
            self.SettingsFrame:SetFrameLevel(5)
        end
        if self.ShowAllFrame then
            self.ShowAllFrame:SetFrameLevel(5)
        end
    end)

    self.MainFrame = WishListFrame
end

function WishListAddon:CreateSettingsFrame()
    local WishListSettingsFrame = CreateFrame("Frame", "WishListSettingsFrame", UIParent, "BasicFrameTemplateWithInset")
    WishListSettingsFrame:SetSize(338, 424)
    WishListSettingsFrame:SetPoint("CENTER", UIParent, "CENTER", 200, 0)
    WishListSettingsFrame:SetMovable(true)
    WishListSettingsFrame:EnableMouse(true)
    WishListSettingsFrame:RegisterForDrag("LeftButton")
    WishListSettingsFrame:SetScript("OnDragStart", WishListSettingsFrame.StartMoving)
    WishListSettingsFrame:SetScript("OnDragStop", WishListSettingsFrame.StopMovingOrSizing)

    WishListSettingsFrame:SetFrameStrata("DIALOG")
    WishListSettingsFrame:SetFrameLevel(5)

    -- Allow closing with ESC
    tinsert(UISpecialFrames, "WishListSettingsFrame")

    WishListSettingsFrame.title = WishListSettingsFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    WishListSettingsFrame.title:SetPoint("LEFT", WishListSettingsFrame.TitleBg, "LEFT", 5, 0)
    WishListSettingsFrame.title:SetText("WishList Settings v" .. WISHLIST_VERSION)

    -- Raise window on click
    WishListSettingsFrame:SetScript("OnMouseDown", function()
        WishListSettingsFrame:SetFrameLevel(10)
        if self.MainFrame then
            self.MainFrame:SetFrameLevel(5)
        end
        if self.ShowAllFrame then
            self.ShowAllFrame:SetFrameLevel(5)
        end
    end)

    -- Determine the largest needed button width
    local buttonLabels = {
        "Print WishList",
        "Print All Items",
        "Reload WishList from file",
        "Clear WishList",
        "Get WishList from Guild"
    }
    local maxWidth = 0
    local tempFont = WishListSettingsFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    for _, label in ipairs(buttonLabels) do
        tempFont:SetText(label)
        maxWidth = math.max(maxWidth, tempFont:GetStringWidth())
    end
    maxWidth = math.ceil(maxWidth) + 24 -- padding for button borders

    local buttonHeight = 32
    local startY = -60
    local spacing = -8

    -- Button: Print WishList (personal)
    local printPersonalBtn = CreateFrame("Button", nil, WishListSettingsFrame, "UIPanelButtonTemplate")
    printPersonalBtn:SetSize(maxWidth, buttonHeight)
    printPersonalBtn:SetPoint("TOP", WishListSettingsFrame, "TOP", 0, startY)
    printPersonalBtn:SetText("Print WishList")
    printPersonalBtn:SetScript("OnClick", function()
        if WishListClass and WishListClass.PrintPersonalWishlist then
            WishListClass:PrintPersonalWishlist()
        else
            print("WishListClass:PrintPersonalWishlist not found.")
        end
    end)

    -- Button: Print All Items
    local printAllBtn = CreateFrame("Button", nil, WishListSettingsFrame, "UIPanelButtonTemplate")
    printAllBtn:SetSize(maxWidth, buttonHeight)
    printAllBtn:SetPoint("TOP", printPersonalBtn, "BOTTOM", 0, spacing)
    printAllBtn:SetText("Print All Items")
    printAllBtn:SetScript("OnClick", function()
        if WishListClass and WishListClass.PrintItems then
            WishListClass:PrintItems()
        else
            print("WishListClass:PrintItems not found.")
        end
    end)

    -- Button: Reload WishList
    local reloadBtn = CreateFrame("Button", nil, WishListSettingsFrame, "UIPanelButtonTemplate")
    reloadBtn:SetSize(maxWidth, buttonHeight)
    reloadBtn:SetPoint("TOP", printAllBtn, "BOTTOM", 0, spacing)
    reloadBtn:SetText("Reload WishList from file")
    reloadBtn:SetScript("OnClick", function()
        if WishListClass and WishListClass.BuildLists then
            WishListClass:BuildLists(true)
            print("WishList reloaded.")
        end
    end)

    -- Button: Clear WishList
    local clearBtn = CreateFrame("Button", nil, WishListSettingsFrame, "UIPanelButtonTemplate")
    clearBtn:SetSize(maxWidth, buttonHeight)
    clearBtn:SetPoint("TOP", reloadBtn, "BOTTOM", 0, spacing)
    clearBtn:SetText("Clear WishList")
    clearBtn:SetScript("OnClick", function()
        WishListDB.items = nil
        WishListDB.personalwishlist = nil
        WishListDB.redCards = nil
        WishListDB.distributed = nil
        print("WishList cleared.")
    end)

    -- Button: Get WishList from Guild
    local getGuildBtn = CreateFrame("Button", nil, WishListSettingsFrame, "UIPanelButtonTemplate")
    getGuildBtn:SetSize(maxWidth, buttonHeight)
    getGuildBtn:SetPoint("TOP", clearBtn, "BOTTOM", 0, spacing)
    getGuildBtn:SetText("Get WishList from Guild")
    getGuildBtn:SetScript("OnClick", function()
        if WishListCommunication and WishListCommunication.isWishListUpdatable then
            WishListCommunication:isWishListUpdatable()
            print("Requested WishList from guild.")
        else
            print("WishListCommunication:isWishListUpdatable not found.")
        end
    end)

    -- Button: Print Red Cards
    local printRedCardsBtn = CreateFrame("Button", nil, WishListSettingsFrame, "UIPanelButtonTemplate")
    printRedCardsBtn:SetSize(maxWidth, buttonHeight)
    printRedCardsBtn:SetPoint("TOP", getGuildBtn, "BOTTOM", 0, spacing)
    printRedCardsBtn:SetText("Print Red Cards")
    printRedCardsBtn:SetScript("OnClick", function()
        if WishListDB and WishListDB.redCards then
            print("=== Red Cards ===")
            for _, name in ipairs(WishListDB.redCards) do
                print(name)
            end
            print("=== End Red Cards ===")
        else
            print("No red cards found.")
        end
    end)

    self.SettingsFrame = WishListSettingsFrame
end

function WishListAddon:CreateShowAllFrame()
    local ShowAllFrame = CreateFrame("Frame", "ShowAllFrame", UIParent, "BasicFrameTemplateWithInset")
    ShowAllFrame:SetSize(338, 424)
    ShowAllFrame:SetPoint("CENTER", UIParent, "CENTER", 200, 0)
    ShowAllFrame:SetMovable(true)
    ShowAllFrame:EnableMouse(true)
    ShowAllFrame:RegisterForDrag("LeftButton")
    ShowAllFrame:SetScript("OnDragStart", ShowAllFrame.StartMoving)
    ShowAllFrame:SetScript("OnDragStop", ShowAllFrame.StopMovingOrSizing)

    ShowAllFrame:SetFrameStrata("DIALOG")
    ShowAllFrame:SetFrameLevel(5)

    tinsert(UISpecialFrames, "ShowAllFrame")

    ShowAllFrame.title = ShowAllFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    ShowAllFrame.title:SetPoint("LEFT", ShowAllFrame.TitleBg, "LEFT", 5, 0)
    ShowAllFrame.title:SetText("WishList: Show All")

    ShowAllFrame:SetScript("OnMouseDown", function()
        ShowAllFrame:SetFrameLevel(10)
        if self.MainFrame then self.MainFrame:SetFrameLevel(5) end
        if self.SettingsFrame then self.SettingsFrame:SetFrameLevel(5) end
    end)

    -- Build player list from WishListDB.items
    local playerNames, playerSet = {}, {}
    for _, playerArr in pairs(WishListDB.items or {}) do
        for _, entry in ipairs(playerArr) do
            local player = entry[1]
            if player and not playerSet[player] then
                table.insert(playerNames, player)
                playerSet[player] = true
            end
        end
    end
    table.sort(playerNames)

    local selectedPlayer = playerNames[1] or ""
    local dropdown = CreateFrame("Frame", "WishListShowAllPlayerDropDown", ShowAllFrame, "UIDropDownMenuTemplate")
    dropdown:SetPoint("TOP", ShowAllFrame, "TOP", 0, -30)
    UIDropDownMenu_SetWidth(dropdown, 160)
    UIDropDownMenu_SetText(dropdown, selectedPlayer)

    -- Slot mapping for lookup
    local slotMap = {
        HEAD = "head", NECK = "neck", SHOULDER = "shoulder", BACK = "back", CHEST = "chest",
        SHIRT = "shirt", TABARD = "tabard", WRIST = "wrist", HANDS = "hands", WAIST = "waist",
        LEGS = "legs", FEET = "feet", FINGER1 = "finger", FINGER2 = "finger",
        TRINKET1 = "trinket", TRINKET2 = "trinket", MAINHAND = "mainhand", OFFHAND = "offhand"
    }

    -- Gear slot positions
    local slots = {
        {name = "HEAD", x = 30, y = -50, label = "Head"},
        {name = "NECK", x = 30, y = -90, label = "Neck"},
        {name = "SHOULDER", x = 30, y = -130, label = "Shoulder"},
        {name = "BACK", x = 30, y = -170, label = "Back"},
        {name = "CHEST", x = 30, y = -210, label = "Chest"},
        {name = "SHIRT", x = 30, y = -250, label = "Shirt"},
        {name = "TABARD", x = 30, y = -290, label = "Tabard"},
        {name = "WRIST", x = 30, y = -330, label = "Wrist"},
        {name = "HANDS", x = 270, y = -50, label = "Hands"},
        {name = "WAIST", x = 270, y = -90, label = "Waist"},
        {name = "LEGS", x = 270, y = -130, label = "Legs"},
        {name = "FEET", x = 270, y = -170, label = "Feet"},
        {name = "FINGER1", x = 270, y = -210, label = "Finger 1"},
        {name = "FINGER2", x = 270, y = -250, label = "Finger 2"},
        {name = "TRINKET1", x = 270, y = -290, label = "Trinket 1"},
        {name = "TRINKET2", x = 270, y = -330, label = "Trinket 2"},
        {name = "MAINHAND", x = 130, y = -370, label = "Main Hand"},
        {name = "OFFHAND", x = 172, y = -370, label = "Off Hand"},
    }

    ShowAllFrame.slots = {}
    for _, slot in ipairs(slots) do
        local btn = CreateFrame("Button", nil, ShowAllFrame, "ItemButtonTemplate")
        btn:SetSize(36, 36)
        btn:SetPoint("TOPLEFT", ShowAllFrame, "TOPLEFT", slot.x, slot.y)
        btn.slotName = slot.name
        btn.slotLabel = slot.label
        btn.icon:SetTexture(nil)
        ShowAllFrame.slots[slot.name] = btn
    end

    -- Helper for green V mark
    local function SetGreenVMark(btn, show)
        if not btn.vMark then
            btn.vMark = btn:CreateFontString(nil, "OVERLAY", "GameFontNormalHuge")
            btn.vMark:SetPoint("BOTTOMRIGHT", btn, "BOTTOMRIGHT", -2, 2)
            btn.vMark:SetText("|cff00ff00V|r")
            btn.vMark:Hide()
        end
        if show then
            btn.vMark:Show()
        else
            btn.vMark:Hide()
        end
    end

    -- Fill slots for selected player
    function ShowAllFrame:UpdateSlots(player)
        print("Updating slots for player:", player)
        -- Clear all slots
        for _, btn in pairs(self.slots) do
            btn.icon:SetTexture(nil)
            if btn.vMark then btn.vMark:Hide() end
            btn:SetScript("OnEnter", nil)
            btn:SetScript("OnLeave", nil)
        end

        local fingerItems, trinketItems = {}, {}

        for itemId, playerArr in pairs(WishListDB.items or {}) do
            local slotKey = WishListDB.slotMap and WishListDB.slotMap[itemId]
            if slotKey then
                for _, entry in ipairs(playerArr) do
                    if entry[1] == player then
                        if slotKey == "finger" then
                            table.insert(fingerItems, {itemId = itemId, players = playerArr})
                        elseif slotKey == "trinket" then
                            table.insert(trinketItems, {itemId = itemId, players = playerArr})
                        else
                            for _, btn in pairs(self.slots) do
                                if btn.slotName:lower() == slotKey then
                                    local icon = GetItemIcon(tonumber(itemId))
                                    if icon then
                                        btn.icon:SetTexture(icon)
                                    end
                                    local hasItem = false
                                    for _, e in ipairs(playerArr) do
                                        if e[1] == player and e[2] then hasItem = true break end
                                    end
                                    if not btn.vMark then
                                        btn.vMark = btn:CreateFontString(nil, "OVERLAY", "GameFontNormalHuge")
                                        btn.vMark:SetPoint("BOTTOMRIGHT", btn, "BOTTOMRIGHT", -2, 2)
                                        btn.vMark:SetText("|cff00ff00V|r")
                                        btn.vMark:Hide()
                                    end
                                    if hasItem then btn.vMark:Show() else btn.vMark:Hide() end
                                    btn:SetScript("OnEnter", function(self)
                                        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                                        GameTooltip:SetItemByID(itemId)
                                        GameTooltip:AddLine("Players:")
                                        for _, e in ipairs(playerArr) do
                                            local color = e[2] and "|cff00ff00" or "|cffffff00"
                                            GameTooltip:AddLine(color .. e[1] .. "|r")
                                        end
                                        GameTooltip:Show()
                                    end)
                                    btn:SetScript("OnLeave", function() GameTooltip:Hide() end)
                                    break
                                end
                            end
                        end
                    end
                end
            end
        end

        -- Sort and assign finger/trinket items to FINGER1/2 and TRINKET1/2
        table.sort(fingerItems, function(a, b) return tonumber(a.itemId) < tonumber(b.itemId) end)
        table.sort(trinketItems, function(a, b) return tonumber(a.itemId) < tonumber(b.itemId) end)

        local function fillMultiSlot(slotPrefix, items)
            for i = 1, 2 do
                local btn = self.slots[slotPrefix .. i]
                local entry = items[i]
                if btn and entry then
                    local icon = GetItemIcon(tonumber(entry.itemId))
                    if icon then
                        btn.icon:SetTexture(icon)
                    end
                    local hasItem = false
                    for _, e in ipairs(entry.players) do
                        if e[1] == player and e[2] then hasItem = true break end
                    end
                    if not btn.vMark then
                        btn.vMark = btn:CreateFontString(nil, "OVERLAY", "GameFontNormalHuge")
                        btn.vMark:SetPoint("BOTTOMRIGHT", btn, "BOTTOMRIGHT", -2, 2)
                        btn.vMark:SetText("|cff00ff00V|r")
                        btn.vMark:Hide()
                    end
                    if hasItem then btn.vMark:Show() else btn.vMark:Hide() end
                    btn:SetScript("OnEnter", function(self)
                        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                        GameTooltip:SetItemByID(entry.itemId)
                        GameTooltip:AddLine("Players:")
                        for _, e in ipairs(entry.players) do
                            local color = e[2] and "|cff00ff00" or "|cffffff00"
                            GameTooltip:AddLine(color .. e[1] .. "|r")
                        end
                        GameTooltip:Show()
                    end)
                    btn:SetScript("OnLeave", function() GameTooltip:Hide() end)
                end
            end
        end

        fillMultiSlot("FINGER", fingerItems)
        fillMultiSlot("TRINKET", trinketItems)
    end

    UIDropDownMenu_Initialize(dropdown, function(self, level, menuList)
        for _, player in ipairs(playerNames) do
            local info = UIDropDownMenu_CreateInfo()
            info.text = player
            info.func = function()
                selectedPlayer = player
                UIDropDownMenu_SetText(dropdown, player)
                ShowAllFrame:UpdateSlots(player)
            end
            UIDropDownMenu_AddButton(info)
        end
    end)

    -- Initial update for the first player
    ShowAllFrame:UpdateSlots(selectedPlayer)

    self.ShowAllFrame = ShowAllFrame
end

function WishListAddon:ToggleShowAllFrame()
    if not self.ShowAllFrame then
        self:CreateShowAllFrame()
        self.ShowAllFrame:Show()
    else
        if self.ShowAllFrame:IsShown() then
            self.ShowAllFrame:Hide()
        else
            self.ShowAllFrame:Show()
        end
    end
end

-- Register slash command for showall window
SLASH_WISHLISTSHOWALL1 = "/wlall"
SlashCmdList["WISHLISTSHOWALL"] = function(msg)
    WishListAddon:ToggleShowAllFrame()
end
