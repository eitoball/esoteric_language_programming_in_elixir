defmodule EsotericLanguageProgrammingInElixir.Hq9plus do
  defmodule Context do
    defstruct src: "", tokens: [], count: 0
  end

  def context(src) do
    %Context{src: src, tokens: String.to_char_list(src)}
  end

  def run(context = %Context{tokens: []}) do
    context
  end

  def run(%Context{src: src, tokens: [chr | rest], count: count}) do
    case chr do
    ?H -> IO.puts("Hello, world!")
    ?9 -> print_99_bottles_of_beer
    ?+ -> count = count + 1
    ?Q -> IO.write(src)
    _ -> :noop
    end
    run(%Context{src: src, tokens: rest, count: count})
  end

  defp print_99_bottles_of_beer do
    Enum.each(99..0, fn n ->
      { pre, post } = case n do
      0 -> { "no more bottles", "99 bottles" }
      1 -> { "1 bottle", "no more bottles" }
      2 -> { "2 bottles", "1 bottle" }
      _ -> { "#{n} bottles", "#{n - 1} bottles" }
      end
      action = if n == 0 do
        "Go to the store and buy some more"
      else
        "Take one down and pass it around"
      end
      IO.puts("#{String.capitalize(pre)} of beer on the wall, #{pre} of beer.")
      IO.puts("#{action}, #{post} of beer on the wall.")
      unless n == 0, do: IO.puts("")
    end)
  end
end
