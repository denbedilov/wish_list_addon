-- WishList.lua
-- init file for the WishList addon

WishListAddon = LibStub("AceAddon-3.0"):NewAddon("WishList")

function WishListAddon:OnInitialize()
    -- Создаём базу данных для хранения настроек
    WishListDB = WishListDB or {}
    LoadWishListFromDB()

    -- Название и версия аддона
    self.AddonNameAndVersion = "|cff00ff00[WishList]|r v" .. (WISHLIST_VERSION or "?.?.?")

    -- Добавляем иконку на мини-карту
    self:AddMapIcon()

    -- Load WishList from a file
    -- self:LoadWishList()

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
        LDBIcon:Register("WishListIcon", dataObj, WishListDB.char)
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

function WishListAddon:LoadWishList()
    local json = require("lib.json")
    local json_text = read_file("wishlist.json") -- replace with your actual filename

    if not json_text or json_text == "" then
        print("|cffff0000[WishList]|r Error: wishlist.json is empty or missing.")
        return
    end

    local success, err = pcall(function()
        WishListImportFromJSON(json_text)
    end)

    if not success then
        print("|cffff0000[WishList]|r Error importing wishlist: " .. tostring(err))
    else
        print("|cff00ff00[WishList]|r Wishlist loaded successfully.")
    end
end
