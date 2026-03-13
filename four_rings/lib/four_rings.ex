defmodule FourRings do
  @moduledoc """
  Entry helpers for the Four Rings project.
  """

  def run(n, h) when is_integer(n) and is_integer(h) do
    FourRings.CLI.main([Integer.to_string(n), Integer.to_string(h)])
  end
end
