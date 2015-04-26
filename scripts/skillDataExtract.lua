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

--- Used to extract SavedVariables
--- Required: /quant itr-all-skills or /quant itr-class-skills and /quant skill-full in-game
--- Required: Rserve must be running for this script

print("Loading libraries")
local cfg = cfg or assert(loadfile("cfg.lua"))()
local u = inc("util")
local sv = inc("loadfile")
local r = inc("extract")

print("Account: " .. cfg.account)
print("Server: " .. cfg.server)

print("Loading saved variables")
sv:loadSavedVariables(cfg.account, cfg.server)
local skilldata = sv:getSVEntry("SkillsCurve")
local skillfull = sv:getSVEntry("SkillsFullInfo")
local skillref = r:initSkillData(sv)

--Header
local header = {
    "Skill",
    "Skill Type",
    "Skill Line",
    "Rank",
    "Description",
    "Description 2",
    "Mechanic",
    "Cost",
    "Target",
    "Min Range",
    "Max Range",
    "Radius",
    "Distance",
    "Channeled?",
    "Cast Time",
    "Channel Time",
    "Duration"
}

local f = assert(io.open("skilldata.dat", "w"))
f:write(table.concat(header,"\t"),"\n")
for skill_lvl,numbers in pairs(skilldata) do
    local skill = skill_lvl:gsub("..$","")
    local ref = skillref[skill]
    local data = skillfull[ref.type][ref.line][skill]

    local row = {
        skill,
        u.nn(ref.type),
        u.nn(ref.line),
        4, --Hardcoding rank 4, though possible want different ranks later
        u.nn(data.description),
        u.nn(data.descriptionHeader),
        u.getMechanicName(data.mechanic),
        u.nn(data.cost),
        u.nn(data.targetDescription),
        u.nn(data.minRangeCM),
        u.nn(data.maxRangeCM),
        u.nn(data.radiusCM),
        u.nn(data.distanceCM),
        u.bl(data.channeled),
        u.nn(data.castTime),
        u.nn(data.channelTime),
        u.nn(data.durationMS)
    }

    local DESCR = 5

    local lastFindPos = 1
    local formulaNum = 1
    local formulae = {}
    for _,rawnumbers in ipairs(numbers) do
        local fit = r:getFitData(rawnumbers)
        local delta = 1E-5
        if fit.main < delta then fit.main = 0 end
        if fit.power < delta then fit.power = 0 end
        if fit.int < delta then fit.int = 0 end

        local desc = row[DESCR]
        local start = desc:find("|c")
        local _,fin = desc:find("|r")
        local toReplace = desc:sub(start,fin)

        local formulasig = fit.main .. "/" .. fit.power .. "/" .. fit.int .. "/" .. fit.rsq
        if fit.const then
            row[DESCR] = r:replaceNumberInDescription(desc, toReplace, fit.int)
        else
            if not formulae[formulasig] then
                table.insert(row,fit.main)
                table.insert(row,fit.power)
                table.insert(row,fit.health)
                table.insert(row,fit.int)
                table.insert(row,fit.rsq)
                formulae[formulasig] = "##f" .. formulaNum .. "##"
                formulaNum = formulaNum + 1
            end
            row[DESCR] = r:replaceNumberInDescription(desc, toReplace, formulae[formulasig])
        end
    end

    for k,v in ipairs(row) do
        if type(v) == "string" then
            row[k] = v:gsub("[\t\n]", "  ")
        end
    end
    f:write(table.concat(row,"\t"),"\n")
end

