defmodule RayzTest do
  use ExUnit.Case
  doctest Rayz

  test "greets the world" do
    assert Rayz.hello() == :world
  end
end
