-- WishList.lua
-- init file for the WishList addon

WishListAddon = LibStub("AceAddon-3.0"):NewAddon("WishList")

function WishListAddon:OnInitialize()

    -- Создаём базу данных для хранения настроек
    WishListDB = WishListDB or {}

    -- Название и версия аддона
    self.AddonNameAndVersion = "|cff00ff00[WishList]|r v" .. (WISHLIST_VERSION or "?.?.?")

    -- Добавляем иконку на мини-карту
    self:AddMapIcon()

    -- Load WishList from a file
    WishListClass:BuildLists()

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

-- Create your extra tooltip once

if not WishListExtraTooltip then
    WishListExtraTooltip = CreateFrame("GameTooltip", "WishListExtraTooltip", UIParent, "GameTooltipTemplate")
end

GameTooltip:HookScript("OnTooltipSetItem", function(self)
    local name, link = self:GetItem()
    if link then
        local itemID = tonumber(link:match("item:(%d+)"))
        if itemID and WishListClass and WishListClass.GetOrderedPlayersByItemId then
            local players = WishListClass:GetOrderedPlayersByItemId(tostring(itemID))
            if players and #players > 0 then
                local truePlayers, falsePlayers = {}, {}
                for _, entry in ipairs(players) do
                    local player, has = entry[1], entry[2]
                    if has then
                        table.insert(truePlayers, player)
                    else
                        table.insert(falsePlayers, player)
                    end
                end
                if #truePlayers > 0 or #falsePlayers > 0 then
                    WishListExtraTooltip:SetOwner(GameTooltip, "ANCHOR_NONE")
                    WishListExtraTooltip:ClearAllPoints()
                    WishListExtraTooltip:SetPoint("TOPLEFT", GameTooltip, "TOPRIGHT", 0, 0)
                    WishListExtraTooltip:ClearLines()
                    WishListExtraTooltip:AddLine("BiS for :")
                    for _, player in ipairs(truePlayers) do
                        WishListExtraTooltip:AddLine("|cff00ff00"..player.."|r")
                    end
                    if #falsePlayers > 0 then
                        WishListExtraTooltip:AddLine("|cffffff00"..falsePlayers[1].."|r")
                        for i = 2, #falsePlayers do
                            WishListExtraTooltip:AddLine("|cff888888"..falsePlayers[i].."|r")
                        end
                    end
                    WishListExtraTooltip:Show()
                    return
                end
            end
        end
    end
    WishListExtraTooltip:Hide()
end)

GameTooltip:HookScript("OnHide", function()
    if WishListExtraTooltip then WishListExtraTooltip:Hide() end
end)