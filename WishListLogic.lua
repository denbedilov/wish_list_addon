-- WishListUI.lua
-- All logic for WishList addon

-- Подключение библиотеки для работы с JSON
local json = require("lib.json")

function Encode(color, text)
    return string.format("\124c%s%s\124r", color, text)
end

function PrintRed(text)
    print(Encode("FF8D0202", text))
end

-- Импортирует JSON-строку, валидирует и добавляет в WishListDB.gearLists
function WishListImportFromJSON(jsonText)
    print("|cff00ff00[WishList]|r Importing from JSON:", jsonText)
    local obj = json.decode(jsonText)
    print("|cff00ff00[WishList]|r Importing list '", obj)
    WishListDB = WishListDB or {}
    WishListDB.gearLists = WishListDB.gearLists or {}
    WishListDB.gearLists = obj
    print("|cff00ff00[WishList]|r Imported list '", WishListDB.gearList)
    return true
end