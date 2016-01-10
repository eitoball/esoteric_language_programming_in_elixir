defmodule EsotericLanguageProgrammingInElixir.Whitespace.CompilerTest do
  use ExUnit.Case

  alias EsotericLanguageProgrammingInElixir.Whitespace.Compiler, as: Compiler

  test 'push 0' do
    assert "    \n" |> instructions_for == [{:push, 0}]
  end

  test 'push 5' do
    assert "   \t \t\n" |> instructions_for == [{:push, 5}]
  end

  test 'push -12' do
    assert "  \t\t\t  \n" |> instructions_for == [{:push, -12}]
  end

  test 'push 0; push 1' do
    assert "    \n   \t\n" |> instructions_for == [{:push, 0}, {:push, 1}]
  end

  test 'dup' do
    assert " \n " |> instructions_for == [{:dup}]
  end

  test 'copy 1' do
    assert " \t  \t\n" |> instructions_for == [{:copy, 1}]
  end

  test 'swap' do
    assert " \n\t" |> instructions_for == [{:swap}]
  end

  test 'discard' do
    assert " \n\n" |> instructions_for == [{:discard}]
  end

  test 'slide 1' do
    assert " \t\n \t\n" |> instructions_for == [{:slide, 1}]
  end

  test 'add' do
    assert "\t   " |> instructions_for == [{:add}]
  end

  test 'sub' do
    assert "\t  \t" |> instructions_for == [{:sub}]
  end

  test 'mul' do
    assert "\t  \n" |> instructions_for == [{:mul}]
  end

  test 'div' do
    assert "\t \t " |> instructions_for == [{:div}]
  end

  test 'mod' do
    assert "\t \t\t" |> instructions_for == [{:mod}]
  end

  test 'heap_write' do
    assert "\t\t " |> instructions_for == [{:heap_write}]
  end

  test 'heap_read' do
    assert "\t\t\t" |> instructions_for == [{:heap_read}]
  end

  test 'label " "' do
    assert "\n   \n" |> instructions_for == [{:label, " "}]
  end

  test 'call " "' do
    assert "\n \t \n" |> instructions_for == [{:call, " "}]
  end

  test 'jump " "' do
    assert "\n \n \n" |> instructions_for == [{:jump, " "}]
  end

  test 'jump_zero " "' do
    assert "\n\t  \n" |> instructions_for == [{:jump_zero, " "}]
  end

  test 'jump_nega " "' do
    assert "\n\t\t \n" |> instructions_for == [{:jump_nega, " "}]
  end

  test 'return' do
    assert "\n\t\n" |> instructions_for == [{:return}]
  end

  test 'exit' do
    assert "\n\n\n" |> instructions_for == [{:exit}]
  end

  test 'char_out' do
    assert "\t\n  " |> instructions_for == [{:char_out}]
  end

  test 'num_out' do
    assert "\t\n \t" |> instructions_for == [{:num_out}]
  end

  test 'char_in' do
    assert "\t\n\t " |> instructions_for == [{:char_in}]
  end

  test 'num_in' do
    assert "\t\n\t\t" |> instructions_for == [{:num_in}]
  end

  test 'push 1, num_out, exit' do
    assert "   \t\n\t\n \t\n\n\n" |> instructions_for == [{:push, 1}, {:num_out}, {:exit}]
  end

  def instructions_for(src) do
    src |> Compiler.compile
  end
end
