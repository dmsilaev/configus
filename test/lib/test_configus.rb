require 'test_helper'

class TestConfigus < MiniTest::Test
  def setup
    @builder = Configus::Builder.build :development do
      env :production do
        website_url 'http://example.com'
        email do
          pop do
            address 'pop.example.com'
            port    110
          end
          smtp do
            address 'smtp.example.com'
            port    25
          end
        end
      end

      env :development, :parent => :production do
        website_url 'http://text.example.com'
        email do
          smtp do
            address 'smtp.text.example.com'
          end
        end
        full_name do
          first_name "Bob"
          last_name "Marley"
        end
      end
    end
  end

  def test_default_env
    assert_equal @builder.default_env, :development
  end

  def test_configus
    assert_equal @builder.website_url, "http://text.example.com"
  end

  def test_nesting
    assert_equal @builder.full_name.first_name, "Bob"
  end

  def test_parent_nesting
    assert_equal @builder.email.pop.port, 110
  end

  def test_redefine
    assert_equal @builder.email.smtp.address, 'smtp.text.example.com'
  end

  def test_arg_error
    assert_raises(ArgumentError) do
      broken = Configus::Builder.build :a do
        env :b do
          foo "bar"
        end
      end
    end
  end

  def test_cycle
    assert_raises(Configus::BuilderUndefinedEnvironmentError) do
      cycled = Configus::Builder.build :a do
        env :a, :parent => :b do
          foo "baz"
        end

        env :b, :parent => :a do
          foo "bar"
        end
      end
    end
    assert_raises(Configus::BuilderUndefinedEnvironmentError) do
      cycled = Configus::Builder.build :a do
        env :b, :parent => :a do
          foo "bar"
        end

        env :a, :parent => :b do
          foo "baz"
        end
      end
    end
  end

  def test_twice_defined_env
    assert_raises(Configus::BuilderTwiceDefinedEnvironmentError) do
      twice_defined = Configus::Builder.build :a do
        env :a do
          foo "baz"
        end

        env :b, :parent => :a do
          foo "bar"
        end

        env :b, :parent => :a do
          foo "quuz"
        end
      end
    end
  end
end
