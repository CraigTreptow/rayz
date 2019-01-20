defmodule Rayz.Epsilon do
  @epsilon 0.000_01

  @moduledoc """
  Floating point calculations get weird
  """

  @doc """
  Equality.

  ## Examples

   iex> Rayz.Epsilon.equal?(0.0000013, 0.0000012)
   true
  """

  def equal?(a, b) do
    if abs(a - b) < @epsilon do
      true
    else
      false
    end
  end
end
