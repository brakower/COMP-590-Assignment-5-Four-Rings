defmodule FourRings.CLI do
  @moduledoc """
  CLI entrypoint.
  """

  alias FourRings.BeamMon
  alias FourRings.Coordinator

  def main(args) do
    case parse_args(args) do
      {:ok, n, h} ->
        beam_mon_pid = BeamMon.start()
        _coordinator_pid = Coordinator.start(n, h, self())

        receive do
          :coordinator_done ->
            send(beam_mon_pid, :stop)
            IO.puts("Program exited successfully.")
        end

      :error ->
        IO.puts("Usage: mix run -e 'FourRings.CLI.main([\"N\",\"H\"])'")
        IO.puts("Both N and H must be integers >= 1.")
    end
  end

  defp parse_args([n_str, h_str]) do
    with {n, ""} <- Integer.parse(n_str),
         {h, ""} <- Integer.parse(h_str),
         true <- n >= 1,
         true <- h >= 1 do
      {:ok, n, h}
    else
      _ -> :error
    end
  end

  defp parse_args(_), do: :error
end
