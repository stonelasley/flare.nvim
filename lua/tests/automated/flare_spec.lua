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

      local actual = sut._should_highlight(0, 0, 0, true)

      assert.is.False(actual)
    end)

    for k, v in ipairs(sut._options.file_ignore) do
      it("should not if filetype " .. v, function()
        stub(utils, "filetype", v)

        local actual = sut._should_highlight(0, 0, 0, true)

        assert.is.False(actual)
      end)
    end

    it("should respect forced argument", function()
      stub(utils, "is_floating_window", false)
      stub(utils, "table_contains", false)

      local actual = sut._should_highlight(0, 0, 0, true)

      assert.is.True(actual)
    end)

    it("should  respect y_threshold setting", function()
      stub(utils, "is_floating_window", false)
      stub(utils, "table_contains", false)

      sut.setup { enabled = true, y_threshold = 2 }

      local default_position = sut._should_highlight(0, 0, 0, false)
      local one_row_down = sut._should_highlight(1, 0, 0, false)
      local three_rows_down = sut._should_highlight(3, 0, 0, false)

      assert.is.False(default_position)
      assert.is.False(one_row_down)
      assert.is.True(three_rows_down)
    end)

    it("should respect x_threshold", function()
      stub(utils, "is_floating_window", false)
      stub(utils, "table_contains", false)

      sut.setup { enabled = true, x_threshold = 2 }

      local default_position = sut._should_highlight(0, 0, 0, false)
      local two_cols_right = sut._should_highlight(0, 2, 0, false)
      local six_cols_right = sut._should_highlight(0, 5, 0, false)

      assert.is.False(default_position)
      assert.is.False(two_cols_right)
      assert.is.True(six_cols_right)
    end)

    it("should not if plugin disabled", function()
      sut.setup { enabled = false }

      local actual = sut._should_highlight(0, 0, 0, true)

      assert.is.False(actual)
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
end)
