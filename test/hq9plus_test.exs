defmodule Hq9plusTest do
  use ExUnit.Case

  import ExUnit.CaptureIO

  alias EsotericLanguageProgrammingInElixir.Hq9plus, as: Hq9plus

  test "\"H\" should output \"Hello, world!\"" do
    context = Hq9plus.context("H")
    out = capture_io(fn -> Hq9plus.run(context) end)
    assert out == "Hello, world!\n"
  end

  test "\"HH\" should output \"Hello, world!\" twice" do
    context = Hq9plus.context("HH")
    out = capture_io(fn -> Hq9plus.run(context) end)
    assert out == "Hello, world!\nHello, world!\n"
  end

  test "\"H H\" should output \"Hello, world!\" twice" do
    context = Hq9plus.context("H H")
    out = capture_io(fn -> Hq9plus.run(context) end)
    assert out == "Hello, world!\nHello, world!\n"
  end

  test "\"9\" should output whole sentence of '99 bottles of beer'" do
    context = Hq9plus.context("9")
    out = capture_io(fn -> Hq9plus.run(context) end)
    assert Regex.match?(~r/^99 bottles of beer on the wall, 99 bottles of beer\.$/m, out)
    assert Regex.match?(~r/^Go to the store and buy some more, 99 bottles of beer on the wall\.$/m, out)
  end

  test "\"9\n9\" should output whole sentence of '99 bottles of beer' twice" do
    context = Hq9plus.context("9\n9")
    out = capture_io(fn -> Hq9plus.run(context) end)
    assert length(Regex.scan(~r/^99 bottles of beer on the wall, 99 bottles of beer\.$/m, out)) == 2
    assert length(Regex.scan(~r/^Go to the store and buy some more, 99 bottles of beer on the wall\.$/m, out)) == 2
  end

  test "\"+\" increments counter to 1" do
    context = Hq9plus.context("+")
    out = capture_io(fn ->
      r = Hq9plus.run(context)
      assert r.count == 1
    end)
    assert out == ""
  end

  test "\"++++++++++\" increments counter to 10" do
    context = Hq9plus.context("++++++++++")
    out = capture_io(fn ->
      context = Hq9plus.run(context)
      assert context.count == 10
    end)
    assert out == ""
  end

  test "\"Q\" should print own source code" do
    context = Hq9plus.context("Q\n")
    out = capture_io(fn -> Hq9plus.run(context) end)
    assert out == "Q\n"
  end

  test "\"QQ\" should print own source code twice" do
    context = Hq9plus.context("QQ\n")
    out = capture_io(fn -> Hq9plus.run(context) end)
    assert out == "QQ\nQQ\n"
  end

  test "\"H\nQ\n\"" do
    context = Hq9plus.context("H\nQ\n")
    out = capture_io(fn -> Hq9plus.run(context) end)
    assert out == "Hello, world!\nH\nQ\n"
  end
end
