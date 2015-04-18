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

Quant.skill = {}
local skill = Quant.skill

-- Puts all stats into particular ability ID
-- @param abilityId: ESO Ability ID
-- @param stats (optional): table to add to
-- @param nested (optional): if present, dumpt to stats[skillName]
function skill:dumpStats(abilityId, dump, nested)
    dump = dump or {}
    local name = GetAbilityName(abilityId)
    local stats = dump
    if nested then
        dump[name] = {}
        stats = dump[name]
    end

    stats.name = name

    --Description
    stats.descriptionHeader = GetAbilityDescriptionHeader(abilityId)
    stats.description = GetAbilityDescription(abilityId)

    --Cast Time
    local channeled, castTime, channelTime = GetAbilityCastInfo(abilityId)
    stats.channeled = channeled
    stats.castTime = castTime
    stats.channelTime = channelTime

    --Target
    stats.targetDescription = GetAbilityTargetDescription(abilityId)
    --Range
    local minRangeCM, maxRangeCM = GetAbilityRange(abilityId)
    stats.minRangeCM = minRangeCM
    stats.maxRangeCM = maxRangeCM

    --Radius/Distance
    stats.radiusCM = GetAbilityRadius(abilityId)
    stats.distanceCM = GetAbilityAngleDistance(abilityId)

    --Duration
    stats.durationMS = GetAbilityDuration(abilityId)

    --Cost. Mechanic: 0=Magicka, 6=Stamina
    local cost, mechanic = GetAbilityCost(abilityId)
    stats.cost = cost
    stats.mechanic = mechanic
    return stats
end

local typeNames = {
    [SKILL_TYPE_ARMOR] = "Armor",
    [SKILL_TYPE_AVA] = "AvA",
    [SKILL_TYPE_CLASS] = "Class",
    [SKILL_TYPE_GUILD] = "Guild",
    [SKILL_TYPE_NONE] = "None",
    [SKILL_TYPE_RACIAL] = "Racial",
    [SKILL_TYPE_TRADESKILL] = "Tradeskill",
    [SKILL_TYPE_WEAPON] = "Weapon",
    [SKILL_TYPE_WORLD] = "World",
}

function skill:getTypeName(skillType)
    local skillTreeName = typeNames[skillType] or skillType
    if skillType == SKILL_TYPE_CLASS then
        skillTreeName = GetUnitClass('player')
    elseif skillType == SKILL_TYPE_RACIAL then
        --TODO: Determine race?
    end
    return skillTreeName
end

---
-- @brief Iterates over all skills, executing a callback for each skill
-- @param callback - callback function for iteration. Signature: fn(skillType, skillLineIndex, abilityIndex)
-- @param filterTypes (optional) - Types to not iterate on. See typeNames for list of values.
--
function skill:iterateSkills(callback, filterTypes)
    filterTypes = filterTypes or {}
    for skillType = 1, GetNumSkillTypes() do
        if filterTypes[skillType] == nil then
            for skillLineIndex = 1, GetNumSkillLines(skillType) do
                for abilityIndex = 1, GetNumSkillAbilities(skillType, skillLineIndex) do
                    callback(skillType, skillLineIndex, abilityIndex)
                end
            end
        end
    end
end

function skill:simpleDescDump(dump)
    dump = dump or {}
    self:iterateSkills(
        function(skillType, skillLineIndex, abilityIndex)
            local _,_,_,_,_,_,progIndex = GetSkillAbilityInfo(skillType, skillLineIndex, abilityIndex)
            local id0 = GetAbilityProgressionAbilityId(progIndex, 0, 4)
            local id1 = GetAbilityProgressionAbilityId(progIndex, 1, 4)
            local id2 = GetAbilityProgressionAbilityId(progIndex, 2, 4)
            dump[GetAbilityName(id0)] = GetAbilityDescription(id0)
            dump[GetAbilityName(id1)] = GetAbilityDescription(id1)
            dump[GetAbilityName(id2)] = GetAbilityDescription(id2)
        end,
        { SKILL_TYPE_TRADESKILL=0 }
    )
    return dump
end

function skill:extractNumbers(id, dump)
    local name = GetAbilityName(id)
    local desc = GetAbilityDescription(id)
    local i = 1
    for num in string.gfind(desc, "|c......([0-9.]+)|r") do
        dump[name .. "-" .. i] = tostring(num)
        i = i + 1
    end
end

function skill:numberSnapshot(dump)
    dump = dump or {}
    self:iterateSkills(
        function(skillType, skillLineIndex, abilityIndex)
            local _,_,_,passive,_,_,progIndex = GetSkillAbilityInfo(skillType, skillLineIndex, abilityIndex)
            if not passive then
                --Note: hardcoding rank to 4 so max on each
                self:extractNumbers(GetAbilityProgressionAbilityId(progIndex, 0, 4), dump)
                self:extractNumbers(GetAbilityProgressionAbilityId(progIndex, 1, 4), dump)
                self:extractNumbers(GetAbilityProgressionAbilityId(progIndex, 2, 4), dump)
            end
        end,
        { SKILL_TYPE_TRADESKILL=0 }
    )
    return dump
end

Quant:registerCmd("skill-desc", "Dump flat skill description", function()
    d("Dumping skill descriptions")
    local dump = Quant:load("SkillsSimple")
    skill:simpleDescDump(dump)
end)

Quant:registerCmd("skill-full", "Dump skill numbers", function()
    d("Dumping skill numbers")
    local dump=Quant:load("SkillsFullInfo")
    local self=skill
    skill:iterateSkills(
        function(skillType, skillLineIndex, abilityIndex)
            local _,_,_,_,_,_,progIndex = GetSkillAbilityInfo(skillType, skillLineIndex, abilityIndex)
            local typeName = self:getTypeName(skillType)


            if not dump[typeName] then dump[typeName] = {} end
            local skillLineName = GetSkillLineInfo(skillType, skillLineIndex)
            if not dump[typeName][skillLineName] then dump[typeName][skillLineName] = {} end

            local line = dump[typeName][skillLineName]

            --Note: hardcoding rank to 4 so max on each
            self:dumpStats(GetAbilityProgressionAbilityId(progIndex, 0, 4), line, true)
            self:dumpStats(GetAbilityProgressionAbilityId(progIndex, 1, 4), line, true)
            self:dumpStats(GetAbilityProgressionAbilityId(progIndex, 2, 4), line, true)
        end,
        { SKILL_TYPE_TRADESKILL=0 }
    )
end)