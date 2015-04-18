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
--- Required: /quant itr-all-skills or /quant itr-class-skills and /quant skill-full in-game
--- Required: Rserve must be ruu.nning for this script

print("Loading libraries")
local cfg = assert(loadfile("cfg.lua"))()
local u = assert(loadfile("inc/util.lua"))()
local sv = assert(loadfile("inc/loadfile.lua"))()
local JSON = assert(loadfile "inc/JSON.lua")()

print("Account: " .. cfg.account)
print("Server: " .. cfg.server)

print("Loading saved variables")
sv:loadSavedVariables(cfg.account, cfg.server)
local r = assert(loadfile "inc/extract.lua")()

local skilldata = sv:getSVEntry("SkillsCurve")
local skillfull = sv:getSVEntry("SkillsFullInfo")
local skillref = r:initSkillData(sv)

print("Processing raw data into fit info")
local outfile = {}
for skill_lvl,numbers in pairs(skilldata) do
    local skill = skill_lvl:gsub("..$","")
    local ref = skillref[skill]
    local data = skillfull[ref.type][ref.line][skill]

    local skillInfo = {
        name=skill,
        type=ref.type,
        line=ref.line,
        rank=data.rank or 4, --Hardcoding rank 4, though possible want different ranks later
        description=data.description,
        descriptionHeader=data.descriptionHeader,
        mechanic=u.getMechanicName(data.mechanic),
        cost=data.cost,
        target=data.targetDescription,
        minRange=data.minRangeCM,
        maxRange=data.maxRangeCM,
        radius=data.radiusCM,
        distance=data.distanceCM,
        channeled=data.channeled,
        castTime=data.castTime,
        channelTime=data.channelTime,
        durationMS=data.durationMS,
    }

    local lastFindPos = 1
    local formulaNum = 1
    local formulae = {}
    skillInfo.fit = {}
    for _,rawnumbers in ipairs(numbers) do
        local fit = r:getFitData(rawnumbers)
        local delta = 1E-5
        if fit.main < delta then fit.main = 0 end
        if fit.power < delta then fit.power = 0 end
        if fit.health < delta then fit.health = 0 end
        if fit.int < delta then fit.int = 0 end

        local desc = skillInfo.description
        local start = desc:find("|c")
        local _,fin = desc:find("|r")
        local toReplace = desc:sub(start,fin)

        local formulasig = u.makeKey(fit.main, fit.power, fit.health, fit.int, fit.rsq)
        if fit.const then
            skillInfo.description = r:replaceNumberInDescription(desc, toReplace, fit.int)
        else
            if not formulae[formulasig] then
                formulae[formulasig] = "##f" .. formulaNum .. "##"
                skillInfo.fit[formulasig] = {
                    mainCoef=fit.main,
                    powerCoef=fit.power,
                    healthCoef=fit.health,
                    intercept=fit.int,
                    rsq=fit.rsq,
                }
                formulaNum = formulaNum + 1
            end

            skillInfo.description = r:replaceNumberInDescription(desc, toReplace, formulae[formulasig])
        end
    end

    outfile[skill] = skillInfo
end

print("Writing results to: skilldata.json")
local f = assert(io.open("skilldata.json", "w"))
f:write(JSON:encode_pretty(outfile))
f:close()