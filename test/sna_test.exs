defmodule SnaTest do
  use ExUnit.Case
  doctest Sna

  test "greets the world" do
    assert Sna.hello() == :world
  end
end
