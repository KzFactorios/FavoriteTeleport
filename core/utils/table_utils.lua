-- table_utils.lua
-- Table/array utility functions for FavoriteTeleport

local TableUtils = {}

function TableUtils.shallow_copy(tbl)
  local t = {}
  for k, v in pairs(tbl) do t[k] = v end
  return t
end

function TableUtils.remove_first(tbl, value)
  for i, v in ipairs(tbl) do
    if v == value then table.remove(tbl, i); return true end
  end
  return false
end

function TableUtils.table_is_empty(tbl)
  if type(tbl) ~= "table" then return true end
  return next(tbl) == nil
end

function TableUtils.create_empty_indexed_array(count)
  local arr = {}
  for i = 1, count do
    arr[i] = {}
  end
  return arr
end

function TableUtils.array_sort_by_index(array)
  local arr = {}
  for i, item in ipairs(array) do
    if type(item) == "table" then
      item.slot_num = i
      arr[#arr + 1] = item
    end
  end
  return arr
end

function TableUtils.index_is_in_table(_table, idx)
  if type(_table) == "table" then
    for x, v in pairs(_table) do
      if v == idx then
        return true, x
      end
    end
  end
  return false, -1
end

function TableUtils.find_by_predicate(_table, predicate)
  if type(_table) ~= "table" or type(predicate) ~= "function" then
    return nil, nil
  end
  for k, v in pairs(_table) do
    if predicate(v, k) then
      return v, k
    end
  end
  return nil, nil
end

return TableUtils
