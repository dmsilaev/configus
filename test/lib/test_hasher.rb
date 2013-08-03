require "test_helper"

class TestHasher < MiniTest::Test
  def test_hasher_key_value
    hash = Configus::Hasher.build do
      foo "foo"
      bar do
        baz "baz"
        quux 3.1
      end
    end

    assert_equal hash[:foo], "foo"
    assert_equal hash[:bar][:baz], "baz"
  end

  def test_twice_defined_key
    assert_raises(Configus::Hasher::TwiceDefinedKeyError) do
      twice_defined_key = Configus::Hasher.build do
        foo "baz"
        foo "bar"
      end
    end
  end

  def test_twice_defined_nested_key
    assert_raises(Configus::Hasher::TwiceDefinedKeyError) do
      twice_defined_nested_key = Configus::Hasher.build do
        foo do
          quux "baz"
        end
        foo do
          quux "bar"
        end
      end
    end
  end
end
