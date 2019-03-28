local oxomoco = {
    core = {}
}

oxomoco.core.beginswith = function(s, t)
    return s:sub(0, #t) == t
end

oxomoco.core.endswith = function(s, t)
    return s:sub(#s-#t, #s) == t
end

--- Get every unique pairing of two elements from a table.
-- E.g. {a, b, c} -> {{a, b}, {a, c}, {b, c}}
oxomoco.core.pairings = function(tab)
    local byindex = {}
    local count = 0
    for name, item in pairs(tab) do
        count = count + 1
        byindex[count] = item
    end
    local pp = {}
    for i=1, count do
        local a = byindex[i]
        for j=i+1, count do
            local b = byindex[j]
            pp[#pp+1] = {a, b}
        end
    end
    return pp
end

local _logs = {}

--- Backup debugger
oxomoco.core.log = function(text, maxShow)
    text = text or '!'
    table.insert(_logs, tostring(text))
    print(text)
    local begin = 1
    if maxShow then
        begin = math.max(1, #_logs - maxShow)
    end
    local text = table.concat(_logs, ' / ', begin, #_logs)
    pcall(function() love.window.setTitle(text) end)
end

--- Apply defaults to tables.
oxomoco.core.apply = function(tab, default)
    if tab then
        for n, v in pairs(default) do
            tab[n] = tab[n] or v
        end
    else
        tab = default
    end
end

--- Returns a copy of any item (i.e. by value, not reference).
-- Specify deep=true for recursive dereferencing for nested
-- tables et cetera.
-- Specify meta=true to copy metatables (which may conflict
-- with class methods)
oxomoco.core.copy = function(orig, deep, meta)
    deep = deep or false
    meta = meta or false
    local new
    if type(orig) == 'table' then
        new = {}
        for key, val in pairs(orig) do
            if deep then
                new[key] = val
            else
                new[oxomoco.core.copy(key, true)] = oxomoco.core.copy(val, true)
            end
        end
        if meta then
            setmetatable(new, oxomoco.core.copy(getmetatable(orig), true))
        else
            setmetatable(new, getmetatable(orig))
        end
    else
        new = orig
    end
    return new
end

local default_prototype = {
    -- allow inheritance of methods
    __name = 'unknown',
    __index = function(self, key)
        local mt = getmetatable(self) or {}
        if mt == self then return nil end
        return mt[key]
    end,

    -- tell type detectors 'I am a oxomoco item'
    __oxomoco = true,

    -- default items to be assigned
    __defaults = {},

    -- function called after assignment of values
    __init = function(self) end,

    -- something better than 'table'
    __tostring = function(self)
        return '<' .. self.__name .. '>'
    end
}

--- Object type generator returning initialiser.
-- Every oxomoco object is a table, and its metatable
-- is the prototype. If __index is not specified,
-- indexing falls through to this metatable, so
-- you can provide object methods directly.
-- For initialisation you can specify in the prototype
-- the following:
-- __defaults: default variables to imbue into the new object.
--             specify them here and not in the prototype, as
--             weird reference mangling can occur otherwise.
--             You can also provide function(self) returning
--             a value (for variables dependant on others).
-- __init(object): function called at end of initialisation

-- todo: inheritance
oxomoco.core.class = function(prototype)
    oxomoco.core.apply(prototype, default_prototype)

    local asString = '<vector>'

    local metaproto = {
        __oxomocoClass = true,

        __call = function(tab)
            tab = tab or {}
            tab = setmetatable(tab, prototype)
            oxomoco.core.apply(tab, prototype.__defaults)
            tab:__init()
            return tab
        end,

        __tostring = function() return prototype.__name end
    }
    prototype.new = metaproto.__call
    prototype = setmetatable(prototype, metaproto)
    return prototype
end

oxomoco.core.type = function(object)
    local proto = getmetatable(object) or {}
    if proto.__oxomoco then
        return proto
    elseif proto.__oxomocoClass then
        return oxomoco.core.class
    else
        return type(object)
    end
end

local isInstance = function(object, class)
    return oxomoco.core.type(object) == class
end

oxomoco.core.isInstance = function(object, classList)
    if oxomoco.core.type(classList) == oxomoco.core.class then
        classList = {classList}
    end
    for i, class in pairs(classList) do
        if isInstance(object, class) then return true end
    end
    return false
end

return oxomoco.core