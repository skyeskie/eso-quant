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

---Description: Print a list of skills in a tree of type/skill line.
---Known issue: For some reason, 3 skills show up in every skill line:
---      Mages Wrath, Mage's Fury, Endless Fury
---Required: /quant skill-full in-game

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
