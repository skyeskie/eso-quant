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
--
Quant.stat = {}
local stat = Quant.stat

local function getStat(stat) return GetPlayerStat(stat, STAT_BONUS_OPTION_APPLY_BONUS, STAT_SOFT_CAP_OPTION_APPLY_SOFT_CAP) end


function stat:dumpDamageStats(attr)
    local attr = attr or {}
    attr.magicka          = getStat(STAT_MAGICKA_MAX)
    attr.stamina          = getStat(STAT_STAMINA_MAX)
    attr.power            = getStat(STAT_POWER)
    attr.weapon_power     = getStat(STAT_WEAPON_POWER)
    attr.spell_power      = getStat(STAT_SPELL_POWER)
    return attr
end

function stat:dumpResistStats(stats)
    local stats = stats or {}
    stats.armor             = getStat(STAT_ARMOR_RATING)
    stats.spell_resist      = getStat(STAT_SPELL_RESIST)
    stats.resist_crit       = getStat(STAT_CRITICAL_RESISTANCE)
    stats.resist_cold       = getStat(STAT_DAMAGE_RESIST_COLD)
    stats.resist_disease    = getStat(STAT_DAMAGE_RESIST_DISEASE)
    stats.resist_drown      = getStat(STAT_DAMAGE_RESIST_DROWN)
    stats.resist_earth      = getStat(STAT_DAMAGE_RESIST_EARTH)
    stats.resist_fire       = getStat(STAT_DAMAGE_RESIST_FIRE)
    stats.resist_generic    = getStat(STAT_DAMAGE_RESIST_GENERIC)
    stats.resist_magic      = getStat(STAT_DAMAGE_RESIST_MAGIC)
    stats.resist_oblivion   = getStat(STAT_DAMAGE_RESIST_OBLIVION)
    stats.resist_physical   = getStat(STAT_DAMAGE_RESIST_PHYSICAL)
    stats.resist_poison     = getStat(STAT_DAMAGE_RESIST_POISON)
    stats.resist_shock      = getStat(STAT_DAMAGE_RESIST_SHOCK)
    stats.resist_start      = getStat(STAT_DAMAGE_RESIST_START)
    stats.mitigation        = getStat(STAT_MITIGATION)
    stats.physical_resist   = getStat(STAT_PHYSICAL_RESIST)
    stats.spell_mitigation  = getStat(STAT_SPELL_MITIGATION)
    stats.miss              = getStat(STAT_MISS)
    stats.parry             = getStat(STAT_PARRY)
    stats.block             = getStat(STAT_BLOCK)
    stats.dodge             = getStat(STAT_DODGE)
    return stats
end

function stat:dumpMountStats(stats)
    local stats = stats or {}
    stats.mount_stamina     = getStat(STAT_MOUNT_STAMINA_MAX)
    stats.mount_sp_regen    = getStat(STAT_MOUNT_STAMINA_REGEN_COMBAT)
    stats.mount_regen_move  = getStat(STAT_MOUNT_STAMINA_REGEN_MOVING)
    return stats
end

function stat:dumpAllStats()
    local stats = self:dumpDamageStats()
    self:dumpResistStats(stats)
    self:dumpMountStats(stats)
    stats.magicka_regen     = getStat(STAT_MAGICKA_REGEN_COMBAT)
    stats.stamina_regen     = getStat(STAT_STAMINA_REGEN_COMBAT)
    stats.weapon_crit       = getStat(STAT_CRITICAL_STRIKE)
    stats.spell_crit        = getStat(STAT_SPELL_CRITICAL)
    stats.armor_pen         = getStat(STAT_PHYSICAL_PENETRATION)
    stats.spell_pen         = getStat(STAT_SPELL_PENETRATION)

    stats.none              = getStat(STAT_NONE)

    stats.health_regen      = getStat(STAT_HEALTH_REGEN_COMBAT)
    stats.healing_taken     = getStat(STAT_HEALING_TAKEN)
    stats.health            = getStat(STAT_HEALTH_MAX)

    stats.idle_hp_regen     = getStat(STAT_HEALTH_REGEN_IDLE)
    stats.idle_mp_regen     = getStat(STAT_MAGICKA_REGEN_IDLE)
    stats.idle_sp_regen     = getStat(STAT_STAMINA_REGEN_IDLE)
    stats.level             = GetUnitLevel('player')
    --Could do more of the GetUnitLevel if really wanted, but this is a bit overkill as-is
    return stats
end

function stat:getKey(abilityId)
    local cost, mechanic = GetAbilityCost(abilityId)
    if mechanic == POWERTYPE_MAGICKA then
        --Magicka key
        return "M" .. getStat(STAT_MAGICKA_MAX) .. "P" .. getStat(STAT_SPELL_POWER) .. "H" .. getStat(STAT_HEALTH_MAX)
    elseif mechanic == POWERTYPE_STAMINA then
        --Stamina key
        return "S" .. getStat(STAT_STAMINA_MAX) .. "P" .. getStat(STAT_POWER) .. "H" .. getStat(STAT_HEALTH_MAX)
    elseif mechanic == POWERTYPE_ULTIMATE then
        local mainStat = math.max(getStat(STAT_MAGICKA_MAX), getStat(STAT_STAMINA_MAX))
        return "U" .. mainStat .. "P" .. getStat(STAT_POWER) .. "H" .. getStat(STAT_HEALTH_MAX)
    else
        d("Unknown ability cost type: " .. mechanic)
    end
end

function stat:save()
    local sv = Quant:load("PlayerStats")
    sv[GetUnitName('player')] = stat:dumpAllStats()
end

Quant:registerCmd("stat", "Save full stats for character", function() CS:dumpDesc() end)
--Could register other breakdowns. Keeping just the one for now