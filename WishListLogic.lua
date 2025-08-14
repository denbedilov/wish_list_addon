-- WishListLogic.lua

function Encode(color, text)
    return string.format("|c%s%s|r", color, text)
end

function PrintRed(text)
    print(Encode("FF8D0202", text))
end
