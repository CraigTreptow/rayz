defmodule Rayz.Util do
  #https://stackoverflow.com/questions/46867908/insert-at-every-nth-index-of-a-list
  def insert_at_every(list, every, fun) do
    list
    |> Enum.with_index
    |> Enum.flat_map(fn {x, i} ->
      if rem(i, every) == every - 1 do
        [x, fun.()]
      else
        [x]
      end
    end)
  end
end
