--[[
Description: Print a list of skills in a tree of type/skill line.

Known issue: For some reason, 3 skills show up in every skill line:
Mages Wrath, Mage's Fury, Endless Fury
 ]]


local inspect = require('inspect')

local function dump(v) print(inspect(v)) end

dofile(os.getenv('USERPROFILE') .. "\\Documents\\Elder Scrolls Online\\pts\\SavedVariables\\Quant.lua")

local main = QuantData.Default["@Sasky"]["$AccountWide"].Main

local skillfull = main.SkillsFullInfo

for type,lines in pairs(skillfull) do
    print("\n" .. type)
    for line,skills in pairs(lines) do
        print("--\t" .. line)
        for skill in pairs(skills) do
            print("\t" .. skill)
        end
    end
end

--print(inspect(skillfull))