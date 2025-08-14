-- WishList.lua

local eventFrame = CreateFrame("Frame")
WishListDB = WishListDB or {}
eventFrame:RegisterEvent("PLAYER_LOGIN")
eventFrame:SetScript("OnEvent", function(self, event, ...)
    -- Инициализация базы данных при загрузке аддона
    WishListDB = WishListDB or {}
    WishListDB.gearLists = WishListDB.gearLists or {}
    PrintRed("WishList Addon loaded. Version: " .. (WISHLIST_VERSION or "unknown"))
end)



-- Minimap icon setup using LibDataBroker and LibDBIcon
local LDB = LibStub and LibStub("LibDataBroker-1.1", true)
local LDBIcon = LibStub and LibStub("LibDBIcon-1.0", true)

if LDB and LDBIcon then
    local dataobj = LDB:NewDataObject("WishList", {
        type = "launcher",
        text = "WishList",
        icon = "interface/icons/Inv_chest_cloth_challengemage_d_01.blp",
        OnClick = function(self, button)
            if button == "LeftButton" then
                -- Open player gear window
                WishList_ToggleMainFrame()
            elseif button == "RightButton" then
                -- Open settings window
                WishList_ToggleSettingsFrame()
            else
            end
        end,
        OnTooltipShow = function(tooltip)
            tooltip:AddLine("WishList v" .. (WISHLIST_VERSION or "unknown"))
            tooltip:AddLine("Left Click to open WishList")
            tooltip:AddLine("Right Click to open settings")
        end,
    })

    -- SavedVariables for minimap icon position
    if not WishListDB.minimap then WishListDB.minimap = {} end

    LDBIcon:Register("WishList", dataobj, WishListDB.minimap)
end