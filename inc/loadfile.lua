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