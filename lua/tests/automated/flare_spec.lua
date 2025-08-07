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
  end)
end)
