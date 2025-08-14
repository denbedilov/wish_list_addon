local icon_loaded = false
local icon_name = "WishListIcon"

function WishListAddon:addMapIcon()
    -- if WishListAddon.db.char.minimap_icon then
    icon_loaded = true
    local LDB = LibStub("LibDataBroker-1.1", true)
    local LDBIcon = LDB and LibStub("LibDBIcon-1.0", true)
    if LDB then
        local PC_MinimapBtn = LDB:NewDataObject(icon_name, {
            type = "launcher",
            text = icon_name,
            icon = "interface/icons/inv-chest-cloth-challengemage-d-01.blp",
            OnClick = function(_, button)
                if button == "LeftButton" then
                    WishListAddon:createMainFrame()
                end
                if button == "RightButton" then
                    WishListAddon:openConfigDialog()
                end
            end,
            OnTooltipShow = function(tt)
                tt:AddLine(WishListAddon.AddonNameAndVersion)
                tt:AddLine("|cffffff00Left click|r to open the BiS lists window")
                tt:AddLine("|cffffff00Right click|r to open addon configuration window")
            end,
        })
        if LDBIcon then
            LDBIcon:Register(icon_name, PC_MinimapBtn, WishListAddon.db.char)
        end
    end
    -- end
end