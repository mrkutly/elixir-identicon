defmodule IdenticonTest do
  use ExUnit.Case
  doctest Identicon

  test "main" do
		assert Identicon.main("mark") == :ok
		assert_raise ArgumentError, fn -> Identicon.main(123) end
  end
end
