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
  min_lines = 5,
  expanse = 20,
  file_ignore = {
    "NvimTree",
    "fugitive",
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
    vim.fn.timer_start(math.floor(250 / i), function()
      vim.api.nvim_buf_del_extmark(buffer_number, ns_id, mark_id)
    end)
  end
end

local should_highlight = function(buffer_number, cursor_line, force)
  if options.enabled ~= true then
    return
  end
  local floating = utils.is_floating_window(0)
  if floating == true then
    return false
  end

  local ignores = options.file_ignore or {}
  if utils.table_contains(ignores, vim.bo.filetype) then
    return false
  end

  if force == true then
    return true
  end

  local last_line = last_cursor_line or -1
  local current_line = cursor_line or -1
  local line_diff = math.abs(last_line - current_line)
  utils.dump(line_diff)

  if line_diff <= options.min_lines then
    return false
  end
  return true
end

local snapshot_cursor = function()
  local r, c = unpack(utils.win_get_cursor(0))

  last_buffer = vim.fn.bufnr "%"
  last_cursor_line = r
  last_cursor_col = c
end

local clear_history = function()
  last_buffer = nil
  last_cursor_line = nil
  last_cursor_col = nil
end

flare.cursor_moved = function(args, force)
  local forced = force or false
  local line_num = vim.fn.line "."
  local buffer_number = vim.fn.bufnr "%"
  if should_highlight(buffer_number, line_num, forced) ~= true then
    snapshot_cursor()
    return
  else
    snapshot_cursor()
  end

  local ns_id = vim.api.nvim_create_namespace(namespace_name)

  local cursor_line = utils.get_current_line()
  local lcol = utils.win_get_cursor_col(0)

  local status, err = pcall(highlight, buffer_number, ns_id, line_num, cursor_line, lcol)
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

return flare
