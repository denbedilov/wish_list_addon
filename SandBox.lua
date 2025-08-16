dofile("WishListClass.lua")

json = require("lib.json")

-- Read JSON from file
local function read_file(filename)
    local f = assert(io.open(filename, "r"))
    local content = f:read("*a")
    f:close()
    return content
end

-- returns dumpped table
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

-- local json_text = read_file("wishlist.json") -- replace with your actual filename
local json_text = [[
{
	"agility": {
		"leather": {
			"head":{
				"token":{
					"itemID":"123",
					"players":[
						{"Джуниеса":false},
						{"Мбх":false},
						{"Пивнойпанд":false}
					]
				},
				"some head":{
					"itemID":"123",
					"players":[
						{"den":true},
						{"max":false},
						{"random":false}
					]
				}
			},
			"neck":{
				"some neck":{
					"itemID":"86953",
					"players":[
						{"Джуниеса":true},
						{"Мбх":false},
						{"Пивнойпанд":false}
					]
				}
			}
		}
	},
	"strength": {},
	"intellect": {}
}
]]

local function test_json(jsonText)
    local obj = WishListClass.FromJSON(jsonText) or {}
    obj:Print()
    -- print(dump(obj))
end

test_json(json_text)