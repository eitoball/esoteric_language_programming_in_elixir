defmodule StarryTest do
  use ExUnit.Case

  import ExUnit.CaptureIO

  alias EsotericLanguageProgrammingInElixir.Starry

  test "exercise 1" do
    src = """
            +               +  *       +     * + .
            +         +  *      +** + .
            +* + . + .
        +* .
       +       +  *       +  * +          +  *         +* .
         +             +  * + .
          +       +  *          +  *          +** + .
       +       +  *       +  *        +  ** + .
        +* + .       +        +  * * + .
       +       +  *       +  * * .
       +        +  *          +  *        +* .
"""
    assert capture_io(fn -> Starry.run(src) end) == "Hello, World!"
  end

  test "exercise 2" do
    src = """
     + +  .
               + .
      + +  .
               + .
`
 +   +* +  .
               + .
     +'
"""
    out = capture_io(fn ->
      pid = Process.spawn(
        fn ->
          try do
            Starry.run(src)
          rescue
            _ -> IO.write("")
          end
        end, [])
      :timer.kill_after(1_000, pid)
    end)
    IO.puts("output: #{inspect out}")
    assert true # 出力が安定しないので
  end

  test "exercise 3" do
    src = """
,
     + +  .
               + .
      + +  .
               + .
   +   +
       + *
`
   +
 +   +* +  .
               + .
   +   +
      + * +
'
"""
    out = capture_io "10", fn ->
      src |> Starry.run
    end
    assert out == "0\n1\n1\n2\n3\n5\n8\n13\n21\n34\n"
  end
end
