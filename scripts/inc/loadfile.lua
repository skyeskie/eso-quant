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

---Description: Loads Quant data from SavedVariables

local M = {}
function M:loadSavedVariables(account, server)
    if self.data ~=nil then return end
    dofile(os.getenv('USERPROFILE') .. "\\Documents\\Elder Scrolls Online\\" .. server .. "\\SavedVariables\\Quant.lua")
    self.data = QuantData.Default[account]["$AccountWide"].Main
    return self.data
end

function M:getSVEntry(entry)
    return self.data[entry]
end

function M:loadSVEntry(account, server, entry)
    self:loadSavedVariables(account, server)
    return self.data[entry]
end

return M