defmodule EsotericLanguageProgrammingInElixir.Whitespace.CLI do
  alias EsotericLanguageProgrammingInElixir.Whitespace.Compiler
  alias EsotericLanguageProgrammingInElixir.Whitespace.VM

  def run(src) do
    src |> Compiler.compile |> VM.context |> VM.run
  end
end
