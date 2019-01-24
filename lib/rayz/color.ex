defmodule Rayz.Color do
  @moduledoc """
  Documentation for Rayz.Color.
  """

  @doc """
      iex> Builder.color(1.1, 2.2, 3.3)
      %Rayz.Color{red: 1.1, green: 2.2, blue: 3.3}
  """

  defstruct(
    red:   0.0,
    green: 0.0,
    blue:  0.0
  )

  @type color :: %Rayz.Color{red: float(), green: float(), blue: float()}

  @spec multiply(color, float()) :: color
  def multiply(color, scalar) when is_float(scalar) do
    %Rayz.Color{
      red:   color.red   * scalar,
      green: color.green * scalar,
      blue:  color.blue  * scalar
    }
  end

  @spec multiply(color, color) :: color
  def multiply(color1, color2) when is_map(color2) do
    # hadamard or Schur product
    %Rayz.Color{
      red:   color1.red   * color2.red,
      green: color1.green * color2.green,
      blue:  color1.blue  * color2.blue
    }
  end

  @spec add(color, color) :: color
  def add(color1, color2) do
    %Rayz.Color{
      red:   color1.red   + color2.red,
      green: color1.green + color2.green,
      blue:  color1.blue  + color2.blue
    }
  end

  @spec subtract(color, color) :: color
  def subtract(color1, color2) do
    %Rayz.Color{
      red:   color1.red   - color2.red,
      green: color1.green - color2.green,
      blue:  color1.blue  - color2.blue
    }
  end

  @spec equal?(color, color) :: boolean()
  def equal?(color1, color2) do
    Util.equal?(color1.red,   color2.red)   &&
    Util.equal?(color1.green, color2.green) &&
    Util.equal?(color1.blue,  color2.blue)
  end
end
