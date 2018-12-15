defmodule WhiteBreadContext do
  use WhiteBread.Context

  given_ "a ← tuple(4.3, -4.2, 3.1, 1.0)", fn state ->
    a = %Rayz.Tuple{ x: 4.3, y: -4.2, z: 3.1, w: 1.0 }
  end

  #given_ "there are 1 coffees left in the machine", fn state ->
  #{:ok, state |> Dict.put(:coffees, 1)}
  #end
end
