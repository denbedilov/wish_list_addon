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

        -- Add import text box and button lower in the settings window
        if not WishListSettingsFrame.importBox then
            local importBox = CreateFrame("EditBox", nil, WishListSettingsFrame, "InputBoxTemplate")
            importBox:SetSize(300, 400)
            importBox:SetPoint("TOP", WishListSettingsFrame, "TOP", 0, -120)
            importBox:SetMultiLine(true)
            importBox:SetAutoFocus(false)
            importBox:SetText("Paste JSON here")
            WishListSettingsFrame.importBox = importBox

            local importBtn = CreateFrame("Button", nil, WishListSettingsFrame, "UIPanelButtonTemplate")
            importBtn:SetSize(100, 28)
            importBtn:SetPoint("TOP", importBox, "BOTTOM", 0, -8)
            importBtn:SetText("Import")
            importBtn:SetScript("OnClick", function()
                local text = importBox:GetText()
                -- TODO: handle import logic here
                print("|cff00ff00[WishList]|r Importing from text:", text)
                WishListImportFromJSON(text)
            end)
            WishListSettingsFrame.importBtn = importBtn
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
