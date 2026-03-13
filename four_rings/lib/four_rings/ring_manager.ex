defmodule FourRings.RingManager do
  @moduledoc """
  Manages one ring:
  - exactly N nodes
  - one active token at a time
  - FIFO queue for waiting work
  """

  alias FourRings.RingNode

  def start(ring_id, n, h, coordinator_pid) do
    spawn(fn -> init(ring_id, n, h, coordinator_pid) end)
  end

  defp init(ring_id, n, h, coordinator_pid) do
    nodes =
      Enum.map(1..n, fn _ ->
        RingNode.start(ring_id, self())
      end)

    connect_ring(nodes)

    state = %{
      ring_id: ring_id,
      h: h,
      coordinator_pid: coordinator_pid,
      first_pid: hd(nodes),
      nodes: nodes,
      busy: false,
      queue: :queue.new(),
      closing: false
    }

    loop(state)
  end

  defp connect_ring(nodes) do
    next_nodes = tl(nodes) ++ [hd(nodes)]

    Enum.zip(nodes, next_nodes)
    |> Enum.each(fn {node_pid, next_pid} ->
      send(node_pid, {:set_next, next_pid})
    end)
  end

  defp loop(state) do
    receive do
      {:submit, token} ->
        handle_submit(state, token)

      {:token_complete, token} ->
        handle_completion(state, token)

      :close_when_done ->
        handle_close_when_done(state)
    end
  end

  defp handle_submit(%{busy: false, first_pid: first_pid} = state, token) do
    send(first_pid, {:token, token})
    loop(%{state | busy: true})
  end

  defp handle_submit(%{busy: true, queue: queue} = state, token) do
    new_queue = :queue.in(token, queue)
    loop(%{state | queue: new_queue})
  end

  defp handle_completion(state, token) do
    send(state.coordinator_pid, {:ring_complete, token})

    case :queue.out(state.queue) do
      {{:value, next_token}, new_queue} ->
        send(state.first_pid, {:token, next_token})
        loop(%{state | queue: new_queue, busy: true})

      {:empty, _empty_queue} ->
        next_state = %{state | busy: false, queue: :queue.new()}

        if next_state.closing do
          shutdown_ring(next_state)
        else
          loop(next_state)
        end
    end
  end

  defp handle_close_when_done(state) do
    cond do
      state.busy ->
        loop(%{state | closing: true})

      not :queue.is_empty(state.queue) ->
        loop(%{state | closing: true})

      true ->
        shutdown_ring(%{state | closing: true})
    end
  end

  defp shutdown_ring(state) do
    Enum.each(state.nodes, fn pid ->
      send(pid, :stop)
    end)

    send(state.coordinator_pid, {:ring_shutdown, state.ring_id})
  end
end
