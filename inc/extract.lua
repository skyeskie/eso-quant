--Main fit find function
local R = require "rclient"
local r = R.connect()

local T = {}
T.types = { M="Magicka", S="Stamina", U="Ulitmate"}
function T:getFitData(data)

    --Construct arrays from data
    local mainstat_array = {}
    local power_array = {}
    local value_array = {}
    local health_array = {}
    local type = "Unknown"
    for k,v in pairs(data) do
        local msu, primary, power, health = k:match("([MSU])([0-9.]+)P([0-9.]+)H?([0-9.]+)?")
        table.insert(mainstat_array, tonumber(primary))
        table.insert(power_array, tonumber(power))
        table.insert(health_array, tonumber(health) or 0)
        table.insert(value_array, tonumber(v))
        type = self.types[msu] or "Unknown"
    end

    --Import data to R
    r["Mainstat"] = mainstat_array
    r["Power"] = power_array
    r["Values"] = value_array
    r["Health"] = health_array

    --First check if it's actually constant
    r("valconst <- max(Values) == min(Values)")
    if r["valconst"][1] then
        return {
            main=0,
            power=0,
            int=value_array[1],
            rsq=1,
            const=true,
        }
    else
        --Get linear fit
        r("fit <- lm(Values ~ Mainstat + Power + Health)")
        r("details <- summary(fit)")

        --Export results from R
        local coef = r["fit$coefficients"]
        local rsq = r["details$r.squared"]

        --Construct result output
        return {
            main=coef.Mainstat,
            power=coef.Power,
            health=coef.Health,
            int=coef["(Intercept)"],
            rsq=rsq[1],
            const=false,
            type=type,
        }
    end
end

function T:replaceNumberInDescription(str, needle, formulaSig)
    local check,f = str:find(needle)
    if check==nil then return str end
    local first = str:sub(1,f)
    local last = ""
    if #str > f then
        last = str:sub(f+1,-1)
    end
    return first:gsub(needle, formulaSig) .. last
end

function T:initSkillData(sv)
    if self.skillref then return self.skillref end
    self.skillref = {}
    local skillfull = sv.getSVEntry("SkillsFullInfo")
    for type,lines in pairs(skillfull) do
        for line,skills in pairs(lines) do
            for skill in pairs(skills) do
                self.skillref[skill] = { type=type, line=line }
            end
        end
    end
    return self.skillref
end

return T