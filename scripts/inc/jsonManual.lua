local function line(indent, string)
    f:write(string.rep("  ",indent))
    f:write(string)
    f:write("\n")
    f:flush()
end

local function escape(str) return '"' .. str:gsub('"','\"') .. '"' end

line(0,"{")
line(1, '"bonus": {')
local last
for key,t in ipairs(setdata.bonuses) do
    if t.desc then
        if last then line(2, last .. ",") end
        last = key .. ': ' .. escape(t.desc):gsub("|cffffff",""):gsub("|r","")
    end
end
if last then line(2,last) end
line(1,"},")

line(1, '"set": {')
local last
for key,t in ipairs(setdata.sets) do
    if last then line(2, last .. ",") end
    line(2, key .. ": {")
    line(3, '"name": ' .. escape(t.name) .. ",")
    line(3, '"bonuses": [')
    if t.bonuses then
        local lastBonus
        for _,bonus in pairs(t.bonuses) do
            if lastBonus then line(4, lastBonus .. ",") end
            lastBonus = '{ "req": ' .. bonus.n .. ', "id": ' .. bonus.id .. '  }'
        end
        line(4,lastBonus)
    end
    line(3,"]")
    last = "}"
end
line(2,last)
line(1, '"}')
line(0,"}")
setdata.items = {} --This is way too big to handle at the moment