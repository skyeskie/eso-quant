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
Quant.sets = {}
local sets = Quant.sets

---Convenience class. Acts like a mapping ID <=> text
---Putting item auto-increments ID
BidiMap = {}
BidiMap.__index = BidiMap
function BidiMap.new()
    local self = setmetatable({}, BidiMap)
    self.lut = {}
    self.data = {}
    return self
end

function BidiMap:getId(string)
    if self.lut[string] then
        return self.lut[string]
    end
    --Add entry
    table.insert(self.lut, string)
    local id = #self.lut
    self.lut[string] = id
    self.data[id] = {}
    return id, true
end

function BidiMap:getData(index)
    --Number, so direct lookup
    if type(index) == "number" then
        return self.data[index]
    end
    --String, so lookup
    local id, new = self:getId(index)
    return self.data[id], new
end
-------------------------------------------------

--Lookup
local SLOT_LOOKUP = {
    [EQUIP_SLOT_BACKUP_MAIN] = "Weapon",
    [EQUIP_SLOT_BACKUP_OFF] = "Weapon2",
    [EQUIP_SLOT_CHEST] = "Chest",
    [EQUIP_SLOT_CLASS1] = "EQUIP_SLOT_CLASS1",
    [EQUIP_SLOT_CLASS2] = "EQUIP_SLOT_CLASS2",
    [EQUIP_SLOT_CLASS3] = "EQUIP_SLOT_CLASS3",
    [EQUIP_SLOT_COSTUME] = "EQUIP_SLOT_COSTUME",
    [EQUIP_SLOT_FEET] = "Feet",
    [EQUIP_SLOT_HAND] = "Hand",
    [EQUIP_SLOT_HEAD] = "Head",
    [EQUIP_SLOT_LEGS] = "Legs",
    [EQUIP_SLOT_MAIN_HAND] = "Weapon",
    [EQUIP_SLOT_NECK] = "Necklace",
    [EQUIP_SLOT_NONE] = "EQUIP_SLOT_NONE",
    [EQUIP_SLOT_OFF_HAND] = "Weapon2",
    [EQUIP_SLOT_RANGED] = "EQUIP_SLOT_RANGED",
    [EQUIP_SLOT_RING1] = "Ring",
    [EQUIP_SLOT_RING2] = "Ring",
    [EQUIP_SLOT_SHOULDERS] = "Shoulders",
    [EQUIP_SLOT_TRINKET1] = "EQUIP_SLOT_TRINKET1",
    [EQUIP_SLOT_TRINKET2] = "EQUIP_SLOT_TRINKET2",
    [EQUIP_SLOT_WAIST] = "Waist",
    [EQUIP_SLOT_WRIST] = "Wrist",
}

local ARMOR_TYPE_LOOKUP = {
    [ARMORTYPE_HEAVY] = "Heavy",
    [ARMORTYPE_LIGHT] = "Medium",
    [ARMORTYPE_MEDIUM] = "Light",
    [ARMORTYPE_NONE] = "None",
}

local WEAPON_TYPE_LOOKUP = {
    [WEAPONTYPE_AXE] = "Axe",
    [WEAPONTYPE_BOW] = "Bow",
    [WEAPONTYPE_DAGGER] = "Dagger",
    [WEAPONTYPE_FIRE_STAFF] = "Fire Staff",
    [WEAPONTYPE_FROST_STAFF] = "Frost Staff",
    [WEAPONTYPE_HAMMER] = "Hammer",
    [WEAPONTYPE_HEALING_STAFF] = "Restoration Staff",
    [WEAPONTYPE_LIGHTNING_STAFF] = "Lightning Staff",
    [WEAPONTYPE_NONE] = "None",
    [WEAPONTYPE_RUNE] = "WEAPONTYPE_RUNE",
    [WEAPONTYPE_SHIELD] = "Shield",
    [WEAPONTYPE_SWORD] = "Sword",
    [WEAPONTYPE_TWO_HANDED_AXE] = "Battle Axe",
    [WEAPONTYPE_TWO_HANDED_HAMMER] = "Mace (2h)",
    [WEAPONTYPE_TWO_HANDED_SWORD] = "Greatsword",
}

--Return same value if can't lookup
--setmetatable(SLOT_LOOKUP, { __index = function(v) return v end})
--setmetatable(ARMOR_TYPE_LOOKUP, { __index = function(v) return v end})

local setInfo = BidiMap.new()
local bonusInfo = BidiMap.new()

function sets:getInfo(id)
    local link = "|H0:item:"..id..":288:50:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:10000:0|h[Item "..id.."]|h"
    local slot1, slot2 = GetComparisonEquipSlotsFromItemLink(link)
    local item = {
        name = GetItemLinkName(link),
        id = id,
        level = GetItemLinkRequiredLevel(link),
        vetRank = GetItemLinkRequiredVeteranRank(link),
        quality = GetItemLinkQuality(link),
        bindable = GetItemLinkBindType(link),
        equipSlot1 = (SLOT_LOOKUP[slot1]),
        equipSlot2 = (SLOT_LOOKUP[slot2]),
    }
    item.link = "|H0:item:"..id..":288:50:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:10000:0|h[Item " .. (item.link or id) .. "]|h"
    if GetItemLinkItemType(link) == ITEMTYPE_ARMOR then
        item.type = "ARMOR"
        item.armorType = ARMOR_TYPE_LOOKUP[GetItemLinkArmorType(link)] or GetItemLinkArmorType(link)
        item.armor = GetItemLinkArmorRating(link, false)
    end

    if GetItemLinkItemType(link) == ITEMTYPE_WEAPON then
        item.type = "WEAPON"
        item.weaponType = WEAPON_TYPE_LOOKUP[GetItemLinkWeaponType(link)]
        item.power = GetItemLinkWeaponPower(link)
    end

    local isSet, setName, nBonus = GetItemLinkSetInfo(link, false)
    if isSet then
        local isNew
        item.set, isNew = setInfo:getId(setName)
        if isNew then
            local setEntry = setInfo:getData(item.set)
            if setEntry == nil then d("NIL") end
            setEntry.name = setName
            setEntry.bonuses = {}
            for i=1,nBonus do
                local n,desc = GetItemLinkSetBonusInfo(link, false, i)
                desc = string.gsub(desc or "", "^\([0-9] items\) ","")
                local id,new = bonusInfo:getId(desc)
                if new then
                    local descTable = bonusInfo:getData(id)
                    descTable.desc = desc
                end
                table.insert(setEntry.bonuses, {id=id, n=n})
            end
        end
    end

    if item.type and item.set then
        return item
    end
    return nil
end

function sets:saveItr()
    d("Scanning from " .. self.itr)
    for i = self.itr,(self.itr+1000) do
        local item = self:getInfo(i)
        if item then
            table.insert(self.data.items, item)
        end
    end

    self.itr = self.itr + 1000
    if self.itr >= self.itrMax then
        d("Finished scan")
        EVENT_MANAGER:UnregisterForUpdate("QuantGearInfo")
    end
end

function sets:saveAll()
    --Zero data
    Quant:save("GearInfo", {
        items = {},
        sets = setInfo.data,
        bonuses = bonusInfo.data,
    })
    --Now grab for iteration
    self.data = Quant:load("GearInfo")

    self.itr = 0
    self.itrMax = 75000
    EVENT_MANAGER:RegisterForUpdate("QuantGearInfo", 100, function()
        self:saveItr()
    end)
end

Quant:registerCmd("sets", "Dump all gear set info", function() sets:saveAll() end)