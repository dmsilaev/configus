require 'test_helper'

class TestConfig < MiniTest::Test
  def setup
    @config = Configus::Config.new({
      foo: "bar",
      nest: {
        name: "Bob",
        info: {
          phone: "555-55-55",
          address: "hell"
        }
      }
    })
  end

  def test_key_value
    assert_equal @config.foo, "bar"
  end

  def test_nested
    assert_equal @config.nest.name, "Bob"
    assert_equal @config.nest.info.address, "hell"
  end

end