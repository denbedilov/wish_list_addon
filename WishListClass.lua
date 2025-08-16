-- WishListClass.lua
-- Reads Items from wishlistdata.lua and builds:
-- 1. items = { [itemId] = { {player, hasItem}, ... }, ... } -- ordered list!
-- 2. personalwishlist = { [slot] = { itemId = ..., players = { {player, hasItem}, ... } }, ... }
-- Only items for the current player are included in personalwishlist.

WishListClass = {}
WishListClass.__index = WishListClass

local itemsData = Items or (wishlistdata and wishlistdata.Items)

function WishListClass:BuildLists(force)
    if force then
        WishListDB.items = nil
        WishListDB.personalwishlist = nil
    end
    local items = {}
    local personalwishlist = {}
    local playerName = UnitName and UnitName("player") or "player"

    local fingerCount, trinketCount = 0, 0

    -- Items = { ["chest"] = { [itemId] = { players = { {player, hasItem}, ... } }, ... }, ... }
    for slot, slotItems in pairs(itemsData or {}) do
        for itemId, itemData in pairs(slotItems) do
            local players = itemData.players or {}
            -- 1. Build items[itemId] = { {player, hasItem}, ... } (ordered)
            items[itemId] = {}
            for i, entry in ipairs(players) do
                items[itemId][i] = {entry[1], entry[2]}
            end

            -- 2. Build personalwishlist[slot] = { itemId = ..., players = { {player, hasItem}, ... } } for current player
            local found = false
            for _, entry in ipairs(players) do
                if entry[1] == playerName then
                    found = true
                    break
                end
            end
            if found then
                local orderedPlayers = {}
                for i, entry in ipairs(players) do
                    orderedPlayers[i] = {entry[1], entry[2]}
                end
                if slot == "finger" then
                    fingerCount = fingerCount + 1
                    local fingerSlot = "finger" .. fingerCount
                    personalwishlist[fingerSlot] = {
                        itemId = itemId,
                        players = orderedPlayers
                    }
                elseif slot == "trinket" then
                    trinketCount = trinketCount + 1
                    local trinketSlot = "trinket" .. trinketCount
                    personalwishlist[trinketSlot] = {
                        itemId = itemId,
                        players = orderedPlayers
                    }
                else
                    personalwishlist[slot] = {
                        itemId = itemId,
                        players = orderedPlayers
                    }
                end
            end
        end
    end

    WishListDB.items = items
    WishListDB.personalwishlist = personalwishlist
end

function WishListClass:PrintItems()
    print("=== All Items ===")
    for itemId, playerArr in pairs(WishListDB.items or {}) do
        local playerList = {}
        for _, entry in ipairs(playerArr) do
            local player, hasItem = entry[1], entry[2]
            local color = hasItem and "|cff00ff00" or "|cffffff00"
            table.insert(playerList, color .. player .. "|r")
        end
        print("ItemID:", itemId, "Players:", table.concat(playerList, ", "))
    end
    print("=== End All Items ===")
end

function WishListClass:PrintPersonalWishlist()
    print("=== Personal Wishlist ===")
    for slot, data in pairs(WishListDB.personalwishlist or {}) do
        local playerList = {}
        for _, entry in ipairs(data.players) do
            local player, hasItem = entry[1], entry[2]
            local color = hasItem and "|cff00ff00" or "|cffffff00"
            table.insert(playerList, color .. player .. "|r")
        end
        print("Slot:", slot, "ItemID:", data.itemId, "Players:", table.concat(playerList, ", "))
    end
    print("=== End Personal Wishlist ===")
end

function WishListClass:GetOrderedPlayersByItemId(itemId)
    if not WishListDB or not WishListDB.items then return {} end
    local playerArr = WishListDB.items[tostring(itemId)]
    if not playerArr then return {} end
    return playerArr
end

return WishListClass