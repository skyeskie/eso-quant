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

Quant = Quant or {}
Quant.CS = {}

local CS = Quant.CS

function CS:storePoints()
    local out = {}
    for i = 1, GetNumChampionDisciplines() do
        out[i] = {}
        for j = 1, GetNumChampionDisciplineSkills(i) do
            out[i][j] = GetNumPointsSpentOnChampionSkill(i, j)
        end
    end
    return out
end

function CS:generateCurve(constellation, skill)
    local curve = {}
    for i = 1, GetMaxPossiblePointsInChampionSkill() do
        local tooltip = GetChampionAbilityDescription(GetChampionAbilityId(constellation, skill), i);
        local value = string.match(tooltip, "[%d%.]+")
        table.insert(curve, value)
    end
    return curve
end

function CS:generateCPRates()
    local out = {}
    for i = 1, GetNumChampionDisciplines() do
        local constellation = GetChampionDisciplineName(i)
        out[constellation] = {}
        for j = 1, 4 do --Hardcode 4 so don't iterate over passives
            local skill = GetChampionSkillName(i,j)
            out[constellation][skill] = CS:generateCurve(i,j)
            out[constellation][skill].description = GetChampionAbilityDescription(GetChampionAbilityId(i, j), 100)
        end
    end
    return out
end

function CS:getCPDescriptions(level)
    level = level or 100
    local out = {}
    for i = 1, GetNumChampionDisciplines() do
        local constellation = GetChampionDisciplineName(i)
        out[constellation] = {}
        for j = 1, 8 do --Grab passives too
            local skill = GetChampionSkillName(i,j)
            out[constellation][skill] = GetChampionAbilityDescription(GetChampionAbilityId(i, j), level)
        end
    end
    return out
end

Quant:registerCmd("cs", "Dump ChampionSystem skill detail",
    function()
        Quant:save("ChampSysCurves", CS:generateCPRates())
    end
)

Quant:registerCmd("cs-desc", "Dump ChampionSystem skill descriptions",
    function()
        Quant:save("ChampSkills", CS:getCPDescriptions())
    end
)
