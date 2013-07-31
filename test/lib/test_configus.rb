require_relative '../test_helper'

class TestConfigus < MiniTest::Test
  def setup
    @builder = Configus::Builder.build :development do
      env :production do
        a "foo"
      end

      env :development do
        a "bar"
      end

      env :test do
        a "baz"
      end
    end
  end

  #def test_env
  #  assert_equal @builder.all_env,
  #    { :development => { :a => "bar" }, :production => { :a => "foo" } }
  #end

  def test_default_env
    assert_equal @builder.default_env, :development
  end

  def test_configus
    assert_equal @builder.a, "bar"
  end
end
