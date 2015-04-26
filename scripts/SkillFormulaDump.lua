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

---Used to get just skill formulas in CSV
---Required: skillDataExtract.lua run and .dat file in local directory

local fin = io.open("./skilldata.dat", "r")
local fout = io.open("./formulae.csv", "w")

local function split(inputstr, sep)
    if sep == nil then
        sep = "%s"
    end
    local t={}
    local i=1
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
        t[i] = str
        i = i + 1
    end
    return t
end

for line in fin:lines() do
    local keys = split(line,"\t")
    --For DAT, formulas are just sets 5 numbers at the end of set columns
    --So iterate in groups of 5 to get
    for i=17,#keys,5 do
        local row = {
            keys[1].."-"..(i-12)/5,
            keys[i],
            keys[i+1],
            keys[i+2],
            keys[i+3],
            keys[i+4]
        }
        fout:write(table.concat(row,","),"\n")
    end
end
