-- WishListLogic.lua
-- WishList addon logic: database interaction and event handling

function Encode(color, text)
    return string.format("|c%s%s|r", color, text)
end

function PrintRed(text)
    print(Encode("FF850000", text))
end

local function dump(o)
   if type(o) == 'table' then
      local s = '{ '
      for k,v in pairs(o) do
         if type(k) ~= 'number' then k = '"'..k..'"' end
         s = s .. '['..k..'] = ' .. dump(v) .. ','
      end
      return s .. '} '
   else
      return tostring(o)
   end
end
