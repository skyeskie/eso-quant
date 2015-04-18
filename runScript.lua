--
-- Created by IntelliJ IDEA.
-- User: Scott
-- Date: 4/17/2015
-- Time: 10:28 PM
-- To change this template use File | Settings | File Templates.
--

local scripts = {
    { file = "scripts/dumpSetsJson.lua", desc = "Set Info -> JSON" },
    { file = "scripts/DumpForR.lua", desc = "Single Skill Info -> for R" },
    { file = "scripts/dumpSkillDataJson.lua", desc = "Skill Fit -> JSON" },
    { file = "scripts/skillDataExtract.lua", desc = "Skill Fit -> DAT (tab-separated)"  },
    { file = "scripts/SkillFormulaDump.lua", desc = "Skill Formulas only -> CSV" },
    { file = "scripts/skillNamesByLine.lua", desc = "Skill Names -> console" },
}

--Global include function
function inc(file)
    local f = assert(loadfile("scripts/inc/" .. file .. ".lua"))
    return f()
end

local d = print
function print(str)
    d(str)
    io.stdout:flush()
end

--TODO: Prompt user for this if cfg.lua not present
cfg = assert(loadfile("cfg.lua"))()

print("Selection function to run:")
for i,desc in ipairs(scripts) do
    print("  " .. i .. ") " .. desc.desc)
end
io.stdout:write(": ");
io.stdout:flush()

local option = io.stdin:read("*n")
if not scripts[option] then
    print("Invalid option: '" .. option .. "'")
    os.exit(1)
end

dofile(scripts[option].file)