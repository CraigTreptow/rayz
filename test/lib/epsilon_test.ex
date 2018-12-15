defmodule Rayz.EpsilonTest do
  use ExUnit.Case
  doctest Rayz.Epsilon

  test "works for integers" do
    a = 12
    b = 12
    assert Rayz.equal(a, b) == true
  end

  test "Works for floats" do
    a = 0.12
    b = 0.12
    assert Rayz.equal(a, b) == true
  end

  test "Works for floats less precise than the epsilon" do
    a = 0.000_03
    b = 0.000_03
    assert Rayz.equal(a, b) == true
  end

  test "Works for floats more precise then the epsilon" do
    a = 0.000_003
    b = 0.000_004
    assert Rayz.equal(a, b) == true
  end
end
