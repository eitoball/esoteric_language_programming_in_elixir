defmodule EsotericLanguageProgrammingInElixir.Whitespace.Compiler do
  def compile(src) do
    do_compile(src, [])
  end

  def do_compile(src, instructions) when src == "" do
    instructions
  end

  def do_compile(src, instructions) do
    cond do
      Regex.match?(~r/\A  [ \t]+\n/ms, src) ->
        [_, _, num, src] = Regex.run(~r/\A(  )([ \t]+\n)(.*)/ms, src)
        instructions = instructions ++ [{:push, parse_number(num)}]
      Regex.match?(~r/\A \n /ms, src) ->
        [_, _, src] = Regex.run(~r/\A( \n )(.*)/ms, src)
        instructions = instructions ++ [{:dup}]
      Regex.match?(~r/\A \t [ \t]+\n/ms, src) ->
        [_, _, num, src] = Regex.run(~r/\A( \t )([ \t]+\n)(.*)/ms, src)
        instructions = instructions ++ [{:copy, parse_number(num)}]
      Regex.match?(~r/\A \n\t/ms, src) ->
        [_, _, src] = Regex.run(~r/\A( \n\t)(.*)/ms, src)
        instructions = instructions ++ [{:swap}]
      Regex.match?(~r/\A \n\n/ms, src) ->
        [_, _, src] = Regex.run(~r/\A( \n\n)(.*)/ms, src)
        instructions = instructions ++ [{:discard}]
      Regex.match?(~r/\A \t\n[ \t]+\n/ms, src) ->
        [_, _, num, src] = Regex.run(~r/\A( \t\n)([ \t]+\n)(.*)/ms, src)
        instructions = instructions ++ [{:slide, parse_number(num)}]
      Regex.match?(~r/\A\t   /ms, src) ->
        [_, _, src] = Regex.run(~r/\A(\t   )(.*)/ms, src)
        instructions = instructions ++ [{:add}]
      Regex.match?(~r/\A\t  \t/ms, src) ->
        [_, _, src] = Regex.run(~r/\A(\t  \t)(.*)/ms, src)
        instructions = instructions ++ [{:sub}]
      Regex.match?(~r/\A\t  \n/ms, src) ->
        [_, _, src] = Regex.run(~r/\A(\t  \n)(.*)/ms, src)
        instructions = instructions ++ [{:mul}]
      Regex.match?(~r/\A\t \t /ms, src) ->
        [_, _, src] = Regex.run(~r/\A(\t \t )(.*)/ms, src)
        instructions = instructions ++ [{:div}]
      Regex.match?(~r/\A\t \t\t/ms, src) ->
        [_, _, src] = Regex.run(~r/\A(\t \t\t)(.*)/ms, src)
        instructions = instructions ++ [{:mod}]
      Regex.match?(~r/\A\t\t /ms, src) ->
        [_, _, src] = Regex.run(~r/\A(\t\t )(.*)/ms, src)
        instructions = instructions ++ [{:heap_write}]
      Regex.match?(~r/\A\t\t\t/ms, src) ->
        [_, _, src] = Regex.run(~r/\A(\t\t\t)(.*)/ms, src)
        instructions = instructions ++ [{:heap_read}]
      Regex.match?(~r/\A\n  [ \t]+\n/ms, src) ->
        [_, _, label, src] = Regex.run(~r/\A(\n  )([ \t]+)\n(.*)/ms, src)
        instructions = instructions ++ [{:label, label}]
      Regex.match?(~r/\A\n \t[ \t]+\n/ms, src) ->
        [_, _, label, src] = Regex.run(~r/\A(\n \t)([ \t]+)\n(.*)/ms, src)
        instructions = instructions ++ [{:call, label}]
      Regex.match?(~r/\A\n \n[ \t]+\n/ms, src) ->
        [_, _, label, src] = Regex.run(~r/\A(\n \n)([ \t]+)\n(.*)/ms, src)
        instructions = instructions ++ [{:jump, label}]
      Regex.match?(~r/\A\n\t [ \t]+\n/ms, src) ->
        [_, _, label, src] = Regex.run(~r/\A(\n\t )([ \t]+)\n(.*)/ms, src)
        instructions = instructions ++ [{:jump_zero, label}]
      Regex.match?(~r/\A\n\t\t[ \t]+\n/ms, src) ->
        [_, _, label, src] = Regex.run(~r/\A(\n\t\t)([ \t]+)\n(.*)/ms, src)
        instructions = instructions ++ [{:jump_nega, label}]
      Regex.match?(~r/\A\n\t\n/ms, src) ->
        [_, _, src] = Regex.run(~r/\A(\n\t\n)(.*)/ms, src)
        instructions = instructions ++ [{:return}]
      Regex.match?(~r/\A\n\n\n/ms, src) ->
        [_, _, src] = Regex.run(~r/\A(\n\n\n)(.*)/ms, src)
        instructions = instructions ++ [{:exit}]
      Regex.match?(~r/\A\t\n  /ms, src) ->
        [_, _, src] = Regex.run(~r/\A(\t\n  )(.*)/ms, src)
        instructions = instructions ++ [{:char_out}]
      Regex.match?(~r/\A\t\n \t/ms, src) ->
        [_, _, src] = Regex.run(~r/\A(\t\n \t)(.*)/ms, src)
        instructions = instructions ++ [{:num_out}]
      Regex.match?(~r/\A\t\n\t /ms, src) ->
        [_, _, src] = Regex.run(~r/\A(\t\n\t )(.*)/ms, src)
        instructions = instructions ++ [{:char_in}]
      Regex.match?(~r/\A\t\n\t\t/ms, src) ->
        [_, _, src] = Regex.run(~r/\A(\t\n\t\t)(.*)/ms, src)
        instructions = instructions ++ [{:num_in}]
      true ->
        raise inspect(src)
    end
   do_compile(src, instructions)
  end

  def parse_number(str) do
    [_, sign, number] = Regex.run(~r/([ \t])([ \t]+)\n/, str)
    sign = if sign == " ", do: "+", else: "-"
    number = number |> String.replace(" ", "0") |> String.replace("\t", "1")
    "#{sign}#{number}" |> String.to_integer(2)
  end
end
