require_relative '../test_helper'

class TestConfigus < MiniTest::Test
  def setup
    @builder = Configus::Builder.new :development do
      env :production do
        a "foo"
      end

      env :development do
        a "bar"
      end
    end
  end

  def test_env
    assert @builder.all_env == { :development => {}, :production => {} }
  end
end
