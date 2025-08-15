-- Класс Slot, содержит список вещей
local Slot = {}
Slot.__index = Slot

-- Класс Item, содержит список игроков с булевым значением
local Item = {}
Item.__index = Item

function Item:New(item)
    local obj = setmetatable({}, self)
    obj.itemID = item.itemID -- Имя предмета, если нужно
    obj.players = {}
    if type(item) ~= "table" then
        error("Item:New expects a table of players!")
    else
        for player, hasItem in pairs(item.players) do
            obj.players[player] = hasItem
        end
    end
    if obj.players == {} then
        error("Item must have at least one player!")
    end
    return obj
end

function Item:Print()
    local playerList = {}
    for _, player in pairs(self.players) do
        for player, hasItem in pairs(player) do
            print("    " .. tostring(player) .. " " .. tostring(hasItem))
        end
    end
end

function Slot:New(slotName)
    local obj = setmetatable({}, self)
    obj.items = {} -- список вещей в этом слоте
    if slotName.items then
        for item in pairs(slotName.items) do
            obj.items[item] = Item:New(slotName.items[item])
        end
    else
        for item in pairs(slotName) do
            obj.items[item] = Item:New(slotName[item])
        end
        if obj.items == {} then
            error("Slot must have at least one Item!")
        end
    end
    return obj
end

function Slot:GetPlayersForItem(itemName)
    local result = {}
    local itemTable = self.items[itemName]
    if type(itemTable) == "table" then
        for player, hasItem in pairs(itemTable) do
            result[player] = hasItem
        end
    end
    return result
end

function Slot:Print()
    for item, itemObj in pairs(self.items) do
        print("  " .. tostring(item))
        if itemObj and itemObj.Print then
            itemObj:Print()
        end
    end
end

-- WishListClass.lua
-- Класс и логика для работы со списками экипировки и их взаимодействия с базой данных


-- Класс для типа брони с атрибутами по слотам
local ArmorType = {}
ArmorType.__index = ArmorType

function ArmorType:New(armorType)
    local obj = setmetatable({}, self)
    if armorType.head then
        obj.head = Slot:New(armorType.head)
    end
    if armorType.neck then
        obj.neck = Slot:New(armorType.neck)
    end
    if armorType.shoulder then
        obj.shoulder = Slot:New(armorType.shoulder)
    end
    if armorType.back then
        obj.back = Slot:New(armorType.back)
    end
    if armorType.chest then
        obj.chest = Slot:New(armorType.chest)
    end
    if armorType.wrist then
        obj.wrist = Slot:New(armorType.wrist)
    end
    if armorType.hands then
        obj.hands = Slot:New(armorType.hands)
    end
    if armorType.waist then
        obj.waist = Slot:New(armorType.waist)
    end
    if armorType.legs then
        obj.legs = Slot:New(armorType.legs)
    end
    if armorType.feet then
        obj.feet = Slot:New(armorType.feet)
    end
    if armorType.finger1 then
        obj.finger1 = Slot:New(armorType.finger1)
    end
    if armorType.finger2 then
        obj.finger2 = Slot:New(armorType.finger2)
    end
    if armorType.trinket1 then
        obj.trinket1 = Slot:New(armorType.trinket1)
    end
    if armorType.trinket2 then
        obj.trinket2 = Slot:New(armorType.trinket2)
    end
    if armorType.mainHand then
        obj.mainHand = Slot:New(armorType.mainHand)
    end
    if armorType.offHand then
        obj.offHand = Slot:New(armorType.offHand)
    end
    return obj
end

function ArmorType:Print()
    for slotName, slotObj in pairs(self) do
        if type(slotObj) == "table" and slotObj.Print then
            print("- " .. tostring(slotName) .. ":")
            slotObj:Print()
        end
    end
end

-- Базовый класс для главного стата
local MainStat = {}
MainStat.__index = MainStat

function MainStat:New(statName)
    local obj = setmetatable({}, self)
    if statName.cloth then
        obj.cloth = ArmorType:New(statName.cloth)
    end
    if statName.leather then
        obj.leather = ArmorType:New(statName.leather)
    end
    if statName.mail then
        obj.mail = ArmorType:New(statName.mail)
    end
    if statName.plate then
        obj.plate = ArmorType:New(statName.plate)
    end
    return obj
end

function MainStat:Print()
    for _, armorType in ipairs({"cloth","leather","mail","plate"}) do
        if self[armorType] and self[armorType].Print then
            print("== " .. armorType .. " ==")
            self[armorType]:Print()
        end
    end
end


-- Класс для списка экипировки с атрибутами
WishListClass = {}
WishListClass.__index = WishListClass

function WishListClass:New(intellect, agility, strength)
    local obj = setmetatable({}, self)
    obj.intellect = MainStat:New(intellect)
    obj.agility = MainStat:New(agility)
    obj.strength = MainStat:New(strength)
    return obj
end

-- Инициализация объекта WishListClass из JSON-строки
function WishListClass.FromJSON(jsonText)
    if type(jsonText) ~= "string" or jsonText == "" then
        print("|cffff0000[WishList]|r Invalid or empty import string.")
        return nil
    end
    local obj = json.decode(jsonText)
    if type(obj) ~= "table" then
        print("|cffff0000[WishList]|r Import failed: invalid JSON format.")
        return nil
    end
    if not obj.intellect or not obj.agility or not obj.strength then
        print("|cffff0000[WishList]|r Import failed: missing attributes.")
        return nil
    end
    return WishListClass:New(
        obj.intellect,
        obj.agility,
        obj.strength)
end

function WishListClass:Print()
    print("WishListClass:")
    if self.intellect and self.intellect.Print then
        print("[Intellect]")
        self.intellect:Print()
    else
        print("[Intellect] not available")
    end
    if self.agility and self.agility.Print then
        print("[Agility]")
        self.agility:Print()
    else
        print("[Agility] not available")
    end
    if self.strength and self.strength.Print then
        print("[Strength]")
        self.strength:Print()
    else
        print("[Strength] not available")
    end
end

function LoadWishListFromDB()
    if not WishListDB or not WishListDB.gearList then
        print("|cffff0000[WishList]|r Нет сохранённого gearList в базе данных.")
        return nil
    end
    local data = WishListDB.gearList
    if data.intellect and data.agility and data.strength then
        WishListDB.gearList = WishListClass:New(data.intellect, data.agility, data.strength)
    else
        print("|cffff0000[WishList]|r gearList в базе данных не содержит нужных полей.")
        return nil
    end
end
-- Добавляем WishListClass в глобальную область видимости для работы с SandBox.lua
-- _G.WishListClass = WishListClass
