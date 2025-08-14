-- WishListUI.lua
-- All logic for WishList addon

function Encode(color, text)
    return string.format("\124c%s%s\124r", color, text)
end

function Printred(text)
    print(Encode("FF8D0202", text))
end




