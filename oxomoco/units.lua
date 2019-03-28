oxomoco = {
    core = require 'oxomoco.core',
    units = {}
}

--- Scientific notation with default base 10.
-- Base can be changed (eg 1000 / 1024 for prefixes)
oxomoco.units.scinot = function(value, base)
    base = base or 10
    local mg = 0
    repeat
        if value < 1 then
            mg = mg - 1
            value = value * base
        elseif value > 10 then
            mg = mg + 1
            value = value / base
        end
    until (1 < value) and (value < base)
    return value, mg
end

oxomoco.units.SI = {
    base = 1000,
    {-8,'y', 'yocto'},
    {-7,'z', 'zepto'},
    {-6,'a', 'atto'},
    {-5,'f', 'femto'},
    {-4,'p', 'pico'},
    {-3,'n', 'nano'},
    {-2,'µ', 'micro'},
    {-1,'m', 'milli'},
    {1, 'k', 'kilo'},
    {2, 'M', 'mega'},
    {3, 'G', 'giga'},
    {4, 'T', 'tera'},
    {5, 'P', 'peta'},
    {6, 'E', 'exa'},
    {7, 'Z', 'zetta'},
    {8, 'Y', 'yotta'},
}

oxomoco.units.IEC = {
    base = 1024,
    {1, 'Ki', 'kibi'},
    {2, 'Mi', 'mebi'},
    {3, 'Gi', 'gibi'},
    {4, 'Ti', 'tebi'},
    {5, 'Pi', 'pebi'},
    {6, 'Ei', 'ebi'},
    {7, 'Zi', 'zibi'},
    {8, 'Yi', 'yibi'},
}

oxomoco.units.prefix = function(number, digits, longForm, system)
    digits = digits or 3
    system = system or oxomoco.units.SI
    longForm = longForm or false

    local value, mg = oxomoco.units.scinot(number, system.base)

    value = string.format('%.' .. tostring(digits) .. 'f', value)

    if system then
        for i, p in ipairs(system) do
            local magnitude, prefix, long = p
            if mg == magnitude then
                if longForm then
                    prefix = long
                end
                return value .. ' ' .. prefix
            end
        end
    end
    return value .. '×' .. system.base .. '^' .. mg
end

oxomoco.units.scientific = function(number, digits)
    local value, mg = oxomoco.units.scinot(number, system.base)
    value = string.format('%.' .. tostring(digits) .. 'f', value)
    return value ..'×10^' .. mg
end

return oxomoco.units