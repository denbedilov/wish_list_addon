-- addon.lua
WishListAddon = LibStub("AceAddon-3.0"):NewAddon("WishList")

function WishListAddon:OnInitialize()
    -- Создаём базу данных для хранения настроек
    self.db = LibStub("AceDB-3.0"):New("WishListDB", { char = {} }, true)

    -- Название и версия аддона
    self.AddonNameAndVersion = "|cff00ff00[WishList]|r v" .. (WISHLIST_VERSION or "?.?.?")

    -- Добавляем иконку на мини-карту
    self:AddMapIcon()

    print(self.AddonNameAndVersion .. " initialized.")
end

function WishListAddon:AddMapIcon()
    local LDB = LibStub("LibDataBroker-1.1", true)
    local LDBIcon = LDB and LibStub("LibDBIcon-1.0", true)
    if not LDB then return end

    local dataObj = LDB:NewDataObject("WishListIcon", {
        type = "launcher",
        text = "WishList",
        icon = "Interface\\Icons\\Inv_chest_cloth_challengemage_d_01.blp",
        OnClick = function(_, button)
            if button == "LeftButton" then
                WishListAddon:ToggleMainFrame()
            elseif button == "RightButton" then
                WishListAddon:ToggleSettingsFrame()
            end
        end,
        OnTooltipShow = function(tt)
            tt:AddLine(WishListAddon.AddonNameAndVersion)
            tt:AddLine("|cffffff00Left click|r to open the WishList window")
            tt:AddLine("|cffffff00Right click|r to open addon settings")
        end,
    })

    if LDBIcon then
        -- Передаём таблицу настроек персонажа для хранения позиции иконки
        LDBIcon:Register("WishListIcon", dataObj, self.db.char)
    end
end

function WishListAddon:ToggleMainFrame()
    if not self.MainFrame then
        self:CreateMainFrame()
        self.MainFrame:Show()  
    else
        if self.MainFrame:IsShown() then
            self.MainFrame:Hide()
        else
            self.MainFrame:Show()
        end
    end
end


function WishListAddon:ToggleSettingsFrame()
    if not self.SettingsFrame then
        self:CreateSettingsFrame()
        self.SettingsFrame:Show()
    else
        if self.SettingsFrame:IsShown() then
            self.SettingsFrame:Hide()
        else
            self.SettingsFrame:Show()
        end
    end
end
