local u = {}
local inspect = require('inspect')
function u.dump(v) print(inspect(v)) end

function u.nn(v) if v == nil then return "##NIL/UNKNOWN" end return v end
function u.bl(v) if v then return "TRUE" end return "FALSE" end

function u.sortSet(set)
    local array = {}
    for k in pairs(set) do
        table.insert(array, k)
    end
    table.sort(array)
    return array
end

function u.getMechanicName(mechanic)
    if mechanic == 0 then return "Magicka"
    elseif mechanic == 6 then return "Stamina"
    elseif mechanic == 10 then return "Ultimate"
    else return "Unknown: " .. nn(mechanic) end
end
return u