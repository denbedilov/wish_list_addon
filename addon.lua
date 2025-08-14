WishListAddon = LibStub():NewAddon("WishList")

function WishListAddon:OnInitialize()
    -- Initialization code here
    WishListAddon:addMapIcon()
    print("WishListAddon initialized.")
end