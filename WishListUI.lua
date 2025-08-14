-- WishListUI.lua
-- All UI creation for WishList addon

-- Toggle custom frame (like player gear window)
function WishList_ToggleMainFrame()
    if not WishListFrame then
        WishListFrame = CreateFrame("Frame", "WishListFrame", UIParent, "BasicFrameTemplateWithInset")
        WishListFrame:SetSize(338, 424) -- Same as CharacterFrame
        WishListFrame:SetPoint("CENTER", UIParent, "CENTER", -200, 0)
        WishListFrame.title = WishListFrame:CreateFontString(nil, "OVERLAY")
        WishListFrame.title:SetFontObject("GameFontHighlight")
        WishListFrame.title:SetPoint("LEFT", WishListFrame.TitleBg, "LEFT", 5, 0)
        WishListFrame.title:SetText("WishList v" .. (WISHLIST_VERSION or "unknown"))

        -- Make the window movable
        WishListFrame:SetMovable(true)
        WishListFrame:EnableMouse(true)
        WishListFrame:RegisterForDrag("LeftButton")
        WishListFrame:SetScript("OnDragStart", function(self) self:StartMoving() end)
        WishListFrame:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)

        -- Ensure the main window is above all when focused
        WishListFrame:SetFrameStrata("DIALOG")
        WishListFrame:SetScript("OnMouseDown", function(self)
            self:Raise()
        end)

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
            {name = "HeadSlot",    x = 30,  y = -50,  label = "Head"},
            {name = "NeckSlot",    x = 30,  y = -90,  label = "Neck"},
            {name = "ShoulderSlot",x = 30,  y = -130, label = "Shoulder"},
            {name = "BackSlot",    x = 30,  y = -170, label = "Back"},
            {name = "ChestSlot",   x = 30,  y = -210, label = "Chest"},
            {name = "ShirtSlot",   x = 30,  y = -250, label = "Shirt"},
            {name = "TabardSlot",  x = 30,  y = -290, label = "Tabard"},
            {name = "WristSlot",   x = 30,  y = -330, label = "Wrist"},
            -- Right slots
            {name = "HandsSlot",   x = 270, y = -50,  label = "Hands"},
            {name = "WaistSlot",   x = 270, y = -90,  label = "Waist"},
            {name = "LegsSlot",    x = 270, y = -130, label = "Legs"},
            {name = "FeetSlot",    x = 270, y = -170, label = "Feet"},
            {name = "Finger0Slot", x = 270, y = -210, label = "Finger 1"},
            {name = "Finger1Slot", x = 270, y = -250, label = "Finger 2"},
            {name = "Trinket0Slot",x = 270, y = -290, label = "Trinket 1"},
            {name = "Trinket1Slot",x = 270, y = -330, label = "Trinket 2"},
            -- Main/Off hand slots 
            {name = "MainHandSlot",      x = 130, y = -370, label = "Main Hand"},
            {name = "SecondaryHandSlot", x = 172, y = -370, label = "Off Hand"},
        }
        WishListFrame.slots = {}
        for _, slot in ipairs(slots) do
            local btn = CreateFrame("Button", nil, WishListFrame, "ItemButtonTemplate")
            btn:SetSize(36, 36)
            btn:SetPoint("TOPLEFT", slot.x, slot.y)
            btn.icon:SetTexture(nil) -- Empty slot
            btn.slotName = slot.name
            btn.slotLabel = slot.label
            btn:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:SetText(self.slotLabel, 1, 1, 1)
                GameTooltip:Show()
            end)
            btn:SetScript("OnLeave", function(self)
                GameTooltip:Hide()
            end)
            WishListFrame.slots[slot.name] = btn
        end
    end
    if WishListFrame:IsShown() then
        WishListFrame:Hide()
    else
        WishListFrame:Show()
    end
end

function WishList_ToggleSettingsFrame()
    if not WishListSettingsFrame then
        WishListSettingsFrame = CreateFrame("Frame", "WishListSettingsFrame", UIParent, "BasicFrameTemplateWithInset")
        WishListSettingsFrame:SetSize(338, 424) -- Match main window size
        WishListSettingsFrame:SetPoint("CENTER", UIParent, "CENTER", 200, 0)
        WishListSettingsFrame.title = WishListSettingsFrame:CreateFontString(nil, "OVERLAY")
        WishListSettingsFrame.title:SetFontObject("GameFontHighlight")
        WishListSettingsFrame.title:SetPoint("LEFT", WishListSettingsFrame.TitleBg, "LEFT", 5, 0)
        WishListSettingsFrame.title:SetText("WishList Settings v" .. (WISHLIST_VERSION or "unknown"))

        -- Make the window movable
        WishListSettingsFrame:SetMovable(true)
        WishListSettingsFrame:EnableMouse(true)
        WishListSettingsFrame:RegisterForDrag("LeftButton")
        WishListSettingsFrame:SetScript("OnDragStart", function(self) self:StartMoving() end)
        WishListSettingsFrame:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)

        -- Ensure the main window is above all when focused
        WishListSettingsFrame:SetFrameStrata("DIALOG")
        WishListSettingsFrame:SetScript("OnMouseDown", function(self)
            self:Raise()
        end)
    end
    if WishListSettingsFrame:IsShown() then
        WishListSettingsFrame:Hide()
    else
        WishListSettingsFrame:Show()
    end
end
