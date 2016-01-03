defmodule EsotericLanguageProgrammingInElixir.Ook do
  use EsotericLanguageProgrammingInElixir.BrainfCkBase

  defp parse(src) do
    Regex.scan(~r/Ook[.?!]/, src)
      |> List.flatten
      |> Enum.chunk(2)
      |> Enum.map(fn(token) ->
           case token do
           ["Ook.", "Ook?"] -> ?>
           ["Ook?", "Ook."] -> ?<
           ["Ook.", "Ook."] -> ?+
           ["Ook!", "Ook!"] -> ?-
           ["Ook.", "Ook!"] -> ?,
           ["Ook!", "Ook."] -> ?.
           ["Ook!", "Ook?"] -> ?[
           ["Ook?", "Ook!"] -> ?]
           end
         end)
  end
end
