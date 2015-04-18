-- This file is part of Quant
--
-- (C) 2015 Scott Yeskie (Sasky)
--
-- This program is free software; you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation; either version 2 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <http://www.gnu.org/licenses/>.

--- Used to extract set data into JSON format
print("Loading libraries")
local cfg = assert(loadfile("cfg.lua"))()
local u = assert(loadfile("inc/util.lua"))()
local sv = assert(loadfile("inc/loadfile.lua"))()
JSON = assert(loadfile "inc/JSON.lua")()
cfg.server = "live"
print("Account: " .. cfg.account)
print("Server: " .. cfg.server)

print("Loading saved variables")
data = sv:loadSavedVariables(cfg.account, cfg.server)
setdata = sv:getSVEntry("GearInfo")

local function addItemToSet(item)
    local set = setdata.sets[item.set]
    if not set then return end
    if item.armorType or item.equipSlot1 then
        if not set.items then set.items = {} end
        set.items["id"..item.id] = {
            armor = item.armorType,
            piece = item.equipSlot1,
            weapon = item.weaponType,
        }
    end
end

local f = assert(io.open("gearSets.json", "w"))
local i=1
for _,item in pairs(setdata.items) do
    addItemToSet(item)
end
setdata.items = {}
local jsonSetData = JSON:encode_pretty(setdata)
f:write(jsonSetData)
f:close()