local utils = require "flare.utils"
local autocmd = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup

local flare = {}
local last_cursor_line = nil
local last_cursor_col = nil
local last_buffer = nil

local namespace_name = "flare"

local options = {
  enabled = true,
  hl_group = "IncSearch",
  expanse = 6,
  file_ignore = {
    "NvimTree",
    "TelescopePrompt",
    "TelescopeResult",
  },
}

local highlight = function(buffer_number, ns_id, line_num, cursor_line, lcol)
  for i = options.expanse, 1, -1 do
    local left_bound = lcol - i
    if left_bound < 0 then
      left_bound = 0
    end
    local right_bound = lcol + i

    --local lchar = cursor_line:sub(lcol + 1, lcol + 1)
    local lstr = cursor_line:sub(left_bound + 1, right_bound + 1)
    if lstr == nil or lstr == "" then
      lstr = utils.empty_str(i)
    end
    local opts = {
      virt_text = { { lstr, options.hl_group } },
      virt_text_pos = "overlay",
      hl_mode = "blend",
    }
    local mark_id = vim.api.nvim_buf_set_extmark(buffer_number, ns_id, line_num - 1, left_bound, opts)
    vim.fn.timer_start(math.floor(200 / i), function()
      vim.api.nvim_buf_del_extmark(buffer_number, ns_id, mark_id)
    end)
  end
end

local should_highlight = function(cursor_line)
  local floating = utils.is_floating_window(0)
  if floating == true then
    return false
  end

  local ignores = options.file_ignore or {}
  if utils.table_contains(ignores, vim.bo.filetype) then
    return false
  end

  -- local last_line = last_cursor_line or -1
  -- local current_line = cursor_line or -1
  -- local line_diff = math.abs(last_line - current_line)
  -- utils.dump(line_dif)
  -- if line_diff == 0 then
  --   return false
  -- end
  return true
end

local set_history = function(buffer, line, col)
  last_buffer = buffer
  last_cursor_line = line
  last_cursor_col = col
end

local clear_history = function()
  last_buffer = nil
  last_cursor_line = nil
  last_cursor_col = nil
end

local cursor_moved = function(args)
  utils.dump(args)
  if should_highlight() ~= true then
    return
  end

  local ns_id = vim.api.nvim_create_namespace(namespace_name)
  local buffer_number = vim.fn.bufnr "%"
  local line_num = vim.fn.winline()

  local cursor_line = utils.get_current_line()
  local lcol = utils.win_get_cursor_col(0)

  local status, err = pcall(highlight, buffer_number, ns_id, line_num, cursor_line, lcol)
  if err ~= nil then
    utils.dump(err)
  end
end

flare.setup = function(opts)
  local user_opts = opts or {}
  vim.tbl_extend("force", options, user_opts)

  augroup("flare", { clear = true })

  autocmd("BufWinEnter,FocusGained,BufEnter", {
    pattern = { "*" },
    callback = cursor_moved,
    group = "flare",
  })

  autocmd("FocusGained", {
    pattern = { "*" },
    callback = cursor_moved,
    group = "flare",
  })

  autocmd("BufEnter", {
    pattern = { "*" },
    callback = cursor_moved,
    group = "flare",
  })

  autocmd("WinEnter", {
    pattern = { "*" },
    callback = cursor_moved,
    group = "flare",
  })

  autocmd("CursorMoved", {
    pattern = { "*" },
    callback = cursor_moved,
    group = "flare",
  })

  -- autocmd("FocusLost", {
  --   pattern = { "*" },
  --   callback = clear_history,
  --   group = "flare",
  -- })
end

return flare
