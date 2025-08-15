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
    local obj = WishListClass.FromJSON(jsonText)
    WishListDB.gearList = obj
    print("|cff00ff00[WishList]|r Imported list '", WishListDB.gearList)
    return true
end

