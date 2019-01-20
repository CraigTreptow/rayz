defmodule Rayz.Sphere do
  @moduledoc """
  Provides a Sphere
  """

  defstruct(
    id: Integer.to_string(:rand.uniform(4_294_967_296), 32),
    transform: Rayz.Matrix4x4.identity()
  )

  def set_transform(sphere, transform) do
    %Rayz.Sphere{
      id: sphere.id,
      transform: transform
    }
  end

  def new_sphere(transform) do
    %Rayz.Sphere{
      id: Integer.to_string(:rand.uniform(4_294_967_296), 32),
      transform: transform
    }
  end

  def new_sphere() do
    %Rayz.Sphere{
      id: Integer.to_string(:rand.uniform(4_294_967_296), 32)
    }
  end
end
