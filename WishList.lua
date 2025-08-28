-- WishList.lua
-- init file for the WishList addon

WishListAddon = LibStub("AceAddon-3.0"):NewAddon("WishList")

function WishListAddon:OnInitialize()

    -- Create a database for storing settings
    WishListDB = WishListDB or {}
    WishListDB.char = WishListDB.char or {}

    -- Addon name and version
    self.AddonNameAndVersion = "|cff00ff00[WishList]|r v" .. (WISHLIST_VERSION or "?.?.?")

    -- Add icon to the minimap
    self:AddMapIcon()

    -- Use the new update function instead of BuildLists directly
    -- self:UpdateWishList()

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
        -- Pass the character settings table to store the icon position
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
                -- Get red cards list from WishListDB
                local redCards = WishListDB and WishListDB.redCards or {}
                local isRed = {}
                for _, rc in ipairs(redCards) do
                    isRed[rc] = true
                end
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
                        if isRed[player] then
                            WishListExtraTooltip:AddLine("|cffff0000"..player.."|r")
                        else
                            WishListExtraTooltip:AddLine("|cff00ff00"..player.."|r")
                        end
                    end
                    if #falsePlayers > 0 then
                        if isRed[falsePlayers[1]] then
                            WishListExtraTooltip:AddLine("|cffff0000"..falsePlayers[1].."|r")
                        else
                            WishListExtraTooltip:AddLine("|cffffff00"..falsePlayers[1].."|r")
                        end
                        for i = 2, #falsePlayers do
                            if isRed[falsePlayers[i]] then
                                WishListExtraTooltip:AddLine("|cffff0000"..falsePlayers[i].."|r")
                            else
                                WishListExtraTooltip:AddLine("|cff888888"..falsePlayers[i].."|r")
                            end
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

-- Function to update WishList data
function WishListAddon:UpdateWishList()
    -- Check if wishlistdata (Items) is not empty
    if Items and next(Items) then
        -- Data exists, just build lists from it
        if WishListClass and WishListClass.BuildLists then
            WishListClass:BuildLists(true)
            print("|cff00ff00[WishList]|r Wishlist loaded from file.")
        end
    else
        -- Data is empty, try to update from communication
        if WishListCommunication and WishListCommunication.isWishListUpdatable and WishListCommunication:isWishListUpdatable() then
            print("|cff00ff00[WishList]|r Requested wishlist update from other players.")
            WishListCommunication:UpdateWishList()
        else
            -- Fallback: build lists from local data
            if WishListClass and WishListClass.BuildLists then
                WishListClass:BuildLists(false)
                print("|cff00ff00[WishList]|r Wishlist loaded from local DataBase.")
            end
        end
    end
end

-- Register a slash command to open the main window
SLASH_WISHLIST1 = "/wishlist"
SLASH_WISHLIST2 = "/wl"
SlashCmdList["WISHLIST"] = function(msg)
    WishListAddon:ToggleMainFrame()
end