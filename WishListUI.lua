-- WishListUI.lua

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
        {name = "HeadSlot", x = 30, y = -50, label = "Head"},
        {name = "NeckSlot", x = 30, y = -90, label = "Neck"},
        {name = "ShoulderSlot", x = 30, y = -130, label = "Shoulder"},
        {name = "BackSlot", x = 30, y = -170, label = "Back"},
        {name = "ChestSlot", x = 30, y = -210, label = "Chest"},
        {name = "ShirtSlot", x = 30, y = -250, label = "Shirt"},
        {name = "TabardSlot", x = 30, y = -290, label = "Tabard"},
        {name = "WristSlot", x = 30, y = -330, label = "Wrist"},
        -- Right slots
        {name = "HandsSlot", x = 270, y = -50, label = "Hands"},
        {name = "WaistSlot", x = 270, y = -90, label = "Waist"},
        {name = "LegsSlot", x = 270, y = -130, label = "Legs"},
        {name = "FeetSlot", x = 270, y = -170, label = "Feet"},
        {name = "Finger0Slot", x = 270, y = -210, label = "Finger 1"},
        {name = "Finger1Slot", x = 270, y = -250, label = "Finger 2"},
        {name = "Trinket0Slot", x = 270, y = -290, label = "Trinket 1"},
        {name = "Trinket1Slot", x = 270, y = -330, label = "Trinket 2"},
        -- Main/Off hand slots 
        {name = "MainHandSlot", x = 130, y = -370, label = "Main Hand"},
        {name = "SecondaryHandSlot", x = 172, y = -370, label = "Off Hand"},
    }

    WishListFrame.slots = {}
    for _, slot in ipairs(slots) do
        local btn = CreateFrame("Button", nil, WishListFrame, "ItemButtonTemplate")
        btn:SetSize(36, 36)
        btn:SetPoint("TOPLEFT", WishListFrame, "TOPLEFT", slot.x, slot.y)
        btn.icon:SetTexture(nil)
        btn.slotName = slot.name
        btn.slotLabel = slot.label
        btn:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText(self.slotLabel, 1,1,1)
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

    if not WishListSettingsFrame.importBox then
        -- Add a ScrollFrame to contain the EditBox
        -- Create a background frame for visibility
        local bg = CreateFrame("Frame", nil, WishListSettingsFrame, BackdropTemplateMixin and "BackdropTemplate")
        bg:SetSize(310, 230)
        bg:SetPoint("TOP", WishListSettingsFrame, "TOP", 0, -36)
        bg:SetFrameLevel(WishListSettingsFrame:GetFrameLevel() + 1)
        bg:SetBackdrop({
            bgFile = "Interface/Tooltips/UI-Tooltip-Background",
            edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
            edgeSize = 16,
            insets = { left = 4, right = 4, top = 4, bottom = 4 },
        })
        bg:SetBackdropColor(1, 1, 0.85, 0.95) -- light yellowish background
        bg:SetBackdropBorderColor(0.8, 0.5, 0, 1) -- orange border

        local scrollFrame = CreateFrame("ScrollFrame", nil, bg, "UIPanelScrollFrameTemplate")
        scrollFrame:SetSize(290, 210)
        scrollFrame:SetPoint("TOPLEFT", bg, "TOPLEFT", 10, -10)

        local importBox = CreateFrame("EditBox", nil, scrollFrame)
        importBox:SetMultiLine(true)
        importBox:SetSize(270, 210)
        importBox:SetAutoFocus(false)
        importBox:SetFontObject("ChatFontNormal")
        importBox:SetText("")
        importBox:SetMaxLetters(10000)
        importBox:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
        importBox:SetScript("OnTabPressed", function(self) self:Insert("    ") end)
        importBox:SetScript("OnCursorChanged", function(self, x, y, w, h) scrollFrame:UpdateScrollChildRect() end)
        importBox:SetScript("OnTextChanged", function(self) scrollFrame:UpdateScrollChildRect() end)
        importBox:SetScript("OnEditFocusGained", function(self) scrollFrame:UpdateScrollChildRect() end)
        importBox:SetScript("OnEditFocusLost", function(self) scrollFrame:UpdateScrollChildRect() end)
        importBox:SetJustifyH("LEFT")
        importBox:SetJustifyV("TOP")
        importBox:SetMovable(false)
        importBox:SetClampedToScreen(true)
        scrollFrame:SetScrollChild(importBox)
        WishListSettingsFrame.importBox = importBox
        WishListSettingsFrame.importScrollFrame = scrollFrame
    end

    if not WishListSettingsFrame.importBtn then
        -- Add Import button under the text box
        local importBtn = CreateFrame("Button", nil, WishListSettingsFrame, "UIPanelButtonTemplate")
        importBtn:SetSize(120, 28)
        importBtn:SetPoint("TOP", WishListSettingsFrame, "BOTTOM", 0, 100)
        importBtn:SetText("Import")
        importBtn:SetScript("OnClick", function()
            local text = WishListSettingsFrame.importBox:GetText()
            WishListImportFromJSON(text)
            WishListSettingsFrame.importBox:SetText("")  -- Clear the box after import
        end)
        WishListSettingsFrame.importBtn = importBtn
    end

    -- Add import text box and button lower in the settings window
    if not WishListSettingsFrame.printBtn then
        -- Кнопка "Распечатать таблицу"
        local printBtn = CreateFrame("Button", nil, WishListSettingsFrame, "UIPanelButtonTemplate")
        printBtn:SetSize(160, 28)
        printBtn:SetPoint("TOP", WishListSettingsFrame, "BOTTOM", 0, 50)
        printBtn:SetText("Распечатать таблицу")
        printBtn:SetScript("OnClick", function()
            local gearList = WishListDB.gearList or nil
            if gearList and gearList.Print then
                gearList:Print()
            else
                print("|cffff0000[WishList]|r No gear list available to print.")
            end
        end)
        WishListSettingsFrame.printBtn = printBtn
    end

    WishListSettingsFrame:SetFrameStrata("DIALOG")
    WishListSettingsFrame:SetFrameLevel(5)

    -- Добавляем возможность закрытия по ESC
    tinsert(UISpecialFrames, "WishListSettingsFrame")

    WishListSettingsFrame.title = WishListSettingsFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    WishListSettingsFrame.title:SetPoint("LEFT", WishListSettingsFrame.TitleBg, "LEFT", 5, 0)
    WishListSettingsFrame.title:SetText("WishList Settings v" .. WISHLIST_VERSION)

    -- Логика поднятия окна по клику
    WishListSettingsFrame:SetScript("OnMouseDown", function()
        WishListSettingsFrame:SetFrameLevel(10)
        if self.MainFrame then
            self.MainFrame:SetFrameLevel(5)
        end
    end)

    self.SettingsFrame = WishListSettingsFrame
end
