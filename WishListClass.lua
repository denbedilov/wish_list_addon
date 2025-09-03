-- WishListClass.lua
-- Reads Items from wishlistdata.lua and builds:
-- 1. items = { [itemId] = { {player, hasItem}, ... }, ... } -- ordered list!
-- 2. personalwishlist = { [slot] = { itemId = ..., players = { {player, hasItem}, ... } }, ... }
-- Only items for the current player are included in personalwishlist.

WishListClass = {}
WishListClass.__index = WishListClass

local itemsData = Items or (wishlistdata and wishlistdata.Items)
local redCards = Red_cards or (wishlistdata and wishlistdata.Red_cards)

function WishListClass:BuildLists(force)
    -- Only rebuild if force or DB is empty
    if not force and WishListDB.items and next(WishListDB.items) then
        return
    end

    -- Always build from file (Items/RedCards)
    local itemsSource = Items or (wishlistdata and wishlistdata.Items)
    local redCardsSource = RedCards or (wishlistdata and wishlistdata.RedCards)

    WishListDB.items = nil
    WishListDB.personalwishlist = nil
    WishListDB.redCards = nil
    WishListDB.distributed = nil
    WishListDB.slotMap = {}

    local items = {}
    local personalwishlist = {}
    local redCardsList = {}
    local distributed = 0
    local playerName = UnitName and UnitName("player") or "player"

    local fingerCount, trinketCount = 0, 0

    for slot, slotItems in pairs(itemsSource or {}) do
        for itemId, itemData in pairs(slotItems) do
            -- Build slotMap for itemId
            WishListDB.slotMap[itemId] = slot

            -- Save item name if present (as additional parameter under item id)
            items[itemId] = { name = itemData.name }

            local players = itemData.players or {}
            for i, entry in ipairs(players) do
                items[itemId][i] = {entry[1], entry[2]}
                if entry[2] then
                    distributed = distributed + 1
                end
            end

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

    if redCardsSource then
        for _, player in ipairs(redCardsSource) do
            table.insert(redCardsList, player)
        end
    end

    WishListDB.items = items
    WishListDB.personalwishlist = personalwishlist
    WishListDB.redCards = redCardsList
    WishListDB.distributed = distributed
    -- slotMap is already built above
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
        local name = (playerArr.name or (WishListDB.itemNames and WishListDB.itemNames[itemId])) or tostring(itemId)
        print(name, " : ", table.concat(playerList, ", "))
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
        local itemId = data.itemId
        local name = (WishListDB.items and WishListDB.items[itemId] and WishListDB.items[itemId].name)
            or (WishListDB.itemNames and WishListDB.itemNames[itemId])
            or tostring(itemId)
        print(slot, " : ", name, " : ", table.concat(playerList, ", "))
    end
    print("=== End Personal Wishlist ===")
end

function WishListClass:GetOrderedPlayersByItemId(itemId)
    if not WishListDB or not WishListDB.items then return {} end
    local playerArr = WishListDB.items[tostring(itemId)]
    if not playerArr then return {} end
    return playerArr
end

function WishListClass:Equip(itemId, player)
    if not WishListDB or not WishListDB.items or not itemId or not player then return end
    itemId = tostring(itemId)
    local playerArr = WishListDB.items[itemId]
    if not playerArr then return end
    for _, entry in ipairs(playerArr) do
        if entry[1] == player then
            entry[2] = true
            WishListDB.distributed = (WishListDB.distributed or 0) + 1
            break
        end
    end
end

function WishListClass:Unequip(itemId, player)
    if not WishListDB or not WishListDB.items or not itemId or not player then return end
    itemId = tostring(itemId)
    local playerArr = WishListDB.items[itemId]
    if not playerArr then return end
    for _, entry in ipairs(playerArr) do
        if entry[1] == player then
            entry[2] = false
            WishListDB.distributed = math.max((WishListDB.distributed or 0) - 1, 0)
            break
        end
    end
end

return WishListClass