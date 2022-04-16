local assert = require "luassert"

describe("command", function()
  local snapshot
  before_each(function()
    snapshot = assert:snapshot()
  end)

  after_each(function()
    snapshot:revert()
  end)

  it("should pass", function()
    assert.is.True(true)
  end)
end)
