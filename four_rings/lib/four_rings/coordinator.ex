defmodule FourRings.Coordinator do
  @moduledoc """
  Main coordinator process.

  Responsibilities:
  - start 4 ring managers
  - receive user input from InputReader
  - route integers to the correct ring
  - assign token IDs
  - print completion messages
  - coordinate clean shutdown after "done"
  """

  alias FourRings.InputReader
  alias FourRings.RingManager
  alias FourRings.Token

  def start(n, h, parent_pid) do
    spawn(fn -> init(n, h, parent_pid) end)
  end

  def route(x) when x < 0, do: :neg
  def route(0), do: :zero
  def route(x) when x > 0 and rem(x, 2) == 0, do: :pos_even
  def route(_x), do: :pos_odd

  defp init(n, h, parent_pid) do
    managers = %{
      neg: RingManager.start(:neg, n, h, self()),
      zero: RingManager.start(:zero, n, h, self()),
      pos_even: RingManager.start(:pos_even, n, h, self()),
      pos_odd: RingManager.start(:pos_odd, n, h, self())
    }

    InputReader.start(self())

    state = %{
      parent_pid: parent_pid,
      managers: managers,
      next_token_id: 1,
      done_received: false,
      closed_rings: MapSet.new(),
      h: h
    }

    loop(state)
  end

  defp loop(state) do
    receive do
      {:user_line, line} ->
        loop(handle_user_line(state, line))

      {:ring_complete, token} ->
        latency_ms =
          System.convert_time_unit(
            System.monotonic_time() - token.started_at,
            :native,
            :millisecond
          )

        IO.puts(
          "[COMPLETE] token=#{token.token_id} ring=#{token.ring_id} " <>
            "input=#{token.orig_input} final=#{token.current_val} " <>
            "latency_ms=#{latency_ms}"
        )

        loop(state)

      {:ring_shutdown, ring_id} ->
        IO.puts("[RING CLOSED] #{ring_id}")

        new_closed = MapSet.put(state.closed_rings, ring_id)
        new_state = %{state | closed_rings: new_closed}

        if MapSet.size(new_closed) == 4 do
          IO.puts("All rings finished. Clean shutdown complete.")
          send(state.parent_pid, :coordinator_done)
        else
          loop(new_state)
        end
    end
  end

  defp handle_user_line(%{done_received: true} = state, _line), do: state

  defp handle_user_line(state, "done") do
    IO.puts("No longer accepting input. Waiting for queued and active work to finish...")

    Enum.each(state.managers, fn {_ring_id, pid} ->
      send(pid, :close_when_done)
    end)

    %{state | done_received: true}
  end

  defp handle_user_line(state, line) do
    case Integer.parse(line) do
      {x, ""} ->
        ring_id = route(x)

        token = %Token{
          token_id: state.next_token_id,
          ring_id: ring_id,
          orig_input: x,
          current_val: x,
          remaining_hops: state.h,
          started_at: System.monotonic_time()
        }

        manager_pid = Map.fetch!(state.managers, ring_id)
        send(manager_pid, {:submit, token})

        %{state | next_token_id: state.next_token_id + 1}

      _ ->
        IO.puts("Invalid input. Please enter an integer or 'done'.")
        state
    end
  end
end
