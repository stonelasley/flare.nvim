local utils = require "flare.utils"
local autocmd = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup

local flare = {}
local last_cursor_row = 0
local last_cursor_line_length = 0
local last_cursor_col = 0
local last_buffer = nil

local namespace_name = "flare"

local options = {
  enabled = true,
  hl_group = "IncSearch",
  x_threshold = 5,
  y_threshold = 5,
  expanse = 10,
  file_ignore = {
    "NvimTree",
    "fugitive",
    "TelescopePrompt",
    "TelescopeResult",
  },
}

local highlight = function(buffer_number, ns_id, current_row_str, line_num, lcol)
  for i = options.expanse, 1, -1 do
    local left_bound = (lcol - i)
    local right_bound = lcol + i
    if left_bound < 0 then
      left_bound = 0
    end

    local lstr = current_row_str:sub(left_bound + 1, right_bound + 1)
    if lstr == nil or lstr == "" then
      lstr = utils.empty_str(i)
    end
    local opts = {
      virt_text = { { lstr, options.hl_group } },
      virt_text_pos = "overlay",
      hl_mode = "blend",
    }
    local mark_id = vim.api.nvim_buf_set_extmark(buffer_number, ns_id, line_num - 1, left_bound, opts)
    vim.fn.timer_start(math.floor(250 / i), function()
      vim.api.nvim_buf_del_extmark(buffer_number, ns_id, mark_id)
    end)
  end
end

flare.highlightable_y_motion = function(cursor_row, last_cursor_line)
  local last_line = last_cursor_line or 0
  local current_line = cursor_row or 0
  local line_diff = math.abs(last_line - current_line)
  return line_diff >= options.y_threshold
end

flare.highlightable_x_motion = function(cursor_row, last_cursor_line, cursor_col, last_cursor_col)
  if cursor_row ~= last_cursor_line then
    return false
  end
  local last_col = last_cursor_col or 0
  local current_col = cursor_col or 0
  local cursor_diff = math.abs(last_col - current_col)
  return cursor_diff > options.x_threshold
end

local should_highlight = function(cursor_row, cursor_col, cursor_row_length, force)
  if options.enabled ~= true then
    return false
  end
  local floating = utils.is_floating_window(0)
  if floating == true then
    return false
  end

  local ignores = options.file_ignore or {}
  if utils.table_contains(ignores, utils.filetype()) then
    return false
  end

  if force == true then
    return true
  end

  if not flare.highlightable_y_motion(cursor_row, last_cursor_row) then
    if flare.highlightable_x_motion(cursor_row, last_cursor_row, cursor_col, last_cursor_col) then
      return true
    end
    return false
  end

  return true
end

local snapshot_cursor = function()
  local row, col = unpack(utils.win_get_cursor(0))

  last_buffer = vim.fn.bufnr "%"
  last_cursor_line_length = #utils.get_current_line()
  last_cursor_row = row
  last_cursor_col = col
end

local clear_history = function()
  last_buffer = nil
  last_cursor_line_length = 0
  last_cursor_row = nil
  last_cursor_col = nil
end

flare.cursor_moved = function(args, force)
  local forced = force or false
  local cursor_row, cursor_col = unpack(utils.win_get_cursor(0))
  local current_row_str = utils.get_current_line()
  local buffer_number = vim.fn.bufnr "%"
  local ns_id = vim.api.nvim_create_namespace(namespace_name)

  if should_highlight(cursor_row, cursor_col, #current_row_str, forced) ~= true then
    snapshot_cursor()
    return
  else
    snapshot_cursor()
  end

  local status, err = pcall(highlight, buffer_number, ns_id, current_row_str, cursor_row, cursor_col)
  if err ~= nil then
    utils.dump(err)
  end
end

flare.setup = function(opts)
  local user_opts = opts or {}
  options = vim.tbl_extend("force", options, user_opts)

  augroup("flare", { clear = true })

  autocmd("BufWinEnter", {
    pattern = { "*" },
    callback = function(args)
      flare.cursor_moved(args, true)
    end,
    group = "flare",
  })

  autocmd("FocusGained", {
    pattern = { "*" },
    callback = function(args)
      flare.cursor_moved(args, true)
    end,
    group = "flare",
  })

  autocmd("BufEnter", {
    pattern = { "*" },
    callback = function(args)
      flare.cursor_moved(args, true)
    end,
    group = "flare",
  })

  autocmd("CursorMoved", {
    pattern = { "*" },
    callback = flare.cursor_moved,
    group = "flare",
  })
end

flare._should_highlight = should_highlight
flare._options = options
return flare
