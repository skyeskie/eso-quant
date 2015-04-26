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

---Description: Various utility functions

---Inspect: Quick formatted output of Lua table
local u = {}
local inspect = require('inspect')
function u.dump(v) print(inspect(v)) end

---nn: Makes sure value is not NIL
function u.nn(v) if v == nil then return "##NIL/UNKNOWN" end return v end
---bl: Converts boolean to text true/false
function u.bl(v) if v then return "TRUE" end return "FALSE" end

---Sort utility
function u.sortSet(set)
    local array = {}
    for k in pairs(set) do
        table.insert(array, k)
    end
    table.sort(array)
    return array
end

---Translates ESO constants to Magicka, Stamina, and Ultimate
function u.getMechanicName(mechanic)
    if mechanic == 0 then return "Magicka"
    elseif mechanic == 6 then return "Stamina"
    elseif mechanic == 10 then return "Ultimate"
    else return "Unknown: " .. u.nn(mechanic) end
end

---For nested tables, creates tables down to depth as  needed
function u.makeDepth(t, list)
    if not t then return end

    local ptr = t;
    for _,v in ipairs(list) do
        if not ptr[v] then
            ptr[v] = {}
        end
        ptr = ptr[v]
    end
end

---Joins values into a unique, key value. Currently just concat
function u.makeKey(...)
    return table.concat({...},"/")
end
return u