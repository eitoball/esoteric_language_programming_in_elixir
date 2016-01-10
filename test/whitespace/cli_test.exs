defmodule Whitespace.CLITest do
  use ExUnit.Case, async: true

  import ExUnit.CaptureIO

  alias EsotericLanguageProgrammingInElixir.Whitespace.CLI

  test "print Hi" do
    out = capture_io fn ->
      CLI.run("   \t  \t   \n\t\n     \t\t \t  \t\n\t\n     \t \t \n\t\n  \n\n\n")
    end
    assert out == "Hi\n"
  end

  test "print something infitely" do
    pid = Process.spawn fn ->
      CLI.run("\n   \n   \t  \t   \n\t\n     \t\t \t  \t\n\t\n     \t \t \n\t\n  \n \n \n\n\n\n")
    end, []
    :timer.kill_after(pid, 5_000)
  end
end
