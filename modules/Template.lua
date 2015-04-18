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

--[[
-- Example Quant module
--
-- Use this as a basis for other modules
 ]]

--Setup the namespace for the module
Quant = Quant or {}
Quant.foo = {}
local foo = Quant.foo

--Put all functions/variables into the namespace
function foo:saveRepeated()
    --Quant:load is used to get access to SavedVariables
    --This is used if you want to add to the values with successive calls
    --For example, a skill dump on a Nightblade should add to skill dump data
    local sv = Quant:load("Foo", {})
    sv.set = foo:bar()
end

function foo:saveOnce()
    --Quant:save is used to replace existing savedata
    --Use this if a single run captures all information
    Quant:save("Bar", {a=1, b=2})
end

--Register the commands with the Quant handler
--These contain the command name, documentation, and function to call
--NOTE: No parameters can be passed in for the current implementation
Quant:registerCmd("foo", "man foo", function() foo:save() end)