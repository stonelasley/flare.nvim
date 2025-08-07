local utils = require "flare.utils"
local autocmd = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup
local command = vim.api.nvim_create_user_command

local flare = {}
local last_cursor_row = 0
local last_cursor_col = 0

local namespace_name = "flare"
local ns_id = vim.api.nvim_create_namespace(namespace_name)

local options = {
  enabled = true,
  hl_group = "FlareHighlight",
  hl_group_ul = "FlareUnderline",
  x_threshold = 10,
  y_threshold = 5,
  timeout = 150,
  fade = true,
  expanse = 10,
  file_ignore = {
    "dashboard",
    "fugitive",
    "NvimTree",
    "TelescopePrompt",
    "TelescopeResult",
    "Trouble",
  },
  underline = false,
  highlight_on_enter = true,
}

local highlight = function(buffer_number, ns_id, current_row_str, line_num, lcol)
  for i = options.expanse, 1, -1 do
    local left_bound = (lcol - i)
    local right_bound = lcol + i
    if left_bound < 0 then
      right_bound = right_bound + math.abs(left_bound)
      left_bound = 0
    end

    local lstr = current_row_str:sub(left_bound + 1, right_bound + 1)
    if lstr == nil or lstr == "" then
      lstr = utils.empty_str(i)
    end
    local hl_group = options.hl_group
    if options.underline == true then
      hl_group = options.hl_group_ul
    end
    local opts = {
      virt_text = { { lstr, hl_group } },
      virt_text_pos = "overlay",
      hl_mode = "blend",
    }
    local mark_id = vim.api.nvim_buf_set_extmark(buffer_number, ns_id, line_num - 1, left_bound, opts)
    local delay = options.timeout
    if options.fade then
      delay = math.floor(options.timeout / i)
    end
    vim.fn.timer_start(delay, function()
      if vim.api.nvim_buf_is_valid(buffer_number) then
        pcall(vim.api.nvim_buf_del_extmark, buffer_number, ns_id, mark_id)
      end
    end)
    if not options.fade then
      break
    end
  end
end

flare.highlightable_y_motion = function(cursor_row, last_cursor_line)
  local last_line = last_cursor_line or 0
  local current_line = cursor_row or 0
  local line_diff = math.abs(last_line - current_line)
  return line_diff > options.y_threshold
end

flare.highlightable_x_motion = function(cursor_row, prev_cursor_line, cursor_col, prev_cursor_col)
  if cursor_row ~= prev_cursor_line then
    return false
  end
  local last_col = prev_cursor_col or 0
  local current_col = cursor_col or 0
  local cursor_diff = math.abs(last_col - current_col)
  return cursor_diff > options.x_threshold
end

local should_highlight = function(cursor_row, cursor_col, force)
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
  last_cursor_row = row
  last_cursor_col = col
end

flare.cursor_moved = function(args, force)
  local forced = force or false
  local cursor_row, cursor_col = unpack(utils.win_get_cursor(0))
  local current_row_str = utils.get_current_line()
  local buffer_number = vim.fn.bufnr "%"

  if should_highlight(cursor_row, cursor_col, forced) ~= true then
    snapshot_cursor()
    return
  end
  snapshot_cursor()

  pcall(highlight, buffer_number, ns_id, current_row_str, cursor_row, cursor_col)
end

flare.toggle = function()
  options.enabled = not options.enabled
  if options.enabled then
    flare.cursor_moved(nil, true)
  end
end

flare.set_threshold = function(axis, value)
  if not axis or not value then
    vim.notify("Usage: FlareSetThreshold <x|y> <number>", vim.log.levels.ERROR)
    return
  end

  if axis ~= "x" and axis ~= "y" then
    vim.notify("Invalid axis: " .. axis .. ". Must be 'x' or 'y'", vim.log.levels.ERROR)
    return
  end

  local num = tonumber(value)
  if num == nil then
    vim.notify("Invalid number: " .. value, vim.log.levels.ERROR)
    return
  end

  if axis == "x" then
    options.x_threshold = num
  elseif axis == "y" then
    options.y_threshold = num
  end
  flare.cursor_moved(nil, true)
end

flare.setup = function(opts)
  local user_opts = opts or {}
  options = vim.tbl_extend("force", options, user_opts)
  flare._options = options

  vim.cmd [[
      highlight! default link FlareHighlight IncSearch
      highlight FlareUnderline guibg=NONE guifg=NONE gui=underline guisp=red ctermfg=NONE ctermbg=NONE cterm=underline
  ]]

  augroup("flare", { clear = true })

  if options.highlight_on_enter == true then
    autocmd({ "BufWinEnter", "FocusGained", "BufEnter", "WinEnter" }, {
      pattern = { "*" },
      callback = function(args)
        flare.cursor_moved(args, true)
      end,
      group = "flare",
    })
  end

  autocmd("CursorMoved", {
    pattern = { "*" },
    callback = flare.cursor_moved,
    group = "flare",
  })
  command("FlareToggle", flare.toggle, { force = true })
  command("FlareSetThreshold", function(cmd_opts)
    flare.set_threshold(cmd_opts.fargs[1], cmd_opts.fargs[2])
  end, {
    nargs = "*",
    complete = function()
      return { "x", "y" }
    end,
    force = true,
  })
end

flare._should_highlight = should_highlight
flare._options = options
return flare
