defmodule OokTest do
  use ExUnit.Case

  import ExUnit.CaptureIO

  alias EsotericLanguageProgrammingInElixir.Ook, as: Ook

  test "print 'A'" do
    src = """
    Ook. Ook. Ook. Ook. Ook. Ook. Ook. Ook. Ook. Ook. Ook. Ook.
    Ook! Ook? Ook. Ook? Ook. Ook. Ook. Ook. Ook. Ook. Ook. Ook.
    Ook. Ook. Ook. Ook. Ook. Ook. Ook. Ook. Ook. Ook. Ook. Ook.
    Ook? Ook. Ook! Ook! Ook? Ook! Ook. Ook? Ook. Ook. Ook. Ook.
    Ook. Ook. Ook. Ook. Ook. Ook. Ook! Ook.
    """
    out = capture_io(fn -> src |> Ook.context |> Ook.run end)
    assert out == "A"
    # Regex.scan(~r/Ook[.?!]/, src)
      # |> List.flatten
      # |> Enum.chunk(2)
      # |> Enum.each(fn(token) ->
           # case token do
           # ["Ook.", "Ook?"] -> ">"
           # ["Ook?", "Ook."] -> "<"
           # ["Ook.", "Ook."] -> "+"
           # ["Ook!", "Ook!"] -> "-"
           # ["Ook.", "Ook!"] -> ","
           # ["Ook!", "Ook."] -> "."
           # ["Ook!", "Ook?"] -> "["
           # ["Ook?", "Ook!"] -> "]"
           # end |> IO.puts
         # end)
  end
end
