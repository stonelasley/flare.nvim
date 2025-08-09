local assert = require "luassert"
local spy = require "luassert.spy"
local mock = require "luassert.mock"
local stub = require "luassert.stub"
local utils = require "flare.utils"

local sut = require "flare"

describe("flare", function()
  local snapshot
  before_each(function()
    snapshot = assert:snapshot()
  end)

  after_each(function()
    snapshot:revert()
  end)

  describe("should_highlight", function()
    before_each(function()
      sut.setup {}
    end)

    it("should not if floating window", function()
      stub(utils, "is_floating_window", true)

      local actual = sut._should_highlight(0, 0, true)

      assert.is.False(actual)
    end)

    for k, v in ipairs(sut._options.file_ignore) do
      it("should not if filetype " .. v, function()
        stub(utils, "filetype", v)

        local actual = sut._should_highlight(0, 0, true)

        assert.is.False(actual)
      end)
    end

    it("should respect forced argument", function()
      stub(utils, "is_floating_window", false)
      stub(utils, "table_contains", false)

      local actual = sut._should_highlight(0, 0, true)

      assert.is.True(actual)
    end)

    it("should  respect y_threshold setting", function()
      stub(utils, "is_floating_window", false)
      stub(utils, "table_contains", false)

      sut.setup { enabled = true, y_threshold = 2 }

      local default_position = sut._should_highlight(0, 0, false)
      local one_row_down = sut._should_highlight(1, 0, false)
      local three_rows_down = sut._should_highlight(3, 0, false)

      assert.is.False(default_position)
      assert.is.False(one_row_down)
      assert.is.True(three_rows_down)
    end)

    it("should respect x_threshold", function()
      stub(utils, "is_floating_window", false)
      stub(utils, "table_contains", false)

      sut.setup { enabled = true, x_threshold = 2 }

      local default_position = sut._should_highlight(0, 0, false)
      local two_cols_right = sut._should_highlight(0, 2, false)
      local six_cols_right = sut._should_highlight(0, 5, false)

      assert.is.False(default_position)
      assert.is.False(two_cols_right)
      assert.is.True(six_cols_right)
    end)

    it("should not if plugin disabled", function()
      sut.setup { enabled = false }

      local actual = sut._should_highlight(0, 0, true)

      assert.is.False(actual)
    end)
  end)

  describe("highlightable_x_motion", function()
    it("should respect x_threshold setting", function()
      sut.setup { x_threshold = 2 }

      local actual = sut.highlightable_x_motion(0, 0, 0, 0)
      assert.is.False(actual)
      actual = sut.highlightable_x_motion(0, 0, 0, 3)
      assert.is.True(actual)
      actual = sut.highlightable_x_motion(0, 0, 0, 2)
      assert.is.False(actual)
      actual = sut.highlightable_x_motion(0, 0, 0, 99)
      assert.is.True(actual)
    end)

    it("should not flash on y motion that force x motion", function()
      sut.setup { x_threshold = 2 }

      sut.highlightable_x_motion(0, 0, 25, 0)
      local jump_to_empty_line = sut.highlightable_x_motion(1, 0, 0, 25)
      assert.is.False(jump_to_empty_line)
    end)
  end)

  describe("highlightable_y_motion", function()
    it("should respect y_threshold setting", function()
      sut.setup { y_threshold = 2 }

      local actual = sut.highlightable_y_motion(0, 0)
      assert.is.False(actual)
      actual = sut.highlightable_y_motion(3, 0)
      assert.is.True(actual)
      actual = sut.highlightable_y_motion(1, 0)
      assert.is.False(actual)
      actual = sut.highlightable_y_motion(99, 0)
      assert.is.True(actual)
    end)
  end)

  describe("cursor_move", function()
    -- it("should respect enabled setting", function()
    --   local cursor_stub = stub(vim.api, "nvim_win_get_cursor", { 0, 0 })
    --   local namespace = stub(vim.api, "nvim_create_namespace")
    --   local buf_set = stub(vim.api, "nvim_buf_set_extmark")
    --   sut.setup { enabled = false }
    --
    --   sut.cursor_moved()
    --
    --   assert.stub(namespace).was.not_called()
    --   assert.stub(buf_set).was.not_called()
    -- end)
  end)

  describe("fade_speed", function()
    before_each(function()
      -- Mock vim.api functions needed for highlighting
      stub(vim.api, "nvim_buf_set_extmark", 1)
      stub(vim.fn, "timer_start")
      stub(vim.api, "nvim_buf_is_valid", true)
      stub(vim.fn, "bufnr", 1)
      stub(utils, "win_get_cursor", { 5, 10 })
      stub(utils, "get_current_line", "test line content")
      stub(utils, "is_floating_window", false)
      stub(utils, "table_contains", false)
      stub(utils, "filetype", "lua")
    end)

    it("should respect fade_speed setting for delay calculation", function()
      local timer_calls = {}
      stub(vim.fn, "timer_start", function(delay, callback)
        table.insert(timer_calls, delay)
        return 1
      end)

      -- Test with default fade_speed (1.0)
      sut.setup { 
        enabled = true, 
        fade = true, 
        fade_speed = 1.0, 
        timeout = 150, 
        expanse = 3 
      }
      
      sut.cursor_moved(nil, true)
      
      -- With expanse=3, timeout=150, fade_speed=1.0
      -- Expected delays: floor(150/3/1.0)=50, floor(150/2/1.0)=75, floor(150/1/1.0)=150
      assert.same({ 50, 75, 150 }, timer_calls)

      -- Reset and test with faster fade_speed (2.0)
      timer_calls = {}
      sut.setup { 
        enabled = true, 
        fade = true, 
        fade_speed = 2.0, 
        timeout = 150, 
        expanse = 3 
      }
      
      sut.cursor_moved(nil, true)
      
      -- With fade_speed=2.0, delays should be halved
      -- Expected delays: floor(150/3/2.0)=25, floor(150/2/2.0)=37, floor(150/1/2.0)=75
      assert.same({ 25, 37, 75 }, timer_calls)

      -- Reset and test with slower fade_speed (0.5)
      timer_calls = {}
      sut.setup { 
        enabled = true, 
        fade = true, 
        fade_speed = 0.5, 
        timeout = 150, 
        expanse = 3 
      }
      
      sut.cursor_moved(nil, true)
      
      -- With fade_speed=0.5, delays should be doubled
      -- Expected delays: floor(150/3/0.5)=100, floor(150/2/0.5)=150, floor(150/1/0.5)=300
      assert.same({ 100, 150, 300 }, timer_calls)
    end)

    it("should use timeout value when fade is disabled", function()
      local timer_calls = {}
      stub(vim.fn, "timer_start", function(delay, callback)
        table.insert(timer_calls, delay)
        return 1
      end)

      sut.setup { 
        enabled = true, 
        fade = false, 
        fade_speed = 2.0, 
        timeout = 150, 
        expanse = 3 
      }
      
      sut.cursor_moved(nil, true)
      
      -- When fade is disabled, should only use timeout value once, ignoring fade_speed
      assert.same({ 150 }, timer_calls)
    end)
  end)

  describe("commands", function()
    before_each(function()
      sut.setup { enabled = true }
    end)

    it("toggle flips enabled state", function()
      local cursor_stub = stub(sut, "cursor_moved")
      -- Should start as enabled (true) based on default options
      assert.is.True(sut._options.enabled)
      sut.toggle()
      assert.is.False(sut._options.enabled)
      sut.toggle()
      assert.is.True(sut._options.enabled)
      assert.stub(cursor_stub).was.called_with(nil, true)
    end)

    it("set_threshold updates values", function()
      local cursor_stub = stub(sut, "cursor_moved")
      
      -- Test x threshold
      sut.set_threshold("x", "12")
      assert.equals(12, sut._options.x_threshold)
      
      -- Test y threshold  
      sut.set_threshold("y", "7")
      assert.equals(7, sut._options.y_threshold)
      
      -- Test that cursor_moved was called each time
      assert.stub(cursor_stub).was.called.at_least(2)
    end)

    it("set_fade_speed updates fade_speed value", function()
      local cursor_stub = stub(sut, "cursor_moved")
      
      -- Test valid fade speed
      sut.set_fade_speed("2.5")
      assert.equals(2.5, sut._options.fade_speed)
      
      -- Test another valid fade speed
      sut.set_fade_speed("0.5")
      assert.equals(0.5, sut._options.fade_speed)
      
      -- Test that cursor_moved was called each time
      assert.stub(cursor_stub).was.called.at_least(2)
    end)

    it("set_fade_speed handles invalid input", function()
      local notify_stub = stub(vim, "notify")
      local original_speed = sut._options.fade_speed
      
      -- Test invalid number
      sut.set_fade_speed("invalid")
      assert.equals(original_speed, sut._options.fade_speed)
      assert.stub(notify_stub).was.called_with("Invalid fade speed: invalid. Must be a positive number", vim.log.levels.ERROR)
      
      -- Test zero
      sut.set_fade_speed("0")
      assert.equals(original_speed, sut._options.fade_speed)
      assert.stub(notify_stub).was.called_with("Invalid fade speed: 0. Must be a positive number", vim.log.levels.ERROR)
      
      -- Test negative number
      sut.set_fade_speed("-1")
      assert.equals(original_speed, sut._options.fade_speed)
      assert.stub(notify_stub).was.called_with("Invalid fade speed: -1. Must be a positive number", vim.log.levels.ERROR)
      
      -- Test missing argument
      sut.set_fade_speed()
      assert.equals(original_speed, sut._options.fade_speed)
      assert.stub(notify_stub).was.called_with("Usage: FlareSetFadeSpeed <number>", vim.log.levels.ERROR)
    end)
  end)

  describe("gutter highlighting", function()
    before_each(function()
      stub(vim.api, "nvim_buf_set_extmark", 1)
      stub(vim.fn, "timer_start")
      stub(vim.api, "nvim_buf_is_valid", true)
      stub(vim.fn, "bufnr", 1)
      stub(utils, "win_get_cursor", { 5, 10 })
      stub(utils, "get_current_line", "test line content")
      stub(utils, "is_floating_window", false)
      stub(utils, "table_contains", false)
      stub(utils, "filetype", "lua")
    end)

    it("should not highlight gutter when disabled", function()
      local extmark_stub = stub(vim.api, "nvim_buf_set_extmark", 1)
      local clear_stub = stub(vim.api, "nvim_buf_clear_namespace")
      
      sut.setup({ 
        enabled = true, 
        gutter_enabled = false,
        expanse = 1
      })
      
      sut.cursor_moved(nil, true)
      
      -- Should be called once for regular highlight, not for gutter
      assert.stub(extmark_stub).was.called(1)
      assert.stub(clear_stub).was.not_called()
    end)

    it("should highlight gutter when enabled", function()
      local extmark_calls = {}
      local clear_calls = {}
      
      stub(vim.api, "nvim_buf_set_extmark", function(buf, ns, line, col, opts)
        table.insert(extmark_calls, {buf, ns, line, col, opts})
        return 1
      end)
      
      stub(vim.api, "nvim_buf_clear_namespace", function(buf, ns, start_line, end_line)
        table.insert(clear_calls, {buf, ns, start_line, end_line})
      end)
      
      sut.setup({ 
        enabled = true, 
        gutter_enabled = true,
        gutter_sign = "🔥",
        gutter_hl_group = "FlareGutter",
        expanse = 1  -- Reduce to make test simpler
      })
      
      sut.cursor_moved(nil, true)
      
      -- Should be called for both regular highlight and gutter
      assert.equals(2, #extmark_calls)
      
      -- Should clear gutter namespace before setting new mark
      assert.equals(1, #clear_calls)
      
      -- Check gutter extmark has correct options
      local gutter_call = extmark_calls[2]
      assert.equals("🔥", gutter_call[5].sign_text)
      assert.equals("FlareGutter", gutter_call[5].sign_hl_group)
    end)
  end)
end)
