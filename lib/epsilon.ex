defmodule Rayz.Epsilon do
  @epsilon 0.000_01

  def equal(a, b) do
    if abs(a - b) < @epsilon do
      true
    else
      false
    end
  end
end
