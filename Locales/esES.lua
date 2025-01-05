if GetLocale() ~= "esES" then
    return
end

local _, tbl = ...
local LocaleStrings = {
}

for k, v in pairs(LocaleStrings) do
    tbl.LocaleStrings[k] = v
end
