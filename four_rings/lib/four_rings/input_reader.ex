defmodule FourRings.InputReader do
  @moduledoc """
  Dedicated process for reading terminal input so the coordinator
  can keep receiving completion messages concurrently.
  """

  def start(coordinator_pid) do
    spawn(fn -> loop(coordinator_pid) end)
  end

  defp loop(coordinator_pid) do
    line = IO.gets("Enter integer or 'done': ")

    cond do
      is_nil(line) ->
        send(coordinator_pid, {:user_line, "done"})

      true ->
        trimmed = String.trim(line)
        send(coordinator_pid, {:user_line, trimmed})

        if trimmed != "done" do
          loop(coordinator_pid)
        end
    end
  end
end
