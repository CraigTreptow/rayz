defmodule Builder do
  @moduledoc """
  Documentation for Builder.
  """

  @type rayztuple :: %Rayz.Tuple{x: float(), y: float(), z: float(), w: float()}
  @type color :: %Rayz.Color{red: float(), green: float(), blue: float()}
  @type canvas :: %Rayz.Canvas{width: integer(), height: integer()}
  @type matrix4x4() :: 
    {
      float(), float(), float(), float(),
      float(), float(), float(), float(),
      float(), float(), float(), float(),
      float(), float(), float(), float()
    }
  @type matrix3x3() :: 
    {
      float(), float(), float(),
      float(), float(), float(),
      float(), float(), float()
    }
  @type matrix2x2() :: 
    {
      float(), float(),
      float(), float()
    }
  @type ray :: %Rayz.Ray{origin: rayztuple(), direction: rayztuple()}

  @type intersection :: %Rayz.Intersection{t: float(), object: map()}

  @spec intersections(intersection(), intersection(), intersection(), intersection()) :: list()
  def intersections(i1, i2, i3, i4), do: [i1, i2, i3, i4]

  @spec intersections(intersection(), intersection()) :: list()
  def intersections(i1, i2), do: [i1, i2]

  @spec intersection(float(), map()) :: intersection()
  def intersection(t, object), do: %Rayz.Intersection{t: t, object: object}

  #@spec sphere(rayztuple(), rayztuple()) :: ray()
  def sphere() do
    %Rayz.Sphere{
      id: Integer.to_string(:rand.uniform(4_294_967_296), 32)
    }
  end

  @spec ray(rayztuple(), rayztuple()) :: ray()
  def ray(origin, direction), do: %Rayz.Ray{origin: origin, direction: direction}

  @spec shearing(float(), float(), float(), float(), float(), float()) :: matrix4x4()
  def shearing(xy, xz, yx, yz, zx, zy) do
    i = Builder.identity_matrix()

    i
    |> Rayz.Matrix.put_value(0, 1, xy)
    |> Rayz.Matrix.put_value(0, 2, xz)
    |> Rayz.Matrix.put_value(1, 0, yx)
    |> Rayz.Matrix.put_value(1, 2, yz)
    |> Rayz.Matrix.put_value(2, 0, zx)
    |> Rayz.Matrix.put_value(2, 1, zy)
  end

  @spec rotation_z(float()) :: matrix4x4()
  def rotation_z(r) do
    i = Builder.identity_matrix()

    i
    |> Rayz.Matrix.put_value(0, 0,  :math.cos(r))
    |> Rayz.Matrix.put_value(0, 1, -:math.sin(r))
    |> Rayz.Matrix.put_value(1, 0,  :math.sin(r))
    |> Rayz.Matrix.put_value(1, 1,  :math.cos(r))
  end

  @spec rotation_y(float()) :: matrix4x4()
  def rotation_y(r) do
    i = Builder.identity_matrix()

    i
    |> Rayz.Matrix.put_value(0, 0,  :math.cos(r))
    |> Rayz.Matrix.put_value(0, 2,  :math.sin(r))
    |> Rayz.Matrix.put_value(2, 0, -:math.sin(r))
    |> Rayz.Matrix.put_value(2, 2,  :math.cos(r))
  end

  @spec rotation_x(float()) :: matrix4x4()
  def rotation_x(r) do
    i = Builder.identity_matrix()

    i
    |> Rayz.Matrix.put_value(1, 1,  :math.cos(r))
    |> Rayz.Matrix.put_value(1, 2, -:math.sin(r))
    |> Rayz.Matrix.put_value(2, 1,  :math.sin(r))
    |> Rayz.Matrix.put_value(2, 2,  :math.cos(r))
  end

  @spec scaling(float(), float(), float()) :: matrix4x4()
  def scaling(x, y, z) do
    i = Builder.identity_matrix()

    i
    |> Rayz.Matrix.put_value(0, 0, x)
    |> Rayz.Matrix.put_value(1, 1, y)
    |> Rayz.Matrix.put_value(2, 2, z)
  end

  @spec translation(float(), float(), float()) :: matrix4x4()
  def translation(x, y, z) do
    i = Builder.identity_matrix()

    i
    |> Rayz.Matrix.put_value(0, 3, x)
    |> Rayz.Matrix.put_value(1, 3, y)
    |> Rayz.Matrix.put_value(2, 3, z)
  end

  @spec matrix(float(), float(), float(), float(),
               float(), float(), float(), float(),
               float(), float(), float(), float(),
               float(), float(), float(), float()) :: matrix4x4()
  def matrix(a_a, a_b, a_c, a_d, b_a, b_b, b_c, b_d, c_a, c_b, c_c, c_d, d_a, d_b, d_c, d_d) do
    {
      a_a, a_b, a_c, a_d,
      b_a, b_b, b_c, b_d,
      c_a, c_b, c_c, c_d,
      d_a, d_b, d_c, d_d
    }
  end

  def identity_matrix() do
    {
      1, 0, 0, 0,
      0, 1, 0, 0,
      0, 0, 1, 0,
      0, 0, 0, 1
    }
  end

  @spec matrix(float(), float(), float(),
               float(), float(), float(),
               float(), float(), float()) :: matrix3x3()
  def matrix(a_a, a_b, a_c, b_a, b_b, b_c, c_a, c_b, c_c) do
    {
      a_a, a_b, a_c,
      b_a, b_b, b_c,
      c_a, c_b, c_c
    }
  end

  @spec matrix(float(), float(),
               float(), float()) :: matrix2x2()
  def matrix(a_a, a_b, b_a, b_b) do
    {
      a_a, a_b,
      b_a, b_b
    }
  end

  @spec canvas(integer(), integer(), color) :: canvas
  def canvas(w, h, color \\ %Rayz.Color{red: 0, green: 0, blue: 0}) do
    %Rayz.Canvas{
      width:  w,
      height: h,
      pixels: List.duplicate(color, w * h)
    }
  end

  @spec color(float(), float(), float()) :: color
  def color(r, g, b), do: %Rayz.Color{red: r, green: g, blue: b}

  @spec tuple(float(), float(), float(), float()) :: rayztuple
  def tuple(x, y, z, w), do: %Rayz.Tuple{x: x, y: y, z: z, w: w}

  @spec point(float(), float(), float()) :: rayztuple
  def point(x, y, z), do: %Rayz.Tuple{x: x, y: y, z: z, w: 1.0}

  @spec vector(float(), float(), float()) :: rayztuple
  def vector(x, y, z), do: %Rayz.Tuple{x: x, y: y, z: z, w: 0.0}
end
