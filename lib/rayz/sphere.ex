defmodule Rayz.Sphere do
  @moduledoc """
  Documentation for Rayz.Sphere
  """

  @doc """
      iex> s = Builder.sphere()
      %Rayz.Sphere{id: 1}
  """

  defstruct(
    id: Integer.to_string(:rand.uniform(4_294_967_296), 32) #,
    #transform: Rayz.Matrix.identity_matrix()
  )
end
