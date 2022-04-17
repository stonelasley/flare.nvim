local assert = require "luassert"
local spy = require "luassert.spy"
local mock = require "luassert.mock"
local stub = require "luassert.stub"

local sut = require "flare"

describe("flare", function()
  local snapshot
  before_each(function()
    snapshot = assert:snapshot()
  end)

  after_each(function()
    snapshot:revert()
  end)

  describe("cursor_move", function()
    before_each(function()
      snapshot = assert:snapshot()
    end)

    it("should respect enabled setting", function()
      local cursor_stub = stub(vim.api, "nvim_win_get_cursor", { 0, 0 })
      local namespace = stub(vim.api, "nvim_create_namespace")
      local buf_set = stub(vim.api, "nvim_buf_set_extmark")
      sut.setup { enabled = false }

      sut.cursor_moved()

      assert.stub(namespace).was.not_called()
      assert.stub(buf_set).was.not_called()
    end)
  end)
end)
