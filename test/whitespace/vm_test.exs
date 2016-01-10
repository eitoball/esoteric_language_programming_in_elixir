defmodule EsotericLanguageProgrammingInElixir.Whitespace.VMTest do
  use ExUnit.Case

  import ExUnit.CaptureIO

  alias EsotericLanguageProgrammingInElixir.Whitespace.VM, as: VM

  test "context without labels" do
    context = VM.context([{:push, 0}, {:push, 1}, {:add}])
    assert context.labels |> Enum.empty?
  end

  test "context with labels" do
    context = VM.context([{:label, " "}, {:push, 0}, {:push, 1}, {:add}])
    refute context.labels |> Enum.empty?
    assert Map.fetch!(context.labels, " ") == 0
  end

  test "run with empty instruction" do
    assert_raise VM.ProgrammingError, fn ->
      VM.context([]) |> VM.run
    end
  end

  test "[{:push, 1}]" do
    context = VM.context([{:push, 1}, {:exit}]) |> VM.run
    assert context.stack == [1]
  end

  test "[{:push, 1}, {:dup}]" do
    context = [{:push, 1}, {:dup}, {:exit}] |> VM.context |> VM.run
    assert context.stack == [1, 1]
  end

  test "[{:dup}]" do
    assert_raise VM.ProgrammingError, fn ->
      [{:dup}, {:exit}] |> VM.context |> VM.run
    end
  end

  test "[{:push, 1}, {:copy, 0}]" do
    context = [{:push, 1}, {:copy, 0}, {:exit}] |> VM.context |> VM.run
    assert context.stack == [1, 1]
  end

  test "[{:push, 1}, {:push, 2}, {:swap}]" do
    context = [{:push, 1}, {:push, 2}, {:swap}, {:exit}] |> VM.context |> VM.run
    assert context.stack == [1, 2]
  end

  test "[{:push, 1}, {:swap}]" do
    assert_raise VM.ProgrammingError, fn ->
      [{:push, 1}, {:swap}, {:exit}] |> VM.context |> VM.run
    end
  end

  test "[{:push, 1}, {:discard}, {:swap}]" do
    context = [{:push, 1}, {:discard}, {:exit}] |> VM.context |> VM.run
    assert context.stack == []
  end

  test "[{:push, 1}, {:push, 2}, {:push, 3}, {:slide, 2}]" do
    context = [{:push, 1}, {:push, 2}, {:push, 3}, {:slide, 2}, {:exit}] |> VM.context |> VM.run
    assert context.stack == [3]
  end

  test "[{:push, 2}, {:push, 3}, {:slide, 2}]" do
    assert_raise VM.ProgrammingError, fn ->
      [{:push, 2}, {:push, 3}, {:slide, 2}, {:exit}] |> VM.context |> VM.run
    end
  end

  test "[{:push, 1}, {:push, 2}, {:add}]" do
    context = [{:push, 1}, {:push, 2}, {:add}, {:exit}] |> VM.context |> VM.run
    assert context.stack == [3]
  end

  test "[{:push, 2}, {:push, 1}, {:sub}]" do
    context = [{:push, 2}, {:push, 1}, {:sub}, {:exit}] |> VM.context |> VM.run
    assert context.stack == [1]
  end

  test "[{:push, 2}, {:push, 3}, {:mul}]" do
    context = [{:push, 2}, {:push, 3}, {:mul}, {:exit}] |> VM.context |> VM.run
    assert context.stack == [6]
  end

  test "[{:push, 8}, {:push, 2}, {:div}]" do
    context = [{:push, 8}, {:push, 2}, {:div}, {:exit}] |> VM.context |> VM.run
    assert context.stack == [4]
  end

  test "[{:push, 8}, {:push, 3}, {:mod}]" do
    context = [{:push, 8}, {:push, 3}, {:mod}, {:exit}] |> VM.context |> VM.run
    assert context.stack == [2]
  end

  test "[{:push, 0}, {:push, 1}, {:heap_write}]" do
    context = [{:push, 0}, {:push, 1}, {:heap_write}, {:exit}] |> VM.context |> VM.run
    assert Map.fetch!(context.heap, 0) == 1
  end

  test "[{:push, 0}, {:push, 1}, {:heap_write}, {:push, 0}, {:heap_read]]" do
    context = [{:push, 0}, {:push, 1}, {:heap_write}, {:push, 0}, {:heap_read}, {:exit}] |> VM.context |> VM.run
    assert context.stack == [1]
  end

  test "[{:push, 0}, {:heap_read]]" do
    assert_raise VM.ProgrammingError, fn ->
      [{:push, 0}, {:heap_read}, {:exit}] |> VM.context |> VM.run
    end
  end

  test "[{:jump, \" \"}, {:label, \" \"}]" do
    context = [{:jump, " "}, {:push, 1}, {:label, " "}, {:exit}] |> VM.context |> VM.run
    assert context.stack == []
  end

  test "[{:jump, \" \"}]" do
    assert_raise VM.ProgrammingError, fn ->
      [{:jump, " "}, {:push, 1}, {:exit}] |> VM.context |> VM.run
    end
  end

  test "[{:push, 0}, {:jump_zero, \" \"}, {:label, \" \"}]" do
    context = [{:push, 0}, {:jump_zero, " "}, {:push, 1}, {:label, " "}, {:exit}] |> VM.context |> VM.run
    assert context.stack == []
  end

  test "[{:push, -1}, {:jump_nega, \" \"}, {:label, \" \"}]" do
    context = [{:push, -1}, {:jump_nega, " "}, {:push, 1}, {:label, " "}, {:exit}] |> VM.context |> VM.run
    assert context.stack == []
  end

  test ~w/[{:push, 1}, {:call, " "}, {:push, 3}, {:exit}, {:label, " "}, {:push, 2}, {:return}]/ do
    context = [{:push, 1}, {:call, " "}, {:push, 3}, {:exit}, {:label, " "}, {:push, 2}, {:return}] |> VM.context |> VM.run
    assert context.stack == [3, 2, 1]
  end

  test "[{:return}]" do
    assert_raise VM.ProgrammingError, fn ->
      [{:return}] |> VM.context |> VM.run
    end
  end

  test "[{:push, 65}, {:char_out}]" do
    out = capture_io fn ->
      context = [{:push, 65}, {:char_out}, {:exit}] |> VM.context |> VM.run
      assert context.stack == []
    end
    assert out == "A"
  end

  test "[{:push, 12345}, {:num_out}]" do
    out = capture_io fn ->
      context = [{:push, 12345}, {:num_out}, {:exit}] |> VM.context |> VM.run
      assert context.stack == []
    end
    assert out == "12345"
  end

  test "[{:push, 0}, {:char_in}]" do
    capture_io("A", fn ->
      context = [{:push, 0}, {:char_in}, {:exit}] |> VM.context |> VM.run
      assert context.heap == %{0 => 65}
    end)
  end

  test "[{:push, 0}, {:num_in}]" do
    capture_io("12345", fn ->
      context = [{:push, 0}, {:num_in}, {:exit}] |> VM.context |> VM.run
      assert context.heap == %{0 => 12345}
    end)
  end
end
