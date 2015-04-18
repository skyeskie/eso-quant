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

--------------------------------------------------------
-- Quant
--   a tool for quantitative analysis of ESO
--
-- Different tools stored as modules, CLI access
--
-- Author: Sasky
--------------------------------------------------------


Quant = {}
local cmd = {} --command callbacks
local man = {} --description of commands

function Quant:registerCmd(command, desc, callback)
    cmd[command] = callback
    man[command] = desc
end

function Quant:cli(option)
    if cmd[option] then
        cmd[option]()
    else
        d(option)
        d("Quant commands:")
        for name,info in pairs(man) do
            d("    " .. name .. ": " .. info)
        end
    end
end

local save
-- Put output to saved vars. Overwrite previous
function Quant:save(module, values)
    if not save then
        save = ZO_SavedVars:NewAccountWide("QuantData", 1, "Main", {})
        Quant.data = save
    end
    save[module] = values
end

-- Get saved vars module for merging
function Quant:load(module)
    if not save then
        save = ZO_SavedVars:NewAccountWide("QuantData", 1, "Main", {})
        Quant.data = save
    end
    if not save[module] then
        save[module] = {}
    end
    return save[module]
end

SLASH_COMMANDS['/quant'] = function(...) Quant:cli(...) end