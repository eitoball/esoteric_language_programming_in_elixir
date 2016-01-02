defmodule EsotericLanguageProgrammingInElixir.BrainfCk do
  defmodule Context do
    defstruct src: "", tokens: [], pc: 0, tape: %{}, cur: 0, jumps: {}
  end

  defmodule ProgrammingError do
    defexception message: "programming error"
  end

  def context(src) do
    tokens = src |> String.to_char_list
    jumps = analyze_jumps(tokens, 0, %{}, [])
    %Context{src: src, tokens: tokens, jumps: jumps}
  end

  def run(context = %Context{tokens: tokens, pc: pc}) when length(tokens) <= pc do
    context
  end

  def run(context = %Context{tokens: tokens, pc: pc, tape: tape, cur: cur}) do
    token = Enum.at(tokens, pc)
    case token do
      ?+ ->
        {_, tape} = Map.get_and_update(tape, cur, fn(v) ->
          if is_nil(v), do: v = 0
          {v, v + 1}
        end)
      ?- ->
        {_, tape} = Map.get_and_update(tape, cur, fn(v) ->
          if is_nil(v), do: v = 0
          {v, v - 1}
        end)
      ?> ->
        cur = cur + 1
      ?< ->
        if cur > 0, do: cur = cur - 1, else: raise ProgrammingError
      ?. ->
        Map.get(tape, cur) |> <<>> |> IO.write
      ?, ->
        n = IO.getn("") |> String.to_char_list |> List.first
        tape = Map.update(tape, cur, n, &(&1))
      ?[ ->
        v = Map.get(tape, cur, 0)
        if v == 0, do: pc = Map.get(context.jumps, pc)
      ?] ->
        v = Map.get(tape, cur, 0)
        if !is_nil(v) && v != 0, do: pc = Map.get(context.jumps, pc)
      _ -> :noop
    end
    run(%Context{context | pc: pc + 1, tape: tape, cur: cur})
  end

  defp analyze_jumps(tokens, pos, jumps, stack) when length(tokens) <= pos do
    jumps
  end

  defp analyze_jumps(tokens, pos, jumps, stack) do
    case Enum.at(tokens, pos) do
    ?[ ->
        stack = [pos|stack]
    ?] ->
        if Enum.empty?(stack), do: raise ProgrammingError, message: "「]」が多すぎます"
        [h|stack] = stack
        jumps = jumps |> Map.update(h, pos, &(&1)) |> Map.update(pos, h, &(&1))
    _ -> :noop
    end
    analyze_jumps(tokens, pos + 1, jumps, stack)
  end
end
