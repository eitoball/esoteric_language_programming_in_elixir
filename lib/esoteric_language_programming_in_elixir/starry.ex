defmodule EsotericLanguageProgrammingInElixir.Starry do
  defmodule Context do
    defstruct instructions: [], stack: [], labels: %{}
  end

  def run(src) do
    src
    |> compile
    |> find_labels
    |> execute
  end

  def compile(src) do
    %Context{} |> compile(src, 0)
  end

  def compile(context = %Context{}, "", _) do
    context
  end

  def compile(context = %Context{}, " " <> rest, spaces) do
    compile(context, rest, spaces + 1)
  end

  def compile(%Context{instructions: insts}, "+" <> rest, spaces) when spaces == 1 do
    compile(%Context{instructions: insts ++ [:dup]}, rest, 0)
  end

  def compile(%Context{instructions: insts}, "+" <> rest, spaces) when spaces == 2 do
    compile(%Context{instructions: insts ++ [:swap]}, rest, 0)
  end

  def compile(%Context{instructions: insts}, "+" <> rest, spaces) when spaces == 3 do
    compile(%Context{instructions: insts ++ [:rotate]}, rest, 0)
  end

  def compile(%Context{instructions: insts}, "+" <> rest, spaces) when spaces == 4 do
    compile(%Context{instructions: insts ++ [:pop]}, rest, 0)
  end

  def compile(%Context{instructions: insts}, "+" <> rest, spaces) when spaces >= 5 do
    compile(%Context{instructions: insts ++ [{:push, spaces - 5}]}, rest, 0)
  end

  def compile(%Context{instructions: insts}, "*" <> rest, spaces) when rem(spaces, 5) == 0 do
    compile(%Context{instructions: insts ++ [:+]}, rest, 0)
  end

  def compile(%Context{instructions: insts}, "*" <> rest, spaces) when rem(spaces, 5) == 1 do
    compile(%Context{instructions: insts ++ [:-]}, rest, 0)
  end

  def compile(%Context{instructions: insts}, "*" <> rest, spaces) when rem(spaces, 5) == 2 do
    compile(%Context{instructions: insts ++ [:*]}, rest, 0)
  end

  def compile(%Context{instructions: insts}, "*" <> rest, spaces) when rem(spaces, 5) == 3 do
    compile(%Context{instructions: insts ++ [:/]}, rest, 0)
  end

  def compile(%Context{instructions: insts}, "*" <> rest, spaces) when rem(spaces, 5) == 4 do
    compile(%Context{instructions: insts ++ [:%]}, rest, 0)
  end

  def compile(%Context{instructions: insts}, "." <> rest, spaces) when rem(spaces, 2) == 0 do
    compile(%Context{instructions: insts ++ [:num_out]}, rest, 0)
  end

  def compile(%Context{instructions: insts}, "." <> rest, spaces) when rem(spaces, 2) == 1 do
    compile(%Context{instructions: insts ++ [:char_out]}, rest, 0)
  end

  def compile(%Context{instructions: insts}, "," <> rest, spaces) when rem(spaces, 2) == 0 do
    compile(%Context{instructions: insts ++ [:num_in]}, rest, 0)
  end

  def compile(%Context{instructions: insts}, "." <> rest, spaces) when rem(spaces, 2) == 1 do
    compile(%Context{instructions: insts ++ [:char_in]}, rest, 0)
  end

  def compile(%Context{instructions: insts}, "`" <> rest, spaces) do
    compile(%Context{instructions: insts ++ [{:label, spaces}]}, rest, 0)
  end

  def compile(%Context{instructions: insts}, "'" <> rest, spaces) do
    compile(%Context{instructions: insts ++ [{:jump, spaces}]}, rest, 0)
  end

  def compile(context, <<_>> <> rest, spaces) do
    compile(context, rest, spaces)
  end

  def find_labels(context = %Context{instructions: instructions}) do
    find_labels(context, instructions, 0)
  end

  def find_labels(context = %Context{}, [], _) do
    context
  end

  def find_labels(context = %Context{labels: labels}, [{:label, label} | rest], pos) do
    if Map.has_key?(labels, label), do: raise "Programming Error"
    labels = Map.put_new(labels, label, pos)
    find_labels(%Context{context | labels: labels}, rest, pos + 1)
  end

  def find_labels(context = %Context{}, [_ | rest], pos) do
    find_labels(context, rest, pos + 1)
  end

  def execute(context = %Context{}) do
    execute(context, 0)
  end

  def execute(context = %Context{instructions: insts}, pc) when length(insts) <= pc do
    context
  end

  def execute(context = %Context{instructions: insts, stack: stack, labels: labels}, pc) when length(insts) > pc do
    case Enum.at(insts, pc) do
      {:push, num} ->
        if !is_integer(num), do: raise "Programming Error"
        context = %Context{context | stack: [num | stack]}
      :dup ->
        [num | _] = stack
        context = %Context{context | stack: [num | stack]}
      :swap ->
        [y, x | rest] = stack
        context = %Context{context | stack: [x, y | rest]}
      :rotate ->
        [z, y, x | rest] = stack
        context = %Context{context | stack: [y, x, z | rest]}
      :pop ->
        if Enum.empty?(stack), do: raise "Programming Error"
        [_ | rest] = stack
        context = %Context{context | stack: rest}
      :+ ->
        [y, x | rest] = stack
        context = %Context{context | stack: [x + y | rest]}
      :- ->
        [y, x | rest] = stack
        context = %Context{context | stack: [x - y | rest]}
      :* ->
        [y, x | rest] = stack
        context = %Context{context | stack: [x * y | rest]}
      :/ ->
        [y, x | rest] = stack
        context = %Context{context | stack: [div(x, y) | rest]}
      :% ->
        [y, x | rest] = stack
        context = %Context{context | stack: [rem(x, y) | rest]}
      :num_out ->
        [x | rest] = stack
        IO.write(Integer.to_string(x))
        context = %Context{context | stack: rest}
      :char_out ->
        [x | rest] = stack
        IO.write(<<x>>)
        context = %Context{context | stack: rest}
      :num_in ->
        case IO.gets("") do
          :eof ->
            raise "ProgrammingError"
          {:error, _} ->
            raise "ProgrammingError"
          ch ->
            x = ch |> String.rstrip |> String.to_integer
            context = %Context{context | stack: [x | stack]}
        end
      :char_in ->
        case IO.getn("") do
          :eof ->
            raise "ProgrammingError"
          {:error, _} ->
            raise "ProgrammingError"
          ch ->
            x = ch |> String.to_char_list |> List.first
            context = %Context{context | stack: [x | stack]}
        end
      {:label, _} ->
        :noop
      {:jump, label} ->
        [x | rest] = stack
        if x != 0 do
          pc = Map.get(labels, label)
          if is_nil(pc), do: raise "ProgrammingError"
        end
        context = %Context{context | stack: rest}
      _ ->
        raise "[BUG] Unknown instruction"
    end
    execute(context, pc + 1)
  end
end
