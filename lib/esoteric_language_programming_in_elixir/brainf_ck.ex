defmodule EsotericLanguageProgrammingInElixir.BrainfCk do
  use EsotericLanguageProgrammingInElixir.BrainfCkBase

  defp parse(src) do
    src |> String.to_char_list
  end
end
