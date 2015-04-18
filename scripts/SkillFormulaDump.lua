local fin = io.open("./skilldata.dat", "r")
local fout = io.open("./formulae.csv", "w")

local function split(inputstr, sep)
    if sep == nil then
        sep = "%s"
    end
    local t={}
    local i=1
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
        t[i] = str
        i = i + 1
    end
    return t
end

for line in fin:lines() do
    local keys = split(line,"\t")
    for i=17,#keys,4 do
        local row = {
            keys[1].."-"..(i-13)/4,
            keys[i],
            keys[i+1],
            keys[i+2],
            keys[i+3]
        }
        fout:write(table.concat(row,","),"\n")
    end
end
