local assert = require "luassert"
local spy = require "luassert.spy"
local mock = require "luassert.mock"

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
    local apiMock = mock(vim.api, true)
    local fnMock = mock(vim.fn, true)

    before_each(function()
      snapshot = assert:snapshot()
    end)

    it("should respect enabled setting", function()
      sut.setup { enabled = false }

      sut.cursor_moved()

      assert.stub(apiMock.nvim_create_namespace).was.not_called()
      assert.stub(apiMock.nvim_buf_set_extmark).was.not_called()
    end)
  end)
end)
