local assert = require "luassert"

local sut = require "flare.utils"

describe("utils", function()
  local snapshot
  before_each(function()
    snapshot = assert:snapshot()
  end)

  after_each(function()
    snapshot:revert()
  end)

  describe("table_contains", function()
    it("should check if table contains value", function()
      local t = {
        "foo",
      }
      local actual = sut.table_contains(t, "foo")
      -- local actual2 = sut.table_contains(t, "bar")

      assert.is.True(actual)
      -- assert.is.False(actual2)
    end)
  end)

  describe("empty_str", function()
    it("should create empty string", function()
      local actual = sut.empty_str()

      assert.are.equal(" ", actual)
    end)

    it("should create string of length", function()
      local actual = sut.empty_str(10)

      assert.are.equal("          ", actual)
    end)
  end)
end)
