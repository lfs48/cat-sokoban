--Utility functions

local util = {}

--Deeply copy a table
--From https://stackoverflow.com/questions/640642/how-do-you-copy-a-lua-table-by-value
function util.deepClone(obj, seen)
    if type(obj) ~= 'table' then return obj end
    if seen and seen[obj] then return seen[obj] end
    local s = seen or {}
    local res = setmetatable({}, getmetatable(obj))
    s[obj] = res
    for k, v in pairs(obj) do res[util.deepClone(k, s)] = util.deepClone(v, s) end
    return res
end

--Export module
return util
  