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
            address 'smpt.text.example.com'
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
end
