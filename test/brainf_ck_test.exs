defmodule Brainf_CkTest do
  use ExUnit.Case

  import ExUnit.CaptureIO

  alias EsotericLanguageProgrammingInElixir.BrainfCk, as: Brainf_ck

  test "+" do
    context = "+" |> Brainf_ck.context |> Brainf_ck.run
    assert context.tape[0] == 1
  end

  test "-" do
    context = "-" |> Brainf_ck.context |> Brainf_ck.run
    assert context.tape[0] == -1
  end

  test "'>'" do
    context = ">" |> Brainf_ck.context |> Brainf_ck.run
    assert context.cur == 1
  end

  test "'<' when cur is 0" do
    assert_raise Brainf_ck.ProgrammingError, fn ->
      "<" |> Brainf_ck.context |> Brainf_ck.run
    end
  end

  test "'<' when cur is 1" do
    context = Brainf_ck.context("<")
      |> struct(cur: 1)
      |> Brainf_ck.run
    assert context.cur == 0
  end

  test "'.'" do
    out = capture_io fn ->
      context = Brainf_ck.context(".")
        |> struct(tape: %{0 => 65})
        |> Brainf_ck.run
    end
    assert out == "A"
  end

  test "','" do
    capture_io "A", fn ->
      context = Brainf_ck.context(",") |> Brainf_ck.run
      assert Map.get(context.tape, 0) == ?A
    end
  end

  test "'[+++[---]---]+++'" do
    context = Brainf_ck.context("[+++[---]---]+++") |> Brainf_ck.run
    assert Map.get(context.tape, 0) == 3
  end

  test "']' should raise ProgrammingError" do
    assert_raise Brainf_ck.ProgrammingError, fn ->
      "]" |> Brainf_ck.context |> Brainf_ck.run
    end
  end

  test "print 'A'" do
    context = Brainf_ck.context("""
    ++++++++++ ++++++++++ ++++++++++
    ++++++++++ ++++++++++ ++++++++++
    +++++ .
    """)
    out = capture_io(fn -> Brainf_ck.run(context) end)
    assert out == "A"
  end

  test "print 'A' shorter version" do
    context = Brainf_ck.context("""
    ++++++ [> ++++++++++ < -] > +++++.
    """)
    out = capture_io(fn -> Brainf_ck.run(context) end)
    assert out == "A"
  end
end
