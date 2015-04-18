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
Quant.pwr = {}
local pwr = Quant.pwr

local powertypes = {
    [POWERTYPE_ADRENALINE] = "Adrenaline",
    [POWERTYPE_CHARGES] = "Charges",
    [POWERTYPE_COMBO] = "Combo",
    [POWERTYPE_FERVOR] = "Fervor",
    [POWERTYPE_FINESSE] = "Finesse",
    [POWERTYPE_HEALTH] = "Health",
    [POWERTYPE_INVALID] = "n/a",
    [POWERTYPE_MAGICKA] = "Magicka",
    [POWERTYPE_MOMENTUM] = "Momentum",
    [POWERTYPE_MOUNT_STAMINA] = "HorseStam",
    [POWERTYPE_POWER] = "Power",
    [POWERTYPE_STAMINA] = "Stamina",
    [POWERTYPE_ULTIMATE] = "Ultimate",
    [POWERTYPE_WEREWOLF] = "Werewolf"
}

--Deduped output
local ddList = {}
local function dd(id, val)
    if ddList[id] ~= val then
        d(val)
        ddList[id] = val
    end
end

function pwr:powerUpdate(type)
    EVENT_MANAGER:RegisterForEvent("QuantPower", EVENT_POWER_UPDATE,
        function(id, unit, ind, type, val, max, effmax)
            if type == type then
                if not lastval then lastval = effmax end
                type = powertypes[type] or type
                dd(id, nn(unit) ..": " .. nn(ind) .. " -- " .. nn(type) .. " => " ..nn(val) .. "/" .. nn(max) .. " (" .. nn(effmax) .. ") " .. (val - lastval) )
                lastval = val
            end
        end
    )
end

function pwr:stop()
    EVENT_MANAGER:UnregisterForEvent("QuantPower", EVENT_POWER_UPDATE)
end

function pwr:dumpPower()
    Quant:save("power", ddList)
end

Quant:registerCmd("stam", "Dump stamina changes to chat", function() pwr:powerUpdate(POWERTYPE_STAMINA) end)
Quant:registerCmd("mag", "Dump magicka changes to chat", function() pwr:powerUpdate(POWERTYPE_MAGICKA) end)
Quant:registerCmd("poweroff", "Stop stamina/magicka chat dump", function() pwr:stop() end)
Quant:registerCmd("power", "Save de-duped power to vars (req. stam or mag)", function() pwr:dumpPower() end)

--[[

For logging combat info:
 EVENT_COMBAT_EVENT (
        integer result,
        bool isError,
        string abilityName,
        integer abilityGraphic,
        integer abilityActionSlotType,
        string sourceName,
        integer sourceType,
        string targetName,
        integer targetType,
        integer hitValue,
        integer powerType,
        integer damageType,
        bool log
 )

  EVENT_IMPACTFUL_HIT ??

 EVENT_EFFECT_CHANGED (
        integer changeType,
        integer effectSlot,
        string effectName,
        string unitTag,
        number beginTime,
        number endTime,
        integer stackCount,
        string iconName,
        string buffType,
        integer effectType,
        integer abilityType,
        integer statusEffectType
 )

 xxEVENT_ABILITY_COOLDOWN_UPDATED (integer abilityId)

 EVENT_ABILITY_REQUIREMENTS_FAIL (integer errorId)

 xxEVENT_STATS_UPDATED (string unitTag)

 EVENT_POWER_UPDATE (string unitTag, luaindex powerIndex, integer powerType, integer powerValue, integer powerMax, integer powerEffectiveMax)
  --used for updating main stats of player


 xxEVENT_NON_COMBAT_BONUS_CHANGED (integer nonConbatBonus, integer oldValue, integer newValue)

 ?EVENT_ACTION_SLOT_GAME_UPDATE


 ?EVENT_ACTION_SLOT_STATE_UPDATE(d)
--]]