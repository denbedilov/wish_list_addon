-- WishListCommunication.lua
-- Handles WishList sync via addon messages

local ADDON_PREFIX = "WishList"

-- Register prefix on load
C_ChatInfo.RegisterAddonMessagePrefix(ADDON_PREFIX)

-- Serialize WishListDB.items using AceSerializer if available, else fallback to tostring
local AceSerializer = LibStub and LibStub("AceSerializer-3.0", true)

local updatable = false

WishListCommunication = {}

function WishListCommunication:SerializeWishList()
    -- Include distributed and redCards in the data sent
    local data = {
        items = WishListDB.items,
        distributed = WishListDB.distributed,
        redCards = WishListDB.redCards,
        personalwishlist = WishListDB.personalwishlist,
    }
    if AceSerializer then
        return AceSerializer:Serialize(data)
    else
        return tostring(data)
    end
end

function WishListCommunication:DeserializeWishList(data)
    if AceSerializer then
        local success, tbl = AceSerializer:Deserialize(data)
        if success then return tbl end
    end
    return nil
end

-- Send your wishlist to a channel ("GUILD", "RAID", "WHISPER", etc.)
function WishListCommunication:SendWishList(channel, target)
    local data = self:SerializeWishList()
    if channel == "WHISPER" and target then
        C_ChatInfo.SendAddonMessage(ADDON_PREFIX, "WISHLIST_UPDATE" .. data, "WHISPER", target)
    else
        C_ChatInfo.SendAddonMessage(ADDON_PREFIX, "WISHLIST_UPDATE" .. data, channel)
    end
end

-- Returns true if we can send distributed count to guild (if in guild and distributed exists)
function WishListCommunication:isWishListUpdatable()
    -- Only allow if in a guild and distributed is present
    if IsInGuild() then
        -- Send distributed count to guild channel
        local msg = "GET_DISTRIBUTED"
        C_ChatInfo.SendAddonMessage(ADDON_PREFIX, msg, "GUILD")
    end
    print("|cffffff00[WishList]|r You must be in a guild to update your wishlist from others.")
    return false
end

-- Handle incoming messages
local commFrame = CreateFrame("Frame")
commFrame:RegisterEvent("CHAT_MSG_ADDON")
commFrame:SetScript("OnEvent", function(self, event, prefix, message, channel, sender)
    if prefix ~= ADDON_PREFIX then return end
    print("|cff00ff00[WishList]|r Received addon message from:", sender)
    if message == "REQ" and channel == "WHISPER" then
        -- Someone requested our wishlist, send it back
        WishListCommunication:SendWishList("WHISPER", sender)
    elseif message == "GET_DISTRIBUTED" and channel == "GUILD" then
        local myDistributed = WishListDB and WishListDB.distributed or 0
        C_ChatInfo.SendAddonMessage(ADDON_PREFIX, "DISTRIBUTED:" .. tostring(myDistributed), "WHISPER", sender)
    elseif message == "DISTRIBUTED" and channel == "WHISPER" then
        -- Received distributed count from another player
        local theirDistributed = tonumber(message:match("^DISTRIBUTED:(%d+)"))
        local myDistributed = 0
        if WishListDB and WishListDB.distributed then
            myDistributed = WishListDB.distributed
        end
        
        if theirDistributed and theirDistributed > myDistributed then
            print("|cffffff00[WishList]|r A newer wishlist version is available from " .. sender .. " (" .. theirDistributed .. " > " .. myDistributed .. ")")
            -- Optionally, request their full wishlist:
            C_ChatInfo.SendAddonMessage(ADDON_PREFIX, "REQ", "WHISPER", sender)
        end
    elseif message:find("^WISHLIST_UPDATE") and channel == "WHISPER" then
        -- Received wishlist data
        local payload = message:gsub("^WISHLIST_UPDATE", "")
        local data = WishListCommunication:DeserializeWishList(payload)
        if data then
            print("|cff00ff00[WishList]|r Received wishlist from:", sender)
            -- Only update if received distributed is higher or local is missing
            local theirDistributed = 0
            if type(data) == "table" and data.distributed then
                theirDistributed = tonumber(data.distributed) or 0
            end
            local myDistributed = WishListDB and WishListDB.distributed or 0
            if theirDistributed > myDistributed then
                -- Save the received wishlist (full DB)
                for k, v in pairs(data) do
                    WishListDB[k] = v
                end
                print("|cff00ff00[WishList]|r Wishlist updated from " .. sender .. " (distributed: " .. theirDistributed .. ")")
            else
                print("|cffffff00[WishList]|r Received wishlist from " .. sender .. " but it is not newer (distributed: " .. theirDistributed .. ", local: " .. myDistributed .. ")")
            end
        end
    else
        print("|cffffff00[WishList]|r Received unknown message from " .. sender .. ": " .. message)
    end
end)

return WishListCommunication