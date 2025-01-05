if GetLocale() ~= "ptBR" then
    return
end

local _, tbl = ...
local LocaleStrings = {
}

for k, v in pairs(LocaleStrings) do
    tbl.LocaleStrings[k] = v
end
