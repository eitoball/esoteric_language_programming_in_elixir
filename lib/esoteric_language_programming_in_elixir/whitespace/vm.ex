defmodule EsotericLanguageProgrammingInElixir.Whitespace.VM do
  defmodule Context do
    defstruct instructions: [], stack: [], heap: %{}, labels: nil, return_to: [], pos: 0
  end

  defmodule ProgrammingError do
    defexception [:message]
  end

  def context(instructions) do
    %Context{instructions: instructions} |> find_labels
  end

  def run(context = %Context{instructions: instructions, pos: pos}) when pos <= length(instructions) do
    new_context = nil
    case Enum.at(instructions, pos) do
      {:push, item} ->
        new_context = context |> push(item)
      {:dup} ->
        case context.stack do
          [] -> raise ProgrammingError, message: "スタックが空ですが、:dupしようとしました"
          [item | _] -> new_context = context |> push(item)
        end
      {:copy, at} ->
        new_context = context |> push(Enum.at(context.stack, at))
      {:swap} ->
        {new_context, [item1, item2]} = popn(context, 2)
        new_context = new_context |> push(item1) |> push(item2)
      {:discard} ->
        {new_context, _} = context |> pop
      {:slide, until} ->
        {new_context, [item|rest]} = context |> popn(until + 1)
        new_context = new_context |> push(item)
      {:add} ->
        {new_context, [item2, item1]} = context |> popn(2)
        new_context = new_context |> push(item1 + item2)
      {:sub} ->
        {new_context, [item2, item1]} = context |> popn(2)
        new_context = new_context |> push(item1 - item2)
      {:mul} ->
        {new_context, [item2, item1]} = context |> popn(2)
        new_context = new_context |> push(item1 * item2)
      {:div} ->
        {new_context, [item2, item1]} = context |> popn(2)
        new_context = new_context |> push(div(item1, item2))
      {:mod} ->
        {new_context, [item2, item1]} = context |> popn(2)
        new_context = new_context |> push(rem(item1, item2))
      {:heap_write} ->
        {new_context, [value, address]} = context |> popn(2)
        new_context = %Context{new_context | heap: Map.update(new_context.heap, address, value, &(&1))}
      {:heap_read} ->
        {new_context, address} = context |> pop
        case Map.fetch(new_context.heap, address) do
          {:ok, value} -> new_context = new_context |> push(value)
          :error -> raise ProgrammingError, message: "ヒープの未初期化の位置を読み出そうとしました（address = #{address}）"
        end
      {:label, _} ->
        new_context = context # ラベルの位置はすでに調べてあるので、何もしない
      {:jump, label} ->
        new_context = jump_to(context, label)
      {:jump_zero, label} ->
        {new_context, item} = context |> pop
        if item == 0, do: new_context = new_context |> jump_to(label)
      {:jump_nega, label} ->
        {new_context, item} = context |> pop
        if item < 0, do: new_context = new_context |> jump_to(label)
      {:call, label} ->
        new_context = %Context{context | return_to: [context.pos | context.return_to]} |> jump_to(label)
      {:return} ->
        case context.return_to do
          [new_pos | rest] ->
            new_context = %Context{context | pos: new_pos, return_to: rest}
          [] ->
            raise ProgrammingError, "サブルーチンの外からreturnしようとしました"
        end
      {:char_out} ->
        {new_context, item} = context |> pop
        IO.write(<<item>>)
      {:num_out} ->
        {new_context, item} = context |> pop
        IO.write(item |> Integer.to_string)
      {:char_in} ->
        case IO.getn("") do
          :eof -> raise ProgrammingError
          {:error, _reason} -> raise ProgrammingError
          data ->
            value = data |> String.to_char_list |> List.first
            {new_context, address} = context |> pop
            new_context = %Context{new_context | heap: Map.update(new_context.heap, address, value, &(&1))}
        end
      {:num_in} ->
        case IO.gets("") do
          :eof -> raise ProgrammingError
          {:error, _reason} -> raise ProgrammingError
          data ->
            value = data |> String.to_integer
            {new_context, address} = context |> pop
            new_context = %Context{new_context | heap: Map.update(new_context.heap, address, value, &(&1))}
        end
      {:exit} ->
        :noop
      _ ->
        raise ProgrammingError, message: "わかりません。#{inspect Enum.at(instructions, pos)}"
    end
    if new_context, do: run(%Context{new_context | pos: new_context.pos + 1}), else: context
  end

  def run(%Context{}) do
    raise ProgrammingError, message: "プログラムの最後はexit命令を実行してください"
  end

  defp push(context = %Context{stack: stack}, item) when is_integer(item) do
    %Context{context | stack: [item | stack]}
  end

  defp push(%Context{}, item) do
    raise ProgrammingError, "整数以外（#{item}）をプッシュしようとしました"
  end

  defp pop(context = %Context{stack: [item | rest]}) do
    {%Context{context | stack: rest}, item}
  end

  defp pop(%Context{stack: []}) do
    raise ProgrammingError, "空のスタックをポップしようとしました"
  end

  defp popn(context = %Context{}, n), do: popn(context, n, [])

  defp popn(context = %Context{}, 0, items), do: {context, items}

  defp popn(context = %Context{}, n, items) do
    {new_context, item} = pop(context)
    popn(new_context, n - 1, items ++ [item])
  end

  defp jump_to(context = %Context{labels: labels}, label) do
    case Map.fetch(labels, label) do
      {:ok, new_pos} -> %Context{context | pos: new_pos}
      :error -> raise ProgrammingError, message: "ジャンプ先（#{inspect label}）が見つかりません"
    end
  end

  defp find_labels(context = %Context{instructions: instructions}) do
    labels = instructions |> find_labels(0, %{})
    %Context{context | labels: labels}
  end

  defp find_labels([], _pos, labels) do
    labels
  end

  defp find_labels([{:label, name} | rest], pos, labels) do
    find_labels(rest, pos + 1, Map.put_new(labels, name, pos))
  end

  defp find_labels([_ | rest], pos, labels) do
    find_labels(rest, pos + 1, labels)
  end
end
