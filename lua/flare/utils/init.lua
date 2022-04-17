local utils = {}
local a = vim.api

utils.empty_str = function(length)
  local len = length or 1
  local tbl = {}
  for i = len, 1, -1 do
    table.insert(tbl, " ")
  end
  return table.concat(tbl, "")
end

utils.win_get_cursor = function(window)
  local win = window or 0
  return a.nvim_win_get_cursor(win)
end

utils.get_current_line = function()
  return a.nvim_get_current_line()
end

utils.filetype = function()
  return vim.bo.filetype
end

utils.table_contains = function(tbl, val)
  for index, value in ipairs(tbl) do
    if value == val then
      return true
    end
  end

  return false
end

utils.is_floating_window = function(window)
  local config = a.nvim_win_get_config(window)
  return config.zindex ~= nil
end

utils.dump = function(val)
  print(vim.inspect(val))
end

return utils
