-- WishListLogic.lua

-- -- Подключение библиотеки для работы с JSON
-- local json = json or {}

function Encode(color, text)
    return string.format("|c%s%s|r", color, text)
end

function PrintRed(text)
    print(Encode("FF850000", text))
end

-- Импортирует JSON-строку, валидирует и добавляет в WishListDB.gearList
function WishListImportFromJSON(jsonText)
    print("|cff00ff00[WishList]|r Importing from JSON:", jsonText)
    local obj = json.decode(jsonText)
    print("|cff00ff00[WishList]|r Importing list '", obj)
    WishListDB = WishListDB or {}
    WishListDB.gearList = WishListDB.gearList or {}
    WishListDB.gearList = obj
    print("|cff00ff00[WishList]|r Imported list '", WishListDB.gearList)
    return true
end