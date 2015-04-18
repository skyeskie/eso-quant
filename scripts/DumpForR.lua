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

---
--- This script is to export a particular skill's data for more analysis in R
--- Required: /quant itr-all-skills or /quant itr-class-skills
--- Edit the following to your account name to use:
local account = "@Sasky"
--- Edit server to which saved variables: "live", "liveeu", "pts"
local server = "pts"
---

local function d(v) io.stdout:write(v,"\n") end
local function prepInput() io.stdout:write(": "); io.stdout:flush()  end
local inspect = require('inspect')
dofile(os.getenv('USERPROFILE') .. "\\Documents\\Elder Scrolls Online\\"..server.."\\SavedVariables\\Quant.lua")
local main = QuantData.Default[account]["$AccountWide"].Main
local skillfull = main.SkillsFullInfo
local skilldata = main.SkillsCurve

local function selectKey(data, msg)
    local arr = {}
    for key in pairs(data) do
        table.insert(arr,key)
    end
    table.sort(arr)

    d(msg .. ":")
    for k,v in ipairs(arr) do
        d(" " .. k .. ": " .. v)
    end
    prepInput()
    local selection = io.stdin:read("*n")
    if not arr[selection] then
        io.stderr:write("Invalid selection")
        os.exit(1)
    end
    return data[arr[selection]], arr[selection]
end

local lines = selectKey(skillfull,"Select skill type")
local skills = selectKey(lines, "Select skill line")
local _,skill = selectKey(skills, "Select skill")
local skillnums = skilldata[skill.."-4"]
local dataset = selectKey(skillnums, "Select which numbers")

local f = assert(io.open("rawnum.csv", "w"))
local i = 1
f:write("MainStat,Power,Damage\n")
for k,v in pairs(dataset) do
    local _, primary, power = k:match("([MSU])([0-9.]+)P([0-9.]+)")
    f:write(primary,",",power,",",v,"\n")
end
