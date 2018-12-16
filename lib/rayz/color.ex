defmodule Rayz.Color do
  @moduledoc """
  Provides a Color
  """

  defstruct(
    red: 1.0,
    green: 1.0,
    blue: 1.0
  )

  # Aka Hadamard product (or Schur product)
  @spec multiply(%Rayz.Color{red: float(), green: float(), blue: float()}, %Rayz.Color{
          red: float(),
          green: float(),
          blue: float()
        }) :: %Rayz.Color{red: float(), green: float(), blue: float()}
  def multiply(color1 = %Rayz.Color{}, color2 = %Rayz.Color{}) do
    %Rayz.Color{
      red: color1.red * color2.red,
      green: color1.green * color2.green,
      blue: color1.blue * color2.blue
    }
  end

  @spec multiply(%Rayz.Color{red: float(), green: float(), blue: float()}, float()) ::
          %Rayz.Color{red: float(), green: float(), blue: float()}
  def multiply(color, scalar) do
    %Rayz.Color{
      red: color.red * scalar,
      green: color.green * scalar,
      blue: color.blue * scalar
    }
  end

  @spec subtract(%Rayz.Color{red: float(), green: float(), blue: float()}, %Rayz.Color{
          red: float(),
          green: float(),
          blue: float()
        }) :: %Rayz.Color{red: float(), green: float(), blue: float()}
  def subtract(color1, color2) do
    %Rayz.Color{
      red: color1.red - color2.red,
      green: color1.green - color2.green,
      blue: color1.blue - color2.blue
    }
  end

  @spec add(%Rayz.Color{red: float(), green: float(), blue: float()}, %Rayz.Color{
          red: float(),
          green: float(),
          blue: float()
        }) :: %Rayz.Color{red: float(), green: float(), blue: float()}
  def add(color1, color2) do
    %Rayz.Color{
      red: color1.red + color2.red,
      green: color1.green + color2.green,
      blue: color1.blue + color2.blue
    }
  end

  @spec new_color(float(), float(), float()) :: %Rayz.Color{
          red: float(),
          green: float(),
          blue: float()
        }
  def new_color(red, green, blue) do
    %Rayz.Color{red: red, green: green, blue: blue}
  end
end
